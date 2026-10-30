import 'package:flutter/material.dart';

import '../db/daos/library_dao.dart';

/// Лимит автозагрузки по умолчанию: 10 ГБ. `null` в настройках = без лимита.
const int defaultDownloadLimitBytes = 10 * 1024 * 1024 * 1024;

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
    this.crossfadeSeconds = 6,
    this.lyricsSize = LyricsSize.normal,
    this.lyricsDimOthers = true,
    this.compactUi = true,
    this.showMiniPlayer = true,
    this.homeBackground = HomeBackground.both,
    this.waveOnWifiOnly = false,
    this.waveSoundCloud = false,
    this.showNavLabels = true,
    this.artworkShape = ArtworkShape.rounded,
    this.hideAiTracks = false,
    this.censorBypass = true,
    this.searchHistory = const [],
    this.homeCoverTone = HomeCoverTone.normal,
    this.blurBottom = 16,
    this.blurTop = 24,
    this.blurCover = 24,
    this.openPlayerOnPlay = false,
    this.autoDownloadLikes = false,
    this.autoDownloadWifiOnly = true,
    this.autoDownloadAllApproved = false,
    this.downloadLimitBytes = defaultDownloadLimitBytes,
    this.autoDownloadQuality = 'normal',
    this.eqEnabled = false,
    this.eqPreset = 'flat',
    this.eqCustomGains = const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    this.eqCustomLevel = 0,
    this.githubToken = '',
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

  /// Перекрытие конца трека началом следующего, секунды; 0 — выключено.
  final int crossfadeSeconds;

  final bool waveOnWifiOnly;

  /// Подмешивать в волну треки из SoundCloud рядом с рекомендациями Яндекса.
  final bool waveSoundCloud;

  /// Размер строк в караоке и приглушение неактивных строк.
  final LyricsSize lyricsSize;
  final bool lyricsDimOthers;

  /// Компактная нижняя панель и плотные списки.
  final bool compactUi;

  /// Показывать мини-плеер над навигацией.
  final bool showMiniPlayer;

  /// Чем залит фон главной: обложкой волны, цветными пятнами или обеими.
  final HomeBackground homeBackground;

  /// Подписи в нижней навигации. Без них пилюля ниже и иконки крупнее.
  final bool showNavLabels;

  /// Форма большой обложки в плеере.
  final ArtworkShape artworkShape;

  /// Скрывать треки с явной пометкой ИИ в названии или исполнителе.
  final bool hideAiTracks;

  /// Подменять зацензуренные треки версией из открытой базы.
  final bool censorBypass;

  /// Недавние поисковые запросы, новые сверху.
  final List<String> searchHistory;

  /// Тон фоновой обложки на главной.
  final HomeCoverTone homeCoverTone;

  /// Размытие нижних пилюль, верхних панелей и фоновых обложек; 0 — выкл.
  final double blurBottom;
  final double blurTop;
  final double blurCover;

  /// Открывать полный плеер при запуске трека из списка. По умолчанию
  /// выключено: играет мини-плеер, полный открывается тапом по нему.
  final bool openPlayerOnPlay;

  /// Автозагрузка лайков выключена, пока пользователь сам не включит её.
  final bool autoDownloadLikes;

  /// Автозагрузка ходит только по Wi-Fi/unmetered; ручные загрузки — везде.
  final bool autoDownloadWifiOnly;

  /// Пробные 20 треков уже приняты, можно ставить в очередь все лайки.
  final bool autoDownloadAllApproved;

  /// Байты; null — без лимита, только проверка свободного места.
  final int? downloadLimitBytes;

  /// low | normal | high — отдельно от качества потокового воспроизведения.
  final String autoDownloadQuality;

  /// Эквалайзер: пресет и включённость. Пресеты живут в features/player.
  final bool eqEnabled;
  final String eqPreset;

  /// Своя настройка: 10 полос (по reference-частотам) и уровень в дБ.
  final List<double> eqCustomGains;
  final double eqCustomLevel;

  /// Fine-grained PAT для приватных GitHub Releases. Хранится только на
  /// устройстве и никогда не попадает в APK, если не задан при сборке.
  final String githubToken;

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
    bool? fade,
    int? crossfadeSeconds,
    bool? waveOnWifiOnly,
    bool? waveSoundCloud,
    LyricsSize? lyricsSize,
    bool? lyricsDimOthers,
    bool? compactUi,
    bool? showMiniPlayer,
    HomeBackground? homeBackground,
    bool? showNavLabels,
    ArtworkShape? artworkShape,
    bool? hideAiTracks,
    bool? censorBypass,
    List<String>? searchHistory,
    HomeCoverTone? homeCoverTone,
    double? blurBottom,
    double? blurTop,
    double? blurCover,
    bool? openPlayerOnPlay,
    bool? autoDownloadLikes,
    bool? autoDownloadWifiOnly,
    bool? autoDownloadAllApproved,
    int? downloadLimitBytes,
    bool clearDownloadLimit = false,
    String? autoDownloadQuality,
    bool? eqEnabled,
    String? eqPreset,
    List<double>? eqCustomGains,
    double? eqCustomLevel,
    String? githubToken,
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
    fade: fade ?? this.fade,
    crossfadeSeconds: crossfadeSeconds ?? this.crossfadeSeconds,
    waveOnWifiOnly: waveOnWifiOnly ?? this.waveOnWifiOnly,
    waveSoundCloud: waveSoundCloud ?? this.waveSoundCloud,
    lyricsSize: lyricsSize ?? this.lyricsSize,
    lyricsDimOthers: lyricsDimOthers ?? this.lyricsDimOthers,
    compactUi: compactUi ?? this.compactUi,
    showMiniPlayer: showMiniPlayer ?? this.showMiniPlayer,
    homeBackground: homeBackground ?? this.homeBackground,
    showNavLabels: showNavLabels ?? this.showNavLabels,
    artworkShape: artworkShape ?? this.artworkShape,
    hideAiTracks: hideAiTracks ?? this.hideAiTracks,
    censorBypass: censorBypass ?? this.censorBypass,
    searchHistory: searchHistory ?? this.searchHistory,
    homeCoverTone: homeCoverTone ?? this.homeCoverTone,
    blurBottom: blurBottom ?? this.blurBottom,
    blurTop: blurTop ?? this.blurTop,
    blurCover: blurCover ?? this.blurCover,
    openPlayerOnPlay: openPlayerOnPlay ?? this.openPlayerOnPlay,
    autoDownloadLikes: autoDownloadLikes ?? this.autoDownloadLikes,
    autoDownloadWifiOnly: autoDownloadWifiOnly ?? this.autoDownloadWifiOnly,
    autoDownloadAllApproved:
        autoDownloadAllApproved ?? this.autoDownloadAllApproved,
    downloadLimitBytes: clearDownloadLimit
        ? null
        : (downloadLimitBytes ?? this.downloadLimitBytes),
    autoDownloadQuality: autoDownloadQuality ?? this.autoDownloadQuality,
    eqEnabled: eqEnabled ?? this.eqEnabled,
    eqPreset: eqPreset ?? this.eqPreset,
    eqCustomGains: eqCustomGains ?? this.eqCustomGains,
    eqCustomLevel: eqCustomLevel ?? this.eqCustomLevel,
    githubToken: githubToken ?? this.githubToken,
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
    'crossfade_seconds': crossfadeSeconds,
    'wave_on_wifi_only': waveOnWifiOnly,
    'wave_soundcloud': waveSoundCloud,
    'lyrics_size': lyricsSize.name,
    'lyrics_dim': lyricsDimOthers,
    'compact_ui': compactUi,
    'show_mini_player': showMiniPlayer,
    'home_background': homeBackground.name,
    'show_nav_labels': showNavLabels,
    'artwork_shape': artworkShape.name,
    'hide_ai_tracks': hideAiTracks,
    'censor_bypass': censorBypass,
    'search_history': searchHistory,
    'home_cover_tone': homeCoverTone.name,
    'blur_bottom': blurBottom,
    'blur_top': blurTop,
    'blur_cover': blurCover,
    'open_player_on_play': openPlayerOnPlay,
    'auto_download_likes': autoDownloadLikes,
    'auto_download_wifi_only': autoDownloadWifiOnly,
    'auto_download_all_approved': autoDownloadAllApproved,
    'download_limit_bytes': downloadLimitBytes,
    'auto_download_quality': autoDownloadQuality,
    'eq_enabled': eqEnabled,
    'eq_preset': eqPreset,
    'eq_custom_gains': eqCustomGains,
    'eq_custom_level': eqCustomLevel,
    'github_token': githubToken,
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

    final rawLimit = json['download_limit_bytes'];

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
      crossfadeSeconds: switch (json['crossfade_seconds']) {
        final int value when value >= 0 && value <= 12 => value,
        _ => 6,
      },
      waveOnWifiOnly: json['wave_on_wifi_only'] == true,
      waveSoundCloud: json['wave_soundcloud'] == true,
      lyricsSize: required('lyrics_size', LyricsSize.values, LyricsSize.normal),
      lyricsDimOthers: json['lyrics_dim'] != false,
      compactUi: json['compact_ui'] != false,
      showMiniPlayer: json['show_mini_player'] != false,
      showNavLabels: json['show_nav_labels'] != false,
      artworkShape: required(
        'artwork_shape',
        ArtworkShape.values,
        ArtworkShape.rounded,
      ),
      hideAiTracks: json['hide_ai_tracks'] == true,
      censorBypass: json['censor_bypass'] != false,
      homeCoverTone: required(
        'home_cover_tone',
        HomeCoverTone.values,
        HomeCoverTone.normal,
      ),
      blurBottom: switch (json['blur_bottom']) {
        final num value => value.toDouble().clamp(0.0, 40.0).toDouble(),
        _ => 16,
      },
      blurTop: switch (json['blur_top']) {
        final num value => value.toDouble().clamp(0.0, 40.0).toDouble(),
        _ => 24,
      },
      blurCover: switch (json['blur_cover']) {
        final num value => value.toDouble().clamp(0.0, 40.0).toDouble(),
        _ => 24,
      },
      openPlayerOnPlay: json['open_player_on_play'] == true,
      autoDownloadLikes: json['auto_download_likes'] == true,
      autoDownloadWifiOnly: json['auto_download_wifi_only'] != false,
      autoDownloadAllApproved: json['auto_download_all_approved'] == true,
      downloadLimitBytes: json.containsKey('download_limit_bytes')
          ? switch (rawLimit) {
              final num value when value > 0 => value.toInt(),
              _ => null,
            }
          : defaultDownloadLimitBytes,
      autoDownloadQuality: switch (json['auto_download_quality']) {
        'low' => 'low',
        'high' => 'high',
        _ => 'normal',
      },
      eqEnabled: json['eq_enabled'] == true,
      eqPreset: json['eq_preset'] is String
          ? json['eq_preset']! as String
          : 'flat',
      eqCustomGains: switch (json['eq_custom_gains']) {
        final List<Object?> items when items.length == 10 => [
          for (final item in items)
            ((item as num?)?.toDouble() ?? 0).clamp(-12.0, 12.0).toDouble(),
        ],
        _ => const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      },
      eqCustomLevel: switch (json['eq_custom_level']) {
        final num value => value.toDouble().clamp(-12.0, 12.0).toDouble(),
        _ => 0,
      },
      githubToken: json['github_token'] is String
          ? (json['github_token']! as String).trim()
          : '',
      searchHistory: switch (json['search_history']) {
        final List<Object?> items => [
          for (final item in items)
            if (item is String && item.trim().isNotEmpty) item,
        ],
        _ => const [],
      },
      homeBackground: required(
        'home_background',
        HomeBackground.values,
        HomeBackground.both,
      ),
    );
  }
}

