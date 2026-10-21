import 'package:flutter/material.dart';

import '../db/daos/library_dao.dart';

/// Всё, что пользователь крутит в настройках. Один снимок — одна запись в БД,
/// поэтому смена темы, языка и иконки не расползается по нескольким ключам.
@immutable
final class Prefs {
  const Prefs({
    this.themeMode = ThemeMode.dark,
    this.palette = AppPalette.brand,
    this.accent = AccentColor.acid,
    this.contrast = Contrast.normal,
    this.corner = CornerRadius.round,
    this.animations = AnimationsSpeed.normal,
    this.localeCode = 'ru',
    this.collectionSort = CollectionSort.added,
    this.launcherIcon = LauncherIcon.defaultIcon,
    this.quality = 'auto',
    this.fade = true,
    this.lyricsSize = LyricsSize.normal,
    this.lyricsDimOthers = true,
    this.compactUi = true,
    this.showMiniPlayer = true,
    this.homeBackground = HomeBackground.both,
    this.frameHz = 120,
    this.waveOnWifiOnly = false,
  });

  final ThemeMode themeMode;
  final AppPalette palette;
  final AccentColor accent;
  final Contrast contrast;
  final CornerRadius corner;
  final AnimationsSpeed animations;
  final String? localeCode;
  final CollectionSort collectionSort;
  final LauncherIcon launcherIcon;
  final String quality;

  /// Плавное поднятие/опускание громкости при старте, паузе и смене трека.
  final bool fade;

  /// Запрошенная частота кадров окна. 0 — не вмешиваться в выбор системы.
  final double frameHz;
  final bool waveOnWifiOnly;

  /// Размер строк в караоке и приглушение неактивных строк.
  final LyricsSize lyricsSize;
  final bool lyricsDimOthers;

  /// Компактная нижняя панель и плотные списки.
  final bool compactUi;

  /// Показывать мини-плеер над навигацией.
  final bool showMiniPlayer;

  /// Чем залит фон главной: обложкой волны, цветными пятнами или обеими.
  final HomeBackground homeBackground;

  Locale? get locale => localeCode == null ? null : Locale(localeCode!);

  /// Длительность перехода с учётом пользовательского масштаба анимаций.
  Duration scaleMs(int milliseconds) => Duration(
    milliseconds: switch (animations) {
      AnimationsSpeed.off => 0,
      AnimationsSpeed.slow => milliseconds,
      AnimationsSpeed.normal => (milliseconds * 0.75).round(),
      AnimationsSpeed.fast => (milliseconds * 0.5).round(),
    },
  );

  Prefs copyWith({
    ThemeMode? themeMode,
    AppPalette? palette,
    AccentColor? accent,
    Contrast? contrast,
    CornerRadius? corner,
    AnimationsSpeed? animations,
    String? localeCode,
    bool clearLocale = false,
    CollectionSort? collectionSort,
    LauncherIcon? launcherIcon,
    String? quality,
    double? frameHz,
    bool? fade,
    bool? waveOnWifiOnly,
    LyricsSize? lyricsSize,
    bool? lyricsDimOthers,
    bool? compactUi,
    bool? showMiniPlayer,
    HomeBackground? homeBackground,
  }) => Prefs(
    themeMode: themeMode ?? this.themeMode,
    palette: palette ?? this.palette,
    accent: accent ?? this.accent,
    contrast: contrast ?? this.contrast,
    corner: corner ?? this.corner,
    animations: animations ?? this.animations,
    localeCode: clearLocale ? null : (localeCode ?? this.localeCode),
    collectionSort: collectionSort ?? this.collectionSort,
    launcherIcon: launcherIcon ?? this.launcherIcon,
    quality: quality ?? this.quality,
    frameHz: frameHz ?? this.frameHz,
    fade: fade ?? this.fade,
    waveOnWifiOnly: waveOnWifiOnly ?? this.waveOnWifiOnly,
    lyricsSize: lyricsSize ?? this.lyricsSize,
    lyricsDimOthers: lyricsDimOthers ?? this.lyricsDimOthers,
    compactUi: compactUi ?? this.compactUi,
    showMiniPlayer: showMiniPlayer ?? this.showMiniPlayer,
    homeBackground: homeBackground ?? this.homeBackground,
  );

