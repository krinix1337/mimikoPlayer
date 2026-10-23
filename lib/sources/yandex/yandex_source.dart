import 'dart:async';

import '../../core/content/censor_base.dart';
import '../../core/sources/music_source.dart';
import '../../core/sources/source_dto.dart';
import '../../core/sources/source_errors.dart';
import '../../core/sources/source_id.dart';
import '../../core/logging/app_logger.dart';
import '../../core/sources/stream_target.dart';
import '../lyrics/lrclib.dart';
import 'yandex_api.dart';
import 'yandex_auth.dart';
import 'yandex_dto.dart';
import 'yandex_station.dart';
import 'yandex_stream.dart';

/// Я.Музыка как источник: поиск, метаданные, поток, лайки, плейлисты, волна.
class YandexSource implements MusicSource {
  YandexSource({YandexApi? api}) : _api = api ?? YandexApi();

  final YandexApi _api;
  late final YandexStream _stream = YandexStream(_api);
  late final YandexStation station = YandexStation(_api);
  YandexAuth? _auth;

  final StreamController<AuthState> _authChanges =
      StreamController<AuthState>.broadcast();

  @override
  SourceId get id => SourceId.yandex;

  @override
  SourceCapabilities get capabilities => const SourceCapabilities(
    canSearch: true,
    canStream: true,
    canBrowse: true,
    canImportPlaylist: true,
    canRadio: true,
    canReportPlay: true,
    requiresAuth: true,
  );

  @override
  AuthState get auth => _auth?.state ?? const AuthNeedsDeviceLogin();

  @override
  Stream<AuthState> get authChanges => _authChanges.stream;

  /// Позволяет источнику переживать переподключение авторизации: auth
  /// приходит извне (он же нужен экрану входа).
  void attachAuth(YandexAuth auth) {
    _auth = auth;
    auth.changes.listen((state) {
      if (!_authChanges.isClosed) _authChanges.add(state);
    });
  }

  @override
  Future<void> warmUp() => _auth?.ensureValid() ?? Future<void>.value();

  /// Экран входа работает через источник, а не через auth напрямую: источник
  /// знает, что авторизация у него обязательна.
  Future<DeviceLogin> requestDeviceLogin() async =>
      _requireAuth().startDeviceLogin();

  Future<bool> completeDeviceLogin(DeviceLogin login) =>
      _requireAuth().completeDeviceLogin(login);

  Future<void> signOut() => _requireAuth().logout();

  YandexAuth _requireAuth() =>
      _auth ?? (throw StateError('YandexSource без YandexAuth'));

  @override
  Future<SearchResult> search(
    String query, {
    int page = 0,
    int pageSize = 50,
  }) async {
    final result = await _api.get('/search', {
      'text': query,
      'type': 'track',
      'page': '$page',
      'page-size': '$pageSize',
    });
    if (!result.isOk) {
      throw result.failure!;
    }

    // Страница поиска лежит в `results`, а не в `items` (проверено живым
    // запросом; донорский клиент читал `items` и потому видел пустой поиск).
    final paging = result.asMap?['tracks'];
    final items = paging is Map ? paging['results'] : null;
    final tracks = YandexDto.tracks(items is List ? items : const []);
    final total = paging is Map ? (paging['total'] as num?)?.toInt() : null;

    return SearchResult(
      tracks: tracks,
      page: page,
      total: total,
      hasMore: total == null
          ? tracks.length >= pageSize
          : (page + 1) * pageSize < total,
    );
  }

  @override
  Future<SourceTrack?> getTrack(RemoteTrackRef ref) async {
    final tracks = await getTracksByIds([ref]);
    return tracks.isEmpty ? null : tracks.first;
  }

  @override
  Future<List<SourceTrack>> getTracksByIds(List<RemoteTrackRef> refs) async {
    if (refs.isEmpty) return const [];
    // Яндекс не принимает композитные id вида `track-album`: только числа.
    final ids = refs.map((ref) => ref.remoteId).join(',');
    final result = await _api.get('/tracks', {'track-ids': ids});
    if (!result.isOk) return const [];
    return YandexDto.tracks(result.data);
  }

