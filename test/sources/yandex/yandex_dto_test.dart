import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/sources/source_id.dart';
import 'package:phoneyandex/sources/yandex/yandex_dto.dart';

/// Срез реального ответа `/search` (зонд 2026-10-21). Тест держит привязку к
/// именам полей Яндекса: они не выводятся из документации, а проверка на
/// устройстве стоит запуска приложения.
const realTrackJson = {
  'id': 1710820,
  'realId': '1710820',
  'title': 'Killer Queen',
  'durationMs': 181020,
  'available': true,
  'availableForPremiumUsers': true,
  'explicit': false,
  'lyricsAvailable': true,
  'coverUri':
      'avatars.yandex.net/get-music-content/117546/c8c68f43.a.5901220-1/%%',
  'artists': [
    {'id': 79215, 'name': 'Queen'},
  ],
  'albums': [
    {
      'id': 5901220,
      'title': 'Greatest Hits',
      'coverUri':
          'avatars.yandex.net/get-music-content/117546/c8c68f43.a.5901220-1/%%',
      'year': 2018,
    },
  ],
};

void main() {
  group('YandexDto.track', () {
    test('собирает SourceTrack из реальных полей', () {
      final track = YandexDto.track(Map<String, dynamic>.from(realTrackJson));

      expect(track.ref.source, SourceId.yandex);
      expect(track.ref.remoteId, '1710820');
      expect(track.ref.albumId, '5901220');
      expect(track.title, 'Killer Queen');
      expect(track.artists, ['Queen']);
      expect(track.artistIds, ['79215']);
      expect(track.album, 'Greatest Hits');
      expect(track.duration, const Duration(milliseconds: 181020));
      expect(track.lyricsAvailable, isTrue);
      expect(track.availableForPremium, isTrue);
      expect(track.available, isTrue);
    });

    test('обложка разворачивается в https-адрес с размером', () {
      final track = YandexDto.track(Map<String, dynamic>.from(realTrackJson));
      expect(
        track.coverUrl,
        'https://avatars.yandex.net/get-music-content/117546/'
        'c8c68f43.a.5901220-1/400x400',
      );
    });

    test('ISRC у Яндекса отсутствует — матчинг идёт по имени и артисту', () {
      final track = YandexDto.track(Map<String, dynamic>.from(realTrackJson));
      expect(track.isrc, isNull);
    });

    test('для запросов к API id остаётся числовым, альбом — отдельно', () {
      final track = YandexDto.track(Map<String, dynamic>.from(realTrackJson));
      expect(track.ref.remoteId, '1710820');
      expect(track.ref.albumId, '5901220');
      expect(track.ref.remoteId, isNot(contains('-')));
    });

    test('трек без альбома и обложки не роняет разбор', () {
      final track = YandexDto.track(const {
        'id': 1,
        'title': 'Без альбома',
        'durationMs': 1000,
        'artists': <Object>[],
      });

      expect(track.albumRemoteId, isNull);
      expect(track.ref.remoteId, '1');
      expect(track.coverUrl, isNull);
      expect(track.artists, isEmpty);
      expect(track.mainArtist, 'unknown');
      // available отсутствует в JSON — считаем доступным, как Яндекс в /search.
      expect(track.available, isTrue);
    });

    test('снятый с публикации трек помечается недоступным', () {
      final json = Map<String, dynamic>.from(realTrackJson)
        ..['available'] = false;
      expect(YandexDto.track(json).available, isFalse);
    });
  });
}
