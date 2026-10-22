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

  @override
  Future<PlaylistSnapshot?> getPlaylist(String remotePlaylistId) async {
    final uid = auth is AuthReady ? (auth as AuthReady).uid : null;
    if (uid == null) return null;

    final result = await _api.get('/users/$uid/playlists', {
      'kinds': remotePlaylistId,
    });
    if (!result.isOk) return null;

    final fetched = result.asList.where(
      (item) => item['kind'].toString() == remotePlaylistId,
    );
    final first = fetched.isEmpty ? null : fetched.first;
    if (first == null) return null;

    final tracks = YandexDto.tracks(first['tracks']);

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
          YandexDto.coverFrom(artist['cover'], size: '600x600') ??
          YandexDto.coverUrl(artist['ogImage'], size: '600x600'),
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
    final result = await _stream.resolve(track.ref.remoteId, source: id);

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
  });

  final String remoteId;
  final String title;
  final String? coverUrl;
  final int? year;
  final int? trackCount;
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
