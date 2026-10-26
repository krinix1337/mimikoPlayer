import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../app_providers.dart';
import '../../app_services.dart';
import '../../core/db/daos/downloads_dao.dart';
import '../../core/logging/app_logger.dart';
import '../../core/platform/mimiko_platform.dart';
import '../../core/sources/source_errors.dart';
import '../../core/sources/source_id.dart';
import '../../core/sources/stream_resolver.dart';
import '../../core/sources/stream_target.dart';
import 'download_scheduler.dart';

/// Скачивание трека для офлайна: берём уже подписанный резолвером URL,
/// кладём файл в приватный каталог приложения и пишем строку в
/// `downloaded_files`. Плеер потом выбирает файл до всей сетевой цепочки.
class DownloadService {
  DownloadService(this._services);

  final AppServices _services;

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 10),
      followRedirects: true,
      validateStatus: (status) => status == 200 || status == 206,
      headers: const {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/126.0 Mobile Safari/537.36',
      },
    ),
  );

  Future<void> download(
    String localTrackId, {
    void Function(double? progress)? onProgress,
    void Function(int received, int? total)? onBytes,
    CancelToken? cancelToken,
    Quality? quality,
    String origin = 'manual',
    Future<bool> Function(int extraBytes)? fitsInLimit,
    Future<bool> Function()? stillAllowed,
  }) async {
    final existing = await _services.db.streamsDao.downloadedFilePath(
      localTrackId,
    );
    if (existing != null) {
      onProgress?.call(1);
      return;
    }

    final variants = await _services.db.tracksDao.variantsOf(localTrackId);
    if (variants.every((v) => v.ref.source == SourceId.local)) {
      throw const DownloadSkipException('Трек уже лежит в телефоне');
    }

    final dir = await _downloadDir();

    // Одна перевалидация: 401/403 на готовой ссылке означает протухшую подпись,
    // и лечится новым резолвом, а не паузой до следующего запуска.
    for (var attempt = 1; ; attempt++) {
      final result = await _services.resolver.resolve(
        localTrackId: localTrackId,
        variants: variants,
        quality: quality ?? _services.defaultQuality,
        bypassCache: attempt > 1,
      );
      final playback = result.playback;
      if (playback == null) throw _resolveFailure(result);

      final target = playback.target;
      if (target is! StreamUrl) {
        throw const DownloadSkipException('Трек уже лежит в телефоне');
      }
      if (_isHls(null, target.url)) {
        throw const DownloadSkipException(hlsSkipReason);
      }

      try {
        final audio = await fetchResumable(
          url: target.url,
          headers: target.headers,
          dir: dir,
          localTrackId: localTrackId,
          cancelToken: cancelToken,
          onBytes: (received, total) {
            onBytes?.call(received, total);
            onProgress?.call(
              total == null || total == 0 ? null : received / total,
            );
          },
          fitsInLimit: fitsInLimit,
          stillAllowed: stillAllowed,
          onStarted: (codec, total, offset) =>
              _services.db.streamsDao.markDownloading(
                localTrackId: localTrackId,
                source: playback.usedSource,
                filePath: p.join(dir.path, '$localTrackId.$codec'),
                quality: playback.quality,
                origin: origin,
              ),
          onLog: (codec, total, offset) => AppLogger.instance.info(
            'download start $localTrackId '
            '${playback.usedSource.wire} $codec total=$total offset=$offset',
          ),
        );
        final coverPath = await saveCover(localTrackId);
        await _services.db.streamsDao.markDownloaded(
          localTrackId: localTrackId,
          source: playback.usedSource,
          filePath: audio.path,
          quality: playback.quality,
          sizeBytes: audio.bytes,
          codec: audio.codec,
          origin: origin,
          coverPath: coverPath,
        );
        AppLogger.instance.info(
          'download done $localTrackId ${audio.bytes} bytes ${audio.path}',
        );
        onProgress?.call(1);
        return;
      } on DioException catch (error) {
        final code = error.response?.statusCode;
        if ((code == 401 || code == 403) && attempt == 1) {
          await _services.db.streamsDao.invalidate(
            localTrackId,
            playback.usedSource,
          );
          continue;
        }
        if (code == 404) {
          throw const DownloadSkipException('Источник отдал 404');
        }
        await _services.db.streamsDao.markDownloadFailed(
          localTrackId,
          '$error',
        );
        rethrow;
      }
    }
  }

  /// Отказ цепочки источников: снятая публикация, регион или отсутствие
  /// подписки не рассосутся от повторной попытки — такой трек идёт в
  /// «пропущено». Сеть, 5xx и троттлинг остаются на повтор.
  Exception _resolveFailure(ResolveResult result) {
    for (final failure in result.failures) {
      final reason = switch (failure.reason) {
        SourceFailReason.notInCatalog ||
        SourceFailReason.unavailable ||
        SourceFailReason.allSourcesExhausted => 'Недоступно офлайн',
        SourceFailReason.geoBlocked => 'Недоступно в твоём регионе',
        SourceFailReason.needsPlus => 'Нужна подписка источника',
        SourceFailReason.authRequired ||
        SourceFailReason.authExpired => 'Нужен вход в источник',
        SourceFailReason.codecUnsupported => 'Кодек не поддерживается',
        _ => null,
      };
      if (reason != null) return DownloadSkipException(reason);
    }
    return const DownloadException('Ни один источник не отдал поток');
  }

  /// HTTP-механика одной закачки: `.part`, Range, 206/200/416 и обрыв по
  /// отмене. Вынесена из [download], чтобы цикл докачки был покрыт тестом на
  /// локальном сервере — без БД и источников.
  static Future<DownloadedAudio> fetchResumable({
    required Uri url,
    Map<String, String> headers = const {},
    required Directory dir,
    required String localTrackId,
    CancelToken? cancelToken,
    void Function(int received, int? total)? onBytes,
    Future<bool> Function(int extraBytes)? fitsInLimit,
    Future<bool> Function()? stillAllowed,
    Future<void> Function(String codec, int? total, int offset)? onStarted,
    void Function(String codec, int? total, int offset)? onLog,
    Dio? dio,
  }) async {
    final client = dio ?? _dio;
    final temp = File(p.join(dir.path, '$localTrackId.part'));
    var offset = await temp.exists() ? await temp.length() : 0;
    final requestHeaders = {
      ...headers,
      if (offset > 0) 'Range': 'bytes=$offset-',
    };

    final Response<ResponseBody> response;
    try {
      response = await client.get<ResponseBody>(
        '$url',
        cancelToken: cancelToken,
        options: Options(
          headers: requestHeaders,
          responseType: ResponseType.stream,
        ),
      );
    } on DioException catch (error) {
      if (_isCancelled(error)) throw const DownloadPausedException();
      if (error.response?.statusCode == 416) {
        await _delete(temp);
        throw const DownloadException('Частичный файл повреждён, начну заново');
      }
      rethrow;
    }

    final status = response.statusCode ?? 200;
    final mime = response.headers
        .value(Headers.contentTypeHeader)
        ?.split(';')
        .first
        .trim();
    if (_isHls(mime, url)) {
      await _delete(temp);
      throw const DownloadSkipException(hlsSkipReason);
    }

    final codec = _extensionFor(mime, url);
    final total = _totalBytes(response.headers);
    var received = offset;
    var append = offset > 0 && status == 206;

    if (offset > 0 && status == 200) {
      // Источник проигнорировал Range: начинаем файл заново.
      append = false;
      received = 0;
      offset = 0;
      await _delete(temp);
    } else if (status == 206) {
      final start = _rangeStart(response.headers.value('content-range'));
      if (start != null && start != offset) {
        await _delete(temp);
        throw const DownloadException('Источник вернул не тот диапазон');
      }
    }

    // Место резервируем по фактическому размеру ответа: проверка «до резолва»
    // не знает длину трека и пропускала переполнение лимита ровно на один трек.
    if (fitsInLimit != null && total != null) {
      final extra = total - offset;
      if (extra > 0 && !await fitsInLimit(extra)) {
        // `.part` оставляем: место может освободиться, и трек докачается с того
        // же обрыва, а не начнётся заново.
        throw const DownloadLimitException();
      }
    }

    final file = File(p.join(dir.path, '$localTrackId.$codec'));
    await onStarted?.call(codec, total, offset);
    onLog?.call(codec, total, offset);

    var lastEmit = 0;
    var lastGate = DateTime.now().millisecondsSinceEpoch;
    final sink = temp.openWrite(
      mode: append ? FileMode.append : FileMode.write,
    );
    try {
      onBytes?.call(received, total);
      await for (final chunk in response.data!.stream) {
        sink.add(chunk);
        received += chunk.length;
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - lastEmit > 200) {
          lastEmit = now;
          onBytes?.call(received, total);
        }
        if (stillAllowed != null && now - lastGate > 2000) {
          lastGate = now;
          if (!await stillAllowed()) {
            // Сеть сменилась посреди потока: держим `.part` и встаём на паузу.
            throw const DownloadPausedException();
          }
        }
      }
      await sink.flush();
      await sink.close();
    } on DioException catch (error) {
      // Отмена приходит из потока ответа, а не из самого запроса.
      await sink.close();
      if (_isCancelled(error)) throw const DownloadPausedException();
      rethrow;
    } on DownloadPausedException {
      await sink.flush();
      await sink.close();
      rethrow;
    } on Object {
      await sink.close();
      rethrow;
    }

    if (received < 64 * 1024) {
      await _delete(temp);
      throw const DownloadException('Источник вернул не аудио');
    }

    if (await file.exists()) await file.delete();
    await temp.rename(file.path);
    return DownloadedAudio(path: file.path, bytes: received, codec: codec);
  }

  Future<void> remove(String localTrackId) async {
    final row = await (_services.db.select(
      _services.db.downloadedFiles,
    )..where((t) => t.localTrackId.equals(localTrackId))).getSingleOrNull();
    if (row != null) {
      final file = File(row.filePath);
      if (await file.exists()) await file.delete();
      final part = File('${row.filePath}.part');
      if (await part.exists()) await part.delete();
    }
    final dir = await _downloadDir();
    final temp = File(p.join(dir.path, '$localTrackId.part'));
    if (await temp.exists()) await temp.delete();
    final cover = File(p.join(dir.path, 'covers', '$localTrackId.jpg'));
    if (await cover.exists()) await cover.delete();
    await _services.db.streamsDao.removeDownload(localTrackId);
  }

  /// Обложка нужна только для офлайн-списка: ошибка картинки не должна
  /// отменять уже скачанный аудиофайл.
  Future<String?> saveCover(String localTrackId) async {
    try {
      final dir = await _downloadDir();
      final track = await _services.db.tracksDao.byId(localTrackId);
      final url = track?.coverUrl;
      if (url == null || !url.startsWith('http')) return null;
      final covers = Directory(p.join(dir.path, 'covers'));
      if (!await covers.exists()) await covers.create(recursive: true);
      final file = File(p.join(covers.path, '$localTrackId.jpg'));
      if (await file.exists()) return file.path;

      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
        return null;
      }
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } on Object catch (error) {
      AppLogger.instance.warn('обложка не скачалась: $error');
      return null;
    }
  }

  static Future<Directory> _downloadDir() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'downloads'));
    if (await dir.exists() == false) await dir.create(recursive: true);
    return dir;
  }

  static int? _totalBytes(Headers headers) {
    final range = headers.value('content-range');
    if (range != null) {
      final total = range.split('/').last.trim();
      final parsed = int.tryParse(total);
      if (parsed != null && parsed > 0) return parsed;
    }
    final length = int.tryParse(
      headers.value(Headers.contentLengthHeader) ?? '',
    );
    return length != null && length > 0 ? length : null;
  }

  static int? _rangeStart(String? header) {
    if (header == null) return null;
    final match = RegExp(r'bytes\s+(\d+)-').firstMatch(header);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static bool _isHls(String? mime, Uri url) {
    final type = mime?.toLowerCase();
    return url.path.toLowerCase().endsWith('.m3u8') ||
        type == 'application/vnd.apple.mpegurl' ||
        type == 'application/x-mpegurl' ||
        type == 'audio/mpegurl';
  }

  static bool _isCancelled(DioException error) =>
      CancelToken.isCancel(error) || error.type == DioExceptionType.cancel;

  static Future<void> _delete(File file) async {
    if (await file.exists()) await file.delete();
  }

  static String _extensionFor(String? mime, Uri url) {
    final byMime = switch (mime) {
      'audio/mpeg' || 'audio/mp3' => 'mp3',
      'audio/mp4' || 'audio/aac' || 'audio/x-m4a' => 'm4a',
      'audio/webm' => 'webm',
      'audio/ogg' => 'ogg',
      'audio/opus' => 'opus',
      _ => null,
    };
    if (byMime != null) return byMime;

    final ext = p.extension(url.path).toLowerCase().replaceFirst('.', '');
    if (const {'mp3', 'm4a', 'aac', 'webm', 'ogg', 'opus'}.contains(ext)) {
      return ext;
    }
    return 'mp3';
  }
}