  Map<String, Object?> toJson() => {
    'theme_mode': themeMode.name,
    'palette': palette.name,
    'accent': accent.name,
    'contrast': contrast.name,
    'corner': corner.name,
    'animations': animations.name,
    'locale': localeCode ?? 'system',
    'collection_sort': collectionSort.name,
    'launcher_icon': launcherIcon.component,
    'quality': quality,
    'fade': fade,
    'frame_hz': frameHz,
    'wave_on_wifi_only': waveOnWifiOnly,
    'lyrics_size': lyricsSize.name,
    'lyrics_dim': lyricsDimOthers,
    'compact_ui': compactUi,
    'show_mini_player': showMiniPlayer,
    'home_background': homeBackground.name,
  };

  static Prefs fromJson(Map<String, Object?> json) {
    T? byName<T>(List<T> options, String? raw) {
      if (raw == null) return null;
      for (final option in options) {
        if (option.toString().endsWith('.$raw')) return option;
      }
      return null;
    }

    T required<T>(String key, List<T> options, T fallback) =>
        byName(options, json[key] is String ? json[key]! as String : null) ??
        fallback;

    return Prefs(
      themeMode: required('theme_mode', ThemeMode.values, ThemeMode.dark),
      palette: required('palette', AppPalette.values, AppPalette.brand),
      accent: required('accent', AccentColor.values, AccentColor.acid),
      contrast: required('contrast', Contrast.values, Contrast.normal),
      corner: required('corner', CornerRadius.values, CornerRadius.round),
      animations: required(
        'animations',
        AnimationsSpeed.values,
        AnimationsSpeed.normal,
      ),
      localeCode: switch (json['locale']) {
        null => 'ru',
        'system' => null,
        final String code => code,
        _ => 'ru',
      },
      collectionSort: required(
        'collection_sort',
        CollectionSort.values,
        CollectionSort.added,
      ),
      launcherIcon: LauncherIcon.fromComponent(
        json['launcher_icon'] is String ? json['launcher_icon']! as String : '',
      ),
      quality: json['quality'] is String ? json['quality']! as String : 'auto',
      fade: json['fade'] != false,
      frameHz: json['frame_hz'] is num
          ? (json['frame_hz']! as num).toDouble()
          : 120,
      waveOnWifiOnly: json['wave_on_wifi_only'] == true,
      lyricsSize: required(
        'lyrics_size',
        LyricsSize.values,
        LyricsSize.normal,
      ),
      lyricsDimOthers: json['lyrics_dim'] != false,
      compactUi: json['compact_ui'] != false,
      showMiniPlayer: json['show_mini_player'] != false,
      homeBackground: required(
        'home_background',
        HomeBackground.values,
        HomeBackground.both,
      ),
    );
  }
}

/// Источник цветовых ролей. `dynamic` работает только на Android 12+.
enum AppPalette { brand, dynamic, mono }

/// Пресеты акцента: тон-сид для всей тоновой палитры.
enum AccentColor {
  acid(0xFFD8F544),
  violet(0xFF6C5CE7),
  coral(0xFFFF6B5B),
  teal(0xFF22C7A9),
  amber(0xFFFFB03A),
  ice(0xFF7FC8FF);

  const AccentColor(this.hex);

  final int hex;

  Color get color => Color(hex);
}

enum Contrast { normal, high }

enum CornerRadius {
  soft(12),
  round(20),
  pill(28);

  const CornerRadius(this.radius);

  final double radius;
}

enum AnimationsSpeed { off, fast, normal, slow }

/// Фон главной: обложка волны, цветные пятна или оба слоя.
enum HomeBackground { cover, blobs, both }

/// Размер текста караоке: множитель к базовому размеру строки.
enum LyricsSize {
  small(0.85),
  normal(1.0),
  large(1.2);

  const LyricsSize(this.scale);

  final double scale;
}

/// Иконка в лаунчере: `activity-alias` с этим компонентом включается,
/// остальные отключаются. `defaultIcon` — основной `<activity>`.
enum LauncherIcon {
  defaultIcon('MimikoLauncherDefault'),
  acid('MimikoLauncherAcid'),
  mono('MimikoLauncherMono'),
  night('MimikoLauncherNight'),
  sunset('MimikoLauncherSunset'),
  mint('MimikoLauncherMint');

  const LauncherIcon(this.component);

  final String component;

  static LauncherIcon fromComponent(String component) {
    for (final icon in values) {
      if (icon.component == component) return icon;
    }
    return defaultIcon;
  }
}