  /// Лайки аккаунта: эндпоинт отдаёт только пары id/albumId, поэтому
  /// метаданные добираются через [getTracksByIds].
  ///
  /// `limit: null` — сколько отдал Я.Музыка: страница `/likes/tracks`
  /// не пагинируется и приносит всю коллекцию целиком (на аккаунте
  /// владельца это 1028 пары), поэтому резать её по умолчанию нельзя.
  /// Сколько лайков пришло в последнем ответе: сравнение с числом
  /// разрезолвленных показывает, потерялись ли треки в пачках.
  int lastLikesExpected = 0;

  Future<List<LikedTrack>> likedTracks({int? limit}) async {
    final uid = auth is AuthReady ? (auth as AuthReady).uid : null;
    if (uid == null) return const [];

    final result = await _api.get('/users/$uid/likes/tracks');
    final library = result.asMap?['library'];
    final pairs = library is Map ? library['tracks'] : null;
    if (pairs is! List) return const [];

    final entries = <(RemoteTrackRef, DateTime?)>[
      for (final pair in (limit == null ? pairs : pairs.take(limit)))
        if (pair is Map)
          (
            RemoteTrackRef(
              SourceId.yandex,
              '${pair['id']}',
              albumId: pair['albumId'] == null ? null : '${pair['albumId']}',
            ),
            DateTime.tryParse('${pair['timestamp']}'),
          ),
    ];

    // Пакет режем: слишком длинный query Яндекс тоже не любит. Дату лайка
    // приклеиваем к треку по remoteId после пакетной загрузки.
    final byId = <String, DateTime?>{};
    final refs = <RemoteTrackRef>[];
    for (final (ref, at) in entries) {
      byId[ref.remoteId] = at;
      refs.add(ref);
    }

    lastLikesExpected = refs.length;
    final liked = <LikedTrack>[];
    for (var i = 0; i < refs.length; i += 50) {
      final batch = await getTracksByIds(
        refs.sublist(i, (i + 50).clamp(0, refs.length)),
      );
      for (final track in batch) {
        liked.add(LikedTrack(track, likedAt: byId[track.ref.remoteId]));
      }
    }
    return liked;
  }

  Future<List<PlaylistSummary>> playlists() async {
    final uid = auth is AuthReady ? (auth as AuthReady).uid : null;
    if (uid == null) return const [];

    final result = await _api.get('/users/$uid/playlists/list');
    if (!result.isOk) return const [];

    return [
      for (final playlist in result.asList)
        PlaylistSummary(
          remotePlaylistId: '${playlist['kind']}',
          title: '${playlist['title'] ?? 'Без названия'}',
          trackCount: (playlist['trackCount'] as num?)?.toInt(),
          coverUrl:
              YandexDto.coverFrom(playlist['cover']) ??
              YandexDto.coverUrl(playlist['coverUri']),
          isSystem: playlist['type'] != null && '${playlist['type']}' != 'user',
        ),
    ];
  }

  /// Плейлисты, которые пользователь лайкнул у других авторов.
  Future<List<PlaylistSummary>> likedPlaylists() async {
    final uid = auth is AuthReady ? (auth as AuthReady).uid : null;
    if (uid == null) return const [];
    final result = await _api.get('/users/$uid/likes/playlists');
    if (!result.isOk) return const [];
    final out = <PlaylistSummary>[];
    for (final item in result.asList) {
      final playlist = item['playlist'];
      if (playlist is! Map) continue;
      final owner = (playlist['owner'] as Map?)?['uid'];
      final kind = playlist['kind'];
      if (owner == null || kind == null) continue;
      out.add(
        PlaylistSummary(
          remotePlaylistId: '$owner:$kind',
          title: (playlist['title'] ?? 'Плейлист').toString(),
          trackCount: (playlist['trackCount'] as num?)?.toInt(),
          coverUrl:
              YandexDto.coverFrom(playlist['cover']) ??
              YandexDto.coverUrl(playlist['coverUri']),
          isSystem: true,
        ),
      );
    }
    return out;
  }

