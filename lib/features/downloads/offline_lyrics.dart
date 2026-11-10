import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../app_services.dart';
import '../../core/logging/app_logger.dart';
import '../../core/sources/source_dto.dart';
import '../../core/sources/source_id.dart';
import '../../sources/lyrics/lrclib.dart';
import '../../sources/lyrics/lyrics_service.dart';

/// Текст скачанного трека лежит рядом с аудио: без интернета караоке и
/// слова в плеере должны открываться так же, как с ним.
abstract final class OfflineLyrics {
  static Future<File> _file(String localTrackId) async {
    final support = await getApplicationSupportDirectory();
    return File(
      p.join(support.path, 'downloads', 'lyrics', '$localTrackId.json'),
    );
  }

  static Future<Lyrics?> load(String localTrackId) async {
    try {
      final file = await _file(localTrackId);
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString());
      if (json is! Map) return null;
      return Lyrics(
        synced: json['synced'] == true,
        plain: '${json['plain'] ?? ''}',
        lines: [
          for (final line in (json['lines'] as List? ?? const []))
            if (line is Map)
              LyricLine(
                start: Duration(milliseconds: (line['s'] as num).toInt()),
                end: Duration(milliseconds: (line['e'] as num).toInt()),
                text: '${line['t']}',
              ),
        ],
      );
    } on Object catch (error) {
      AppLogger.instance.warn('офлайн-текст не прочитался: $error');
      return null;
    }
  }

  static Future<void> save(String localTrackId, Lyrics lyrics) async {
    if (lyrics.isEmpty) return;
    try {
      final file = await _file(localTrackId);
      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode({
          'synced': lyrics.synced,
          'plain': lyrics.plain,
          'lines': [
            for (final line in lyrics.lines)
              {
                's': line.start.inMilliseconds,
                'e': line.end.inMilliseconds,
                't': line.text,
              },
          ],
        }),
        flush: true,
      );
    } on Object catch (error) {
      AppLogger.instance.warn('офлайн-текст не сохранился: $error');
    }
  }

  static Future<void> delete(String localTrackId) async {
    try {
      final file = await _file(localTrackId);
      if (await file.exists()) await file.delete();
    } on Object {
      // Лишний файл в пару килобайт ничему не мешает.
    }
  }

  /// Скачан ли трек целиком: только тогда текст стоит хранить.
  static Future<bool> isDownloaded(AppServices services, String id) async {
    final row = await services.db.streamsDao.downloadedFile(id);
    return row != null && row.state == 'complete';
  }
}

/// Текст трека из сети: каскад LRCLIB → Musixmatch → NetEase → Яндекс.
Future<Lyrics> fetchTrackLyrics(AppServices services, String trackId) async {
  final db = services.db;
  final track = await db.tracksDao.byId(trackId);
  if (track == null) return const Lyrics(lines: [], synced: false);
  final artists = await db.tracksDao.artistNamesOf(trackId);
  final variants = await db.tracksDao.variantsOf(trackId);
  SourceTrack? yandexVariant;
  for (final variant in variants) {
    if (variant.ref.source == SourceId.yandex) {
      yandexVariant = variant;
      break;
    }
  }
  final yandex = services.yandex;
  Future<Lyrics?> Function()? official;
  if (yandexVariant != null && yandex != null) {
    final remoteId = yandexVariant.ref.remoteId;
    official = () => yandex.lyrics(remoteId);
  }
  return LyricsService.shared.fetch(
    title: track.title,
    artist: artists.isEmpty ? '' : artists.first,
    album: await db.tracksDao.albumTitleOf(trackId),
    duration: Duration(seconds: track.durationSec),
    official: official,
  );
}
