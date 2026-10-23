import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/prefs/prefs.dart';
import 'package:phoneyandex/theme/app_theme.dart';

BorderRadius _cardRadius(ThemeData theme) =>
    (theme.cardTheme.shape! as RoundedRectangleBorder).borderRadius
        as BorderRadius;

/// Контраст по WCAG: то, что реально читается, а не «тёмный/светлый».
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('скругление из настроек доходит до карточек', () {
    for (final corner in CornerRadius.values) {
      final theme = AppTheme.build(Brightness.dark, Prefs(corner: corner));
      expect(_cardRadius(theme).topLeft.x, corner.radius);
    }
  });

  test('акцент правит primary, а текст на нём читается', () {
    for (final accent in AccentColor.values) {
      for (final brightness in Brightness.values) {
        final scheme = AppTheme.build(
          brightness,
          Prefs(accent: accent),
        ).colorScheme;
        if (brightness == Brightness.dark) {
          expect(scheme.primary, accent.color);
        }
        expect(
          _contrast(scheme.primary, scheme.onPrimary),
          greaterThan(4.5),
          reason: '${accent.name} / $brightness',
        );
      }
    }
  });

  test('высокий контраст утяжеляет текст и светит им по поверхности', () {
    final normal = AppTheme.build(Brightness.dark, const Prefs());
    final high = AppTheme.build(
      Brightness.dark,
      const Prefs(contrast: Contrast.high),
    );
    // M3: обычный body — 400, высокий контраст поднимает до 600.
    expect(high.textTheme.bodyMedium!.fontWeight, FontWeight.w600);
    expect(normal.textTheme.bodyMedium!.fontWeight, FontWeight.w400);
    expect(
      _contrast(high.colorScheme.onSurface, high.colorScheme.surface),
      greaterThan(
        _contrast(normal.colorScheme.onSurface, normal.colorScheme.surface),
      ),
    );
  });

  test('монохром не красит поверхности в акцент', () {
    final mono = AppTheme.build(
      Brightness.dark,
      const Prefs(palette: AppPalette.mono, accent: AccentColor.coral),
    );
    expect(mono.colorScheme.primary, AccentColor.coral.color);
    expect(
      mono.colorScheme.surfaceContainerHigh.computeLuminance() < 0.2,
      isTrue,
    );
  });

  test('AMOLED держит поверхности чёрными, акцент остаётся пользователя', () {
    final theme = AppTheme.build(
      Brightness.dark,
      const Prefs(palette: AppPalette.amoled, accent: AccentColor.orchid),
    );
    expect(theme.colorScheme.surface, const Color(0xFF000000));
    expect(theme.colorScheme.surfaceContainerLowest, const Color(0xFF000000));
    expect(theme.scaffoldBackgroundColor, const Color(0xFF000000));
    // Контейнеры чуть светлеют, иначе карточки сливаются с фоном.
    expect(
      theme.colorScheme.surfaceContainerHigh,
      isNot(const Color(0xFF000000)),
    );
    expect(theme.colorScheme.primary, AccentColor.orchid.color);
  });

  test('светлая тема остаётся светлой при любом акценте', () {
    for (final accent in AccentColor.values) {
      final theme = AppTheme.build(Brightness.light, Prefs(accent: accent));
      expect(theme.brightness, Brightness.light);
      // Текст по поверхности тоже не должен сливаться: это и есть типичная
      // поломка при светлом акценте.
      expect(
        _contrast(theme.colorScheme.onSurface, theme.colorScheme.surface),
        greaterThan(4.5),
        reason: accent.name,
      );
    }
  });
}
