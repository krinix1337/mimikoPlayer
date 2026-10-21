import 'dart:convert';

import 'package:drift/drift.dart';

import '../database.dart';

/// Очередь живёт в БД, потому что Android 17 даёт while-in-use только
/// сервису, запущенному из foreground или по явному действию пользователя:
/// после media-кнопки на мёртвом процессе Dart-состояния нет, и восстанавливать
/// очередь приходится отсюда.
class QueueDao {
  QueueDao(this._db);

  final AppDatabase _db;

  static const String kindPlayer = 'player';
  static const String kindRadio = 'radio';

  /// Один снимок на kind: PK здесь автоинкрементный, а уникальность держит
  /// индекс по `kind`, поэтому upsert делаем явным delete+insert.
  Future<void> save({
    required String kind,
    required List<String> localTrackIds,
    required int index,
    required Duration position,
    required String repeatMode,
    required bool shuffleEnabled,
    Map<String, Object?>? sourceHint,
  }) => _db.transaction(() async {
    await (_db.delete(_db.queueSnapshots)
          ..where((t) => t.kind.equals(kind)))
        .go();
    await _db.into(_db.queueSnapshots).insert(
      QueueSnapshotsCompanion.insert(
        kind: kind,
        itemsJson: jsonEncode(localTrackIds),
        queueIndex: Value(index),
        positionMs: Value(position.inMilliseconds),
        repeatMode: Value(repeatMode),
        shuffleEnabled: Value(shuffleEnabled),
        sourceHintJson: sourceHint == null
            ? const Value.absent()
            : Value(jsonEncode(sourceHint)),
        savedAt: Value(DateTime.now()),
      ),
    );
  });

  Future<QueueSnapshot?> load(String kind) => (_db.select(_db.queueSnapshots)
        ..where((t) => t.kind.equals(kind))
        ..limit(1))
      .getSingleOrNull();

  static List<String> itemsOf(QueueSnapshot snapshot) =>
      (jsonDecode(snapshot.itemsJson) as List).map((e) => '$e').toList();

  static Map<String, Object?>? hintOf(QueueSnapshot snapshot) {
    final raw = snapshot.sourceHintJson;
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map ? decoded.cast<String, Object?>() : null;
  }
}
