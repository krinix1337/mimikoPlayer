import '../../l10n/app_localizations.dart';
import '../../sources/yandex/yandex_station.dart';

/// Название выбранного режима «Моей волны» для пилюли и плеера. Обычная
/// волна даёт null: отдельной плашки у неё нет.
String? waveModeLabel(WaveSettings? settings, AppLocalizations l) {
  if (settings == null) return null;
  final parts = <String>[];
  final mood = switch (settings.moodEnergy) {
    'active' => l.moodEnergyActive,
    'fun' => l.moodEnergyFun,
    'calm' => l.moodEnergyCalm,
    'sad' => l.moodEnergySad,
    _ => null,
  };
  if (mood != null) parts.add(mood);
  final character = switch (settings.diversity) {
    'favorite' => l.diversityFavorite,
    'discover' => l.diversityDiscover,
    'popular' => l.diversityPopular,
    _ => null,
  };
  if (character != null) parts.add(character);
  final language = switch (settings.language) {
    'russian' => l.languageRussian,
    'not-russian' => l.languageForeign,
    'without-words' => l.languageInstrumental,
    _ => null,
  };
  if (language != null) parts.add(language);
  return parts.isEmpty ? null : parts.join(' · ');
}
