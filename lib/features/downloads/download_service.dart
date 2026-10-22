import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../app_providers.dart';
import '../../app_services.dart';
import '../../core/logging/app_logger.dart';
import '../../core/sources/source_id.dart';
import '../../core/sources/stream_target.dart';

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
  }) async {
    final existing = await _services.db.streamsDao.downloadedFilePath(
      localTrackId,
    );
    if (existing != null) return;

    final variants = await _services.db.tracksDao.variantsOf(localTrackId);
    if (variants.every((v) => v.ref.source == SourceId.local)) {
      throw const DownloadException('Трек уже хранится локально');
    }

    final result = await _services.resolver.resolve(
      localTrackId: localTrackId,
      variants: variants,
      quality: _services.defaultQuality,
    );
    final playback = result.playback;
    if (playback == null) {
      throw const DownloadException('Ни один источник не отдал поток');
    }

    final target = playback.target;
    if (target is! StreamUrl) {
      throw const DownloadException('Трек уже хранится локально');
    }
    final url = target.url;
    if (url.path.endsWith('.m3u8')) {
      throw const DownloadException('Потоковый плейлист пока не скачивается');
    }

    final dir = await _downloadDir();
    final response = await _dio.get<ResponseBody>(
      '$url',
      options: Options(
        headers: {...target.headers, 'Range': 'bytes=0-'},
        responseType: ResponseType.stream,
      ),
    );
    final total = _totalBytes(response.headers);
    final mime = response.headers
        .value(Headers.contentTypeHeader)
        ?.split(';')
        .first
        .trim();
    final ext = _extensionFor(mime, url);
    AppLogger.instance.info(
      'download start $localTrackId '
      '${playback.usedSource.wire} $ext total=$total',
    );
    final file = File(p.join(dir.path, '$localTrackId.$ext'));
    final temp = File('${file.path}.part');
    if (await temp.exists()) await temp.delete();

    await _services.db.streamsDao.markDownloading(
      localTrackId: localTrackId,
      source: playback.usedSource,
      filePath: file.path,
      quality: playback.quality,
    );

    var received = 0;
    var lastEmit = 0;
    final sink = temp.openWrite();
    try {
      await for (final chunk in response.data!.stream) {
        sink.add(chunk);
        received += chunk.length;
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - lastEmit > 200) {
          lastEmit = now;
          onProgress?.call(total == null || total == 0 ? null : received / total);
        }
      }
      await sink.flush();
      await sink.close();
    } on Object catch (error) {
      await sink.close();
      if (await temp.exists()) await temp.delete();
      await _services.db.streamsDao.markDownloadFailed(
        localTrackId,
        '$error',
      );
      rethrow;
    }

    if (received < 64 * 1024) {
      if (await temp.exists()) await temp.delete();
      await _services.db.streamsDao.markDownloadFailed(
        localTrackId,
        'Ответ слишком короткий для аудио',
      );
      throw const DownloadException('Источник вернул не аудио');
    }

    if (await file.exists()) await file.delete();
    await temp.rename(file.path);
    await _services.db.streamsDao.markDownloaded(
      localTrackId: localTrackId,
      source: playback.usedSource,
      filePath: file.path,
      quality: playback.quality,
      sizeBytes: received,
      codec: ext,
    );
    AppLogger.instance.info(
      'download done $localTrackId $received bytes ${file.path}',
    );
    onProgress?.call(1);
  }

  Future<void> remove(String localTrackId) async {
    final row = await (_services.db.select(
      _services.db.downloadedFiles,
    )..where((t) => t.localTrackId.equals(localTrackId)))
        .getSingleOrNull();
    if (row != null) {
      final file = File(row.filePath);
      if (await file.exists()) await file.delete();
      final part = File('${row.filePath}.part');
      if (await part.exists()) await part.delete();
    }
    await _services.db.streamsDao.removeDownload(localTrackId);
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
    final length = int.tryParse(headers.value(Headers.contentLengthHeader) ?? '');
    return length != null && length > 0 ? length : null;
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

enum DownloadPhase { downloading, complete, failed }

@immutable
final class DownloadStatus {
  const DownloadStatus({
    required this.phase,
    this.progress,
    this.error,
  });

  final DownloadPhase phase;

  /// 0..1; null — размер ответа неизвестен.
  final double? progress;
  final String? error;
}

/// Активные загрузки. Завершённые дополнительно подтверждаются запросом к
/// `downloaded_files`, поэтому после перезапуска статус не теряется.
class DownloadController extends Notifier<Map<String, DownloadStatus>> {
  @override
  Map<String, DownloadStatus> build() => const {};

  Future<void> start(String localTrackId) async {
    if (state[localTrackId]?.phase == DownloadPhase.downloading) return;
    _set(
      localTrackId,
      const DownloadStatus(phase: DownloadPhase.downloading, progress: 0),
    );
    final service = DownloadService(ref.read(appServicesProvider));
    try {
      await service.download(
        localTrackId,
        onProgress: (progress) => _set(
          localTrackId,
          DownloadStatus(
            phase: DownloadPhase.downloading,
            progress: progress,
          ),
        ),
      );
      _set(
        localTrackId,
        const DownloadStatus(phase: DownloadPhase.complete, progress: 1),
      );
      ref.invalidate(isDownloadedProvider(localTrackId));
      ref.invalidate(collectionProvider);
    } on Object catch (error) {
      _set(
        localTrackId,
        DownloadStatus(phase: DownloadPhase.failed, error: '$error'),
      );
      ref.invalidate(isDownloadedProvider(localTrackId));
      rethrow;
    }
  }

  Future<void> remove(String localTrackId) async {
    await DownloadService(ref.read(appServicesProvider)).remove(localTrackId);
    final next = Map<String, DownloadStatus>.of(state)..remove(localTrackId);
    state = next;
    ref.invalidate(isDownloadedProvider(localTrackId));
    ref.invalidate(collectionProvider);
  }

  void _set(String id, DownloadStatus status) {
    state = {...state, id: status};
  }
}

final downloadControllerProvider =
    NotifierProvider<DownloadController, Map<String, DownloadStatus>>(
      DownloadController.new,
    );

final downloadStatusProvider = Provider.family<DownloadStatus?, String>(
  (ref, id) => ref.watch(downloadControllerProvider.select((all) => all[id])),
);

final isDownloadedProvider = FutureProvider.family<bool, String>((ref, id) async {
  final path = await ref
      .watch(appServicesProvider)
      .db
      .streamsDao
      .downloadedFilePath(id);
  return path != null;
});