final class DownloadException implements Exception {
  const DownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Отмена по кнопке паузы: это не ошибка, `.part` остаётся на диске.
final class DownloadPausedException implements Exception {
  const DownloadPausedException();
}

/// Файл не влезает в лимит загрузок или в оставшееся свободное место.
final class DownloadLimitException implements Exception {
  const DownloadLimitException();
}

/// Трек нельзя скачать в принципе: снят, закрыт регионом, нужен Плюс или
/// это HLS-плейлист. Повторная попытка ничего не изменит.
final class DownloadSkipException implements Exception {
  const DownloadSkipException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Результат одной HTTP-закачки.
final class DownloadedAudio {
  const DownloadedAudio({
    required this.path,
    required this.bytes,
    required this.codec,
  });

  final String path;
  final int bytes;
  final String codec;
}

/// Больше пяти попыток трек не гоняем: он оседает в «пропущено» с причиной.
const int maxDownloadAttempts = 5;

const String hlsSkipReason = 'Потоковый плейлист пока не скачивается';

/// Сколько оставляем свободным на устройстве после загрузки.
const int minFreeDownloadBytes = 2 * 1024 * 1024 * 1024;

/// Причина паузы: её показывает UI очереди, а pumpAutoQueue по ней узнаёт
/// остановку по месту и не крутит дальше всю тысячу лайков.
const String limitPauseReason =
    'Достигнут лимит загрузок или мало свободного места';

enum DownloadPhase { downloading, paused, complete, failed, skipped }

/// Причина отмены автозагрузки, когда пользователь сам нажал «скачать»:
/// задача возвращается в очередь, а не встает «на паузе».
const String preemptReason = 'preempt';

@immutable
final class DownloadStatus {
  const DownloadStatus({required this.phase, this.progress, this.error});

