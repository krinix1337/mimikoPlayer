import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/db/daos/library_dao.dart';
import 'package:phoneyandex/core/prefs/prefs.dart';

void main() {
  test('снимок настроек переживает сохранение и чтение', () {
    const prefs = Prefs(
      themeMode: ThemeMode.light,
      palette: AppPalette.mono,
      contrast: Contrast.high,
      corner: CornerRadius.pill,
      animations: AnimationsSpeed.slow,
      localeCode: 'en',
      collectionSort: CollectionSort.artist,
      quality: 'lossless',
      blurBottom: 24,
      blurTop: 36,
      blurCover: 16,
      showNavLabels: false,
      artworkShape: ArtworkShape.circle,
      hideAiTracks: true,
      censorBypass: false,
      accent: AccentColor.rose,
      launcherIcon: LauncherIcon.forest,
      searchHistory: ['queen', 'joji'],
      homeCoverTone: HomeCoverTone.darker,
      showDjInfo: false,
      autoDownloadLikes: true,
      autoDownloadWifiOnly: false,
      autoDownloadAllApproved: true,
      downloadLimitBytes: 5 * 1024 * 1024 * 1024,
      autoDownloadQuality: 'high',
    );

    final restored = Prefs.fromJson(prefs.toJson());
    expect(restored, isA<Prefs>());
    expect(restored.themeMode, ThemeMode.light);
    expect(restored.palette, AppPalette.mono);
    expect(restored.accent, AccentColor.rose);
    expect(restored.contrast, Contrast.high);
    expect(restored.corner, CornerRadius.pill);
    expect(restored.animations, AnimationsSpeed.slow);
    expect(restored.localeCode, 'en');
    expect(restored.collectionSort, CollectionSort.artist);
    expect(restored.launcherIcon, LauncherIcon.forest);
    expect(restored.quality, 'lossless');
    expect(restored.blurBottom, 24);
    expect(restored.blurTop, 36);
    expect(restored.blurCover, 16);
    expect(restored.showNavLabels, isFalse);
    expect(restored.artworkShape, ArtworkShape.circle);
    expect(restored.hideAiTracks, isTrue);
    expect(restored.censorBypass, isFalse);
    expect(restored.searchHistory, ['queen', 'joji']);
    expect(restored.homeCoverTone, HomeCoverTone.darker);
    expect(restored.showDjInfo, isFalse);
    expect(restored.autoDownloadLikes, isTrue);
    expect(restored.autoDownloadWifiOnly, isFalse);
    expect(restored.autoDownloadAllApproved, isTrue);
    expect(restored.downloadLimitBytes, 5 * 1024 * 1024 * 1024);
    expect(restored.autoDownloadQuality, 'high');
    expect(const Prefs().censorBypass, isTrue);
  });

  test('автозагрузка по умолчанию выключена, лимит 10 ГБ', () {
    const defaults = Prefs();
    expect(defaults.autoDownloadLikes, isFalse);
    expect(defaults.autoDownloadWifiOnly, isTrue);
    expect(defaults.autoDownloadAllApproved, isFalse);
    expect(defaults.downloadLimitBytes, defaultDownloadLimitBytes);
    expect(defaults.autoDownloadQuality, 'normal');

    expect(Prefs.fromJson({}).downloadLimitBytes, defaultDownloadLimitBytes);
    expect(
      Prefs.fromJson({'download_limit_bytes': null}).downloadLimitBytes,
      isNull,
    );
    expect(
      Prefs.fromJson({'download_limit_bytes': 0}).downloadLimitBytes,
      isNull,
    );
    expect(
      const Prefs().copyWith(clearDownloadLimit: true).downloadLimitBytes,
      isNull,
    );
  });

  test('история поиска чистится от пустых и нестроковых значений', () {
    final restored = Prefs.fromJson({
      'search_history': ['queen', '', 5, ' joji '],
    });
    expect(restored.searchHistory, ['queen', ' joji ']);
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
      'blur_bottom': 'много',
      'blur_cover': -5,
    });
    expect(restored.palette, AppPalette.brand);
    expect(restored.corner, CornerRadius.round);
    expect(restored.quality, 'auto');
    expect(restored.blurBottom, 16);
    expect(restored.blurCover, 0);
  });

  test('анимации «выключены» дают нулевую длительность', () {
    const off = Prefs(animations: AnimationsSpeed.off);
    expect(off.scaleMs(320), Duration.zero);
    expect(
      const Prefs().scaleMs(320) <
          const Prefs(animations: AnimationsSpeed.slow).scaleMs(320),
      isTrue,
    );
    expect(
      const Prefs(animations: AnimationsSpeed.fast).scaleMs(400),
      const Duration(milliseconds: 200),
    );
  });

  test('сортировка коллекции берётся из настроек', () {
    expect(
      Prefs.fromJson({'collection_sort': 'duration'}).collectionSort,
      CollectionSort.duration,
    );
  });
}
