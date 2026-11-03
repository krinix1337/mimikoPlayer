import 'dart:async';

import '../../core/constants.dart';
import '../../core/identity/normalizer.dart';
import '../../core/logging/app_logger.dart';
import '../../core/sources/music_source.dart';
import '../../core/sources/source_dto.dart';
import '../../core/sources/source_errors.dart';
import '../../core/sources/source_id.dart';
import '../../core/sources/stream_target.dart';
import 'soundcloud_api.dart';
import 'soundcloud_dto.dart';

/// SoundCloud как бесплатный источник без входа.
///
/// Часть треков отдаётся только 30-секундными превью (`SNIP`/`preview`) или
/// зашифрованным HLS — такие помечаются недоступными и не попадают в очередь
/// как полноценные. Полные версии играют прогрессивным MP3 или чистым HLS.
class SoundCloudSource implements MusicSource {
  SoundCloudSource({SoundCloudApi? api}) : _api = api ?? SoundCloudApi();

  final SoundCloudApi _api;

  @override
  SourceId get id => SourceId.soundcloud;

  @override
  SourceCapabilities get capabilities =>
      const SourceCapabilities(canSearch: true, canStream: true);

  @override
  AuthState get auth => const AuthAnonymous();

  @override
  Stream<AuthState> get authChanges => const Stream<AuthState>.empty();

  @override
  Future<void> warmUp() async {
    await _api.ensureClientId();
  }

