import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/links/yandex_playlist_link.dart';

void main() {
  test('ссылка пользователя даёт owner:kind', () {
    final link = YandexPlaylistLink.tryParse(
      'https://music.yandex.ru/users/1874380055/playlists/3?utm_source=share',
    );
    expect(link?.remotePlaylistId, '1874380055:3');
  });

  test('короткая ссылка остаётся одним kind', () {
    final link = YandexPlaylistLink.tryParse(
      'https://music.yandex.ru/playlists/1234-abcd',
    );
    expect(link?.remotePlaylistId, '1234-abcd');
  });

  test('текст с подписью и хвостовой пунктуацией парсится', () {
    final link = YandexPlaylistLink.tryParse(
      'Слушай: https://music.yandex.com/users/42/playlists/7).',
    );
    expect(link?.remotePlaylistId, '42:7');
  });

  test('чужой хост и мусор не считаются ссылкой', () {
    expect(YandexPlaylistLink.tryParse('просто текст'), isNull);
    expect(
      YandexPlaylistLink.tryParse('https://example.com/users/1/playlists/2'),
      isNull,
    );
    expect(
      YandexPlaylistLink.tryParse('https://music.yandex.ru/album/123'),
      isNull,
    );
  });

  test('путь без схемы (холодный старт VIEW) распознаётся', () {
    final link = YandexPlaylistLink.fromUri(
      Uri.parse('/users/1874380055/playlists/3'),
    );
    expect(link?.remotePlaylistId, '1874380055:3');
    final short = YandexPlaylistLink.fromUri(Uri.parse('/playlists/xyz'));
    expect(short?.remotePlaylistId, 'xyz');
  });

  test('из нескольких ссылок берётся плейлист', () {
    final link = YandexPlaylistLink.tryParse(
      'https://example.com/a https://music.yandex.ru/users/9/playlists/2',
    );
    expect(link?.remotePlaylistId, '9:2');
  });
}
