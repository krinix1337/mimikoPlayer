import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/platform/mimiko_platform.dart';
import '../../core/sources/music_source.dart';
import '../../core/sources/source_dto.dart';
import '../../core/sources/source_errors.dart';
import '../../core/sources/source_id.dart';
import '../../core/sources/stream_target.dart';

/// Локальные файлы в app-private каталоге `Android/data/<id>/files/Music`.
/// Сюда же на этапе «офлайн» ложатся скачанные треки, поэтому источник
/// работает по тем же правилам, что и сетевые.
class LocalSource implements MusicSource {
  static const Set<String> _audioExtensions = {
    '.mp3',
    '.m4a',
    '.aac',
    '.flac',
    '.ogg',
    '.opus',
    '.wav',
  };

  @override
  SourceId get id => SourceId.local;

  @override
  SourceCapabilities get capabilities => const SourceCapabilities(
    canSearch: true,
    canStream: true,
    canBrowse: true,
  );

  @override
  AuthState get auth => const AuthAnonymous();

  @override
  Stream<AuthState> get authChanges => const Stream<AuthState>.empty();

  @override
  Future<void> warmUp() async {}

  @override
  Future<SearchResult> search(
    String query, {
    int page = 0,
    int pageSize = 50,
  }) async {
    final tracks = await _scan();
    final needle = query.trim().toLowerCase();
    final matched = needle.isEmpty
        ? tracks
        : tracks
              .where(
                (t) =>
                    t.title.toLowerCase().contains(needle) ||
                    t.artists.any((a) => a.toLowerCase().contains(needle)),
              )
              .toList();
    return SearchResult(
      tracks: matched.skip(page * pageSize).take(pageSize).toList(),
      page: page,
      total: matched.length,
      hasMore: matched.length > (page + 1) * pageSize,
    );
  }

  @override
  Future<SourceTrack?> getTrack(RemoteTrackRef ref) async =>
      (await _scan()).where((t) => t.ref.remoteId == ref.remoteId).firstOrNull;

  @override
  Future<List<SourceTrack>> getTracksByIds(List<RemoteTrackRef> refs) async {
    final wanted = refs.map((r) => r.remoteId).toSet();
    return (await _scan())
        .where((t) => wanted.contains(t.ref.remoteId))
        .toList();
  }

  @override
  Future<PlaylistSnapshot?> getPlaylist(String remotePlaylistId) async => null;

  @override
  Future<StreamResult> resolveStream(
    SourceTrack track, {
    Quality preferred = Quality.auto,
  }) async {
    final path = track.ref.remoteId;
    if (await File(path).exists() == false) {
      return StreamFailed(
        SourceFailure(
          source: id,
          reason: SourceFailReason.localFileMissing,
          message: 'файл не найден: $path',
        ),
      );
    }
    return StreamReady(
      target: StreamFile(path),
      source: id,
      quality: Quality.auto,
      codec: p.extension(path).replaceFirst('.', ''),
      // Файл не истекает: резолвер всегда должен брать его из кэша.
      ttlHint: const Duration(days: 3650),
    );
  }

  @override
  Future<void> reportPlaybackEvent(
    SourceTrack track,
    PlaybackEventType type,
    Duration played,
  ) async {}

  @override
  Future<void> dispose() async {}

  Future<List<SourceTrack>> _scan() async {
    final dir = await musicDirectory();
    if (await dir.exists() == false) return const [];

    final tracks = <SourceTrack>[];
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final extension = p.extension(entity.path).toLowerCase();
      if (!_audioExtensions.contains(extension)) continue;

      final info = await _infoFor(entity.path);
      tracks.add(
        SourceTrack(
          // remoteId локального трека — это его путь: он и есть идентификатор.
          ref: RemoteTrackRef(id, entity.path),
          title: _pickTitle(info.title, entity.path),
          artists: info.artist == null || info.artist!.isEmpty
              ? const []
              : [info.artist!],
          album: info.album,
          duration: Duration(milliseconds: info.durationMs),
          coverUrl: await _coverFor(entity.path, info.art),
          // Без декодирования длительность неизвестна, если в файле нет тега;
          // отпечаток строится по нулю, матчинг с каталогами — на этапе офлайна.
          raw: {'sizeBytes': await entity.length()},
        ),
      );
    }
    tracks.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return tracks;
  }

  static final Map<String, LocalMediaInfo> _infoCache = {};

  /// Тег читаем один раз на файл за запуск приложения: обход папки
  /// повторяется при каждом открытии вкладки «Файлы».
  static Future<LocalMediaInfo> _infoFor(String path) async {
    if (_infoCache[path] case final cached?) return cached;
    final info = await MimikoPlatform.mediaInfo(path);
    _infoCache[path] = info;
    return info;
  }

  static String _pickTitle(String? fromTag, String path) {
    final tag = fromTag?.trim() ?? '';
    // У некоторых файлов TITLE совпадает с именем файла — берём тег, когда
    // он непустой и отличается от basename.
    if (tag.isEmpty || tag == p.basenameWithoutExtension(path)) {
      return p.basenameWithoutExtension(path);
    }
    return tag;
  }

  /// Обложку из тега пишем рядом с приложением и отдаём file-ссылку:
  /// тащить base64 через БД на каждый трек — лишний трафик для SQLite.
  static Future<String?> _coverFor(String path, Uint8List? art) async {
    if (art == null || art.isEmpty) return null;
    try {
      final support = await getApplicationSupportDirectory();
      final dir = Directory(p.join(support.path, 'art'));
      if (await dir.exists() == false) await dir.create(recursive: true);
      final file = File(p.join(dir.path, '${_stableKey(path)}.jpg'));
      if (await file.exists() == false) await file.writeAsBytes(art);
      return Uri.file(file.path).toString();
    } on FileSystemException {
      return null;
    }
  }

  static String _stableKey(String path) => base64Url
      .encode(utf8.encode(path))
      .replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
}

/// Каталог, куда ложатся локальные и скачанные файлы.
Future<Directory> musicDirectory() async {
  final external = await getExternalStorageDirectory();
  // getExternalStorageDirectory возвращает null только на устройствах без
  // внешнего хранилища — тогда работаем во внутреннем.
  final root = external ?? await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(root.path, 'Music'));
  if (await dir.exists() == false) await dir.create(recursive: true);
  return dir;
}
