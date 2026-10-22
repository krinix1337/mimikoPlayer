import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../../core/logging/app_logger.dart';
import '../../core/sources/music_source.dart';
import '../../core/sources/source_dto.dart';
import '../../core/sources/source_errors.dart';
import '../../core/sources/source_id.dart';
import '../../core/sources/stream_target.dart';

/// `SearchPage` в youtube_explode не передаёт свои default-заголовки в
/// запрос. На части сетей YouTube отвечает страницей согласия без
/// `ytInitialData`, и поиск падает. Добавляем cookie согласия и нормальный
/// User-Agent на уровне HTTP-клиента — тогда страница сразу отдаёт выдачу.
class _ConsentHttpClient extends yt.YoutubeHttpClient {
  static const _extraHeaders = {
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
    'cookie': 'CONSENT=YES+cb; SOCS=CAI',
    'accept-language': 'en-US,en;q=0.9',
  };

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    for (final entry in _extraHeaders.entries) {
      request.headers.putIfAbsent(entry.key, () => entry.value);
    }
    return super.send(request);
  }
}

/// YouTube как бесплатный резервный источник: поиск без ключа API, метаданные
/// видео и аудиопоток через youtube_explode_dart. Ссылки на поток живут
/// несколько часов и привязаны к запросу, поэтому кэш резолвера ограничен
/// `ttlHint`.
class YoutubeSource implements MusicSource {
  YoutubeSource({yt.YoutubeExplode? client}) {
    _client = client;
  }

  yt.YoutubeExplode? _client;

