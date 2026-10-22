import 'dart:convert';

import 'package:drift/drift.dart';

import '../../identity/normalizer.dart';
import '../../identity/track_identity.dart';
import '../../sources/source_dto.dart';
import '../../sources/source_id.dart';
import '../database.dart';

final class IngestResult {
  const IngestResult(this.localTrackId, this.tier);

  final String localTrackId;
  final MatchTier tier;
}

/// Сведение удалённых треков из разных каталогов в одну локальную строку.
class TracksDao {
  TracksDao(this._db);

  final AppDatabase _db;

  /// Порядок совпадения: точный удалённый id → ISRC → отпечаток → нечёткое
  /// сравнение. Нечёткое совпадение крепит только mapping, строки не сливает.
  Future<IngestResult> ingest(SourceTrack track) => _db.transaction(() async {
    final source = track.ref.source;

    final existing = await (_db.select(_db.remoteIdMappings)
          ..where(
            (t) =>
                t.source.equals(source.wire) &
                t.remoteId.equals(track.ref.remoteId),
          )
          ..limit(1))
        .getSingleOrNull();

    if (existing != null) {
      await _touch(existing.localTrackId, source);
      return IngestResult(existing.localTrackId, MatchTier.exactRemote);
    }

    final isrc = normalizeIsrc(track.isrc);
    if (isrc.isNotEmpty) {
      final byIsrc = await (_db.select(_db.tracks)
            ..where((t) => t.isrc.equals(isrc))
            ..limit(1))
          .getSingleOrNull();
      if (byIsrc != null) {
        await _attachMapping(track, byIsrc.id, MatchTier.isrc);
        return IngestResult(byIsrc.id, MatchTier.isrc);
      }
    }

    final fingerprint = trackFingerprint(track);
    final byFingerprint = await (_db.select(_db.tracks)
          ..where((t) => t.fingerprint.equals(fingerprint))
          ..limit(1))
        .getSingleOrNull();
    if (byFingerprint != null) {
      await _attachMapping(track, byFingerprint.id, MatchTier.fingerprint);
      return IngestResult(byFingerprint.id, MatchTier.fingerprint);
    }

    if (await _findFuzzyMatch(track) case final fuzzy?) {
      await _attachMapping(track, fuzzy, MatchTier.fuzzy);
      return IngestResult(fuzzy, MatchTier.fuzzy);
    }

    return _create(track, fingerprint);
  });

  Future<IngestResult> _create(SourceTrack track, String fingerprint) async {
    final localId = localTrackIdFor(track);
    final artists = await _upsertArtists(track);
    final albumId = await _upsertAlbum(track);
    final now = DateTime.now();

    await _db.into(_db.tracks).insert(
      TracksCompanion.insert(
        id: localId,
        title: track.title,
        titleNorm: normalizeTitle(track.title),
        durationSec: (track.duration.inMilliseconds / 1000).round(),
        mainArtistId: Value(artists.mainId),
        albumId: Value(albumId),
        coverUrl: Value(track.coverUrl),
        isrc: Value(normalizeIsrc(track.isrc).isEmpty ? null : normalizeIsrc(track.isrc)),
        explicitFlag: Value(track.explicitFlag),
        lyricsAvailable: Value(track.lyricsAvailable ?? false),
        fingerprint: fingerprint,
        metadataSource: track.ref.source.wire,
        createdAt: Value(now),
        updatedAt: Value(now),
        lastSeenAt: Value(now),
      ),
      onConflict: DoUpdate(
        // Повторный ingest того же отпечатка не должен затирать локальные
        // правки и стирать обложку, если новые метаданные пришли без неё.
        (_) => TracksCompanion(
          title: Value(track.title),
          coverUrl: track.coverUrl == null
              ? const Value.absent()
              : Value(track.coverUrl),
          updatedAt: Value(now),
          lastSeenAt: Value(now),
        ),
      ),
    );

    await _db.batch((batch) {
      for (var i = 0; i < artists.ids.length; i++) {
        final artistId = artists.ids[i];
        batch.insert(
          _db.trackArtists,
          TrackArtistsCompanion.insert(
            trackId: localId,
            artistId: artistId,
            position: Value(i),
          ),
          onConflict: DoUpdate(
            (_) => TrackArtistsCompanion(position: Value(i)),
          ),
        );
      }
    });

    await _attachMapping(track, localId, MatchTier.none);
    return IngestResult(localId, MatchTier.none);
  }