  final DownloadPhase phase;

  /// 0..1; null — размер ответа неизвестен.
  final double? progress;
  final String? error;
}

/// Активные загрузки. Завершённые дополнительно подтверждаются запросом к
/// `downloaded_files`, поэтому после перезапуска статус не теряется.
class DownloadController extends Notifier<Map<String, DownloadStatus>> {
  final Map<String, CancelToken> _active = {};
  final Map<String, DownloadOrigin> _activeOrigin = {};

  /// Id треков, чью автозагрузку вытеснила ручная: им возвращаем очередь.
  final Set<String> _preempted = {};
  final Map<String, DateTime> _lastProgressWrite = {};
  bool _pumpingAuto = false;

  @override
  Map<String, DownloadStatus> build() => const {};

  Future<void> start(
    String localTrackId, {
    DownloadOrigin origin = DownloadOrigin.manual,
    Quality? quality,
    bool checkFreeSpace = true,
  }) async {
    if (state[localTrackId]?.phase == DownloadPhase.downloading) return;
    final dao = _dao;
    final enqueued = await dao.enqueue(
      localTrackId,
      origin: origin,
      quality: quality?.wire,
      retryExcluded: origin == DownloadOrigin.manual,
    );
    if (enqueued == DownloadEnqueueResult.alreadyDownloaded) {
      _set(
        localTrackId,
        const DownloadStatus(phase: DownloadPhase.complete, progress: 1),
      );
      _invalidate(localTrackId);
      return;
    }
    if (enqueued == DownloadEnqueueResult.excluded ||
        enqueued == DownloadEnqueueResult.paused) {
      return;
    }

    if (!await _hasRoomFor(extraBytes: 0, checkFreeSpace: checkFreeSpace)) {
      await dao.pause(localTrackId, reason: limitPauseReason);
      _set(
        localTrackId,
        const DownloadStatus(
          phase: DownloadPhase.paused,
          error: limitPauseReason,
        ),
      );
      _invalidate(localTrackId);
      throw const DownloadException(limitPauseReason);
    }

    if (origin == DownloadOrigin.auto && _active.isNotEmpty) {
      // Одна загрузка за раз: ручная важнее, авто подождёт своей очереди.
      return;
    }
    if (origin == DownloadOrigin.manual) {
      for (final entry in _active.entries.toList()) {
        if (_activeOrigin[entry.key] == DownloadOrigin.auto) {
          _preempted.add(entry.key);
          entry.value.cancel(preemptReason);
        }
      }
    }

    final task = await dao.claim(localTrackId);
    if (task == null) {
      // Либо трек уже забрал другой изолят, либо файл успели докачать.
      final current = await dao.byId(localTrackId);
      if (current == null) {
        final path = await ref
            .read(appServicesProvider)
            .db
            .streamsDao
            .downloadedFilePath(localTrackId);
        if (path != null) {
          _set(
            localTrackId,
            const DownloadStatus(phase: DownloadPhase.complete, progress: 1),
          );
          _invalidate(localTrackId);
        }
      }
      return;
    }

    final token = CancelToken();
    _active[localTrackId] = token;
    _activeOrigin[localTrackId] = origin;
    // Полоска стартует с уже скачанного, а не с нуля: `.part` пережил паузу.
    final stored = task.totalBytes == null || task.totalBytes == 0
        ? 0.0
        : (task.receivedBytes / task.totalBytes!).clamp(0.0, 1.0);
    _set(
      localTrackId,
      DownloadStatus(phase: DownloadPhase.downloading, progress: stored),
    );

    final service = DownloadService(ref.read(appServicesProvider));
    final wifiGated =
        origin == DownloadOrigin.auto &&
        ref.read(prefsProvider).autoDownloadWifiOnly;
    try {
      await service.download(
        localTrackId,
        origin: origin.name,
        quality: quality,
        cancelToken: token,
        fitsInLimit: (extra) =>
            _hasRoomFor(extraBytes: extra, checkFreeSpace: checkFreeSpace),
        stillAllowed: wifiGated ? _autoNetworkAllowed : null,
        onProgress: (progress) {
          if (_active[localTrackId] != token) return;
          _set(
            localTrackId,
            DownloadStatus(
              phase: DownloadPhase.downloading,
              progress: progress,
            ),
          );
        },
        onBytes: (received, total) =>
            _writeProgress(localTrackId, received, total),
      );
      await dao.remove(localTrackId);
      _set(
        localTrackId,
        const DownloadStatus(phase: DownloadPhase.complete, progress: 1),
      );
      _invalidate(localTrackId);
    } on DownloadLimitException {
      await dao.pause(localTrackId, reason: limitPauseReason);
      _set(
        localTrackId,
        const DownloadStatus(
          phase: DownloadPhase.paused,
          error: limitPauseReason,
        ),
      );
      _invalidate(localTrackId);
      throw const DownloadException(limitPauseReason);
    } on DownloadSkipException catch (error) {
      await dao.markSkipped(localTrackId, error.message);
      _set(
        localTrackId,
        DownloadStatus(phase: DownloadPhase.skipped, error: error.message),
      );
      _invalidate(localTrackId);
      rethrow;
    } on DownloadPausedException {
      if (_preempted.remove(localTrackId)) {
        // Вытеснили ручной загрузкой: возвращаем в очередь, а не в «на паузе».
        await dao.pause(localTrackId);
        await dao.resume(localTrackId);
        final next = Map<String, DownloadStatus>.of(state)
          ..remove(localTrackId);
        state = next;
      } else {
        await dao.pause(localTrackId);
        _set(
          localTrackId,
          DownloadStatus(
            phase: DownloadPhase.paused,
            progress: state[localTrackId]?.progress,
          ),
        );
      }
      _invalidate(localTrackId);
    } on Object catch (error) {
      final text = '$error';
      final retry = text.contains('429')
          ? const Duration(minutes: 30)
          : const Duration(minutes: 5);
      await dao.markFailed(
        localTrackId,
        error: text,
        nextAttemptAt: DateTime.now().add(retry),
      );
      final after = await dao.byId(localTrackId);
      final exhausted = (after?.attempts ?? 0) >= maxDownloadAttempts;
      if (exhausted) {
        await dao.markSkipped(
          localTrackId,
          'Не скачался за $maxDownloadAttempts попыток',
        );
      }
      _set(
        localTrackId,
        DownloadStatus(
          phase: exhausted ? DownloadPhase.skipped : DownloadPhase.failed,
          error: text,
        ),
      );
      _invalidate(localTrackId);
      rethrow;
    } finally {
      if (_active[localTrackId] == token) {
        _active.remove(localTrackId);
        _activeOrigin.remove(localTrackId);
      }
      _lastProgressWrite.remove(localTrackId);
      // Освободившийся слот забирает очередь автозагрузки — иначе она ждала бы
      // следующего пинка до перезапуска.
      unawaited(_continueAuto());
    }
  }