  /// Открытый плейлист по ссылке: название и строки «Исполнитель — Название».
  /// В ответе /resolve полные данные только у первых треков, остальные
  /// приходят одним id и дочитываются пачками.
  Future<({String title, List<String> rows})?> playlistRows(String url) async {
    final reply = await _api.resolveUrl(url);
    final data = reply.asMap;
    if (data == null || data['tracks'] is! List) return null;
    final raw = [
      for (final item in data['tracks'] as List)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
    final missing = [
      for (final item in raw)
        if (item['title'] == null) '${item['id']}',
    ];
    final full = <String, Map<String, dynamic>>{};
    for (var i = 0; i < missing.length; i += 50) {
      final batch = await _api.tracks(missing.skip(i).take(50).toList());
      if (batch.data is List) {
        for (final item in batch.data! as List) {
          if (item is Map) full['${item['id']}'] = Map.from(item);
        }
      }
    }
    final rows = <String>[];
    for (final item in raw) {
      final track = item['title'] == null ? full['${item['id']}'] : item;
      if (track == null) continue;
      final title = '${track['title'] ?? ''}'.trim();
      final meta = track['publisher_metadata'];
      final artist = meta is Map && '${meta['artist'] ?? ''}'.trim().isNotEmpty
          ? '${meta['artist']}'.trim()
          : '${(track['user'] as Map?)?['username'] ?? ''}'.trim();
      if (title.isEmpty) continue;
      // Заголовок на SoundCloud часто уже «Исполнитель - Трек».
      rows.add(
        RegExp(r'\s[-–—]\s').hasMatch(title) || artist.isEmpty
            ? title
            : '$artist - $title',
      );
    }
    return (title: '${data['title'] ?? ''}'.trim(), rows: rows);
  }

  @override
  Future<SearchResult> search(
    String query, {
    int page = 0,
    int pageSize = 50,
  }) async {
    final needle = query.trim();
    if (needle.isEmpty) return const SearchResult(tracks: [], page: 0);
    try {
      final reply = await _api.search(
        needle,
        limit: pageSize,
        offset: page * pageSize,
      );
      final data = reply.asMap;
      if (data == null) {
        if (reply.failure case final failure?) {
          AppLogger.instance.warn('soundcloud search: ${failure.message}');
        }
        return SearchResult(tracks: const [], page: page);
      }
      final tracks = SoundCloudDto.searchTracks(data);
      final total = data['total_results'];
      return SearchResult(
        tracks: tracks,
        page: page,
        total: total is int ? total : tracks.length,
        hasMore: data['next_href'] != null,
      );
    } on Object catch (error) {
      AppLogger.instance.warn('soundcloud search "$needle": $error');
      return SearchResult(tracks: const [], page: page);
    }
  }

  /// Волна целиком из SoundCloud: от каждого затравочного трека берём
  /// похожие и раскладываем ветки по очереди, чтобы подряд не шёл один
  /// исполнитель. Превью, блок, зашифрованный HLS и короткие отрывки отсеяны.
  Future<List<SourceTrack>> radio({
    required List<String> seedIds,
    int target = 20,
    Set<String> excludeSongs = const {},
  }) async {
    if (seedIds.isEmpty) return const [];
    final branches = await Future.wait([
      for (final seed in seedIds.take(4)) _related(seed),
    ]);
    final seen = <String>{...seedIds};
    // На SoundCloud одну песню перезаливают разные аккаунты: другой id,
    // свой список артистов и пара секунд разницы. Сравниваем по названию
    // и любому из исполнителей — и с тем, что уже стоит в очереди.
    final songs = <String>{...excludeSongs};
    bool isNewSong(SourceTrack track) {
      final keys = songKeys(track.title, track.artists);
      if (keys.any(songs.contains)) return false;
      songs.addAll(keys);
      return true;
    }

    final result = <SourceTrack>[];
    final longest = branches.fold(
      0,
      (max, b) => b.length > max ? b.length : max,
    );
    // Два прохода: сначала только «слушабельные» треки, и лишь если их
    // слишком мало — добираем с мягким порогом прослушиваний.
    for (final minPlays in const [_radioMinPlays, _radioFallbackPlays]) {
      for (var i = 0; i < longest && result.length < target; i++) {
        for (final branch in branches) {
          if (i >= branch.length || result.length >= target) continue;
          final track = branch[i];
          if (!isRadioWorthy(track, minPlays: minPlays)) continue;
          if (seen.contains(track.ref.remoteId)) continue;
          if (!isNewSong(track)) continue;
          seen.add(track.ref.remoteId);
          result.add(track);
        }
      }
      if (result.length >= target ~/ 2) break;
    }
    return result;
  }

  static const _radioMinPlays = 20000;
  static const _radioFallbackPlays = 2000;

  /// Перезаливы с изменённой скоростью, нарезки, миксы и «биты» — то, что в
  /// волне звучит как мусор. Обычные ремиксы оставляем.
  static final _junkTitle = RegExp(
    r'slowed|sped[\s-]?up|speed[\s-]?up|nightcore|reverb|\b8d\b|'
    r'bass\s?boost|type\s?beat|mashup|snippet|preview|\bleak|'
    r'\bdj\s?set\b|\bmix(tape)?\b\s*\d|podcast|episode|'
    r'замедл|ускор|\bремикс\s+by\b',
    caseSensitive: false,
  );

  /// Годится ли трек для волны: играется целиком, длина обычной песни,
  /// заметное число прослушиваний и без признаков мусорного перезалива.
  static bool isRadioWorthy(
    SourceTrack track, {
    int minPlays = _radioMinPlays,
  }) {
    if (!track.available) return false;
    final seconds = track.duration.inSeconds;
    if (seconds < 90 || seconds > 8 * 60) return false;
    if (_junkTitle.hasMatch(track.title)) return false;
    final plays = track.raw?['plays'];
    // Нет счётчика (старый кэш) — не режем, иначе волна пустеет.
    if (plays is num && plays < minPlays) return false;
    return true;
  }

  /// Ключи «название|исполнитель» для отсева перезаливов в [radio].
  static List<String> songKeys(String title, List<String> artists) {
    final normalized = normalizeTitle(title);
    return [
      for (final artist in artists) '$normalized|${normalizeArtist(artist)}',
    ];
  }

  /// Затравка для [radio]: первый играбельный трек по запросу (обычно имя
  /// исполнителя из волны Яндекса — так SoundCloud-волна сохраняет вкус).
  Future<String?> seedFor(String query) async {
    final found = await search(query, pageSize: 10);
    // Затравка задаёт всю ветку рекомендаций: берём популярный трек, а не
    // первый попавшийся перезалив.
    final wanted = normalizeArtist(query);
    bool byArtist(SourceTrack track) =>
        track.artists.any((artist) => normalizeArtist(artist) == wanted);
    for (final pass in const [
      (plays: _radioMinPlays, sameArtist: true),
      (plays: _radioMinPlays, sameArtist: false),
      (plays: 0, sameArtist: false),
    ]) {
      for (final track in found.tracks) {
        if (pass.sameArtist && !byArtist(track)) continue;
        if (isRadioWorthy(track, minPlays: pass.plays)) {
          return track.ref.remoteId;
        }
      }
    }
    return null;
  }

  Future<List<SourceTrack>> _related(String remoteId) async {
    try {
      final reply = await _api.related(remoteId);
      if (reply.failure case final failure?) {
        AppLogger.instance.warn('soundcloud related: ${failure.message}');
      }
      return SoundCloudDto.searchTracks(reply.asMap);
    } on Object catch (error) {
      AppLogger.instance.warn('soundcloud related $remoteId: $error');
      return const [];
    }
  }

  @override
  Future<SourceTrack?> getTrack(RemoteTrackRef ref) async {
    if (ref.source != id) return null;
    final tracks = await getTracksByIds([ref]);
    return tracks.isEmpty ? null : tracks.first;
  }

  @override
  Future<List<SourceTrack>> getTracksByIds(List<RemoteTrackRef> refs) async {
    final wanted = [
      for (final ref in refs)
        if (ref.source == id) ref.remoteId,
    ];
    if (wanted.isEmpty) return const [];
    try {
      final reply = await _api.tracks(wanted);
      final parsed = SoundCloudDto.tracks(reply.data);
      final byId = {for (final track in parsed) track.ref.remoteId: track};
      return [for (final remoteId in wanted) ?byId[remoteId]];
    } on Object catch (error) {
      AppLogger.instance.warn('soundcloud tracks: $error');
      return const [];
    }
  }

  @override
  Future<PlaylistSnapshot?> getPlaylist(String remotePlaylistId) async => null;

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

    try {
      final reply = await _api.track(track.ref.remoteId);
      final json = reply.asMap;
      if (json == null) {
        final failure =
            reply.failure ??
            SourceFailure(source: id, reason: SourceFailReason.unavailable);
        return StreamFailed(failure);
      }

      final parsed = SoundCloudDto.track(json);
      if (parsed == null || !parsed.available) {
        return StreamFailed(
          SourceFailure(
            source: id,
            reason: SourceFailReason.unavailable,
            message: 'трек недоступен на SoundCloud (превью или блок)',
          ),
        );
      }

      final transcoding = SoundCloudDto.pickTranscoding(
        json,
        preferred: preferred,
      );
      if (transcoding == null) {
        return StreamFailed(
          SourceFailure(
            source: id,
            reason: SourceFailReason.unavailable,
            message: 'нет незашифрованной аудиодорожки',
          ),
        );
      }
      final transcodingUrl = transcoding['url'];
      if (transcodingUrl is! String || transcodingUrl.isEmpty) {
        return StreamFailed(
          SourceFailure(
            source: id,
            reason: SourceFailReason.remoteError,
            message: 'транскодинг без URL',
          ),
        );
      }

      final authorization = json['track_authorization'];
      final mediaReply = await _api.resolveMedia(
        transcodingUrl,
        trackAuthorization: authorization is String ? authorization : null,
      );
      final media = mediaReply.asMap;
      final mediaUrl = media?['url'];
      if (mediaUrl is! String || mediaUrl.isEmpty) {
        return StreamFailed(
          mediaReply.failure ??
              SourceFailure(
                source: id,
                reason: SourceFailReason.remoteError,
                message: 'SoundCloud не отдал медиа-URL',
              ),
        );
      }

      final now = DateTime.now();
      final expiresAt =
          SoundCloudDto.expiresAt(mediaUrl) ??
          now.add(const Duration(hours: 1));
      final ttl = expiresAt.difference(now);
      return StreamReady(
        target: StreamUrl(
          url: Uri.parse(mediaUrl),
          expiresAt: expiresAt,
          cacheKey: track.ref.remoteId,
        ),
        source: id,
        quality: preferred,
        codec: SoundCloudDto.codecOf(transcoding),
        bitrateKbps: SoundCloudDto.bitrateOf(transcoding),
        ttlHint: ttl > streamTtlMax ? streamTtlMax : ttl,
      );
    } on Object catch (error) {
      AppLogger.instance.warn(
        'soundcloud stream ${track.ref.remoteId}: $error',
      );
      return StreamFailed(
        SourceFailure(
          source: id,
          reason: SourceFailReason.remoteError,
          message: 'SoundCloud: $error',
        ),
      );
    }
  }

  @override
  Future<void> reportPlaybackEvent(
    SourceTrack track,
    PlaybackEventType type,
    Duration played,
  ) async {}

  @override
  Future<void> dispose() => _api.dispose();
}
