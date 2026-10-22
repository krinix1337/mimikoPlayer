import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/content/ai_filter.dart';

void main() {
  test('явные пометки ИИ в названии и исполнителе ловятся', () {
    expect(AiFilter.matches('Song', ['D-Dolls [Ai_MUSIC]']), isTrue);
    expect(AiFilter.matches('Track (AI cover)', ['Someone']), isTrue);
    expect(AiFilter.matches('Новая песня', ['Нейросеть']), isTrue);
    expect(AiFilter.matches('Ремикс', ['Suno']), isTrue);
    expect(AiFilter.matches('Трек', ['Udio']), isTrue);
  });

  test('обычные имена не считаются ИИ', () {
    expect(AiFilter.matches('Aiden', ['Aiden Yoo']), isFalse);
    expect(AiFilter.matches('Rain', ['Rain']), isFalse);
    expect(AiFilter.matches('Песня', ['Король и Шут']), isFalse);
    expect(AiFilter.matches('Sunday', ['Sundays']), isFalse);
  });

  test('список Slopless разбирается в набор id', () {
    final ids = AiFilter.instance.parse(
      '{"timestamp":"2026-10-22","artists":[544,"123",42.0,null]}',
    );
    expect(ids, containsAll([544, 123, 42]));
    expect(ids.length, 3);
  });
}
