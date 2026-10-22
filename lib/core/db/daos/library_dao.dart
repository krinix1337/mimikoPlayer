import 'package:drift/drift.dart';

import '../../sources/source_dto.dart';
import '../../sources/source_id.dart';
import '../database.dart';

/// Библиотека пользователя: лайки и плейлисты поверх локальных строк треков.
class LibraryDao {
  LibraryDao(this._db);

  final AppDatabase _db;

  /// state: 1 лайк, -1 дизлайк, 0 — снять отметку.
  ///
  /// [refreshTimestamp] = false держит `likedAt` первым: массовый импорт из
  /// Яндекса иначе переставляет всю коллекцию на каждый прогон.
  Future<void> setLike(
    String localTrackId,
    int state, {
    SourceId? remoteSource,
    bool refreshTimestamp = true,
    DateTime? likedAt,
  }) async {
    final synced = remoteSource != null;
    if (state == 0) {
      await (_db.delete(
        _db.likes,
      )..where((t) => t.localTrackId.equals(localTrackId))).go();
      return;
    }
    await _db
        .into(_db.likes)
        .insertOnConflictUpdate(
          LikesCompanion(
            localTrackId: Value(localTrackId),
            state: Value(state),
            likedAt: likedAt != null
                ? Value(likedAt)
                : refreshTimestamp
                ? Value(DateTime.now())
                : const Value.absent(),
            syncedToRemote: Value(synced),
            remoteSource: remoteSource == null
                ? const Value.absent()
                : Value(remoteSource.wire),
          ),
        );
  }

  /// 1 любимое, -1 нелюбимое, 0 ничего.
  Future<int> likeState(String localTrackId) async {
    final row =
        await (_db.select(_db.likes)
              ..where((t) => t.localTrackId.equals(localTrackId))
              ..limit(1))
            .getSingleOrNull();
    return row?.state ?? 0;
  }

  Future<List<String>> likedTrackIds() async {
    final rows =
        await (_db.select(_db.likes)
              ..where((t) => t.state.equals(1))
              ..orderBy([(t) => OrderingTerm.desc(t.likedAt)]))
            .get();
    return [for (final row in rows) row.localTrackId];
  }

