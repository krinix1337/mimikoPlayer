import 'package:drift/drift.dart';

import '../../sources/stream_target.dart';
import '../../sources/source_id.dart';
import '../database.dart';

class HistoryDao {
  HistoryDao(this._db);

  final AppDatabase _db;

  /// Пишем локально всегда, даже без сети: история нужна и для вытеснения
  /// офлайна, и для «давно не слушанного».
  Future<void> record({
    required String localTrackId,
    required SourceId source,
    required Quality quality,
    required Duration played,
    required bool completed,
    String? skipReason,
    String? eventJson,
  }) => _db
      .into(_db.history)
      .insert(
        HistoryCompanion.insert(
          localTrackId: localTrackId,
          playedMs: Value(played.inMilliseconds),
          completed: Value(completed),
          source: source.wire,
          quality: Value(quality.wire),
          skipReason: Value(skipReason),
          eventJson: Value(eventJson),
        ),
      );

  Future<DateTime?> lastPlayedAt(String localTrackId) async {
    final row =
        await (_db.select(_db.history)
              ..where((t) => t.localTrackId.equals(localTrackId))
              ..orderBy([(t) => OrderingTerm.desc(t.playedAt)])
              ..limit(1))
            .getSingleOrNull();
    return row?.playedAt;
  }

  Future<List<HistoryData>> recent({int limit = 100}) =>
      (_db.select(_db.history)
            ..orderBy([(t) => OrderingTerm.desc(t.playedAt)])
            ..limit(limit))
          .get();
}
