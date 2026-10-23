import 'source_id.dart';

/// Что источник умеет. На основании этого цепочка не трогает каталоги.
final class SourceCapabilities {
  const SourceCapabilities({
    this.canSearch = false,
    this.canStream = false,
    this.canBrowse = false,
    this.canImportPlaylist = false,
    this.canRadio = false,
    this.canReportPlay = false,
    this.canFetchLyrics = false,
    this.requiresAuth = false,
  });

  final bool canSearch;
  final bool canStream;
  final bool canBrowse;
  final bool canImportPlaylist;
  final bool canRadio;
  final bool canReportPlay;
  final bool canFetchLyrics;
  final bool requiresAuth;
}

sealed class AuthState {
  const AuthState();

  /// Источник готов отдавать приватные данные.
  bool get isReady => this is AuthReady;
}

final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

/// Работаем без учётки (например, публичная часть Deezer).
final class AuthAnonymous extends AuthState {
  const AuthAnonymous();
}

final class AuthReady extends AuthState {
  const AuthReady({
    required this.uid,
    required this.login,
    required this.hasPlus,
    required this.accessTokenExpiresAt,
  });

  final String uid;
  final String login;
  final bool hasPlus;
  final DateTime accessTokenExpiresAt;
}

/// Нужен device flow: показать код и подождать подтверждения.
final class AuthNeedsDeviceLogin extends AuthState {
  const AuthNeedsDeviceLogin({this.userCode, this.verificationUrl});

  final String? userCode;
  final String? verificationUrl;
}

final class AuthExpired extends AuthState {
  const AuthExpired();
}

final class AuthFailed extends AuthState {
  const AuthFailed(this.message);

  final String message;
}

/// Трек у конкретного источника ещё до сведения в локальную строку.
final class RemoteTrackRef {
  const RemoteTrackRef(this.source, this.remoteId, {this.albumId});

  final SourceId source;

  /// Идентификатор ровно в терминах источника: Яндекс, например, принимает
  /// только числовой `id`, но не `id-albumId`.
  final String remoteId;
  final String? albumId;
}

final class SourceTrack {
  const SourceTrack({
    required this.ref,
    required this.title,
    required this.artists,
    required this.duration,
    this.artistIds = const [],
    this.artistCovers = const [],
    this.album,
    this.albumRemoteId,
    this.coverUrl,
    this.isrc,
    this.explicitFlag = false,
    this.lyricsAvailable,
    this.available = true,
    this.availableForPremium,
    this.raw,
  });

  final RemoteTrackRef ref;
  final String title;

  /// В порядке значимости; [mainArtist] — первый, если список пуст.
  final List<String> artists;
  final List<String> artistIds;

  /// Обложка каждого артиста в том же порядке, что [artists]; null — источник
  /// её не отдал. Из неё заполняется аватар в коллекции без лишних запросов.
  final List<String?> artistCovers;
  final String? album;
  final String? albumRemoteId;
  final Duration duration;
  final String? coverUrl;

  /// Мост между каталогами: без ISRC этап резервных источников матчит только
  /// по нормализованным имени и артисту.
  final String? isrc;
  final bool explicitFlag;
  final bool? lyricsAvailable;
  final bool available;
  final bool? availableForPremium;

  /// Сырой JSON источника: чтобы добавить поле позже без нового запроса.
  final Map<String, Object?>? raw;

  String get mainArtist => artists.isEmpty ? 'unknown' : artists.first;
}

final class SearchResult {
  const SearchResult({
    required this.tracks,
    required this.page,
    this.total,
    this.hasMore = false,
  });

  final List<SourceTrack> tracks;
  final int page;
  final int? total;
  final bool hasMore;
}

final class PlaylistSnapshot {
  const PlaylistSnapshot({
    required this.remotePlaylistId,
    required this.title,
    required this.tracks,
    this.coverUrl,
    this.description,
    this.total,
    this.partial = false,
  });

  final String remotePlaylistId;
  final String title;
  final String? coverUrl;
  final String? description;
  final List<SourceTrack> tracks;
  final int? total;

  /// Список пришёл не целиком (курсорная пагинация).
  final bool partial;
}

enum PlaybackEventType {
  trackStarted('trackStarted'),
  trackFinished('trackFinished'),
  skip('skip'),
  like('like'),
  dislike('dislike');

  const PlaybackEventType(this.wire);

  final String wire;
}
