/// Нормализация названий для сведения треков из разных каталогов в одну
/// локальную строку. Изменение правил = миграция данных: отпечаток трека
/// хранится в БД, поэтому правки здесь проверяются golden-тестами.
library;

/// Кириллицу не транслитерируем: каталог Яндекса русский, транслитерация
/// только рассыплет матчинг.
const Map<String, String> _latinAccents = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'æ': 'ae',
  'ç': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ñ': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ž': 'z',
  'ş': 's',
  'ğ': 'g',
  'ı': 'i',
  'ő': 'o',
  'ű': 'u',
};

/// Слова, которые несут смысл названия, но не различают треки.
final RegExp _noiseBlock = RegExp(
  r'[\(\[\{](?:[^)\]\}]*)?'
  r'(?:feat|ft|feat\.|feature|with|versus|vs|remaster|remastered|live|version|'
  r'official|audio|video|lyric|lyrics|karaoke|cover|demo|edit|radio|instrumental|'
  r'mix|reprise|bonus)[^)\]\}]*[\)\]\}]',
  caseSensitive: false,
);

final RegExp _noiseSuffix = RegExp(
  r'\s*[-–—]\s*(?:official|lyrics?|audio|video|visualizer|mv|hd|hq|full)\b.*$',
  caseSensitive: false,
);

final RegExp _collapsable = RegExp(
  r'[.,_!/:;?+=~\u2010-\u2015\u2212\u2018\u2019\u201c\u201d\x27\x22\-]+',
);
final RegExp _spaces = RegExp(r'\s+');

String _stripAccents(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    if (_latinAccents.containsKey(ch)) {
      buffer.write(_latinAccents[ch]);
    } else if (rune < 0x0300 || rune > 0x036f) {
      // Combining marks после decomposition'а; сами по себе не встречаются.
      buffer.write(ch);
    }
  }
  return buffer.toString();
}

/// Базовая нормализация: регистр, диакритика, шум в скобках, пунктуация.
String normalizeText(String input) {
  var s = input.toLowerCase().trim();
  s = s.replaceAll(_noiseBlock, ' ');
  s = s.replaceAll(_noiseSuffix, ' ');
  s = s.replaceAll('&', ' and ');
  s = s.replaceAll('×', 'x');
  s = s.replaceAllMapped(RegExp(r'\b(?:ft|feat|feature)\.?\s+'), (m) => ' ');
  s = _stripAccents(s);
  s = s.replaceAll(_collapsable, ' ');
  s = s.replaceAll(_spaces, ' ');
  return s.trim();
}

String normalizeTitle(String title) => normalizeText(title);

String normalizeArtist(String artist) => normalizeText(artist);

/// Артист для отпечатка: первый в списке, иначе известная заглушка.
String mainArtistOf(List<String> artists) =>
    artists.isEmpty ? 'unknown' : normalizeArtist(artists.first);

/// Токены для нечёткого сравнения артистов.
Set<String> tokenize(String normalized) =>
    normalized.split(' ').where((t) => t.isNotEmpty).toSet();

/// Доля совпавших токенов от более короткого набора: 1.0 значит «один артист
/// целиком содержится в другом».
double tokenOverlap(Set<String> a, Set<String> b) {
  if (a.isEmpty || b.isEmpty) return 0;
  final shorter = a.length <= b.length ? a : b;
  final other = shorter == a ? b : a;
  final hits = shorter.where(other.contains).length;
  return hits / shorter.length;
}
