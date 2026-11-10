import '../sources/source_dto.dart';

/// Виды «перезаливов», которые можно убрать из волны.
enum RemixKind {
  slowed,
  spedUp,
  nightcore,
  bassBoost,
  eightD,
  mylancore;

  /// Слова в названии, версии или альбоме, по которым вид узнаётся.
  /// Ищутся целыми словами без учёта регистра.
  List<RegExp> get patterns => switch (this) {
    RemixKind.slowed => [
      RegExp(r'\bslowed\b'),
      RegExp(r'\breverb(ed)?\b'),
      RegExp(r'\bslow(ed)?\s*(\+|&|and)\s*reverb'),
      RegExp(r'замедл'),
    ],
    RemixKind.spedUp => [
      RegExp(r'\bsped[\s-]*up\b'),
      RegExp(r'\bspeed[\s-]*up\b'),
      RegExp(r'\bspedup\b'),
      RegExp(r'ускор'),
    ],
    RemixKind.nightcore => [RegExp(r'\bnightcore\b'), RegExp(r'найткор')],
    RemixKind.bassBoost => [
      RegExp(r'\bbass[\s-]*boost(ed)?\b'),
      RegExp(r'бас[\s-]*буст'),
    ],
    RemixKind.eightD => [RegExp(r'\b8d\b'), RegExp(r'\b8d\s*audio\b')],
    RemixKind.mylancore => [
      RegExp(r'\bm[yeia]l+[ae]n+core\b'),
      RegExp(r'\bmelancore\b'),
    ],
  };

  static Set<RemixKind> fromWire(Object? value) => {
    if (value is List)
      for (final item in value)
        for (final kind in RemixKind.values)
          if (kind.name == item) kind,
  };
}

/// Убирает slowed / sped up / nightcore и прочие перезаливы из волны.
///
/// Включённые виды выставляет плеер и экран волны из настроек: фильтр нужен
/// и фоновой докачке, где Riverpod недоступен.
final class RemixFilter {
  RemixFilter._();

  static final RemixFilter instance = RemixFilter._();

  Set<RemixKind> enabled = const {};

  bool get active => enabled.isNotEmpty;

  bool isFiltered(SourceTrack track) {
    if (enabled.isEmpty) return false;
    final version = track.raw?['version'];
    return matches(
      [
        track.title,
        if (version is String) version,
        if (track.album != null) track.album!,
      ].join(' '),
    );
  }

  /// Проверка по строке: название вместе с версией и альбомом.
  bool matches(String text) {
    if (enabled.isEmpty) return false;
    final lower = text.toLowerCase();
    for (final kind in enabled) {
      for (final pattern in kind.patterns) {
        if (pattern.hasMatch(lower)) return true;
      }
    }
    return false;
  }
}
