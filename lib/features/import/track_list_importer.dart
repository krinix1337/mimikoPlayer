import '../../core/db/database.dart';
import '../../core/sources/cross_source.dart';
import '../../core/sources/source_dto.dart';
import '../../core/sources/source_id.dart';
import '../../sources/yandex/yandex_source.dart';

/// Перенос списка «Исполнитель — Название» из любого сервиса: строки ищутся
/// в Яндексе и складываются в локальный плейлист. Ничего не пишется в
/// аккаунт, поэтому перенос безопасен для чужой подборки.
final class TrackListImporter {
  const TrackListImporter({required this.yandex, required this.db});

  final YandexSource yandex;
  final AppDatabase db;

  Future<TrackListImportResult> import({
    required String title,
    required String text,
    void Function(int done, int total)? onProgress,
  }) async {
    final rows = [
      for (final line in text.split('\n'))
        if (line.trim().isNotEmpty) line.trim(),
    ].take(300).toList();
    if (rows.isEmpty) {
      return const TrackListImportResult(
        matched: 0,
        skipped: 0,
        playlistId: null,
      );
    }

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final playlistId = 'pl_list_$stamp';
    await db.libraryDao.ensurePlaylistShell(
      id: playlistId,
      source: SourceId.local,
      remotePlaylistId: 'list:$stamp',
      title: title.trim().isEmpty ? 'Импорт' : title.trim(),
      kind: 'imported',
      totalTracks: 0,
    );
    await db.libraryDao.clearPlaylistTracks(playlistId);

    var matched = 0;
    var skipped = 0;
    final entries = <({String localTrackId, String sourceId, String remoteId})>[];
    final cache = <String, SourceTrack?>{};
    for (var i = 0; i < rows.length; i++) {
      onProgress?.call(i, rows.length);
      final parts = rows[i].split(RegExp(r'\s+[-–—]\s+|\t+'));
      if (parts.length < 2) {
        skipped++;
        continue;
      }
      final artist = parts.first.trim();
      final trackTitle = parts.sublist(1).join(' - ').trim();
      if (artist.isEmpty || trackTitle.isEmpty) {
        skipped++;
        continue;
      }
      final key = '$artist|$trackTitle'.toLowerCase();
      final cached = cache.containsKey(key);
      var found = cache[key];
      if (!cached) {
        try {
          final result = await yandex.search(
            '$artist $trackTitle',
            pageSize: 10,
          );
          found = pickCrossSourceMatch(
            result.tracks,
            title: trackTitle,
            artists: [artist],
            duration: Duration.zero,
          );
        } on Object {
          found = null;
        }
        cache[key] = found;
      }
      if (found == null) {
        skipped++;
        continue;
      }
      final ingested = await db.tracksDao.ingest(found);
      entries.add((
        localTrackId: ingested.localTrackId,
        sourceId: found.ref.source.wire,
        remoteId: found.ref.remoteId,
      ));
      matched++;
    }
    await db.libraryDao.appendPlaylistTracks(playlistId, entries);
    onProgress?.call(rows.length, rows.length);
    return TrackListImportResult(
      matched: matched,
      skipped: skipped,
      playlistId: playlistId,
    );
  }
}

final class TrackListImportResult {
  const TrackListImportResult({
    required this.matched,
    required this.skipped,
    required this.playlistId,
  });

  final int matched;
  final int skipped;
  final String? playlistId;
}
