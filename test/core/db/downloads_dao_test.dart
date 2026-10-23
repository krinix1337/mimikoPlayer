import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/db/daos/downloads_dao.dart';
import 'package:phoneyandex/core/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    for (final id in ['t_1', 't_2', 't_3']) {
      await db
          .into(db.tracks)
          .insert(
            TracksCompanion.insert(
              id: id,
              title: 'Трек $id',
              titleNorm: 'трек $id',
              durationSec: 180,
              fingerprint: 'fp-$id',
              metadataSource: 'yandex',
            ),
          );
    }
  });

  tearDown(() => db.close());

  test('ручная задача идёт раньше автозагрузки, дубли не плодятся', () async {
    final dao = db.downloadsDao;
    expect(
      await dao.enqueue('t_1', origin: DownloadOrigin.auto),
      DownloadEnqueueResult.queued,
    );
    expect(
      await dao.enqueue('t_2', origin: DownloadOrigin.manual),
      DownloadEnqueueResult.queued,
    );
    expect(
      await dao.enqueue('t_1', origin: DownloadOrigin.auto),
      DownloadEnqueueResult.alreadyQueued,
    );

    final next = await dao.nextTask();
    expect(next?.localTrackId, 't_2');
    expect((await dao.stats()).queued, 2);
  });

  test(
    'зависшая downloading возвращается в очередь после перезапуска',
    () async {
      final dao = db.downloadsDao;
      await dao.enqueue('t_1', origin: DownloadOrigin.auto);
      expect((await dao.claim('t_1'))?.localTrackId, 't_1');
      expect(await dao.nextTask(origin: DownloadOrigin.auto), isNull);

      expect(await dao.requeueStale(), 1);
      expect(
        (await dao.nextTask(origin: DownloadOrigin.auto))?.localTrackId,
        't_1',
      );
    },
  );

  test('пропущенный трек авто не берёт, ручная перезапускает', () async {
    final dao = db.downloadsDao;
    await dao.enqueue('t_1', origin: DownloadOrigin.auto);
    expect((await dao.claim('t_1'))?.localTrackId, 't_1');
    await dao.markSkipped('t_1', 'Недоступно офлайн');

    expect(await dao.nextTask(origin: DownloadOrigin.auto), isNull);
    expect((await dao.stats()).skipped, 1);
    expect(
      await dao.enqueue('t_1', origin: DownloadOrigin.auto),
      DownloadEnqueueResult.alreadyQueued,
    );
    expect(
      await dao.enqueue('t_1', origin: DownloadOrigin.manual),
      DownloadEnqueueResult.queued,
    );
  });

  test(
    'пачка ставится в очередь одной транзакцией и уважает complete',
    () async {
      await db
          .into(db.downloadedFiles)
          .insert(
            DownloadedFilesCompanion.insert(
              localTrackId: 't_1',
              filePath: '/tmp/t_1.mp3',
              source: 'yandex',
              state: const Value('complete'),
            ),
          );

      final dao = db.downloadsDao;
      expect(
        await dao.enqueueAll([
          't_1',
          't_2',
          't_3',
          't_2',
        ], origin: DownloadOrigin.auto),
        2,
      );
      expect((await dao.byId('t_1')), isNull);
      expect((await dao.stats()).queued, 2);
      expect(
        await dao.enqueue('t_1', origin: DownloadOrigin.manual),
        DownloadEnqueueResult.alreadyDownloaded,
      );
    },
  );

  test('claim, прогресс, пауза и продолжение меняют состояние', () async {
    final dao = db.downloadsDao;
    await dao.enqueue('t_1', origin: DownloadOrigin.manual);

    final claimed = await dao.claim('t_1');
    expect(claimed?.state, DownloadTaskState.downloading.name);
    expect(claimed?.attempts, 1);
    expect(await dao.claim('t_1'), isNull);

    await dao.updateProgress('t_1', receivedBytes: 512, totalBytes: 2048);
    var task = await dao.byId('t_1');
    expect(task?.receivedBytes, 512);
    expect(task?.totalBytes, 2048);

    await dao.pause('t_1', reason: 'ждём Wi-Fi');
    expect((await dao.byId('t_1'))?.state, DownloadTaskState.paused.name);

    await dao.resume('t_1');
    task = await dao.byId('t_1');
    expect(task?.state, DownloadTaskState.queued.name);
    expect(task?.lastError, isNull);

    await dao.claim('t_1');
    await dao.markFailed('t_1', error: '429', nextAttemptAt: DateTime(2030));
    task = await dao.byId('t_1');
    expect(task?.state, DownloadTaskState.failed.name);
    expect(task?.lastError, '429');
    expect(task?.nextAttemptAt, DateTime(2030));
    expect((await dao.stats()).failed, 1);
  });

  test('исключённая задача не воскресает, ручной retry разрешён', () async {
    final dao = db.downloadsDao;
    await dao.enqueue('t_1', origin: DownloadOrigin.auto);
    await dao.exclude('t_1', reason: 'удалён вручную');

    expect(
      await dao.enqueue('t_1', origin: DownloadOrigin.auto),
      DownloadEnqueueResult.excluded,
    );
    expect(
      await dao.enqueue('t_1', origin: DownloadOrigin.manual),
      DownloadEnqueueResult.excluded,
    );
    expect(
      await dao.enqueue(
        't_1',
        origin: DownloadOrigin.manual,
        retryExcluded: true,
      ),
      DownloadEnqueueResult.queued,
    );
    expect((await dao.byId('t_1'))?.state, DownloadTaskState.queued.name);
  });

  test('пауза всей очереди не трогает excluded и completed-файлы', () async {
    final dao = db.downloadsDao;
    await dao.enqueue('t_1', origin: DownloadOrigin.auto);
    await dao.enqueue('t_2', origin: DownloadOrigin.manual);
    await dao.enqueue('t_3', origin: DownloadOrigin.auto);
    await dao.exclude('t_3');

    await dao.pauseQueued();
    var stats = await dao.stats();
    expect(stats.queued, 0);
    expect(stats.paused, 2);
    expect(stats.excluded, 1);

    await dao.resumePaused();
    stats = await dao.stats();
    expect(stats.queued, 2);
    expect(stats.paused, 0);
  });

  test('автозадача повторяется только после nextAttemptAt', () async {
    final dao = db.downloadsDao;
    await dao.enqueue('t_1', origin: DownloadOrigin.auto);
    await dao.claim('t_1');
    await dao.markFailed(
      't_1',
      error: '429',
      nextAttemptAt: DateTime.now().add(const Duration(minutes: 30)),
    );

    expect(
      await dao.enqueue('t_1', origin: DownloadOrigin.auto),
      DownloadEnqueueResult.alreadyQueued,
    );

    await dao.resume('t_1');
    await dao.claim('t_1');
    await dao.markFailed(
      't_1',
      error: '429',
      nextAttemptAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    expect(
      await dao.enqueue('t_1', origin: DownloadOrigin.auto),
      DownloadEnqueueResult.queued,
    );
  });

  test('pauseAll останавливает и stale downloading после kill', () async {
    final dao = db.downloadsDao;
    await dao.enqueue('t_1', origin: DownloadOrigin.auto);
    await dao.claim('t_1');
    await dao.enqueue('t_2', origin: DownloadOrigin.manual);

    await dao.pauseAll();
    final stats = await dao.stats();
    expect(stats.downloading, 0);
    expect(stats.queued, 0);
    expect(stats.paused, 2);
  });

  test('сводка считает только complete-файлы', () async {
    for (final (id, size, state) in [
      ('t_1', 1024, 'complete'),
      ('t_2', 4096, 'failed'),
    ]) {
      await db
          .into(db.downloadedFiles)
          .insert(
            DownloadedFilesCompanion.insert(
              localTrackId: id,
              filePath: '/tmp/$id.mp3',
              sizeBytes: Value(size),
              source: 'yandex',
              state: Value(state),
            ),
          );
    }

    final summary = await db.downloadsDao.completedFilesSummary();
    expect(summary.count, 1);
    expect(summary.bytes, 1024);
  });
}
