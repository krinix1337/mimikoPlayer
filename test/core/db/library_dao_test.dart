import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/db/daos/library_dao.dart';
import 'package:phoneyandex/core/db/database.dart';
import 'package:phoneyandex/core/sources/source_dto.dart';
import 'package:phoneyandex/core/sources/source_id.dart';
import 'package:phoneyandex/core/sources/stream_target.dart';

SourceTrack _track(
  String id,
  String title,
  String artist,
  int seconds, {
  List<String?> artistCovers = const [],
}) => SourceTrack(
  ref: RemoteTrackRef(SourceId.yandex, id),
  title: title,
  artists: [artist],
  artistCovers: artistCovers,
  duration: Duration(seconds: seconds),
  coverUrl: 'https://example/$id.jpg',
);

void main() {
  late AppDatabase db;
  late LibraryDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = LibraryDao(db);
  });
  tearDown(() => db.close());

  Future<String> seed(
    String id,
    String title,
    String artist,
    int seconds,
  ) async =>
      (await db.tracksDao.ingest(_track(id, title, artist, seconds)))
          .localTrackId;

  test(
    'строки несут исполнителя и обложку, а не служебное имя источника',
    () async {
      final id = await seed('11', 'Молчит', 'Король и Шут', 200);
      await dao.setLike(id, 1);

      final rows = await dao.collectionRows(CollectionKind.liked);
      expect(rows.single.localTrackId, id);
      expect(rows.single.artist, 'Король и Шут');
      expect(rows.single.coverUrl, 'https://example/11.jpg');
      expect(rows.single.durationSec, 200);
    },
  );

  test('повторный импорт не переставляет коллекцию', () async {
    // Регресс: массовая загрузка лайков писала likedAt = now каждому треку,
    // и после каждого импорта порядок в коллекции менялся целиком.
    final first = await seed('1', 'А', 'X', 100);
    final second = await seed('2', 'Б', 'Y', 120);
    await dao.setLike(first, 1);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await dao.setLike(second, 1);

    final before = [
      for (final row in await dao.collectionRows(CollectionKind.liked))
        row.localTrackId,
    ];

    await dao.setLike(first, 1, refreshTimestamp: false);
    await dao.setLike(second, 1, refreshTimestamp: false);

    final after = [
      for (final row in await dao.collectionRows(CollectionKind.liked))
        row.localTrackId,
    ];
    expect(after, before);
  });

  test('сортировка по названию и по длительности', () async {
    final a = await seed('3', 'Яблоко', 'Z', 300);
    final b = await seed('4', 'Апельсин', 'A', 120);
    await dao.setLike(a, 1);
    await dao.setLike(b, 1);

    final byTitle = await dao.collectionRows(
      CollectionKind.liked,
      sort: CollectionSort.title,
    );
    expect(byTitle.map((row) => row.localTrackId).toList(), [b, a]);

    final byDuration = await dao.collectionRows(
      CollectionKind.liked,
      sort: CollectionSort.duration,
    );
    expect(byDuration.first.localTrackId, a);
  });

  test('артисты без удалённого id не конфликтуют на уникальном индексе', () async {
    // Регресс: remote_artist_id был пустой строкой у всех, и второй артист
    // того же источника падал на artists_by_source (source, remote_artist_id).
    final a = await seed('7', 'Песня', 'Артист Один', 100);
    final b = await seed('8', 'Другая', 'Артист Два', 100);

    final names = <String>[];
    for (final id in [a, b]) {
      names.add((await db.tracksDao.artistNamesOf(id)).join(', '));
    }
    expect(names, ['Артист Один', 'Артист Два']);
  });

  test('дизлайки не попадают в любимое', () async {
    final liked = await seed('5', 'Л', 'L', 100);
    final hated = await seed('6', 'Н', 'H', 100);
    await dao.setLike(liked, 1);
    await dao.setLike(hated, -1);

    expect(
      (await dao.collectionRows(CollectionKind.liked))
          .map((row) => row.localTrackId),
      [liked],
    );
    expect(
      (await dao.collectionRows(CollectionKind.disliked))
          .map((row) => row.localTrackId),
      [hated],
    );
  });

  test('обложка артиста сохраняется из ответа каталога', () async {
    await db.tracksDao.ingest(
      _track(
        '9',
        'С обложкой',
        'Артист С Фото',
        100,
        artistCovers: const ['https://example/artist.jpg'],
      ),
    );
    final artist = await db.select(db.artists).getSingle();
    expect(artist.coverUrl, 'https://example/artist.jpg');
  });

  test(
    'плейлист без собственной обложки берёт обложку первого трека',
    () async {
      await dao.importPlaylist(
        source: SourceId.yandex,
        snapshot: PlaylistSnapshot(
          remotePlaylistId: '77',
          title: 'Без обложки',
          tracks: [_track('10', 'Первый', 'Артист', 100)],
        ),
      );

      final overview = await dao.playlistsOverview();
      expect(overview.single.coverUrl, 'https://example/10.jpg');
    },
  );

  test('повтор трека сохраняется отдельной строкой, source/remote верные', () async {
    final first = _track('20', 'Первый', 'Артист', 100);
    final second = _track('21', 'Второй', 'Артист', 120);
    await dao.importPlaylist(
      source: SourceId.yandex,
      snapshot: PlaylistSnapshot(
        remotePlaylistId: '88',
        title: 'С дублем',
        // Один и тот же трек дважды: PK (playlist, track) второй раз не пустит.
        tracks: [first, first, second],
      ),
    );

    final links = await db.select(db.playlistTracks).get();
    links.sort((a, b) => a.position.compareTo(b.position));
    expect(links.map((l) => l.remoteId), ['20', '20', '21']);
    expect(links.map((l) => l.position), [0, 1, 2]);
    expect((await dao.playlistRows('yandex:88')).length, 3);
  });

  test('короткая ссылка без метаданных не создаёт трек в плейлисте', () async {
    final broken = SourceTrack(
      ref: const RemoteTrackRef(SourceId.yandex, '99'),
      title: '',
      artists: const [],
      duration: Duration.zero,
    );
    await dao.importPlaylist(
      source: SourceId.yandex,
      snapshot: PlaylistSnapshot(
        remotePlaylistId: '89',
        title: 'Короткие ссылки',
        tracks: [broken, _track('22', 'Живой', 'Артист', 120)],
      ),
    );

    final links = await db.select(db.playlistTracks).get();
    expect(links, hasLength(1));
    expect(links.single.remoteId, '22');
  });

  test('плейлист, удалённый на сервере, исчезает и локально', () async {
    for (final (kind, title, id) in [('1', 'A', '30'), ('2', 'B', '31')]) {
      await dao.importPlaylist(
        source: SourceId.yandex,
        snapshot: PlaylistSnapshot(
          remotePlaylistId: kind,
          title: title,
          tracks: [_track(id, title, 'Артист', 100)],
        ),
      );
    }

    expect(await dao.removePlaylistsExcept({'yandex:1'}), 1);
    expect((await dao.playlistsOverview()).map((p) => p.id), ['yandex:1']);
  });

  test('скачанное попадает в отдельный раздел коллекции', () async {
    final id = await seed('12', 'Офлайн', 'Артист', 100);
    await db.streamsDao.markDownloaded(
      localTrackId: id,
      source: SourceId.yandex,
      filePath: '/downloads/12.mp3',
      quality: Quality.auto,
      sizeBytes: 1024,
      codec: 'mp3',
    );

    final rows = await dao.collectionRows(CollectionKind.downloaded);
    expect(rows.single.localTrackId, id);
    expect(rows.single.title, 'Офлайн');
  });

  test('повторная загрузка заменяет строку, а не падает на UNIQUE', () async {
    final id = await seed('13', 'Повтор', 'Артист', 100);
    await db.streamsDao.markDownloading(
      localTrackId: id,
      source: SourceId.yandex,
      filePath: '/downloads/13.mp3',
      quality: Quality.auto,
    );
    await db.streamsDao.markDownloaded(
      localTrackId: id,
      source: SourceId.yandex,
      filePath: '/downloads/13.mp3',
      quality: Quality.auto,
      sizeBytes: 2048,
      codec: 'mp3',
    );
    await db.streamsDao.markDownloaded(
      localTrackId: id,
      source: SourceId.yandex,
      filePath: '/downloads/13.mp3',
      quality: Quality.auto,
      sizeBytes: 4096,
      codec: 'mp3',
    );

    final rows = await db.select(db.downloadedFiles).get();
    expect(rows, hasLength(1));
    expect(rows.single.sizeBytes, 4096);
    expect(rows.single.state, 'complete');
  });

  test('строки очереди сохраняют порядок и повторы', () async {
    final first = await seed('41', 'Первый', 'A', 100);
    final second = await seed('42', 'Второй', 'B', 120);

    final rows = await dao.rowsForIds([second, first, second]);
    expect(
      [for (final row in rows) row.localTrackId],
      [second, first, second],
    );
    expect(rows.map((row) => row.title), ['Второй', 'Первый', 'Второй']);
    expect(rows.map((row) => row.artist), ['B', 'A', 'B']);
    expect(rows.map((row) => row.durationSec), [120, 100, 120]);
  });

  test('волна видит только «нелюбимые» из переданных треков', () async {
    final liked = await seed('21', 'Любимый', 'A', 100);
    final disliked = await seed('22', 'Нелюбимый', 'B', 101);
    final plain = await seed('23', 'Обычный', 'C', 102);
    await dao.setLike(liked, 1);
    await dao.setLike(disliked, -1);

    expect(
      await dao.dislikedAmong([liked, disliked, plain]),
      {disliked},
    );
  });

  test('оболочка плейлиста и пачка треков дают готовый список', () async {
    final first = await seed('31', 'Первый', 'A', 100);
    final second = await seed('32', 'Второй', 'B', 101);
    await dao.ensurePlaylistShell(
      id: 'pl_test',
      source: SourceId.local,
      remotePlaylistId: 'list:7',
      title: 'Перенесённый',
    );
    await dao.appendPlaylistTracks('pl_test', [
      (
        localTrackId: first,
        sourceId: SourceId.yandex.wire,
        remoteId: '31',
      ),
      (
        localTrackId: second,
        sourceId: SourceId.yandex.wire,
        remoteId: '32',
      ),
    ]);

    final overview = await dao.playlistById('pl_test');
    expect(overview?.title, 'Перенесённый');
    expect(overview?.trackCount, 2);
    final rows = await dao.playlistRows('pl_test');
    expect([for (final row in rows) row.localTrackId], [first, second]);
  });
}
