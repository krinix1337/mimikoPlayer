class Routes {
  const Routes._();

  static const home = '/';
  static const discover = '/discover';
  static const search = '/search';
  static const library = '/library';
  static const player = '/player';
  static const settings = '/settings';
  static const logs = '/logs';
  static const karaoke = '/karaoke';
  static const artist = '/artist';
  static const artistTracks = '/artist-tracks';
  static const artistAlbums = '/artist-albums';
  static const album = '/album';
  static const chart = '/chart';
  static const newReleases = '/new-releases';

  static String artistFor(String id) => '$artist?id=${Uri.encodeComponent(id)}';

  static String artistTracksFor(String id) =>
      '$artistTracks?id=${Uri.encodeComponent(id)}';

  static String artistAlbumsFor(String id) =>
      '$artistAlbums?id=${Uri.encodeComponent(id)}';

  static String albumFor(String id) => '$album?id=${Uri.encodeComponent(id)}';

  static String karaokeFor(String trackId) =>
      '$karaoke?track=${Uri.encodeComponent(trackId)}';

  // Дочерние пути живут под /library — так они вложены в роутере.
  static const collectionLiked = '/library/liked';
  static const collectionDisliked = '/library/disliked';
  static const collectionFiles = '/library/files';
  static const collectionRecent = '/library/recent';
  static const collectionDownloaded = '/library/downloaded';
  static const collectionPlaylists = '/library/playlists';

  /// `/library/playlists/yandex%3A123456` — id плейлиста внутри пути.
  static const playlistPrefix = '/library/playlists';
  static String playlist(String id) =>
      '$playlistPrefix/${Uri.encodeComponent(id)}';
}