  @override
  Future<PlaylistSnapshot?> getPlaylist(String remotePlaylistId) async {
    final uid = auth is AuthReady ? (auth as AuthReady).uid : null;
    if (uid == null) return null;

    // Понравившийся чужой плейлист приходит как «ownerUid:kind»: запрашивать
    // его надо у владельца, а не у себя.
    final parts = remotePlaylistId.split(':');
    final owner = parts.length == 2 ? parts.first : uid;
    final kind = parts.length == 2 ? parts.last : remotePlaylistId;
    final result = await _api.get('/users/$owner/playlists', {'kinds': kind});
    if (!result.isOk) return null;

    final fetched = result.asList.where(
      (item) => item['kind'].toString() == kind,
    );
    final first = fetched.isEmpty ? null : fetched.first;
    if (first == null) return null;

    // `/playlists` отдаёт только короткие ссылки `{id, albumId}` — без
    // названий, артистов и длительности. Если скормить их ingest напрямую,
    // у всех треков оказывается один и тот же пустой отпечаток, и плейлист
    // схлопывается в одну случайную песню. Поэтому добираем полные объекты.
    final refs = playlistTrackRefs(first['tracks']);
    final tracks = await _resolvePlaylistTracks(refs);
    // Частично разрешённый плейлист не импортируем: импорт заменяет связи
    // целиком, и обрезанный список стёр бы то, что уже есть.
    if (tracks == null) return null;

    return PlaylistSnapshot(
      remotePlaylistId: remotePlaylistId,
      title: '${first['title'] ?? 'Плейлист'}',
      description: first['description']?.toString(),
      // У пользовательских плейлистов обложки часто нет вовсе — Яндекс
      // рисует мозаику на клиенте. Берём обложку первого трека: карточка
      // перестаёт быть серым квадратом и после импорта не зависит от сети.
      coverUrl:
          YandexDto.coverFrom(first['cover']) ??
          YandexDto.coverUrl(first['coverUri']) ??
          (tracks.isEmpty ? null : tracks.first.coverUrl),
      total: (first['trackCount'] as num?)?.toInt(),
      tracks: tracks,
    );
  }

  /// Короткие ссылки из ответа `/playlists`: `{timestamp, id, albumId}`.
  static List<RemoteTrackRef> playlistTrackRefs(Object? value) => [
    for (final item in (value is List ? value : const <Object>[]))
      if (item is Map && item['id'] != null)
        RemoteTrackRef(
          SourceId.yandex,
          '${item['id']}',
          albumId: item['albumId'] == null ? null : '${item['albumId']}',
        ),
  ];

  /// Восстанавливает порядок и повторы плейлиста по загруженным трекам:
  /// батч `/tracks` дедуплицирует ответ, а плейлист — нет.
  static List<SourceTrack> orderPlaylistTracks(
    List<RemoteTrackRef> refs,
    Iterable<SourceTrack> full,
  ) {
    final byRemote = {for (final track in full) track.ref.remoteId: track};
    return [for (final ref in refs) ?byRemote[ref.remoteId]];
  }

  Future<List<SourceTrack>?> _resolvePlaylistTracks(
    List<RemoteTrackRef> refs,
  ) async {
    if (refs.isEmpty) return const [];
    // Тот же размер пачки, что у лайков: длинный query Яндекс не любит.
    final batches = <List<RemoteTrackRef>>[
      for (var i = 0; i < refs.length; i += 50)
        refs.sublist(i, (i + 50).clamp(0, refs.length)),
    ];
    final full = <SourceTrack>[];
    // Пачки идут последовательно: залп из десятка запросов Яндекс режет,
    // и тогда часть плейлистов молча не импортируется. Одну неудачную
    // пачку повторяем, прежде чем отдать null.
    for (final batch in batches) {
      var part = await _fetchTrackBatch(batch);
      part ??= await _fetchTrackBatch(batch);
      if (part == null) {
        AppLogger.instance.warn('плейлист: полные треки не загрузились');
        return null;
      }
      full.addAll(part);
    }
    final ordered = orderPlaylistTracks(refs, full);
    if (ordered.length != refs.length) {
      AppLogger.instance.warn(
        'плейлист: разрешилось ${ordered.length} из ${refs.length} треков',
      );
      return null;
    }
    return ordered;
  }

