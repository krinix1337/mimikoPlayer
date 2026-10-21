import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/db/daos/library_dao.dart';
import 'package:phoneyandex/core/prefs/prefs.dart';

void main() {
  test('снимок настроек переживает сохранение и чтение', () {
    const prefs = Prefs(
      themeMode: ThemeMode.light,
      palette: AppPalette.mono,
      accent: AccentColor.teal,
      contrast: Contrast.high,
      corner: CornerRadius.pill,
      animations: AnimationsSpeed.slow,
      localeCode: 'en',
      collectionSort: CollectionSort.artist,
      launcherIcon: LauncherIcon.night,
      quality: 'lossless',
      frameHz: 90,
    );

    final restored = Prefs.fromJson(prefs.toJson());
    expect(restored, isA<Prefs>());
    expect(restored.themeMode, ThemeMode.light);
    expect(restored.palette, AppPalette.mono);
    expect(restored.accent, AccentColor.teal);
    expect(restored.contrast, Contrast.high);
    expect(restored.corner, CornerRadius.pill);
    expect(restored.animations, AnimationsSpeed.slow);
    expect(restored.localeCode, 'en');
    expect(restored.collectionSort, CollectionSort.artist);
    expect(restored.launcherIcon, LauncherIcon.night);
    expect(restored.quality, 'lossless');
    expect(restored.frameHz, 90);
  });

  test('«как в системе» отличается от «не задано»', () {
    // Пропущенный ключ — это старый установщик: держим русский.
    expect(const Prefs().toJson()['locale'], 'ru');
    expect(Prefs.fromJson({'locale': 'system'}).localeCode, isNull);
    expect(Prefs.fromJson({}).localeCode, 'ru');
    expect(Prefs.fromJson({'locale': 'en'}).locale, const Locale('en'));
  });

  test('неизвестное значение не роняет чтение, а откатывает поле', () {
    final restored = Prefs.fromJson({
      'palette': 'neon',
      'corner': 'square',
      'quality': 42,
      'frame_hz': 'много',
    });
    expect(restored.palette, AppPalette.brand);
    expect(restored.corner, CornerRadius.round);
    expect(restored.quality, 'auto');
    expect(restored.frameHz, 120);
  });

  test('анимации «выключены» дают нулевую длительность', () {
    const off = Prefs(animations: AnimationsSpeed.off);
    expect(off.scaleMs(320), Duration.zero);
    expect(const Prefs().scaleMs(320) < const Prefs(animations: AnimationsSpeed.slow).scaleMs(320), isTrue);
    expect(const Prefs(animations: AnimationsSpeed.fast).scaleMs(400),
        const Duration(milliseconds: 200));
  });

  test('сортировка коллекции берётся из настроек', () {
    expect(
      Prefs.fromJson({'collection_sort': 'duration'}).collectionSort,
      CollectionSort.duration,
    );
  });
}
