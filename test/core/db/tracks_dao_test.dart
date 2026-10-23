import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/db/database.dart';
import 'package:phoneyandex/core/identity/track_identity.dart';
import 'package:phoneyandex/core/sources/source_dto.dart';
import 'package:phoneyandex/core/sources/source_id.dart';

extension on SourceTrack {
  SourceTrack copyWithLikeAlbum(String albumId) => SourceTrack(
    ref: RemoteTrackRef(ref.source, ref.remoteId, albumId: albumId),
    title: title,
    artists: artists,
    duration: duration,
    isrc: isrc,
  );
}

SourceTrack track(
  SourceId source,
  String remoteId, {
  String title = 'Ветер',
  List<String> artists = const ['Ария'],
  int seconds = 213,
  String? isrc,
}) => SourceTrack(
  ref: RemoteTrackRef(source, remoteId),
  title: title,
  artists: artists,
  duration: Duration(seconds: seconds),
  isrc: isrc,
);

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('вариант для источника несёт чистый id, а не `track-album`', () async {
    // Регресс: составной ключ попадал в download-info, и Яндекс отвечал 400.
    final ingested = await db.tracksDao.ingest(
      track(
        SourceId.yandex,
        '147872699',
        title: 'Killer Queen',
        artists: ['Queen'],
        seconds: 181,
      ).copyWithLikeAlbum('5901220'),
    );

    final variants = await db.tracksDao.variantsOf(ingested.localTrackId);
    expect(variants, hasLength(1));
    expect(variants.single.ref.remoteId, '147872699');
    expect(variants.single.ref.albumId, '5901220');
  });

  test('повторный ingest не плодит дубль и не падает', () async {
    final source = track(SourceId.yandex, '111', isrc: 'RU-Z01-99-00001');

    final first = await db.tracksDao.ingest(source);
    final second = await db.tracksDao.ingest(source);

    expect(second.localTrackId, first.localTrackId);
    expect(second.tier, MatchTier.exactRemote);
    expect(await db.tracksDao.byIdList([first.localTrackId]), hasLength(1));
    expect(await db.rowCountSnapshot().then((r) => r['tracks']), 1);
  });

  test('localIdForRemote находит уже сведённый трек', () async {
    final ingested = await db.tracksDao.ingest(
      track(SourceId.yandex, '501', title: 'Найдётся'),
    );

    expect(
      await db.tracksDao.localIdForRemote(
        const RemoteTrackRef(SourceId.yandex, '501'),
      ),
      ingested.localTrackId,
    );
    expect(
      await db.tracksDao.localIdForRemote(
        const RemoteTrackRef(SourceId.yandex, '999'),
      ),
      isNull,
    );
  });

  test(
    'короткая ссылка не удерживает полноценный трек в общей строке',
    () async {
      const short = SourceTrack(
        ref: RemoteTrackRef(SourceId.yandex, '42', albumId: '7'),
        title: '',
        artists: [],
        duration: Duration.zero,
        raw: {'id': 42, 'albumId': 7, 'timestamp': '2026-10-01T00:00:00'},
      );
      final empty = await db.tracksDao.ingest(short);

      const full = SourceTrack(
        ref: RemoteTrackRef(SourceId.yandex, '42', albumId: '7'),
        title: 'Настоящий',
        artists: ['Артист'],
        duration: Duration(minutes: 3),
        raw: {'id': 42, 'title': 'Настоящий', 'durationMs': 180000},
      );
      final ingested = await db.tracksDao.ingest(full);

      expect(ingested.localTrackId, isNot(empty.localTrackId));
      expect(
        (await db.tracksDao.byId(ingested.localTrackId))!.title,
        'Настоящий',
      );
      // Отравленная связь перезаписана на нормальную строку, а не осталась
      // указывать на общий пустой трек.
      final mapping = await db.select(db.remoteIdMappings).getSingle();
      expect(mapping.localTrackId, ingested.localTrackId);
    },
  );

  test('повторный ingest заполняет пустые метаданные старой строки', () async {
    const empty = SourceTrack(
      ref: RemoteTrackRef(SourceId.yandex, '777'),
      title: '',
      artists: [],
      duration: Duration.zero,
    );
    final first = await db.tracksDao.ingest(empty);
    final second = await db.tracksDao.ingest(
      track(
        SourceId.yandex,
        '777',
        title: 'Контракт',
        artists: ['Пошлая Молли'],
        seconds: 154,
      ),
    );

    expect(second.localTrackId, first.localTrackId);
    expect(second.tier, MatchTier.exactRemote);
    final row = await db.tracksDao.byId(first.localTrackId);
    expect(row?.title, 'Контракт');
    expect(row?.durationSec, 154);
    expect(await db.tracksDao.artistNamesOf(first.localTrackId), [
      'Пошлая Молли',
    ]);
  });

  test('тот же трек из другого источника сводится по отпечатку', () async {
    final yandex = await db.tracksDao.ingest(track(SourceId.yandex, '111'));
    final youtube = await db.tracksDao.ingest(
      track(SourceId.youtube, 'dQw4w', title: 'Ветер (Live)'),
    );

    expect(youtube.localTrackId, yandex.localTrackId);
    expect(youtube.tier, MatchTier.fingerprint);

    final variants = await db.tracksDao.variantsOf(yandex.localTrackId);
    expect(variants.map((v) => v.ref.source), {
      SourceId.yandex,
      SourceId.youtube,
    });
  });

  test('ISRC сводит треки с разной записью длительности', () async {
    final first = await db.tracksDao.ingest(
      track(SourceId.yandex, '1', seconds: 200, isrc: 'US-R1X-15-00001'),
    );
    final second = await db.tracksDao.ingest(
      track(SourceId.deezer, '9', seconds: 194, isrc: 'US-R1X-15-00001'),
    );

    expect(second.localTrackId, first.localTrackId);
    expect(second.tier, MatchTier.isrc);
  });

  test('нечёткое совпадение крепит mapping, но не сливает строки', () async {
    final a = await db.tracksDao.ingest(
      track(
        SourceId.youtube,
        'yt1',
        title: 'Wind Of Change',
        artists: ['Scorpions'],
        seconds: 300,
      ),
    );
    final b = await db.tracksDao.ingest(
      track(
        SourceId.soundcloud,
        'sc1',
        title: 'Wind Of Change',
        artists: ['Scorpions'],
        seconds: 302,
      ),
    );

    expect(b.localTrackId, a.localTrackId);
    expect(b.tier, MatchTier.fuzzy);
    final mapping = await (db.select(
      db.remoteIdMappings,
    )..where((t) => t.remoteId.equals('sc1'))).getSingle();
    expect(mapping.mappingConfidence, 'fuzzy');
  });

  test('другая песня того же артиста остаётся отдельной строкой', () async {
    await db.tracksDao.ingest(track(SourceId.yandex, '1', title: 'Ветер'));
    final other = await db.tracksDao.ingest(
      track(SourceId.yandex, '2', title: 'Штиль', seconds: 250),
    );

    expect(await db.rowCountSnapshot().then((r) => r['tracks']), 2);
    expect(other.tier, MatchTier.none);
  });

  test('пакетный ingest сохраняет порядок и не дублирует строки', () async {
    // Поиск тапает по списку: id должны соответствовать порядку hits,
    // иначе очередь стартует не с той песни.
    final ids = await db.tracksDao.ingestAll([
      track(SourceId.yandex, '10', title: 'Первая', seconds: 100),
      track(SourceId.yandex, '11', title: 'Вторая', seconds: 110),
      track(SourceId.yandex, '10', title: 'Первая', seconds: 100),
    ]);

    expect(ids.length, 3);
    expect(ids[0], ids[2]);
    expect(ids[0], isNot(ids[1]));
    expect(await db.rowCountSnapshot().then((r) => r['tracks']), 2);
  });
}