  static const _streamHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/126.0 Mobile Safari/537.36',
    'Referer': 'https://www.youtube.com/',
  };

  yt.YoutubeExplode get _yt =>
      _client ??= yt.YoutubeExplode(httpClient: _ConsentHttpClient());

  @override
  SourceId get id => SourceId.youtube;

  @override
  SourceCapabilities get capabilities => const SourceCapabilities(
    canSearch: true,
    canStream: true,
  );

  @override
  AuthState get auth => const AuthAnonymous();

  @override
  Stream<AuthState> get authChanges => const Stream<AuthState>.empty();

  @override
  Future<void> warmUp() async => _yt;

  @override
  Future<SearchResult> search(
    String query, {
    int page = 0,
    int pageSize = 50,
  }) async {
    final needle = query.trim();
    if (needle.isEmpty) {
      return const SearchResult(tracks: [], page: 0);
    }

    final videos = await _searchVideos(needle);
    final tracks = <SourceTrack>[
      for (final video in videos)
        if (_isMusicVideo(video)) _trackOf(video),
    ];
    return SearchResult(
      tracks: tracks.take(pageSize).toList(),
      page: page,
      total: tracks.length,
      hasMore: false,
    );
  }

  /// Поиск YouTube иногда падает на разборе служебных секций выдачи.
  /// Пробуем запрос как есть, затем укороченный — без кавычек и скобок.
  Future<List<yt.Video>> _searchVideos(String query) async {
    final attempts = <String>[
      query,
      query.replaceAll(RegExp(r'[«»"“”()\[\].,!?—–-]'), ' ').trim(),
    ];
    Object? lastError;
    for (final attempt in attempts.toSet()) {
      if (attempt.isEmpty) continue;
      try {
        final found = await _yt.search.search(attempt);
        if (found.isNotEmpty) return found;
      } on Object catch (error) {
        lastError = error;
        AppLogger.instance.warn('youtube search "$attempt": $error');
      }
    }
    if (lastError != null) throw lastError;
    return const [];
  }

  static bool _isMusicVideo(yt.Video video) {
    final duration = video.duration;
    if (video.isLive || duration == null) return false;
    return duration >= const Duration(seconds: 20) &&
        duration <= const Duration(hours: 3);
  }

  SourceTrack _trackOf(yt.Video video) => SourceTrack(
    ref: RemoteTrackRef(SourceId.youtube, video.id.value),
    title: video.title,
    artists: [video.author],
    duration: video.duration ?? Duration.zero,
    // Канал YouTube — не артист Яндекса: id канала оставляем в raw, а не в
    // artistIds, иначе карточка артиста открывалась бы с чужим id.
    coverUrl: video.thumbnails.highResUrl,
    available: !video.isLive,
    raw: {
      'videoId': video.id.value,
      'channelId': video.channelId.value,
      'url': video.url,
    },
  );

  @override
  Future<SourceTrack?> getTrack(RemoteTrackRef ref) async {
    final tracks = await getTracksByIds([ref]);
    return tracks.isEmpty ? null : tracks.first;
  }

  @override
  Future<List<SourceTrack>> getTracksByIds(List<RemoteTrackRef> refs) async {
    final result = <SourceTrack>[];
    for (final ref in refs) {
      if (ref.source != SourceId.youtube) continue;
      try {
        final video = await _yt.videos.get(ref.remoteId);
        result.add(_trackOf(video));
      } on Object catch (error) {
        AppLogger.instance.warn('youtube video ${ref.remoteId}: $error');
      }
    }
    return result;
  }

  @override
  Future<PlaylistSnapshot?> getPlaylist(String remotePlaylistId) async => null;

  @override
  Future<StreamResult> resolveStream(
    SourceTrack track, {
    Quality preferred = Quality.auto,
  }) async {
    if (track.ref.source != SourceId.youtube) {
      return StreamFailed(
        SourceFailure(source: id, reason: SourceFailReason.notInCatalog),
      );
    }

    try {
      AppLogger.instance.info('youtube stream ${track.ref.remoteId}');
      final clients = <yt.YoutubeApiClient>[
        yt.YoutubeApiClient.androidSdkless,
        yt.YoutubeApiClient.ios,
        yt.YoutubeApiClient.androidVr,
        yt.YoutubeApiClient.androidMusic,
        yt.YoutubeApiClient.mweb,
        yt.YoutubeApiClient.tv,
      ];
      yt.StreamManifest? manifest;
      Object? lastError;
      for (final client in clients) {
        try {
          // Watch page на мобильных сетях часто отдаёт «video unavailable»;
          // player-API без него оказывается заметно надёжнее.
          manifest = await _yt.videos.streams
              .getManifest(
                track.ref.remoteId,
                ytClients: [client],
                requireWatchPage: false,
              )
              .timeout(const Duration(seconds: 8));
          if (manifest.audioOnly.isNotEmpty) break;
        } on Object catch (error) {
          lastError = error;
        }
      }
      if (manifest == null) {
        throw lastError ?? StateError('YouTube не отдал манифест');
      }
      final all = manifest.audioOnly.toList();
      if (all.isEmpty) {
        return StreamFailed(
          SourceFailure(
            source: id,
            reason: SourceFailReason.unavailable,
            message: 'у видео нет аудиодорожки',
          ),
        );
      }
      all.sort((a, b) => b.bitrate.compareTo(a.bitrate));

      // MP4/AAC понятнее Android-декодеру; Opus берём, только если mp4 нет.
      final preferredContainer = all
          .where((stream) => stream.container == yt.StreamContainer.mp4)
          .toList();
      final pool = preferredContainer.isNotEmpty ? preferredContainer : all;
      final chosen = switch (preferred) {
        Quality.low => pool.last,
        Quality.normal => pool[pool.length ~/ 2],
        Quality.auto || Quality.high || Quality.lossless => pool.first,
      };

      return StreamReady(
        target: StreamUrl(
          url: chosen.url,
          headers: _streamHeaders,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
          cacheKey: track.ref.remoteId,
        ),
        source: id,
        quality: preferred,
        codec: chosen.audioCodec,
        bitrateKbps: chosen.bitrate.kiloBitsPerSecond.round(),
        ttlHint: const Duration(hours: 2),
      );
    } on Object catch (error) {
      AppLogger.instance.warn('youtube stream не получен: $error');
      return StreamFailed(
        SourceFailure(
          source: id,
          reason: SourceFailReason.remoteError,
          message: '$error',
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
  Future<void> dispose() async {
    _client?.close();
    _client = null;
  }
}
