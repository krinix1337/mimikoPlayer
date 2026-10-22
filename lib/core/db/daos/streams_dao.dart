import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../../sources/source_errors.dart';
import '../../sources/source_id.dart';
import '../../sources/stream_resolver.dart';
import '../../sources/stream_target.dart';
import '../database.dart';

/// Реализация [ResolutionStore] поверх SQLite: переживает смерть процесса,
/// поэтому подписанные ссылки не перевалидируются на каждом старте.
class StreamsDao implements ResolutionStore {
  StreamsDao(this._db);

  final AppDatabase _db;

  @override
  Future<String?> downloadedFilePath(String localTrackId) async {
    final row = await (_db.select(_db.downloadedFiles)
          ..where((t) => t.localTrackId.equals(localTrackId))
          ..where((t) => t.state.equals('complete'))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return await File(row.filePath).exists() ? row.filePath : null;
  }

  Future<void> markDownloading({
    required String localTrackId,
    required SourceId source,
    required String filePath,
    required Quality quality,
  }) => _replaceDownload(
    DownloadedFilesCompanion.insert(
      localTrackId: localTrackId,
      filePath: filePath,
      source: source.wire,
      quality: Value(quality.wire),
      state: const Value('downloading'),
    ),
  );

  Future<void> markDownloaded({
    required String localTrackId,
    required SourceId source,
    required String filePath,
    required Quality quality,
    required int sizeBytes,
    String? codec,
  }) => _replaceDownload(
    DownloadedFilesCompanion.insert(
      localTrackId: localTrackId,
      filePath: filePath,
      source: source.wire,
      quality: Value(quality.wire),
      codec: Value(codec),
      sizeBytes: Value(sizeBytes),
      state: const Value('complete'),
      errorText: const Value(null),
      downloadedAt: Value(DateTime.now()),
    ),
  );

  /// У `downloaded_files` уникален `local_track_id`, а PK — autoincrement.
  /// Обычный `insertOnConflictUpdate` целится в PK и падал на повторной
  /// загрузке с UNIQUE constraint; здесь заменяем строку явно.
  Future<void> _replaceDownload(DownloadedFilesCompanion row) =>
      _db.transaction(() async {
        await (_db.delete(_db.downloadedFiles)
              ..where((t) => t.localTrackId.equals(row.localTrackId.value)))
            .go();
        await _db.into(_db.downloadedFiles).insert(row);
      });

  Future<void> markDownloadFailed(String localTrackId, String error) =>
      (_db.update(_db.downloadedFiles)
            ..where((t) => t.localTrackId.equals(localTrackId)))
          .write(
            DownloadedFilesCompanion(
              state: const Value('failed'),
              errorText: Value(error),
            ),
          );

  Future<void> removeDownload(String localTrackId) =>
      (_db.delete(_db.downloadedFiles)
            ..where((t) => t.localTrackId.equals(localTrackId)))
          .go();

  Future<int> downloadedBytes() async {
    final rows = await _db.select(_db.downloadedFiles).get();
    return rows.fold<int>(0, (sum, row) => sum + row.sizeBytes);
  }

  @override
  Future<ResolvedPlayback?> cached(
    String localTrackId,
    SourceId source,
    Quality quality,
  ) async {
    final row = await (_db.select(_db.streamResolutions)
          ..where((t) => t.localTrackId.equals(localTrackId))
          ..where((t) => t.source.equals(source.wire))
          ..where((t) => t.quality.equals(quality.wire))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;

    final target = row.targetKind == 'file'
        ? StreamFile(row.filePath ?? '')
        : StreamUrl(
            url: Uri.parse(row.url),
            headers: _decodeHeaders(row.headersJson),
            expiresAt: row.expiresAt,
            cacheKey: row.localTrackId,
          );

    return ResolvedPlayback(
      localTrackId: row.localTrackId,
      usedSource: SourceId.fromWire(row.source),
      quality: Quality.fromWire(row.quality),
      target: target,
      expiresAt: row.expiresAt,
      fromCache: true,
    );
  }

  @override
  Future<void> put(ResolvedPlayback playback) {
    final target = playback.target;
    return _db.into(_db.streamResolutions).insertOnConflictUpdate(
      StreamResolutionsCompanion.insert(
        localTrackId: playback.localTrackId,
        source: playback.usedSource.wire,
        quality: playback.quality.wire,
        url: target is StreamUrl ? target.url.toString() : '',
        headersJson: Value(
          jsonEncode(target is StreamUrl ? target.headers : const {}),
        ),
        targetKind: Value(target is StreamFile ? 'file' : 'url'),
        filePath: Value(target is StreamFile ? target.path : null),
        expiresAt: playback.expiresAt,
      ),
    );
  }

  @override
  Future<void> invalidate(String localTrackId, SourceId source) =>
      (_db.delete(_db.streamResolutions)
            ..where(
              (t) =>
                  t.localTrackId.equals(localTrackId) &
                  t.source.equals(source.wire),
            ))
          .go();

  @override
  Future<SourceFailReason?> activeFailure(
    String localTrackId,
    SourceId source,
  ) async {
    final row = await (_db.select(_db.trackFailures)
          ..where((t) => t.localTrackId.equals(localTrackId))
          ..where((t) => t.source.equals(source.wire))
          ..where((t) => t.expiresAt.isBiggerThanValue(DateTime.now()))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return SourceFailReason.values.firstWhere(
      (e) => e.name == row.reason,
      orElse: () => SourceFailReason.remoteError,
    );
  }

  @override
  Future<void> noteFailure(String localTrackId, SourceFailure failure) async {
    final ttl = failure.negativeCacheTtl;
    if (ttl == Duration.zero) {
      // Причину вроде signatureRejected кэшировать нельзя: после починки ключа
      // трек должен сразу снова пробоваться.
      await (_db.delete(_db.trackFailures)
            ..where(
              (t) =>
                  t.localTrackId.equals(localTrackId) &
                  t.source.equals(failure.source.wire),
            ))
          .go();
      return;
    }
    final now = DateTime.now();
    await _db.into(_db.trackFailures).insertOnConflictUpdate(
      TrackFailuresCompanion.insert(
        localTrackId: localTrackId,
        source: failure.source.wire,
        reason: failure.reason.name,
        httpStatus: Value(failure.httpStatus),
        note: Value(failure.message),
        firstFailedAt: Value(now),
        lastFailedAt: Value(now),
        expiresAt: now.add(ttl),
      ),
    );
  }

  static Map<String, String> _decodeHeaders(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map) {
        return {
          for (final e in decoded.entries) '${e.key}': '${e.value}',
        };
      }
    } on FormatException {
      // Побитый JSON = нет заголовков, а не падение плеера.
    }
    return const {};
  }
}
