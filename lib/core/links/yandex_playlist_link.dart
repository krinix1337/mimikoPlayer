/// Ссылка на плейлист Яндекс Музыки, которой с нами поделились.
///
/// Удалённый id нужен в формате `ownerUid:kind` (как его понимает
/// `YandexSource.getPlaylist`); короткие ссылки `/playlists/<kind>` относятся
/// к своему аккаунту и остаются одним `kind`.
final class YandexPlaylistLink {
  const YandexPlaylistLink._(this.remotePlaylistId);

  final String remotePlaylistId;

  static const _hosts = {
    'music.yandex.ru',
    'music.yandex.com',
    'music.yandex.by',
    'music.yandex.kz',
    'music.yandex.uz',
  };

  static final _url = RegExp(r'https?://[^\s<>"]+', caseSensitive: false);
  static const _trailing = ").,;:!?»\"'’";

  /// Ищет первую ссылку на плейлист в произвольном тексте (шаринг часто
  /// добавляет подпись и utm-хвосты).
  static YandexPlaylistLink? tryParse(String text) {
    for (final match in _url.allMatches(text)) {
      var raw = match.group(0)!;
      while (raw.isNotEmpty && _trailing.contains(raw[raw.length - 1])) {
        raw = raw.substring(0, raw.length - 1);
      }
      final uri = Uri.tryParse(raw);
      if (uri == null || !_hosts.contains(uri.host.toLowerCase())) continue;
      final link = fromUri(uri);
      if (link != null) return link;
    }
    return null;
  }

  /// Путь без хоста тоже годится: холодный старт по VIEW Flutter отдаёт как
  /// `/users/<uid>/playlists/<kind>`, без схемы и домена.
  static YandexPlaylistLink? fromUri(Uri uri) {
    final parts = uri.pathSegments.where((part) => part.isNotEmpty).toList();
    if (parts.length >= 4 && parts[0] == 'users' && parts[2] == 'playlists') {
      return YandexPlaylistLink._('${parts[1]}:${parts[3]}');
    }
    if (parts.length >= 2 && parts[0] == 'playlists') {
      return YandexPlaylistLink._(parts[1]);
    }
    return null;
  }
}
