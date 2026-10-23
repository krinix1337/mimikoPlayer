import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/db/daos/queue_dao.dart';
import 'package:phoneyandex/core/db/database.dart';

void main() {
  late AppDatabase db;
  late QueueDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = QueueDao(db);
  });
  tearDown(() => db.close());

  Future<int> rowCount() async =>
      (await db.rowCountSnapshot())['queue_snapshots'] ?? -1;

  test('повторное сохранение того же kind не нарушает уникальность', () async {
    await dao.save(
      kind: QueueDao.kindPlayer,
      localTrackIds: ['t_1', 't_2'],
      index: 0,
      position: Duration.zero,
      repeatMode: 'none',
      shuffleEnabled: false,
    );
    await dao.save(
      kind: QueueDao.kindPlayer,
      localTrackIds: ['t_1', 't_2'],
      index: 1,
      position: const Duration(seconds: 42),
      repeatMode: 'all',
      shuffleEnabled: true,
      sourceHint: {'kind': 'local'},
    );

    expect(await rowCount(), 1);

    final row = await dao.load(QueueDao.kindPlayer);
    expect(row, isNotNull);
    expect(QueueDao.itemsOf(row!), ['t_1', 't_2']);
    expect(row.queueIndex, 1);
    expect(row.positionMs, 42000);
    expect(row.repeatMode, 'all');
    expect(row.shuffleEnabled, isTrue);
    expect(QueueDao.hintOf(row), {'kind': 'local'});
  });

  test('player и radio хранятся раздельно', () async {
    await dao.save(
      kind: QueueDao.kindPlayer,
      localTrackIds: ['t_1'],
      index: 0,
      position: Duration.zero,
      repeatMode: 'none',
      shuffleEnabled: false,
    );
    await dao.save(
      kind: QueueDao.kindRadio,
      localTrackIds: ['t_9'],
      index: 0,
      position: Duration.zero,
      repeatMode: 'none',
      shuffleEnabled: false,
    );

    expect(await rowCount(), 2);
    expect(QueueDao.itemsOf((await dao.load(QueueDao.kindRadio))!), ['t_9']);
  });

  test('пустой hint читается как null', () async {
    await dao.save(
      kind: QueueDao.kindPlayer,
      localTrackIds: ['t_1'],
      index: 0,
      position: Duration.zero,
      repeatMode: 'none',
      shuffleEnabled: false,
    );
    expect(QueueDao.hintOf((await dao.load(QueueDao.kindPlayer))!), isNull);
  });
}