  Future<void> _continueAuto() async {
    if (_pumpingAuto || _active.isNotEmpty) return;
    if (!ref.read(prefsProvider).autoDownloadLikes) return;
    try {
      await pumpAutoQueue();
    } on Object {
      // Очередь разберётся на следующем пинке; здесь только фоновый ход.
    }
  }

  /// Пробные 20 или все лайки — в зависимости от подтверждения.
  Future<int> enqueueAutoLikes() async {
    final prefs = ref.read(prefsProvider);
    if (!prefs.autoDownloadLikes) return 0;

    final db = ref.read(appServicesProvider).db;
    final liked = await db.libraryDao.likedTrackIds();
    final selected = prefs.autoDownloadAllApproved
        ? liked
        : liked.take(20).toList();
    final eligible = <String>[];
    for (final id in selected) {
      final variants = await db.tracksDao.variantsOf(id);
      if (variants.any((variant) => variant.ref.source != SourceId.local)) {
        eligible.add(id);
      }
    }
    return _dao.enqueueAll(
      eligible,
      origin: DownloadOrigin.auto,
      quality: Quality.fromWire(prefs.autoDownloadQuality).wire,
    );
  }

  /// Свежий лайк при включённой автозагрузке: одна задача и сразу в очередь,
  /// не дожидаясь следующего запуска. Дедуп делает `enqueue`.
  Future<void> trackLiked(String localTrackId) async {
    final prefs = ref.read(prefsProvider);
    if (!prefs.autoDownloadLikes) return;
    final queued = await _dao.enqueue(
      localTrackId,
      origin: DownloadOrigin.auto,
      quality: Quality.fromWire(prefs.autoDownloadQuality).wire,
    );
    if (queued != DownloadEnqueueResult.queued) return;
    await scheduleAutoDownload(wifiOnly: prefs.autoDownloadWifiOnly);
    unawaited(pumpAutoQueue());
  }