  Future<List<SourceTrack>?> _fetchTrackBatch(
    List<RemoteTrackRef> batch,
  ) async {
    final result = await _api.get('/tracks', {
      'track-ids': [for (final ref in batch) ref.remoteId].join(','),
    });
    if (!result.isOk) return null;
    return YandexDto.tracks(result.data);
  }

  /// Карточка исполнителя: фото, счётчики, популярные треки и альбомы
  /// приходят одним запросом `brief-info`.
  Future<ArtistBrief?> artist(String artistId) async {
    final result = await _api.get('/artists/$artistId/brief-info');
    if (!result.isOk) return null;
    final data = result.asMap;
    if (data == null) return null;

    final artist = data['artist'];
    if (artist is! Map) return null;
    final counts = artist['counts'];

    return ArtistBrief(
      remoteId: artistId,
      name: '${artist['name'] ?? ''}',
      coverUrl:
          YandexDto.coverFrom(artist['cover'], size: '1000x1000') ??
          YandexDto.coverUrl(artist['ogImage'], size: '1000x1000'),
      trackCount: counts is Map ? (counts['tracks'] as num?)?.toInt() : null,
      albumCount: counts is Map
          ? (counts['directAlbums'] as num?)?.toInt()
          : null,
      listeners: (data['stats'] as Map?)?['lastMonthListeners'] as num?,
      popular: YandexDto.tracks(data['popularTracks']),
      albums: [
        for (final item in (data['albums'] as List? ?? const []))
          if (item is Map)
            AlbumBrief(
              remoteId: '${item['id']}',
              title: '${item['title'] ?? ''}',
              coverUrl:
                  YandexDto.coverFrom(item['cover']) ??
                  YandexDto.coverUrl(item['coverUri']),
              year: (item['year'] as num?)?.toInt(),
              trackCount: (item['trackCount'] as num?)?.toInt(),
            ),
      ],
    );
  }

  /// Полный список треков артиста, а не только популярная пятёрка из
  /// `brief-info`. Яндекс отдаёт его постранично.
  Future<List<SourceTrack>> artistTracks(
    String artistId, {
    int page = 0,
    int pageSize = 100,
  }) async {
    final result = await _api.get('/artists/$artistId/tracks', {
      'page': page,
      'page-size': pageSize,
    });
    if (!result.isOk) return const [];
    return YandexDto.tracks(result.asMap?['tracks']);
  }

  /// Полная дискография артиста. В `brief-info` приходит только несколько
  /// альбомов, а здесь — все прямые альбомы.
  Future<List<AlbumBrief>> artistAlbums(
    String artistId, {
    int page = 0,
    int pageSize = 100,
  }) async {
    final result = await _api.get('/artists/$artistId/direct-albums', {
      'page': page,
      'page-size': pageSize,
    });
    if (!result.isOk) return const [];
    final items = result.asMap?['albums'];
    return [
      for (final item in (items as List? ?? const []))
        if (item is Map)
          AlbumBrief(
            remoteId: '${item['id']}',
            title: '${item['title'] ?? ''}',
            coverUrl:
                YandexDto.coverFrom(item['cover']) ??
                YandexDto.coverUrl(item['coverUri']),
            year: (item['year'] as num?)?.toInt(),
            trackCount: (item['trackCount'] as num?)?.toInt(),
          ),
    ];
  }

  /// Чарт Яндекса: позиция + трек. Полный чарт (100 позиций) отдаёт
  /// `/landing3/chart/russia`; блок `landing3?blocks=chart` — только топ-10.
  Future<List<ChartEntry>> chart() async {
    final result = await _api.get('/landing3/chart/russia');
    if (!result.isOk) return const [];
    return parseChart(result.asMap);
  }

  /// Разбор ответа чарта отдельно от сети: структура вложенная, и её проще
  /// держать под тестом, чем ловить регрессию на живом аккаунте.
  static List<ChartEntry> parseChart(Map<String, dynamic>? result) {
    final chart = result?['chart'];
    final items = chart is Map ? chart['tracks'] : null;
    if (items is! List) return const [];

    final entries = <ChartEntry>[];
    for (final item in items) {
      if (item is! Map || item['track'] is! Map) continue;
      entries.add(
        ChartEntry(
          position:
              ((item['chart'] as Map?)?['position'] as num?)?.toInt() ??
              entries.length + 1,
          track: YandexDto.track(
            Map<String, dynamic>.from(item['track'] as Map),
          ),
        ),
      );
    }
    return entries;
  }

