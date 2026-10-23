import 'package:drift/drift.dart';

import '../database.dart';

enum DownloadOrigin { manual, auto }

enum DownloadTaskState {
  queued,
  downloading,
  paused,
  failed,
  skipped,
  excluded,
}

enum DownloadEnqueueResult {
  queued,
  alreadyQueued,
  alreadyDownloaded,
  excluded,
  paused,
}

/// Очередь загрузок поверх `download_tasks`. Одна строка — один трек:
/// успешная загрузка удаляет задачу, а `excluded` остаётся tombstone'ом,
/// чтобы автоочередь не воскрешала вручную удалённый файл.
class DownloadsDao {
  DownloadsDao(this._db);

  final AppDatabase _db;

  static const int manualPriority = 0;
  static const int autoPriority = 100;

  static DownloadTaskState stateOf(DownloadTask task) =>
      DownloadTaskState.values.firstWhere(
        (state) => state.name == task.state,
        orElse: () => DownloadTaskState.queued,
      );

  Future<DownloadTask?> byId(String localTrackId) =>
      (_db.select(_db.downloadTasks)
            ..where((t) => t.localTrackId.equals(localTrackId))
            ..limit(1))
          .getSingleOrNull();

  Future<List<DownloadTask>> all() => _db.select(_db.downloadTasks).get();