/// Источник цветовых ролей. `dynamic` работает только на Android 12+.
/// `amoled` — чёрные поверхности без тона, чтобы на OLED гасли пиксели.
enum AppPalette { brand, dynamic, mono, amoled }

/// Пресеты акцента: тон-сид для всей тоновой палитры.
enum AccentColor {
  acid(0xFFD8F544),
  violet(0xFF6C5CE7),
  coral(0xFFFF6B5B),
  teal(0xFF22C7A9),
  amber(0xFFFFB03A),
  ice(0xFF7FC8FF),
  sky(0xFF4F8BFF),
  rose(0xFFFF5C9A),
  leaf(0xFF52D273),
  orchid(0xFFCA7BFF);

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

/// Насколько притемнить фоновую обложку главной.
enum HomeCoverTone { darker, normal, lighter }

/// Форма обложки в полноэкранном плеере.
enum ArtworkShape { rounded, soft, circle }

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
  defaultIcon('MimikoLauncherDefault', 'assets/icon/variants/default.png'),
  acid('MimikoLauncherAcid', 'assets/icon/variants/acid.png'),
  mono('MimikoLauncherMono', 'assets/icon/variants/mono.png'),
  night('MimikoLauncherNight', 'assets/icon/variants/night.png'),
  sunset('MimikoLauncherSunset', 'assets/icon/variants/sunset.png'),
  mint('MimikoLauncherMint', 'assets/icon/variants/mint.png'),
  violet('MimikoLauncherViolet', 'assets/icon/variants/violet.png'),
  ice('MimikoLauncherIce', 'assets/icon/variants/ice.png'),
  amber('MimikoLauncherAmber', 'assets/icon/variants/amber.png'),
  forest('MimikoLauncherForest', 'assets/icon/variants/forest.png');

  const LauncherIcon(this.component, this.asset);

  final String component;
  final String asset;

  static LauncherIcon fromComponent(String component) {
    for (final icon in values) {
      if (icon.component == component) return icon;
    }
    return defaultIcon;
  }
}