  /// Вызывается после синхронизации лайков и при включении автозагрузки.
  Future<void> kickAutoDownloads() async {
    final prefs = ref.read(prefsProvider);
    if (!prefs.autoDownloadLikes) return;
    await enqueueAutoLikes();
    await scheduleAutoDownload(wifiOnly: prefs.autoDownloadWifiOnly);
    unawaited(pumpAutoQueue());
  }

  /// Старт приложения: подбираем задачи, застрявшие в `downloading` после
  /// смерти процесса, и отдаём их очереди.
  Future<void> recoverQueue() async {
    final restored = await _dao.requeueStale();
    if (restored > 0) {
      AppLogger.instance.info('загрузки: возвращено в очередь $restored');
      _invalidate(null);
    }
    await _continueAuto();
  }

  /// «Скачать всё» для лайков: очередь ручных загрузок. Пользователь нажал
  /// сам, поэтому Wi-Fi не ждём, но лимит места и один трек за раз остаются.
  Future<int> downloadAllLikes() async {
    final liked = await ref
        .read(appServicesProvider)
        .db
        .libraryDao
        .likedTrackIds();
    return downloadAllTracks(liked);
  }

  /// Пакетная ручная загрузка из списка (лайки, плейлист): только треки с
  /// удалённым вариантом, без Wi-Fi-гейта, с тем же лимитом места.
  Future<int> downloadAllTracks(Iterable<String> localTrackIds) async {
    final services = ref.read(appServicesProvider);
    final eligible = <String>[];
    for (final id in localTrackIds) {
      final variants = await services.db.tracksDao.variantsOf(id);
      if (variants.any((variant) => variant.ref.source != SourceId.local)) {
        eligible.add(id);
      }
    }
    final queued = await _dao.enqueueAll(
      eligible,
      origin: DownloadOrigin.manual,
    );
    unawaited(_pump(origin: DownloadOrigin.manual));
    return queued;
  }

