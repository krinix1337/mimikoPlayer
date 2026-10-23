import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/sources/source_id.dart';
import 'package:phoneyandex/sources/yandex/yandex_dto.dart';
import 'package:phoneyandex/sources/yandex/yandex_source.dart';

Map<String, dynamic> _chartItem(int position, int id) => {
  'chart': {'position': position},
  'track': {
    'id': id,
    'title': 'Трек $id',
    'durationMs': 180000,
    'artists': [
      {'id': 900 + id, 'name': 'Артист $id'},
    ],
    'albums': [
      {
        'id': 500 + id,
        'title': 'Альбом',
        'coverUri': 'avatars.yandex.net/x/%%',
      },
    ],
    'coverUri': 'avatars.yandex.net/x/%%',
  },
};

void main() {
  test('полный чарт разбирает все 100 позиций', () {
    final result = {
      'chart': {
        'tracks': [for (var i = 1; i <= 100; i++) _chartItem(i, 1000 + i)],
      },
    };

    final entries = YandexSource.parseChart(result);
    expect(entries, hasLength(100));
    expect(entries.first.position, 1);
    expect(entries.last.position, 100);
    expect(entries.first.track.ref.source, SourceId.yandex);
    expect(entries.first.track.ref.remoteId, '1001');
    expect(entries.first.track.title, 'Трек 1001');
  });

  test('битые элементы чарта не роняют разбор', () {
    final entries = YandexSource.parseChart({
      'chart': {
        'tracks': [
          {
            'chart': {'position': 1},
          },
          'мусор',
          _chartItem(2, 7),
        ],
      },
    });
    expect(entries, hasLength(1));
    expect(entries.single.position, 2);
  });

  test('обложка из uri и сломанной обложки', () {
    expect(
      YandexDto.coverFrom({'uri': 'avatars.yandex.net/get-music-content/1/%%'}),
      'https://avatars.yandex.net/get-music-content/1/400x400',
    );
    expect(YandexDto.coverFrom({'error': "cover doesn't exist"}), isNull);
    expect(YandexDto.coverFrom(null), isNull);
    expect(
      YandexDto.coverFrom({
        'uri': 'avatars.yandex.net/get-music-content/1/%%',
      }, size: '600x600'),
      'https://avatars.yandex.net/get-music-content/1/600x600',
    );
  });
}
