import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/sources/lyrics/lrclib.dart';

void main() {
  test('LRC: метки времени и текст строки', () {
    final lyrics = LrcLib.parse({
      'syncedLyrics': '''
[00:12.30]Первая строка
[00:16.80]Вторая строка
[01:02.50]Припев''',
      'plainLyrics': 'Первая строка\nВторая строка\nПрипев',
    });

    expect(lyrics.synced, isTrue);
    expect(lyrics.lines.length, 3);
    expect(
      lyrics.lines.first.start,
      const Duration(seconds: 12, milliseconds: 300),
    );
    expect(
      lyrics.lines[1].start,
      const Duration(seconds: 16, milliseconds: 800),
    );
    expect(lyrics.lines.last.text, 'Припев');
  });

  test('LRC: конец строки = начало следующей, у последней — запас', () {
    final lyrics = LrcLib.parse({
      'syncedLyrics': '[00:10.00]раз\n[00:14.00]два',
    });

    expect(lyrics.lines.first.end, const Duration(seconds: 14));
    expect(
      lyrics.lines.last.end - lyrics.lines.last.start,
      const Duration(seconds: 6),
    );
  });

  test(
    'LRC: несколько меток на одной строке дают отдельную строку на каждую',
    () {
      final lyrics = LrcLib.parse({
        'syncedLyrics': '[00:10.00][00:40.00]повтор припева',
      });

      expect(lyrics.lines.length, 2);
      expect(lyrics.lines.first.start, const Duration(seconds: 10));
      expect(lyrics.lines.last.start, const Duration(seconds: 40));
      expect(
        lyrics.lines.every((line) => line.text == 'повтор припева'),
        isTrue,
      );
    },
  );

  test('активная строка и прогресс внутри неё', () {
    final lyrics = LrcLib.parse({
      'syncedLyrics': '[00:10.00]раз\n[00:20.00]два',
    });

    expect(lyrics.lineAt(const Duration(seconds: 5)), 0);
    expect(lyrics.lineAt(const Duration(seconds: 11)), 0);
    expect(lyrics.lineAt(const Duration(seconds: 25)), 1);
    expect(lyrics.lines.first.progressAt(const Duration(seconds: 15)), 0.5);
    expect(lyrics.lines.first.progressAt(const Duration(seconds: 9)), 0);
  });

  test(
    'без таймкодов остаётся обычный текст, и он не считается синхронным',
    () {
      final lyrics = LrcLib.parse({
        'plainLyrics': 'просто\nтекст\nбез времени',
      });

      expect(lyrics.synced, isFalse);
      expect(lyrics.lines.length, 3);
      expect(lyrics.lineAt(Duration.zero), -1);
    },
  );

  test('пустой ответ — пустой результат, а не исключение', () {
    expect(LrcLib.parse(null).isEmpty, isTrue);
    expect(LrcLib.parse({'syncedLyrics': '   '}).isEmpty, isTrue);
  });
}