  Future<void> pumpAutoQueue({
    bool requireNetworkCheck = true,
    Duration? timeBudget,
  }) => _pump(
    origin: DownloadOrigin.auto,
    requireNetworkCheck: requireNetworkCheck,
    timeBudget: timeBudget,
  );

  /// Последовательный прогон очереди: автозагрузка останавливается на уходе с
  /// Wi-Fi и на лимите, ручная очередь сеть не ждёт.
  Future<void> _pump({
    required DownloadOrigin origin,
    bool requireNetworkCheck = true,
    Duration? timeBudget,
  }) async {
    final auto = origin == DownloadOrigin.auto;
    if (_pumpingAuto) return;
    _pumpingAuto = true;
    var failures = 0;
    final startedAt = DateTime.now();
    try {
      while (true) {
        final prefs = ref.read(prefsProvider);
        if (auto && !prefs.autoDownloadLikes) break;
        if (timeBudget != null &&
            DateTime.now().difference(startedAt) >= timeBudget) {
          break;
        }
        if (auto && requireNetworkCheck && !await _autoNetworkAllowed()) break;
        if (_active.isNotEmpty) break;
        final task = await _dao.nextTask(origin: origin);
        if (task == null) break;
        try {
          await start(
            task.localTrackId,
            origin: origin,
            quality: auto ? Quality.fromWire(prefs.autoDownloadQuality) : null,
            checkFreeSpace: auto ? requireNetworkCheck : true,
          );
          failures = 0;
        } on DownloadException catch (error) {
          if (error.message.contains('лимит') ||
              error.message.contains('429')) {
            break;
          }
          failures++;
        } on DownloadSkipException {
          // Пропуск — не неудача: недоступных офлайн треков в лайках много,
          // из-за них очередь не должна вставать.
        } on Object {
          final after = await _dao.byId(task.localTrackId);
          if (after?.lastError?.contains('429') == true) break;
          failures++;
        }
        // Обрыв сети не должен прокрутить всю тысячу лайков в failed.
        if (failures >= 3) break;
      }
    } finally {
      _pumpingAuto = false;
    }
  }

