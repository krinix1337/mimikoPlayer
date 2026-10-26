import 'dart:async';

import '../../core/constants.dart';
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
