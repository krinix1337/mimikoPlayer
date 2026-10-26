import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'blur_settings.dart';
import 'keyboard_theme.dart';
import 'scroll_activity.dart';

/// Панель поверх фона экрана: скругление, тонировка из цветовой схемы и мягкая
/// тень. Размытие подложки включается настройкой «Размытие»: на бюджетном
/// железе BackdropFilter не бесплатный, поэтому по умолчанию мягкий уровень.
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    required this.radius,
    this.color,
    this.padding,
    this.shadow = true,
    this.blurSigma,
  });

  final Widget child;
  final double radius;
  final Color? color;
  final EdgeInsets? padding;
  final bool shadow;

  /// null — взять из общих настроек размытия нижней панели.
  final double? blurSigma;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = BorderRadius.circular(radius);
    final baseSigma = blurSigma ?? currentBlur.bottom;
    final baseColor = color ?? scheme.surfaceContainerHigh;

    return ValueListenableBuilder<bool>(
      valueListenable: appScrollActive,
      builder: (context, scrolling, _) {
        // Пока идёт прокрутка, не пересчитываем BackdropFilter каждый кадр:
        // панель становится плотной, а стекло возвращается после остановки.
        final dense = scrolling && baseSigma > 0;
        final sigma = dense ? 0.0 : baseSigma;
        final surfaceColor = dense
            ? Color.alphaBlend(baseColor, scheme.surfaceContainerHigh)
            : baseColor;
        Widget surface = Material(
          color: surfaceColor,
          borderRadius: shape,
          clipBehavior: Clip.antiAlias,
          child: padding == null
              ? child
              : Padding(padding: padding!, child: child),
        );
        if (sigma > 0) {
          surface = ClipRRect(
            borderRadius: shape,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: surface,
            ),
          );
        }
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: shape,
            boxShadow: shadow && !kKeyboardTestTheme
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: surface,
        );
      },
    );
  }
}