  Future<bool> _autoNetworkAllowed() async {
    if (!ref.read(prefsProvider).autoDownloadWifiOnly) return true;
    final status = await MimikoPlatform.networkStatus();
    return status.canAutoDownload;
  }

  Future<void> pause(String localTrackId) async {
    final token = _active[localTrackId];
    if (token != null && !token.isCancelled) token.cancel('pause');
    await _dao.pause(localTrackId);
    _set(
      localTrackId,
      DownloadStatus(
        phase: DownloadPhase.paused,
        progress: state[localTrackId]?.progress,
      ),
    );
    _invalidate(localTrackId);
  }

  Future<void> resume(String localTrackId) async {
    await _dao.resume(localTrackId);
    await start(localTrackId);
  }

  Future<void> cancelAutoQueue() async {
    await cancelAutoDownload();
    final removed = await _dao.removePendingAutoTasks();
    if (removed.isEmpty) return;
    final next = Map<String, DownloadStatus>.of(state)
      ..removeWhere((id, _) => removed.contains(id));
    state = next;
    _invalidate(null);
  }

  Future<void> pauseAll() async {
    for (final id in _active.keys.toList()) {
      await pause(id);
    }
    await _dao.pauseAll();
    final tasks = await _dao.all();
    for (final task in tasks) {
      if (task.state == DownloadTaskState.paused.name) {
        _set(
          task.localTrackId,
          DownloadStatus(
            phase: DownloadPhase.paused,
            progress: state[task.localTrackId]?.progress,
          ),
        );
      }
    }
  }

  Future<void> resumeAll() async {
    await _dao.resumePaused();
    final tasks = await _dao.all();
    for (final task in tasks) {
      if (task.state != DownloadTaskState.queued.name) continue;
      final current = await _dao.byId(task.localTrackId);
      if (current?.state != DownloadTaskState.queued.name) continue;
      try {
        await start(task.localTrackId);
      } on Object {
        // Ошибка одного трека не должна останавливать остальную очередь.
      }
    }
  }