  /// Пакетный ingest в одной транзакции: поштучный на 40 найденных треках
  /// давал ~10 секунд между тапом и стартом воспроизведения.
  Future<List<String>> ingestAll(List<SourceTrack> tracks) =>
      _db.transaction(() async {
        return [
          for (final track in tracks) (await ingest(track)).localTrackId,
        ];
      });

  Future<List<Track>> byIdList(List<String> localTrackIds) =>
      (_db.select(_db.tracks)..where((t) => t.id.isIn(localTrackIds))).get();

  Future<Track?> byId(String localTrackId) =>
      (_db.select(_db.tracks)..where((t) => t.id.equals(localTrackId)))
          .getSingleOrNull();

  Future<List<String>> artistNamesOf(String trackId) async {
    final query = _db.select(_db.trackArtists).join([
      innerJoin(_db.artists, _db.artists.id.equalsExp(_db.trackArtists.artistId)),
    ])
      ..where(_db.trackArtists.trackId.equals(trackId))
      ..orderBy([OrderingTerm.asc(_db.trackArtists.position)]);

    return (await query.get())
        .map((row) => row.readTable(_db.artists).name)
        .toList();
  }

  /// Все известные варианты этого трека по источникам — ровно то, с чем
  /// работает цепочка резервных источников.
  Future<List<SourceTrack>> variantsOf(String localTrackId) async {
    final track = await byId(localTrackId);
    if (track == null) return const [];

    final mappings = await (_db.select(_db.remoteIdMappings)
          ..where((t) => t.localTrackId.equals(localTrackId)))
        .get();
    final artists = await artistNamesOf(localTrackId);

    return [
      for (final mapping in mappings)
        SourceTrack(
          ref: RemoteTrackRef(
            SourceId.fromWire(mapping.source),
            mapping.remoteId,
            albumId: mapping.albumRemoteId,
          ),
          title: track.title,
          artists: artists,
          duration: Duration(seconds: track.durationSec),
          album: track.albumId == null
              ? null
              : await _albumTitle(track.albumId!),
          albumRemoteId: mapping.albumRemoteId,
          coverUrl: track.coverUrl,
          isrc: track.isrc,
          explicitFlag: track.explicitFlag,
          lyricsAvailable: track.lyricsAvailable,
        ),
    ];
  }

