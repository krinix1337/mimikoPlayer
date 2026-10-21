import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;

import '../db/database.dart';
import 'prefs.dart';

/// Хранилище настроек: один JSON-snapshot на всё, чтобы смена темы, языка и
/// иконки не расползалась по нескольким ключам.
const String prefsKey = 'prefs_v1';

/// Ключ до появления snapshot'а — читаем как fallback.
const String legacyThemeModeKey = 'theme_mode';

Future<Prefs> loadPrefs(AppDatabase db) async {
  final raw = await db.settingsDao.value(prefsKey);
  if (raw == null) {
    final legacy = await db.settingsDao.value(legacyThemeModeKey);
    final mode = ThemeMode.values.firstWhere(
      (mode) => mode.name == legacy,
      orElse: () => ThemeMode.dark,
    );
    return Prefs(themeMode: mode);
  }
  try {
    var decoded = jsonDecode(raw);
    // Старый формат писал строку внутрь строки (jsonEncode в savePrefs и
    // ещё один в SettingsDao.setValue) — такие данные тоже читаем.
    if (decoded is String) decoded = jsonDecode(decoded);
    return decoded is Map<String, Object?>
        ? Prefs.fromJson(decoded)
        : const Prefs();
  } on FormatException {
    return const Prefs();
  }
}

/// `SettingsDao.setValue` кодирует значение сам — второй jsonEncode здесь
/// превращал снимок в строку, и при чтении он молча откатывался к дефолту.
Future<void> savePrefs(AppDatabase db, Prefs prefs) =>
    db.settingsDao.setValue(prefsKey, prefs.toJson());
