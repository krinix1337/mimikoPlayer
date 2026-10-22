import 'source_dto.dart';

/// Подбор той же песни в другом источнике, когда основной поток недоступен.
///
/// Сравнение намеренно осторожное: одинаковое название без совпадения
/// исполнителя или большая разница в длительности считаются промахом.
SourceTrack? pickCrossSourceMatch(
  List<SourceTrack> candidates, {
  required String title,
  required List<String> artists,
  required Duration duration,
}) {
  final titleKey = normalizeMatchText(title);
  final fullKey = normalizeMatchText('$title ${artists.join(' ')}');
  final artistKeys = {
    for (final artist in artists)
      if (normalizeMatchText(artist) case final key when key.isNotEmpty) key,
  };
  if (titleKey.isEmpty) return null;

  SourceTrack? best;
  var bestScore = 0;
  for (final candidate in candidates) {
    final candidateTitle = normalizeMatchText(candidate.title);
    if (candidateTitle.isEmpty) continue;
    if (duration.inSeconds > 0 &&
        candidate.duration.inSeconds > 0 &&
        (candidate.duration.inSeconds - duration.inSeconds).abs() > 12) {
      continue;
    }

    final candidateArtists = {
      for (final artist in candidate.artists)
        if (normalizeMatchText(artist) case final key when key.isNotEmpty) key,
    };
    final artistHit =
        candidateArtists.any(artistKeys.contains) ||
        candidateArtists.any((artist) => _containsWord(fullKey, artist));
    final titleExact = candidateTitle == titleKey;
    final titleInside =
        candidateTitle.length >= 4 &&
        (fullKey.contains(candidateTitle) || titleKey.contains(candidateTitle));
    // Совпадения только по названию мало: так подставляются каверы и чужие
    // песни с тем же названием. Исполнитель должен подтвердиться отдельно.
    if (!artistHit) continue;

    var score = titleExact ? 100 : (titleInside ? 60 : 0);
    if (artistHit) score += 30;
    score -= (candidate.duration - duration).inSeconds.abs() ~/ 4;
    if (score > bestScore) {
      bestScore = score;
      best = candidate;
    }
  }
  return best;
}

/// Запрос для поиска той же песни в другом каталоге. Сырое YouTube-название
/// с «(Official Video)» и каналом Яндекс не находит вовсе.
String crossSourceQuery(String title, List<String> artists) {
  final fromTitle = normalizeMatchText(title);
  if (fromTitle.isNotEmpty) return fromTitle;
  return '$title ${artists.join(' ')}'.trim();
}

/// Убирает из названий YouTube-обвес: «(Official Video)», «[Lyric Video]»,
/// «prod. …», лишнюю пунктуацию. Оставляет смысловые слова для сравнения.
String normalizeMatchText(String input) {
  var text = input.toLowerCase().replaceAll('ё', 'е');
  text = text.replaceAll(RegExp(r'[\(\[\{].*?[\)\]\}]'), ' ');
  text = text.replaceAll(
    RegExp(
      r'\b(official|lyric|lyrics|video|audio|visualizer|visualiser|clip|mv|m/v|'
      r'remaster(ed)?|premiere|preview|hd|hq|4k|8k)\b',
      caseSensitive: false,
    ),
    ' ',
  );
  text = text.replaceAll(RegExp(r'\b(feat|ft|prod)\b.*$'), ' ');
  text = text.replaceAll(RegExp(r'[^a-zа-я0-9]+'), ' ');
  return text.trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Совпадение целого слова или фразы, а не случайной подстроки:
/// «Sia» не должна находиться внутри «Asian».
bool _containsWord(String haystack, String needle) {
  if (needle.isEmpty) return false;
  return haystack == needle ||
      haystack.startsWith('$needle ') ||
      haystack.endsWith(' $needle') ||
      haystack.contains(' $needle ');
}
