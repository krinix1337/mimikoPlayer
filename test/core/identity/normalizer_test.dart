import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/identity/normalizer.dart';

/// Правила нормализации заморожены: отпечаток трека хранится в БД, и любая
/// правка здесь = миграция данных. Тесты golden — они и есть спека.
void main() {
  group('normalizeTitle', () {
    test('снимает ремарки в скобках', () {
      expect(
        normalizeTitle('Bohemian Rhapsody (Remastered 2011)'),
        'bohemian rhapsody',
      );
      expect(
        normalizeTitle('Smoke on the Water [Official Video]'),
        'smoke on the water',
      );
    });

    test('снимает feat и хвост после дефиса', () {
      expect(
        normalizeTitle('Тело (feat. Miyagi)'),
        'тело',
      );
      expect(
        normalizeTitle('Sunflower ft. Joy\n'),
        'sunflower joy',
      );
      expect(
        normalizeTitle('Intro - Official Audio'),
        'intro',
      );
    });

    test('кириллица не транслитерируется', () {
      expect(normalizeTitle('Группа Крой'), 'группа крой');
      expect(normalizeTitle('Ёлка — Городские цветы'), 'ёлка городские цветы');
    });

    test('диакритика латиницы сводится к базе, апостроф становится разделителем', () {
      expect(normalizeTitle('Björk'), 'bjork');
      expect(normalizeTitle('L’Amour'), 'l amour');
      expect(normalizeTitle("L'Amour"), 'l amour');
    });

    test('& читается как and, × как x', () {
      expect(normalizeTitle('Jay-Z & Kanye West'), 'jay z and kanye west');
      expect(normalizeTitle('Kursk × 3'), 'kursk x 3');
    });

    test('пунктуация и повторные пробелы схлопываются', () {
      expect(
        normalizeTitle('  All..Star__2020!!  '),
        'all star 2020',
      );
    });
  });

  group('tokenOverlap', () {
    test('полное вхождение короткого списка', () {
      expect(tokenOverlap({'miyagi'}, {'miyagi', 'floy'}), 1.0);
    });

    test('пересечение половины', () {
      expect(tokenOverlap({'a', 'b'}, {'a', 'c'}), 0.5);
    });

    test('пустое множество не матчится', () {
      expect(tokenOverlap({}, {'a'}), 0);
    });
  });

  test('mainArtistOf не выдумывает артиста', () {
    expect(mainArtistOf([]), 'unknown');
    expect(mainArtistOf(['  S-Tripper  ']), 's tripper');
  });
}