  /// Главный исполнитель вместе с удалённым id: по нему открывается
  /// карточка артиста, а не только строка с именем.
  Future<({String name, String remoteId})?> mainArtistOf(String trackId) async {
    final query = _db.select(_db.trackArtists).join([
      innerJoin(_db.artists, _db.artists.id.equalsExp(_db.trackArtists.artistId)),
    ])
      ..where(_db.trackArtists.trackId.equals(trackId))
      ..orderBy([OrderingTerm.asc(_db.trackArtists.position)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final artist = row.readTable(_db.artists);
    return (name: artist.name, remoteId: artist.remoteArtistId);
  }

  /// Удалённый id альбома из связки с источником — для перехода на альбом.
  Future<String?> albumRemoteIdOf(String trackId) async {
    final mapping = await (_db.select(_db.remoteIdMappings)
          ..where((t) => t.localTrackId.equals(trackId))
          ..limit(1))
        .getSingleOrNull();
    return mapping?.albumRemoteId;
  }

  /// Название альбома трека — нужно для запроса текста в LRCLIB.
  Future<String?> albumTitleOf(String trackId) async {
    final track = await byId(trackId);
    if (track?.albumId == null) return null;
    return _albumTitle(track!.albumId!);
  }

  Future<String?> _albumTitle(int albumId) async {
    final album = await (_db.select(_db.albums)
          ..where((t) => t.id.equals(albumId))
          ..limit(1))
        .getSingleOrNull();
    return album?.title;
  }

  Future<String?> _findFuzzyMatch(SourceTrack track) async {
    final seconds = (track.duration.inMilliseconds / 1000).round();
    final candidates = await (_db.select(_db.tracks)
          ..where((t) => t.titleNorm.equals(normalizeTitle(track.title)))
          ..where(
            (t) =>
                t.durationSec.isBiggerOrEqualValue(seconds - 3) &
                t.durationSec.isSmallerOrEqualValue(seconds + 3),
          ))
        .get();

    for (final candidate in candidates) {
      final asSource = SourceTrack(
        ref: RemoteTrackRef(track.ref.source, candidate.id),
        title: candidate.title,
        artists: await artistNamesOf(candidate.id),
        duration: Duration(seconds: candidate.durationSec),
      );
      if (isFuzzyMatch(track, asSource)) return candidate.id;
    }
    return null;
  }

  Future<void> _touch(String localTrackId, SourceId source) =>
      (_db.update(_db.tracks)..where((t) => t.id.equals(localTrackId))).write(
        TracksCompanion(
          lastSeenAt: Value(DateTime.now()),
          metadataSource: Value(source.wire),
        ),
      );

  Future<void> _attachMapping(SourceTrack track, String localTrackId, MatchTier tier) =>
      _db.into(_db.remoteIdMappings).insertOnConflictUpdate(
        RemoteIdMappingsCompanion.insert(
          source: track.ref.source.wire,
          // Ключ — id в терминах источника: составной `track-album` Яндекс
          // отвергает на download-info, а эндпоинты принимают именно число.
          remoteId: track.ref.remoteId,
          albumRemoteId: Value(track.albumRemoteId ?? track.ref.albumId),
          localTrackId: localTrackId,
          mappingConfidence: Value(switch (tier) {
            MatchTier.none => 'exact',
            _ => tier.name,
          }),
          remoteJson: Value(track.raw == null ? null : jsonEncode(track.raw)),
          firstSeenAt: Value(DateTime.now()),
          lastSeenAt: Value(DateTime.now()),
        ),
      );

  Future<_Artists> _upsertArtists(SourceTrack track) async {
    final source = track.ref.source;
    final ids = <int>[];

    for (var i = 0; i < track.artists.length; i++) {
      final name = track.artists[i];
      final nameNorm = normalizeArtist(name);
      final remoteArtistId = i < track.artistIds.length
          ? track.artistIds[i]
          : null;
      final cover = i < track.artistCovers.length
          ? track.artistCovers[i]
          : null;

      final existing = await (_db.select(_db.artists)
            ..where((t) => t.nameNorm.equals(nameNorm))
            ..limit(1))
          .getSingleOrNull();

      if (existing != null) {
        // У артиста из локального тега удалённого id нет, и на все такие
        // записи он был бы пустой строкой — второй же артист того же
        // источника падал на уникальном индексе artists_by_source.
        // Поэтому без id держим суррогат, а когда id наконец приходит —
        // дописываем его в ту же строку.
        final nextRemote = remoteArtistId != null &&
                existing.remoteArtistId != remoteArtistId
            ? remoteArtistId
            : null;
        final nextCover = existing.coverUrl == null && cover != null
            ? cover
            : null;
        if (nextRemote != null || nextCover != null) {
          await (_db.update(_db.artists)
                ..where((t) => t.id.equals(existing.id)))
              .write(
                ArtistsCompanion(
                  remoteArtistId: nextRemote == null
                      ? const Value.absent()
                      : Value(nextRemote),
                  coverUrl: nextCover == null
                      ? const Value.absent()
                      : Value(nextCover),
                ),
              );
        }
        ids.add(existing.id);
        continue;
      }

      final id = await _db.into(_db.artists).insert(
        ArtistsCompanion.insert(
          name: name,
          nameNorm: nameNorm,
          coverUrl: Value(cover),
          source: source.wire,
          remoteArtistId: remoteArtistId ?? 'name:$nameNorm',
          updatedAt: Value(DateTime.now()),
        ),
      );
      ids.add(id);
    }

    return _Artists(ids, ids.isEmpty ? null : ids.first);
  }

  Future<int?> _upsertAlbum(SourceTrack track) async {
    final title = track.album;
    if (title == null || title.isEmpty) return null;

    final existing = await (_db.select(_db.albums)
          ..where((t) => t.source.equals(track.ref.source.wire))
          ..where(
            (t) => track.albumRemoteId == null
                ? t.title.equals(title)
                : t.remoteAlbumId.equals(track.albumRemoteId!),
          )
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return existing.id;

    return _db.into(_db.albums).insert(
      AlbumsCompanion.insert(
        title: title,
        coverUrl: Value(track.coverUrl),
        source: track.ref.source.wire,
        remoteAlbumId: track.albumRemoteId ?? '',
        artistIdsCsv: Value(track.artistIds.join(',')),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

final class _Artists {
  _Artists(this.ids, this.mainId);

  final List<int> ids;
  final int? mainId;
}