  /// Обычный текст из supplement-ответа (без таймкодов).
  Future<Lyrics?> lyrics(String trackId) async {
    if (!_hasAuth) return null;
    final result = await _api.supplement(trackId);
    if (!result.isOk) return null;
    final parsed = parseSupplement(result.data);
    if (parsed != null) {
      AppLogger.instance.info('текст: yandex supplement $trackId');
    }
    return parsed;
  }

  static Lyrics? parseSupplement(Object? data) {
    if (data is! Map) return null;
    final lyrics = data['lyrics'];
    final text = switch (lyrics) {
      Map() =>
        (lyrics['fullLyrics'] ?? lyrics['lyrics'] ?? lyrics['text'])
            ?.toString(),
      String() => lyrics,
      _ => null,
    };
    if (text == null || text.trim().isEmpty) return null;
    return Lyrics.fromPlain(text);
  }

  /// Новинки лендинга Яндекса. Лендинг отдаёт только id — детали добираем
  /// одним пакетным запросом, чтобы не дёргать альбомы по одному.
  Future<List<AlbumBrief>> newReleases({int limit = 10}) async {
    final landing = await _api.get('/landing3/new-releases');
    if (!landing.isOk) return const [];
    final raw = landing.asMap?['newReleases'];
    if (raw is! List) return const [];
    final ids = [
      for (final item in raw.take(limit))
        if (item != null) '$item',
    ];
    if (ids.isEmpty) return const [];

    final albums = await _api.get('/albums', {'album-ids': ids.join(',')});
    if (!albums.isOk) return const [];
    return [
      for (final item in albums.asList)
        AlbumBrief(
          remoteId: '${item['id'] ?? ''}',
          title: '${item['title'] ?? ''}',
          artists: [
            for (final artist in (item['artists'] as List? ?? const []))
              if (artist is Map) '${artist['name'] ?? ''}',
          ],
          artistIds: [
            for (final artist in (item['artists'] as List? ?? const []))
              if (artist is Map) '${artist['id'] ?? ''}',
          ],
          coverUrl:
              YandexDto.coverFrom(item['cover'], size: '400x400') ??
              YandexDto.coverUrl(item['coverUri'], size: '400x400'),
          year: (item['year'] as num?)?.toInt(),
          trackCount: (item['trackCount'] as num?)?.toInt(),
        ),
    ];
  }

  /// Альбом целиком: метаданные и треки в порядке диска.
  Future<AlbumSnapshot?> album(String albumId) async {
    final result = await _api.get('/albums/$albumId/with-tracks');
    if (!result.isOk) return null;
    final data = result.asMap;
    if (data == null) return null;

    return AlbumSnapshot(
      remoteId: albumId,
      title: '${data['title'] ?? ''}',
      coverUrl:
          YandexDto.coverFrom(data['cover'], size: '800x800') ??
          YandexDto.coverUrl(data['coverUri'], size: '800x800'),
      year: (data['year'] as num?)?.toInt(),
      artists: [
        for (final item in (data['artists'] as List? ?? const []))
          if (item is Map) '${item['name'] ?? ''}',
      ],
      tracks: YandexDto.tracks(
        data['volumes'] is List
            ? [
                for (final volume in data['volumes'] as List)
                  if (volume is List) ...volume,
              ]
            : data['tracks'],
      ),
    );
  }

