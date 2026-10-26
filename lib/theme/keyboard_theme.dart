import 'package:flutter/material.dart';

import '../core/prefs/prefs.dart';
import 'app_theme.dart';

/// Тестовая тема «как Expressive Keyboard»: MD3 Expressive с динамическими
/// цветами, плоскими тональными поверхностями и крупными формами.
/// Включается только сборкой `--dart-define=KEYBOARD_THEME=true`, обычный
/// билд и текущие темы остаются нетронутыми.
const bool kKeyboardTestTheme = bool.fromEnvironment('KEYBOARD_THEME');

@immutable
class KeyboardTokens extends ThemeExtension<KeyboardTokens> {
  const KeyboardTokens();

  double get groupRadius => 28;
  double get itemRadius => 6;
  double get itemPressedRadius => 22;
  double get cardRadius => 28;
  double get panelRadius => 24;
  double get miniPlayerRadius => 28;
  double get navRadius => 28;
  double get accentRadius => 16;

  @override
  KeyboardTokens copyWith() => const KeyboardTokens();

  @override
  KeyboardTokens lerp(KeyboardTokens? other, double t) => this;
}

class KeyboardTheme {
  const KeyboardTheme._();

  static ThemeData build(
    Brightness brightness,
    Prefs prefs,
    ColorScheme? platformScheme,
  ) {
    final scheme = platformScheme ?? _fallback(brightness);
    final baseText = AppTheme.textTheme(scheme, prefs.contrast);
    final text = baseText.copyWith(
      displayLarge: baseText.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      displaySmall: baseText.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: baseText.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: baseText.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: baseText.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: baseText.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      labelLarge: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      labelMedium: baseText.labelMedium?.copyWith(fontWeight: FontWeight.w700),
    );

    const pill = StadiumBorder();
    final rounded20 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );
    final rounded24 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    );
    final rounded28 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceContainer,
      canvasColor: scheme.surfaceContainer,
      splashFactory: InkSparkle.splashFactory,
      textTheme: text,
      primaryTextTheme: text,
      extensions: const [KeyboardTokens()],
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
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceBright,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: rounded28,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        minLeadingWidth: 0,
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: text.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        subtitleTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: pill,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          animationDuration: prefs.scaleMs(200),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: rounded24,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: BorderSide(color: scheme.outlineVariant, width: 1),
          foregroundColor: scheme.onSurface,
          textStyle: text.labelLarge,
          animationDuration: prefs.scaleMs(200),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          shape: pill,
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          shape: const CircleBorder(),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(rounded24),
          side: const WidgetStatePropertyAll(BorderSide.none),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.secondaryContainer,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.onPrimary
                : scheme.onSecondaryContainer,
          ),
          textStyle: WidgetStatePropertyAll(
            text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          animationDuration: prefs.scaleMs(200),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        shape: WidgetStatePropertyAll(rounded28),
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
        elevation: const WidgetStatePropertyAll(0),
        textStyle: WidgetStatePropertyAll(text.bodyLarge),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer,
        selectedColor: scheme.primary,
        disabledColor: scheme.surfaceContainerHighest,
        side: BorderSide.none,
        shape: rounded20,
        labelStyle: text.labelLarge?.copyWith(
          color: scheme.onSecondaryContainer,
        ),
        secondaryLabelStyle: text.labelLarge?.copyWith(color: scheme.onPrimary),
        checkmarkColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.14),
        valueIndicatorColor: scheme.primary,
        valueIndicatorTextStyle: text.labelLarge?.copyWith(
          color: scheme.onPrimary,
        ),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : scheme.outlineVariant,
        ),
        thumbIcon: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Icon(Icons.check_rounded, size: 16, color: scheme.onPrimary)
              : null,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        side: BorderSide(color: scheme.outlineVariant, width: 2),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: rounded28,
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        shape: rounded20,
        width: 420,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: rounded20,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
          shape: WidgetStatePropertyAll(rounded20),
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: rounded20,
        collapsedShape: rounded20,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          side: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        height: 80,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? scheme.onSecondaryContainer
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
    );
  }

  /// Базовые схемы Expressive Keyboard, если Material You недоступен.
  static ColorScheme _fallback(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return ColorScheme.dark().copyWith(
        primary: const Color(0xFFD0BCFF),
        onPrimary: const Color(0xFF381E72),
        primaryContainer: const Color(0xFF4F378B),
        onPrimaryContainer: const Color(0xFFEADDFF),
        secondary: const Color(0xFFCCC2DC),
        onSecondary: const Color(0xFF332D41),
        secondaryContainer: const Color(0xFF4A4458),
        onSecondaryContainer: const Color(0xFFE8DEF8),
        tertiary: const Color(0xFFEFB8C8),
        onTertiary: const Color(0xFF492532),
        tertiaryContainer: const Color(0xFF633B48),
        onTertiaryContainer: const Color(0xFFFFD8E4),
        surface: const Color(0xFF141218),
        onSurface: const Color(0xFFE6E0E9),
        onSurfaceVariant: const Color(0xFFCAC4D0),
        surfaceDim: const Color(0xFF141218),
        surfaceBright: const Color(0xFF3B383E),
        surfaceContainerLowest: const Color(0xFF0F0D13),
        surfaceContainerLow: const Color(0xFF1D1B20),
        surfaceContainer: const Color(0xFF211F26),
        surfaceContainerHigh: const Color(0xFF2B2930),
        surfaceContainerHighest: const Color(0xFF36343B),
        outlineVariant: const Color(0xFF49454F),
      );
    }
    return ColorScheme.light().copyWith(
      primary: const Color(0xFF6750A4),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFEADDFF),
      onPrimaryContainer: const Color(0xFF21005D),
      secondary: const Color(0xFF625B71),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE8DEF8),
      onSecondaryContainer: const Color(0xFF1D192B),
      tertiary: const Color(0xFF7D5260),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFD8E4),
      onTertiaryContainer: const Color(0xFF31111D),
      surface: const Color(0xFFFEF7FF),
      onSurface: const Color(0xFF1D1B20),
      onSurfaceVariant: const Color(0xFF49454F),
      surfaceDim: const Color(0xFFDED8E1),
      surfaceBright: const Color(0xFFFEF7FF),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF7F2FA),
      surfaceContainer: const Color(0xFFF3EDF7),
      surfaceContainerHigh: const Color(0xFFECE6F0),
      surfaceContainerHighest: const Color(0xFFE6E0E9),
      outlineVariant: const Color(0xFFCAC4D0),
    );
  }
}