  Future<DownloadEnqueueResult> enqueue(
    String localTrackId, {
    required DownloadOrigin origin,
    String? quality,
    int? priority,
    bool retryExcluded = false,
  }) async {
    final complete =
        await (_db.select(_db.downloadedFiles)
              ..where((t) => t.localTrackId.equals(localTrackId))
              ..where((t) => t.state.equals('complete'))
              ..limit(1))
            .getSingleOrNull();
    if (complete != null) return DownloadEnqueueResult.alreadyDownloaded;

    final existing = await byId(localTrackId);
    final resolvedPriority =
        priority ??
        (origin == DownloadOrigin.manual ? manualPriority : autoPriority);
    final now = DateTime.now();

    if (existing == null) {
      await _db
          .into(_db.downloadTasks)
          .insert(
            DownloadTasksCompanion.insert(
              localTrackId: localTrackId,
              state: Value(DownloadTaskState.queued.name),
              origin: Value(origin.name),
              priority: Value(resolvedPriority),
              quality: Value(quality),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      return DownloadEnqueueResult.queued;
    }

    final state = stateOf(existing);
    switch (state) {
      case DownloadTaskState.downloading:
        return DownloadEnqueueResult.alreadyQueued;
      case DownloadTaskState.queued:
        if (origin == DownloadOrigin.manual &&
            existing.priority > resolvedPriority) {
          await _write(
            localTrackId,
            DownloadTasksCompanion(
              priority: Value(resolvedPriority),
              updatedAt: Value(now),
            ),
          );
        }
        return DownloadEnqueueResult.alreadyQueued;
      case DownloadTaskState.paused:
        if (origin != DownloadOrigin.manual) {
          return DownloadEnqueueResult.paused;
        }
        break;
      case DownloadTaskState.excluded:
        if (!retryExcluded) return DownloadEnqueueResult.excluded;
        break;
      case DownloadTaskState.failed:
        final due =
            existing.nextAttemptAt != null &&
            !existing.nextAttemptAt!.isAfter(now);
        if (origin == DownloadOrigin.manual || retryExcluded) break;
        if (origin == DownloadOrigin.auto && due) break;
        return DownloadEnqueueResult.alreadyQueued;
      case DownloadTaskState.skipped:
        if (origin != DownloadOrigin.manual && !retryExcluded) {
          return DownloadEnqueueResult.alreadyQueued;
        }
        break;
    }

    await _write(
      localTrackId,
      DownloadTasksCompanion(
        state: Value(DownloadTaskState.queued.name),
        origin: Value(origin.name),
        priority: Value(resolvedPriority),
        quality: Value(quality),
        attempts: const Value(0),
        receivedBytes: const Value(0),
        totalBytes: const Value(null),
        lastError: const Value(null),
        nextAttemptAt: const Value(null),
        updatedAt: Value(now),
      ),
    );
    return DownloadEnqueueResult.queued;
  }

  /// Ставит пачку в одну транзакцию: импорт лайков не должен делать
  /// тысячу отдельных коммитов.
  Future<int> enqueueAll(
    Iterable<String> localTrackIds, {
    required DownloadOrigin origin,
    String? quality,
  }) async {
    var queued = 0;
    await _db.transaction(() async {
      for (final id in localTrackIds) {
        final result = await enqueue(id, origin: origin, quality: quality);
        if (result == DownloadEnqueueResult.queued) queued++;
      }
    });
    return queued;
  }

  Future<DownloadTask?> nextTask({DownloadOrigin? origin}) =>
      (_db.select(_db.downloadTasks)
            ..where((t) {
              final queued = t.state.equals(DownloadTaskState.queued.name);
              return origin == null
                  ? queued
                  : queued & t.origin.equals(origin.name);
            })
            ..orderBy([
              (t) => OrderingTerm.asc(t.priority),
              (t) => OrderingTerm.asc(t.createdAt),
            ])
            ..limit(1))
          .getSingleOrNull();

  /// Забирает только `queued`: два изолята (UI и WorkManager) не должны
  /// качать один трек параллельно в один `.part`.
  Future<DownloadTask?> claim(String localTrackId) async {
    final current = await byId(localTrackId);
    if (current == null) return null;
    final updated =
        await (_db.update(_db.downloadTasks)..where(
              (t) =>
                  t.localTrackId.equals(localTrackId) &
                  t.state.equals(DownloadTaskState.queued.name),
            ))
            .write(
              DownloadTasksCompanion(
                state: Value(DownloadTaskState.downloading.name),
                attempts: Value(current.attempts + 1),
                lastError: const Value(null),
                nextAttemptAt: const Value(null),
                updatedAt: Value(DateTime.now()),
              ),
            );
    if (updated == 0) return null;
    return byId(localTrackId);
  }

  Future<void> updateProgress(
    String localTrackId, {
    required int receivedBytes,
    int? totalBytes,
  }) => _write(
    localTrackId,
    DownloadTasksCompanion(
      state: Value(DownloadTaskState.downloading.name),
      receivedBytes: Value(receivedBytes),
      totalBytes: Value(totalBytes),
      updatedAt: Value(DateTime.now()),
    ),
    only: const {DownloadTaskState.downloading},
  );

  Future<void> pause(String localTrackId, {String? reason}) => _write(
    localTrackId,
    DownloadTasksCompanion(
      state: Value(DownloadTaskState.paused.name),
      lastError: Value(reason),
      updatedAt: Value(DateTime.now()),
    ),
    only: const {DownloadTaskState.queued, DownloadTaskState.downloading},
  );

  Future<void> resume(String localTrackId) => _write(
    localTrackId,
    DownloadTasksCompanion(
      state: Value(DownloadTaskState.queued.name),
      lastError: const Value(null),
      nextAttemptAt: const Value(null),
      updatedAt: Value(DateTime.now()),
    ),
    only: const {DownloadTaskState.paused, DownloadTaskState.failed},
  );

  Future<void> markFailed(
    String localTrackId, {
    required String error,
    DateTime? nextAttemptAt,
  }) => _write(
    localTrackId,
    DownloadTasksCompanion(
      state: Value(DownloadTaskState.failed.name),
      lastError: Value(error),
      nextAttemptAt: Value(nextAttemptAt),
      updatedAt: Value(DateTime.now()),
    ),
    only: const {DownloadTaskState.downloading},
  );

  Future<void> markSkipped(String localTrackId, String reason) => _write(
    localTrackId,
    DownloadTasksCompanion(
      state: Value(DownloadTaskState.skipped.name),
      lastError: Value(reason),
      nextAttemptAt: const Value(null),
      updatedAt: Value(DateTime.now()),
    ),
  );

  Future<void> exclude(String localTrackId, {String? reason}) => _write(
    localTrackId,
    DownloadTasksCompanion(
      state: Value(DownloadTaskState.excluded.name),
      lastError: Value(reason),
      updatedAt: Value(DateTime.now()),
    ),
  );

  Future<void> remove(String localTrackId) => (_db.delete(
    _db.downloadTasks,
  )..where((t) => t.localTrackId.equals(localTrackId))).go();

  Future<void> clear() => _db.delete(_db.downloadTasks).go();

  /// Выключение автозагрузки снимает только ещё не начатые авто-задачи;
  /// скачанные файлы и excluded-tombstone остаются.
  Future<List<String>> removePendingAutoTasks() async {
    final rows =
        await (_db.select(_db.downloadTasks)..where(
              (t) =>
                  t.origin.equals(DownloadOrigin.auto.name) &
                  t.state.isIn([
                    DownloadTaskState.queued.name,
                    DownloadTaskState.paused.name,
                    DownloadTaskState.failed.name,
                    DownloadTaskState.skipped.name,
                  ]),
            ))
            .get();
    final ids = [for (final row in rows) row.localTrackId];
    if (ids.isNotEmpty) {
      await (_db.delete(
        _db.downloadTasks,
      )..where((t) => t.localTrackId.isIn(ids))).go();
    }
    return ids;
  }

  Future<void> pauseQueued() =>
      (_db.update(
        _db.downloadTasks,
      )..where((t) => t.state.equals(DownloadTaskState.queued.name))).write(
        DownloadTasksCompanion(
          state: Value(DownloadTaskState.paused.name),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Пауза всей очереди, включая строки `downloading`, оставшиеся после
  /// убийства процесса: активного CancelToken для них уже нет.
  /// После смерти процесса задача остаётся в `downloading` навсегда: очередь
  /// её не видит, а статистика показывает вечную загрузку. `.part` на диске
  /// уже есть, поэтому просто возвращаем её в `queued`.
  Future<int> requeueStale() =>
      (_db.update(_db.downloadTasks)
            ..where((t) => t.state.equals(DownloadTaskState.downloading.name)))
          .write(
            DownloadTasksCompanion(
              state: Value(DownloadTaskState.queued.name),
              updatedAt: Value(DateTime.now()),
            ),
          );

  Future<void> pauseAll() =>
      (_db.update(_db.downloadTasks)..where(
            (t) => t.state.isIn([
              DownloadTaskState.queued.name,
              DownloadTaskState.downloading.name,
            ]),
          ))
          .write(
            DownloadTasksCompanion(
              state: Value(DownloadTaskState.paused.name),
              updatedAt: Value(DateTime.now()),
            ),
          );

  Future<void> resumePaused() =>
      (_db.update(
        _db.downloadTasks,
      )..where((t) => t.state.equals(DownloadTaskState.paused.name))).write(
        DownloadTasksCompanion(
          state: Value(DownloadTaskState.queued.name),
          lastError: const Value(null),
          nextAttemptAt: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<DownloadQueueStats> stats() async {
    final count = _db.downloadTasks.localTrackId.count();
    final query = _db.selectOnly(_db.downloadTasks)
      ..addColumns([_db.downloadTasks.state, count])
      ..groupBy([_db.downloadTasks.state]);
    return _statsFrom(await query.get(), count);
  }

  Stream<DownloadQueueStats> watchStats() {
    final count = _db.downloadTasks.localTrackId.count();
    final query = _db.selectOnly(_db.downloadTasks)
      ..addColumns([_db.downloadTasks.state, count])
      ..groupBy([_db.downloadTasks.state]);
    return query.watch().map((rows) => _statsFrom(rows, count));
  }

  Future<DownloadedFilesSummary> completedFilesSummary() async {
    final count = _db.downloadedFiles.id.count();
    final bytes = _db.downloadedFiles.sizeBytes.sum();
    final query = _db.selectOnly(_db.downloadedFiles)
      ..addColumns([count, bytes])
      ..where(_db.downloadedFiles.state.equals('complete'));
    final row = await query.getSingle();
    return DownloadedFilesSummary(
      count: row.read(count) ?? 0,
      bytes: row.read(bytes) ?? 0,
    );
  }

  Stream<DownloadedFilesSummary> watchCompletedFilesSummary() {
    final count = _db.downloadedFiles.id.count();
    final bytes = _db.downloadedFiles.sizeBytes.sum();
    final query = _db.selectOnly(_db.downloadedFiles)
      ..addColumns([count, bytes])
      ..where(_db.downloadedFiles.state.equals('complete'));
    return query.watchSingle().map(
      (row) => DownloadedFilesSummary(
        count: row.read(count) ?? 0,
        bytes: row.read(bytes) ?? 0,
      ),
    );
  }

  Future<void> _write(
    String localTrackId,
    DownloadTasksCompanion values, {
    Set<DownloadTaskState>? only,
  }) {
    final update = _db.update(_db.downloadTasks)
      ..where((t) {
        final byId = t.localTrackId.equals(localTrackId);
        if (only == null) return byId;
        return byId & t.state.isIn([for (final state in only) state.name]);
      });
    return update.write(values);
  }

  DownloadQueueStats _statsFrom(List<TypedResult> rows, Expression<int> count) {
    final values = <DownloadTaskState, int>{
      for (final state in DownloadTaskState.values) state: 0,
    };
    for (final row in rows) {
      final raw = row.read(_db.downloadTasks.state);
      if (raw == null) continue;
      final state = DownloadTaskState.values.firstWhere(
        (value) => value.name == raw,
        orElse: () => DownloadTaskState.queued,
      );
      values[state] = row.read(count) ?? 0;
    }
    return DownloadQueueStats(
      queued: values[DownloadTaskState.queued]!,
      downloading: values[DownloadTaskState.downloading]!,
      paused: values[DownloadTaskState.paused]!,
      failed: values[DownloadTaskState.failed]!,
      skipped: values[DownloadTaskState.skipped]!,
      excluded: values[DownloadTaskState.excluded]!,
    );
  }
}

final class DownloadQueueStats {
  const DownloadQueueStats({
    this.queued = 0,
    this.downloading = 0,
    this.paused = 0,
    this.failed = 0,
    this.skipped = 0,
    this.excluded = 0,
  });

  final int queued;
  final int downloading;
  final int paused;
  final int failed;
  final int skipped;
  final int excluded;

  int get active => queued + downloading;
  int get pending => active + paused + failed;
  bool get isEmpty => active == 0 && paused == 0 && failed == 0 && skipped == 0;
}

final class DownloadedFilesSummary {
  const DownloadedFilesSummary({required this.count, required this.bytes});

  final int count;
  final int bytes;

  bool get isEmpty => count == 0;
}