  @override
  Future<StreamResult> resolveStream(
    SourceTrack track, {
    Quality preferred = Quality.auto,
  }) async {
    if (track.ref.source != id) {
      return StreamFailed(
        SourceFailure(source: id, reason: SourceFailReason.notInCatalog),
      );
    }
    if (!track.available) {
      return StreamFailed(
        SourceFailure(
          source: id,
          reason: SourceFailReason.unavailable,
          message: 'трек снят с публикации',
        ),
      );
    }

    // База FckCensorData: незацензуренная версия важнее того, что отдаёт
    // Яндекс, и не требует его токена. Проверка ссылки кэшируется.
    if (CensorBase.instance.enabled) {
      final replacement = await CensorBase.instance.replacementFor(
        track.ref.remoteId,
      );
      if (replacement != null) {
        return StreamReady(
          target: StreamUrl(
            url: Uri.parse(replacement),
            expiresAt: DateTime.now().add(const Duration(days: 3650)),
            cacheKey: track.ref.remoteId,
          ),
          source: id,
          quality: preferred,
          codec: 'mp3',
          ttlHint: const Duration(days: 3650),
        );
      }
    }

    if (!_hasAuth) {
      return StreamFailed(
        SourceFailure(source: id, reason: SourceFailReason.authRequired),
      );
    }

    await warmUp();
    final result = await _stream.resolve(
      track.ref.remoteId,
      source: id,
      preferred: preferred,
    );

    // 403 с пометкой not-allowed у Я.Музыки означает «нужен Плюс», а не «нет
    // доступа к аккаунту».
    if (result case StreamFailed(:final failure)
        when failure.reason == SourceFailReason.geoBlocked &&
            failure.message != null) {
      if (failure.message!.contains('not-allowed')) {
        return StreamFailed(
          SourceFailure(
            source: id,
            reason: SourceFailReason.needsPlus,
            httpStatus: failure.httpStatus,
          ),
        );
      }
    }
    return result;
  }

  @override
  Future<void> reportPlaybackEvent(
    SourceTrack track,
    PlaybackEventType type,
    Duration played,
  ) async {
    final result = await station.feedback(
      trackId: track.ref.remoteId,
      type: type,
      played: played,
    );
    if (!result.isOk) {
      // Без этого «Моя волна» молча перестаёт учиться, а воспроизведение
      // продолжает работать и ничего не показывает.
      AppLogger.instance.warn(
        'rotor feedback ${type.wire} не принят: ${result.failure?.reason.name} '
        'http=${result.failure?.httpStatus}',
      );
    }
  }

  @override
  Future<void> dispose() async {
    await _authChanges.close();
  }

  /// Тoken живёт в api; auth нужен, чтобы его продлить. Без auth источник
  /// всё равно может отдавать поток валидным токеном.
  bool get _hasAuth => _api.hasToken || (_auth?.hasUsableToken ?? false);
}

final class PlaylistSummary {
  const PlaylistSummary({
    required this.remotePlaylistId,
    required this.title,
    this.trackCount,
    this.coverUrl,
    this.isSystem = false,
  });

  final String remotePlaylistId;
  final String title;
  final int? trackCount;
  final String? coverUrl;
  final bool isSystem;
}

/// Трек из лайков вместе с настоящей датой лайка: порядок коллекции должен
/// совпадать с Яндексом, а не с временем импорта.
final class LikedTrack {
  const LikedTrack(this.track, {this.likedAt});

  final SourceTrack track;
  final DateTime? likedAt;
}

final class ArtistBrief {
  const ArtistBrief({
    required this.remoteId,
    required this.name,
    required this.popular,
    required this.albums,
    this.coverUrl,
    this.trackCount,
    this.albumCount,
    this.listeners,
  });

  final String remoteId;
  final String name;
  final String? coverUrl;
  final int? trackCount;
  final int? albumCount;
  final num? listeners;
  final List<SourceTrack> popular;
  final List<AlbumBrief> albums;
}

final class AlbumBrief {
  const AlbumBrief({
    required this.remoteId,
    required this.title,
    this.coverUrl,
    this.year,
    this.trackCount,
    this.artists = const [],
    this.artistIds = const [],
  });

  final String remoteId;
  final String title;
  final String? coverUrl;
  final int? year;
  final int? trackCount;
  final List<String> artists;
  final List<String> artistIds;
}

final class AlbumSnapshot {
  const AlbumSnapshot({
    required this.remoteId,
    required this.title,
    required this.artists,
    required this.tracks,
    this.coverUrl,
    this.year,
  });

  final String remoteId;
  final String title;
  final String? coverUrl;
  final int? year;
  final List<String> artists;
  final List<SourceTrack> tracks;
}

final class ChartEntry {
  const ChartEntry({required this.position, required this.track});

  final int position;
  final SourceTrack track;
}
