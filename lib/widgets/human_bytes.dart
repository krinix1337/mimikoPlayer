import '../l10n/app_localizations.dart';

/// Размер файла с единицей на языке интерфейса: «3.8 ГБ», а не «3.8 GB»
/// рядом с «20 ГБ» лимита на том же экране.
String humanBytes(AppLocalizations l, int bytes) {
  if (bytes < 1024) return l.sizeBytes('$bytes');
  if (bytes < 1024 * 1024) return l.sizeKb((bytes / 1024).toStringAsFixed(0));
  if (bytes < 1024 * 1024 * 1024) {
    return l.sizeMb((bytes / 1024 / 1024).toStringAsFixed(1));
  }
  return l.sizeGb((bytes / 1024 / 1024 / 1024).toStringAsFixed(1));
}
