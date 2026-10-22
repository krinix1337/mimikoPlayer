/// Эвристика для треков, у которых ИИ указан прямо в метаданных.
///
/// В API Яндекса нет официального поля «сгенерировано ИИ», поэтому фильтр
/// не обещает невозможного: он убирает только явные пометки в названии или
/// исполнителе (`[Ai_MUSIC]`, `AI cover`, `Suno`, `нейросеть` и т.п.).
class AiFilter {
  const AiFilter._();

  static final RegExp _latin = RegExp(
    r'(^|[^a-z0-9])(ai[ _-]?(music|cover|song|track|voice|generated|artist|remix)|suno|udio)([^a-z0-9]|$)',
    caseSensitive: false,
  );

  static const List<String> _cyrillic = [
    'нейрослоп',
    'нейросет',
    'нейро-трек',
    'нейротрек',
    'сгенерировано ии',
    'сгенерирован ии',
    'ии-трек',
    'ии трек',
    'ии-кавер',
    'ии кавер',
    'искусственный интеллект',
  ];

  static bool matches(String title, Iterable<String> artists) {
    final text = '$title ${artists.join(' ')}'.toLowerCase();
    if (_latin.hasMatch(text)) return true;
    return _cyrillic.any(text.contains);
  }
}
