import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/db/database.dart';
import 'package:phoneyandex/core/sources/source_dto.dart';
import 'package:phoneyandex/core/sources/source_id.dart';
import 'package:phoneyandex/core/sources/stream_target.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<String> ingest(String id, String title, String artist) async {
    final t = await db.tracksDao.ingest(
      SourceTrack(
        ref: RemoteTrackRef(SourceId.yandex, id),
        title: title,
        artists: [artist],
        duration: const Duration(minutes: 3),
      ),
    );
    return t.localTrackId;
  }

  Future<void> play(String id, int seconds, {bool inStats = true}) =>
      db.historyDao.record(
        localTrackId: id,
        source: SourceId.yandex,
        quality: Quality.auto,
        played: Duration(seconds: seconds),
        completed: false,
        inStats: inStats,
      );

  test('засчитывает только прослушивания от 30 секунд', () async {
    final a = await ingest('1', 'Клей', 'CUPSIZE');
    final b = await ingest('2', 'Династия', 'VILLIAN');
    await play(a, 120);
    await play(a, 60);
    await play(b, 10);
    await play(b, 45, inStats: false);

    final s = await db.statsDao.summary(null);
    expect(s.plays, 2);
    expect(s.tracks, 1);
    expect(s.listened, const Duration(seconds: 190));

    final top = await db.statsDao.topTracks(null);
    expect(top.single.title, 'Клей');
    expect(top.single.subtitle, 'CUPSIZE');

    final artists = await db.statsDao.topArtists(null);
    expect(artists.single.title, 'CUPSIZE');
  });

  test('очистка убирает статистику, но не историю', () async {
    final a = await ingest('1', 'Клей', 'CUPSIZE');
    await play(a, 120);
    await db.statsDao.clear();

    expect((await db.statsDao.summary(null)).plays, 0);
    expect(await db.historyDao.recent(), hasLength(1));
  });

  test('по дням складывает время за сегодня', () async {
    final a = await ingest('1', 'Клей', 'CUPSIZE');
    await play(a, 90);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daily = await db.statsDao.daily(
      today.subtract(const Duration(days: 6)),
    );
    expect(daily[today], const Duration(seconds: 90));
  });
}
