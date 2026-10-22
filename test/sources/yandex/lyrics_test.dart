import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/sources/yandex/yandex_source.dart';

void main() {
  test('supplement-текст разбирается в обычные строки', () {
    final lyrics = YandexSource.parseSupplement({
      'lyrics': {'fullLyrics': 'Первая строка\nВторая строка'},
    });
    expect(lyrics, isNotNull);
    expect(lyrics!.synced, isFalse);
    expect(lyrics.plain, 'Первая строка\nВторая строка');
    expect(lyrics.lines, hasLength(2));
  });

  test('пустой supplement не считается текстом', () {
    expect(YandexSource.parseSupplement(null), isNull);
    expect(YandexSource.parseSupplement({'lyrics': null}), isNull);
    expect(
      YandexSource.parseSupplement({
        'lyrics': {'fullLyrics': '  '},
      }),
      isNull,
    );
  });
}