  Future<void> remove(String localTrackId) async {
    final token = _active.remove(localTrackId);
    _activeOrigin.remove(localTrackId);
    token?.cancel('remove');
    await DownloadService(ref.read(appServicesProvider)).remove(localTrackId);
    await _dao.remove(localTrackId);
    final next = Map<String, DownloadStatus>.of(state)..remove(localTrackId);
    state = next;
    _invalidate(localTrackId);
  }

  Future<void> removeAll() async {
    for (final token in _active.values) {
      token.cancel('remove');
    }
    _active.clear();
    _activeOrigin.clear();
    final service = DownloadService(ref.read(appServicesProvider));
    final rows = await ref
        .read(appServicesProvider)
        .db
        .select(ref.read(appServicesProvider).db.downloadedFiles)
        .get();
    for (final row in rows) {
      await service.remove(row.localTrackId);
    }
    await _dao.clear();
    state = const {};
    _invalidate(null);
  }

  /// Лимит считается по завершённым файлам плюс размер следующего: так очередь
  /// не переполняется ровно на один трек. Свободное место проверяем живьём,
  /// потому что оно меняется после каждой загрузки.
  Future<bool> _hasRoomFor({
    required int extraBytes,
    required bool checkFreeSpace,
  }) async {
    final limit = ref.read(prefsProvider).downloadLimitBytes;
    if (limit != null) {
      final summary = await _dao.completedFilesSummary();
      if (summary.bytes + extraBytes > limit) return false;
    }
    if (!checkFreeSpace) return true;
    final free = await MimikoPlatform.freeBytes();
    return free == 0 || free - extraBytes >= minFreeDownloadBytes;
  }

  /// Подтягивает обложки у треков, скачанных до появления локальных картинок:
  /// без них «Скачанное» офлайн показывает заглушки.
  Future<int> backfillCovers({int limit = 200}) async {
    final services = ref.read(appServicesProvider);
    final service = DownloadService(services);
    final rows = await services.db.streamsDao.completeWithoutCover(
      limit: limit,
    );
    if (rows.isEmpty) return 0;
    AppLogger.instance.info('бэкфилл обложек: пробуем ${rows.length} треков');
    var saved = 0;
    for (final row in rows) {
      final path = await service.saveCover(row.localTrackId);
      if (path == null) continue;
      await services.db.streamsDao.setCoverPath(row.localTrackId, path);
      saved++;
    }
    AppLogger.instance.info('бэкфилл обложек: сохранено $saved');
    if (saved > 0) _invalidate(null);
    return saved;
  }

  void _writeProgress(String id, int received, int? total) {
    final now = DateTime.now();
    final last = _lastProgressWrite[id];
    if (last != null && now.difference(last) < const Duration(seconds: 1)) {
      return;
    }
    _lastProgressWrite[id] = now;
    unawaited(
      _dao.updateProgress(id, receivedBytes: received, totalBytes: total),
    );
  }

  void _invalidate(String? id) {
    if (id != null) {
      ref.invalidate(isDownloadedProvider(id));
    } else {
      ref.invalidate(isDownloadedProvider);
    }
    ref.invalidate(collectionProvider);
    ref.invalidate(downloadQueueStatsProvider);
    ref.invalidate(downloadedFilesSummaryProvider);
  }

  void _set(String id, DownloadStatus status) {
    state = {...state, id: status};
  }

  DownloadsDao get _dao => ref.read(appServicesProvider).db.downloadsDao;
}

final downloadControllerProvider =
    NotifierProvider<DownloadController, Map<String, DownloadStatus>>(
      DownloadController.new,
    );

final downloadStatusProvider = Provider.autoDispose
    .family<DownloadStatus?, String>(
      (ref, id) =>
          ref.watch(downloadControllerProvider.select((all) => all[id])),
    );

final isDownloadedProvider = FutureProvider.autoDispose.family<bool, String>((
  ref,
  id,
) async {
  final path = await ref
      .watch(appServicesProvider)
      .db
      .streamsDao
      .downloadedFilePath(id);
  return path != null;
});