  Future<List<PlaylistOverview>> playlistsOverview() async {
    final query =
        _db.selectOnly(_db.playlists).join([
            leftOuterJoin(
              _db.playlistTracks,
              _db.playlistTracks.playlistId.equalsExp(_db.playlists.id),
            ),
          ])
          ..addColumns([
            _db.playlists.id,
            _db.playlists.title,
            _db.playlists.coverUrl,
            _db.playlists.kind,
            _db.playlists.source,
            _db.playlistTracks.localTrackId.count(),
          ])
          ..groupBy([_db.playlists.id])
          ..orderBy([OrderingTerm.desc(_db.playlists.updatedAt)]);

    final overviews = [
      for (final row in await query.get())
        PlaylistOverview(
          id: row.read(_db.playlists.id)!,
          title: row.read(_db.playlists.title)!,
          coverUrl: row.read(_db.playlists.coverUrl),
          kind: row.read(_db.playlists.kind)!,
          source: row.read(_db.playlists.source)!,
          trackCount: row.read(_db.playlistTracks.localTrackId.count()) ?? 0,
        ),
    ];

    // У пользовательских плейлистов Яндекса обложки часто нет: сервис
    // собирает мозаику на клиенте. Показываем обложку первого трека, иначе
    // целая лента выглядит серыми квадратами.
    final missing = [
      for (final overview in overviews)
        if (overview.coverUrl == null) overview.id,
    ];
    if (missing.isEmpty) return overviews;

    final links =
        await (_db.select(_db.playlistTracks)
              ..where((t) => t.playlistId.isIn(missing))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    final firstTrack = <String, String>{};
    for (final link in links) {
      firstTrack.putIfAbsent(link.playlistId, () => link.localTrackId);
    }
    if (firstTrack.isEmpty) return overviews;

    final tracks = {
      for (final track in await _db.tracksDao.byIdList(
        firstTrack.values.toList(),
      ))
        track.id: track.coverUrl,
    };
    return [
      for (final overview in overviews)
        if (overview.coverUrl == null && firstTrack[overview.id] != null)
          PlaylistOverview(
            id: overview.id,
            title: overview.title,
            kind: overview.kind,
            source: overview.source,
            coverUrl: tracks[firstTrack[overview.id]],
            trackCount: overview.trackCount,
          )
        else
          overview,
    ];
  }

  /// Аватар из карточки артиста: у старых строк coverUrl пустой, потому что
  /// первый ingest не читал обложку артиста из ответа каталога.
  Future<void> setArtistCover(int artistId, String? url) async {
    if (url == null || url.isEmpty) return;
    await (_db.update(_db.artists)..where((t) => t.id.equals(artistId))).write(
      ArtistsCompanion(coverUrl: Value(url), updatedAt: Value(DateTime.now())),
    );
  }

  /// Список коллекции одним заходом: порядок задаёт раздел, а не SQLite.
  /// `byIdList` возвращает строки в порядке первичного ключа, поэтому
  /// сортировка здесь явная и результат не «раскидан» между перезаходами.
  Future<List<CollectionRow>> collectionRows(
    CollectionKind kind, {
    CollectionSort sort = CollectionSort.added,
    int limit = 5000,
  }) async {
    final ordered = switch (kind) {
      CollectionKind.liked || CollectionKind.disliked => await _fromLikes(
        state: kind == CollectionKind.liked ? 1 : -1,
        limit: limit,
      ),
      CollectionKind.files => await _fromMappings(limit: limit),
      CollectionKind.downloaded => await _fromDownloads(limit: limit),
      CollectionKind.recent => await _fromHistory(limit: limit),
    };
    if (ordered.isEmpty) return const [];

    final ids = [for (final (id, _) in ordered) id];
    final tracks = {
      for (final track in await _db.tracksDao.byIdList(ids)) track.id: track,
    };
    final artists = await mainArtistNames(ids);
    final artistRemoteIds = await artistRemoteIdsForTracks(ids);

    final rows = <CollectionRow>[
      for (final (id, markedAt) in ordered)
        if (tracks[id] case final track?)
          CollectionRow(
            localTrackId: id,
            title: track.title,
            artist: artists[id] ?? '',
            artistRemoteIds: artistRemoteIds[id] ?? const [],
            coverUrl: track.coverUrl,
            durationSec: track.durationSec,
            markedAt: markedAt,
            source: SourceId.fromWire(track.metadataSource),
          ),
    ];

    switch (sort) {
      case CollectionSort.added:
        break;
      case CollectionSort.title:
        rows.sort((a, b) => _compareFold(a.title, b.title));
      case CollectionSort.artist:
        rows.sort((a, b) {
          final byArtist = _compareFold(a.artist, b.artist);
          return byArtist != 0 ? byArtist : _compareFold(a.title, b.title);
        });
      case CollectionSort.duration:
        rows.sort((a, b) => b.durationSec.compareTo(a.durationSec));
    }
    return rows;
  }

  /// Главный исполнитель для пачки треков — один запрос вместо N.
  Future<Map<String, String>> mainArtistNames(List<String> trackIds) async {
    if (trackIds.isEmpty) return const {};
    final query =
        _db.selectOnly(_db.trackArtists).join([
            innerJoin(
              _db.artists,
              _db.artists.id.equalsExp(_db.trackArtists.artistId),
            ),
          ])
          ..addColumns([_db.trackArtists.trackId, _db.artists.name])
          ..where(_db.trackArtists.trackId.isIn(trackIds))
          ..orderBy([OrderingTerm.asc(_db.trackArtists.position)]);

    final result = <String, String>{};
    for (final row in await query.get()) {
      final trackId = row.read(_db.trackArtists.trackId);
      if (trackId == null || result.containsKey(trackId)) continue;
      result[trackId] = row.read(_db.artists.name) ?? '';
    }
    return result;
  }

  /// Удалённые id всех артистов трека — для AI-фильтра по списку Slopless.
  Future<Map<String, List<String>>> artistRemoteIdsForTracks(
    List<String> trackIds,
  ) async {
    if (trackIds.isEmpty) return const {};
    final query =
        _db.selectOnly(_db.trackArtists).join([
            innerJoin(
              _db.artists,
              _db.artists.id.equalsExp(_db.trackArtists.artistId),
            ),
          ])
          ..addColumns([_db.trackArtists.trackId, _db.artists.remoteArtistId])
          ..where(_db.trackArtists.trackId.isIn(trackIds));

    final result = <String, List<String>>{};
    for (final row in await query.get()) {
      final trackId = row.read(_db.trackArtists.trackId);
      final remoteId = row.read(_db.artists.remoteArtistId);
      if (trackId == null || remoteId == null || remoteId.isEmpty) continue;
      result.putIfAbsent(trackId, () => []).add(remoteId);
    }
    return result;
  }

  Future<List<(String, DateTime)>> _fromLikes({
    required int state,
    required int limit,
  }) async {
    final rows =
        await (_db.select(_db.likes)
              ..where((t) => t.state.equals(state))
              ..orderBy([(t) => OrderingTerm.desc(t.likedAt)])
              ..limit(limit))
            .get();
    return [for (final row in rows) (row.localTrackId, row.likedAt)];
  }

  Future<List<(String, DateTime)>> _fromMappings({required int limit}) async {
    final rows =
        await (_db.select(_db.remoteIdMappings)
              ..where((t) => t.source.equals(SourceId.local.wire))
              ..orderBy([(t) => OrderingTerm.desc(t.firstSeenAt)])
              ..limit(limit))
            .get();
    return [for (final row in rows) (row.localTrackId, row.firstSeenAt)];
  }

  Future<List<(String, DateTime)>> _fromDownloads({required int limit}) async {
    final rows =
        await (_db.select(_db.downloadedFiles)
              ..where((t) => t.state.equals('complete'))
              ..orderBy([(t) => OrderingTerm.desc(t.downloadedAt)])
              ..limit(limit))
            .get();
    return [for (final row in rows) (row.localTrackId, row.downloadedAt)];
  }

  Future<List<(String, DateTime)>> _fromHistory({required int limit}) async {
    final rows =
        await (_db.select(_db.history)
              ..orderBy([(t) => OrderingTerm.desc(t.playedAt)])
              ..limit(limit * 3))
            .get();
    final seen = <String>{};
    final result = <(String, DateTime)>[];
    for (final row in rows) {
      if (!seen.add(row.localTrackId)) continue;
      result.add((row.localTrackId, row.playedAt));
      if (result.length >= limit) break;
    }
    return result;
  }

  static int _compareFold(String a, String b) =>
      a.toLowerCase().compareTo(b.toLowerCase());

  /// Топ исполнителей по прослушиваниям — секция «Артисты» в коллекции.
  Future<List<ArtistPlaycount>> topArtists({int limit = 12}) async {
    final plays = _db.history.id.count();
    final seconds = _db.history.playedMs.sum();
    final query =
        _db.selectOnly(_db.artists).join([
            innerJoin(
              _db.trackArtists,
              _db.trackArtists.artistId.equalsExp(_db.artists.id),
            ),
            innerJoin(
              _db.history,
              _db.history.localTrackId.equalsExp(_db.trackArtists.trackId),
            ),
          ])
          ..addColumns([
            _db.artists.id,
            _db.artists.name,
            _db.artists.coverUrl,
            _db.artists.remoteArtistId,
            plays,
            seconds,
          ])
          ..groupBy([_db.artists.id])
          ..orderBy([OrderingTerm.desc(plays)])
          ..limit(limit);

    return [
      for (final row in await query.get())
        ArtistPlaycount(
          artistId: row.read(_db.artists.id)!,
          name: row.read(_db.artists.name)!,
          coverUrl: row.read(_db.artists.coverUrl),
          remoteId: row.read(_db.artists.remoteArtistId) ?? '',
          plays: row.read(plays) ?? 0,
          listenedMs: row.read(seconds) ?? 0,
        ),
    ];
  }

  /// Треки плейлиста в том порядке, в каком их положил источник:
  /// `position` пишется при импорте и не зависит от даты добавления.
  Future<List<CollectionRow>> playlistRows(String playlistId) async {
    final links =
        await (_db.select(_db.playlistTracks)
              ..where((t) => t.playlistId.equals(playlistId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    if (links.isEmpty) return const [];

    final ids = [for (final link in links) link.localTrackId];
    final tracks = {
      for (final track in await _db.tracksDao.byIdList(ids)) track.id: track,
    };
    final artists = await mainArtistNames(ids);
    final artistRemoteIds = await artistRemoteIdsForTracks(ids);

    return [
      for (final link in links)
        if (tracks[link.localTrackId] case final track?)
          CollectionRow(
            localTrackId: track.id,
            title: track.title,
            artist: artists[track.id] ?? '',
            artistRemoteIds: artistRemoteIds[track.id] ?? const [],
            coverUrl: track.coverUrl,
            durationSec: track.durationSec,
            markedAt: link.addedAt,
            source: SourceId.fromWire(track.metadataSource),
          ),
    ];
  }

  Future<PlaylistOverview?> playlistById(String id) async {
    final row =
        await (_db.select(_db.playlists)
              ..where((t) => t.id.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    final count =
        await (_db.selectOnly(_db.playlistTracks)
              ..addColumns([_db.playlistTracks.localTrackId.count()])
              ..where(_db.playlistTracks.playlistId.equals(id)))
            .getSingle();
    var coverUrl = row.coverUrl;
    if (coverUrl == null) {
      final first =
          await (_db.select(_db.playlistTracks)
                ..where((t) => t.playlistId.equals(id))
                ..orderBy([(t) => OrderingTerm.asc(t.position)])
                ..limit(1))
              .getSingleOrNull();
      if (first != null) {
        coverUrl = (await _db.tracksDao.byId(first.localTrackId))?.coverUrl;
      }
    }
    return PlaylistOverview(
      id: row.id,
      title: row.title,
      kind: row.kind,
      source: row.source,
      coverUrl: coverUrl,
      trackCount: count.read(_db.playlistTracks.localTrackId.count()) ?? 0,
    );
  }

  /// Имиты удалённого плейлиста в локальный: строки треков уже сведены
  /// `TracksDao.ingest`, здесь остаются только связи.
  Future<String> importPlaylist({
    required SourceId source,
    required PlaylistSnapshot snapshot,
  }) async {
    final id = '${source.wire}:${snapshot.remotePlaylistId}';
    final now = DateTime.now();

    await _db
        .into(_db.playlists)
        .insertOnConflictUpdate(
          PlaylistsCompanion.insert(
            id: id,
            source: Value(source.wire),
            remotePlaylistId: Value(snapshot.remotePlaylistId),
            title: snapshot.title,
            description: Value(snapshot.description),
            coverUrl: Value(snapshot.coverUrl),
            kind: const Value('imported'),
            totalTracks: Value(snapshot.total ?? snapshot.tracks.length),
            canEdit: const Value(false),
            lastSyncedAt: Value(now),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    await (_db.delete(
      _db.playlistTracks,
    )..where((t) => t.playlistId.equals(id))).go();

    // В плейлисте Яндекса один и тот же трек может встречаться дважды:
    // первичный ключ (playlist_id, local_track_id) второй раз не пустит,
    // поэтому повторные вхождения схлопываем.
    final localIds = <String>[];
    final seen = <String>{};
    for (final track in snapshot.tracks) {
      final id = (await _db.tracksDao.ingest(track)).localTrackId;
      if (!seen.add(id)) continue;
      localIds.add(id);
    }

    await _db.batch((batch) {
      for (var i = 0; i < localIds.length; i++) {
        final track = snapshot.tracks[i];
        batch.insert(
          _db.playlistTracks,
          PlaylistTracksCompanion.insert(
            playlistId: id,
            // Трек обязательно уже сведён: ingest идемпотентен и возвращает
            // тот же localTrackId для того же удалённого id.
            localTrackId: localIds[i],
            position: Value(i),
            sourceId: track.ref.source.wire,
            remoteId: track.ref.remoteId,
            addedAt: Value(now),
          ),
        );
      }
    });

    return id;
  }
}

/// Строка списка коллекции: трек + то, что реально видно в строке.
final class CollectionRow {
  const CollectionRow({
    required this.localTrackId,
    required this.title,
    required this.artist,
    required this.durationSec,
    required this.source,
    this.coverUrl,
    this.markedAt,
    this.artistRemoteIds = const [],
  });

  final String localTrackId;
  final String title;
  final String artist;

  /// id артистов в их источниках: по ним AI-фильтр сверяется со списком.
  final List<String> artistRemoteIds;
  final int durationSec;
  final SourceId source;
  final String? coverUrl;

  /// Когда попало в раздел: лайк, скачивание или проигрывание.
  final DateTime? markedAt;
}

enum CollectionKind { liked, disliked, files, recent, downloaded }

enum CollectionSort { added, title, artist, duration }

final class ArtistPlaycount {
  const ArtistPlaycount({
    required this.artistId,
    required this.name,
    required this.plays,
    required this.listenedMs,
    this.coverUrl,
    this.remoteId = '',
  });

  final int artistId;
  final String name;
  final String? coverUrl;

  /// id артиста в Яндексе; пусто у артистов из локальных тегов.
  final String remoteId;
  final int plays;
  final int listenedMs;
}

final class PlaylistDetail {
  const PlaylistDetail({required this.overview, required this.rows});

  final PlaylistOverview overview;
  final List<CollectionRow> rows;
}

final class PlaylistOverview {
  const PlaylistOverview({
    required this.id,
    required this.title,
    required this.kind,
    required this.source,
    this.coverUrl,
    this.trackCount = 0,
  });

  final String id;
  final String title;
  final String kind;
  final String source;
  final String? coverUrl;
  final int trackCount;
}
