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
}) =>
    SourceTrack(
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

  Future<String> seed(String id, String title, String artist, int seconds) async =>
      (await db.tracksDao.ingest(_track(id, title, artist, seconds))).localTrackId;

  test('строки несут исполнителя и обложку, а не служебное имя источника', () async {
    final id = await seed('11', 'Молчит', 'Король и Шут', 200);
    await dao.setLike(id, 1);

    final rows = await dao.collectionRows(CollectionKind.liked);
    expect(rows.single.localTrackId, id);
    expect(rows.single.artist, 'Король и Шут');
    expect(rows.single.coverUrl, 'https://example/11.jpg');
    expect(rows.single.durationSec, 200);
  });

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
      (await dao.collectionRows(CollectionKind.liked)).map((row) => row.localTrackId),
      [liked],
    );
    expect(
      (await dao.collectionRows(CollectionKind.disliked)).map((row) => row.localTrackId),
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

  test('плейлист без собственной обложки берёт обложку первого трека', () async {
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
}
