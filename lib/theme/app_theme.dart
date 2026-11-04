import 'package:flutter/material.dart';

import '../core/prefs/prefs.dart';

/// Material 3 Expressive: честные тоновые роли, крупные радиусы, тяжёлая
/// типографика и пружинные состояния нажатия. Всё выводится из [Prefs],
/// поэтому тема, акцент, контраст и радиусы меняются на месте.
class AppTheme {
  const AppTheme._();

  static ThemeData build(
    Brightness brightness,
    Prefs prefs, {
    ColorScheme? platformScheme,
  }) {
    final scheme = _scheme(brightness, prefs, platformScheme);
    final radius = prefs.corner.radius;
    final text = textTheme(scheme, prefs.contrast);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      disabledColor: scheme.onSurface.withValues(alpha: 0.38),
      textTheme: text,
      primaryTextTheme: text,
      extensions: const [],
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 24),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.displaySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        // M3: высота 80, индикатор 32×64 — в пилюле навигации это читается
        // как стандартный навбар, а не как «полоска».
        height: 80,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          animationDuration: prefs.scaleMs(200),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: BorderSide(color: scheme.outlineVariant, width: 1),
          foregroundColor: scheme.onSurface,
          animationDuration: prefs.scaleMs(200),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _actionInk(scheme),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          ),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        side: BorderSide.none,
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainerHighest,
        checkmarkColor: scheme.onSecondaryContainer,
        // Выбранный чип — primaryContainer, а не грязный secondary: с
        // кислотным сид secondary тон уходит в болотный.
        labelStyle: text.labelLarge!,
        secondaryLabelStyle: text.labelLarge!.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        minLeadingWidth: 0,
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: text.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        subtitleTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      // Слайдер M3 Expressive (2024): толстая дорожка, ручка-палочка с
      // зазором и точки-остановки — формы берутся из year2023: false.
      sliderTheme: SliderThemeData(
        // ignore: deprecated_member_use
        year2023: false,
        activeTrackColor: _actionInk(scheme),
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: _actionInk(scheme),
        overlayColor: _actionInk(scheme).withValues(alpha: 0.14),
        valueIndicatorColor: scheme.inverseSurface,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? _actionInk(scheme)
              : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : scheme.outlineVariant,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? _actionInk(scheme)
              : scheme.onSurfaceVariant,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? _actionInk(scheme)
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        side: BorderSide(color: scheme.outlineVariant, width: 2),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius + 8),
          side: BorderSide.none,
        ),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: _actionInk(scheme),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        width: 420,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide.none,
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          ),
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radius + 12),
          ),
          side: BorderSide.none,
        ),
      ),
    );
  }

  static Color _actionInk(ColorScheme scheme) => scheme.primary;

  static ColorScheme _scheme(
    Brightness brightness,
    Prefs prefs,
    ColorScheme? platformScheme,
  ) {
    if (prefs.palette == AppPalette.dynamic && platformScheme != null) {
      // Material You: роли берём целиком у системы, своих тонов не подмешиваем.
      return platformScheme;
    }

    if (prefs.palette == AppPalette.amoled) {
      return _amoledScheme(brightness, prefs);
    }

    if (prefs.contrast == Contrast.high) {
      // WCAG-пресеты Flutter: тот же акцент, но текст и разделители с
      // гарантированным контрастом.
      final hc = brightness == Brightness.dark
          ? const ColorScheme.highContrastDark()
          : const ColorScheme.highContrastLight();
      return hc.copyWith(
        primary: prefs.accent.color,
        onPrimary: _inkOn(prefs.accent.color),
        secondaryContainer: hc.surfaceContainerHighest,
        onSecondaryContainer: hc.onSurface,
      );
    }

    final base = ColorScheme.fromSeed(
      seedColor: prefs.accent.color,
      brightness: brightness,
    );
    return _withSurfaceTones(base, prefs, brightness);
  }

  /// AMOLED: поверхности уходят в настоящий чёрный, чтобы на OLED-экране
  /// пиксели действительно гасли. Акцент пользователь выбирает сам, он же
  /// остаётся единственным цветным пятном.
  static ColorScheme _amoledScheme(Brightness brightness, Prefs prefs) {
    final base = _withSurfaceTones(
      ColorScheme.fromSeed(
        seedColor: prefs.accent.color,
        brightness: brightness,
      ),
      prefs,
      brightness,
    );
    if (brightness == Brightness.light) {
      return base.copyWith(
        surface: const Color(0xFFFFFFFF),
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        surfaceDim: const Color(0xFFF2F2F2),
      );
    }
    return base.copyWith(
      surface: const Color(0xFF000000),
      onSurface: const Color(0xFFFFFFFF),
      onSurfaceVariant: const Color(0xFFB7B7B7),
      surfaceContainerLowest: const Color(0xFF000000),
      surfaceContainerLow: const Color(0xFF080808),
      surfaceContainer: const Color(0xFF121212),
      surfaceContainerHigh: const Color(0xFF1A1A1A),
      surfaceContainerHighest: const Color(0xFF232323),
      surfaceBright: const Color(0xFF2B2B2B),
      surfaceDim: const Color(0xFF000000),
      outline: const Color(0xFF8A8A8A),
      outlineVariant: const Color(0xFF2A2A2A),
    );
  }

  /// Tonal ramp: surface и контейнеры — нейтральные тоны M3, а не произвольные
  /// серые. Акцент остаётся один, как требует Expressive.
  static ColorScheme _withSurfaceTones(
    ColorScheme base,
    Prefs prefs,
    Brightness brightness,
  ) {
    if (prefs.palette == AppPalette.mono) {
      return ColorScheme.fromSeed(
        seedColor: Colors.grey,
        brightness: brightness,
      ).copyWith(
        primary: prefs.accent.color,
        onPrimary: _inkOn(prefs.accent.color),
        primaryContainer: prefs.accent.color.withValues(
          alpha: brightness == Brightness.dark ? 0.22 : 0.3,
        ),
        onPrimaryContainer: brightness == Brightness.dark
            ? const Color(0xFFF2F3EF)
            : const Color(0xFF14170A),
      );
    }

    if (brightness == Brightness.dark) {
      return base.copyWith(
        primary: prefs.accent.color,
        onPrimary: _inkOn(prefs.accent.color),
        primaryContainer: base.primaryContainer,
        surface: const Color(0xFF0B0C0F),
        onSurface: const Color(0xFFE9EAEC),
        surfaceContainerLowest: const Color(0xFF0B0C0F),
        surfaceContainerLow: const Color(0xFF13151A),
        surfaceContainer: const Color(0xFF191C22),
        surfaceContainerHigh: const Color(0xFF23262E),
        surfaceContainerHighest: const Color(0xFF2E323B),
        surfaceBright: const Color(0xFF353941),
        surfaceDim: const Color(0xFF0B0C0F),
        secondaryContainer: base.secondaryContainer,
        outlineVariant: const Color(0xFF333740),
      );
    }

    return base.copyWith(
      primary: _darkenForLight(prefs.accent.color),
      onPrimary: _inkOn(_darkenForLight(prefs.accent.color)),
      surface: const Color(0xFFFBF8F5),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF5F2EE),
      surfaceContainer: const Color(0xFFEFEBE6),
      surfaceContainerHigh: const Color(0xFFE9E5DF),
      surfaceContainerHighest: const Color(0xFFE3DED8),
    );
  }

  /// Черный или белый — тот, что даёт больший контраст с подложкой.
  /// Порог по яркости ошибается на коралловом и янтарном: там белый текст
  /// читается за счёт чего угодно, кроме контраста.
  static Color _inkOn(Color background) {
    const dark = Color(0xFF14170A);
    if (_contrast(dark, background) >= _contrast(Colors.white, background)) {
      return dark;
    }
    return Colors.white;
  }

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  /// Светлый акцент на белой поверхности не читается, поэтому тон опускаем
  /// до контраста 4.5 с выбранным чернильным цветом, а не «на глаз».
  static Color _darkenForLight(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    var candidate = hsl
        .withSaturation(hsl.saturation.clamp(0.45, 0.9))
        .withLightness(hsl.lightness < 0.45 ? hsl.lightness : 0.36)
        .toColor();
    for (
      var step = 0;
      step < 12 && _contrast(candidate, _inkOn(candidate)) < 4.5;
      step++
    ) {
      candidate = HSLColor.fromColor(candidate)
          .withLightness(
            (HSLColor.fromColor(candidate).lightness - 0.04).clamp(0.12, 1.0),
          )
          .toColor();
    }
    return candidate;
  }

  /// Шкала ровно по токенам M3: display/headline — emphasized (для
  /// выразительности), body — 400, label — 500. Высокий контраст поднимает
  /// вес body до 600, как требует MD3 для контроля читаемости.
  static TextTheme textTheme(ColorScheme scheme, Contrast contrast) {
    final bodyWeight = contrast == Contrast.high
        ? FontWeight.w600
        : FontWeight.w400;
    final labelWeight = contrast == Contrast.high
        ? FontWeight.w700
        : FontWeight.w500;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        height: 64 / 57,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.25,
        color: scheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        height: 44 / 36,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: labelWeight,
        letterSpacing: 0.15,
        color: scheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: labelWeight,
        letterSpacing: 0.1,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: bodyWeight,
        letterSpacing: 0.5,
        color: scheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: bodyWeight,
        letterSpacing: 0.25,
        color: scheme.onSurfaceVariant,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: bodyWeight,
        letterSpacing: 0.4,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: labelWeight,
        letterSpacing: 0.1,
        color: scheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: labelWeight,
        letterSpacing: 0.5,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        height: 16 / 11,
        fontWeight: labelWeight,
        letterSpacing: 0.5,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
