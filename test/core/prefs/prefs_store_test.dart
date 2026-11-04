import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/db/daos/library_dao.dart';
import 'package:phoneyandex/core/db/database.dart';
import 'package:phoneyandex/core/prefs/prefs.dart';
import 'package:phoneyandex/core/prefs/prefs_store.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('настройки переживают перезапуск через базу', () async {
    // Регресс: savePrefs кодировал снимок в строку, а SettingsDao — ещё раз,
    // поэтому после перезапуска всё возвращалось к значениям по умолчанию.
    const saved = Prefs(
      themeMode: ThemeMode.light,
      accent: AccentColor.teal,
      corner: CornerRadius.pill,
      localeCode: 'en',
      compactUi: false,
      homeBackground: HomeBackground.cover,
      collectionSort: CollectionSort.duration,
    );
    await savePrefs(db, saved);

    final restored = await loadPrefs(db);
    expect(restored.themeMode, ThemeMode.light);
    expect(restored.accent, AccentColor.teal);
    expect(restored.corner, CornerRadius.pill);
    expect(restored.localeCode, 'en');
    expect(restored.compactUi, isFalse);
    expect(restored.homeBackground, HomeBackground.cover);
    expect(restored.collectionSort, CollectionSort.duration);
  });

  test('старый двойной JSON тоже читается', () async {
    const legacy = Prefs(themeMode: ThemeMode.light, accent: AccentColor.ice);
    // Пишем так, как это лежало в базе до исправления.
    await db.settingsDao.setValue(
      prefsKey,
      '{"theme_mode":"light","accent":"ice"}',
    );

    final restored = await loadPrefs(db);
    expect(restored.themeMode, ThemeMode.light);
    expect(restored.accent, AccentColor.ice);
    expect(legacy.accent, AccentColor.ice);
  });

  test('пустая база даёт значения по умолчанию', () async {
    final restored = await loadPrefs(db);
    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.accent, AccentColor.acid);
  });

  test('старый токен GitHub стирается из сохранённых настроек', () async {
    await db.settingsDao.setValue(prefsKey, {
      'theme_mode': 'light',
      'github_token': 'github_pat_secret',
    });

    final restored = await loadPrefs(db);
    expect(restored.themeMode, ThemeMode.light);
    final raw = await db.settingsDao.value(prefsKey);
    expect(raw, isNot(contains('github_token')));
    expect(raw, isNot(contains('github_pat_secret')));
  });
}
