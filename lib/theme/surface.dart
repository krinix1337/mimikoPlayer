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
      builder: (context, scrolling, _) => TweenAnimationBuilder<double>(
        // Живое размытие под движущимся списком — главный источник рывков:
        // на 120 Гц GPU не успевал пересчитывать его каждый кадр. Пока
        // экран едет, стекло плавно густеет до плотной подложки, после
        // остановки так же плавно возвращается. Резкая подмена раньше
        // читалась как моргание — здесь переход идёт за 220 мс.
        tween: Tween(end: scrolling || baseSigma <= 0 ? 0.0 : 1.0),
        // Уходит сразу (размытие под движущимся списком не считаем ни
        // кадра), возвращается плавно — один раз, когда экран уже стоит.
        duration: scrolling ? Duration.zero : const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        builder: (context, glass, _) => _build(
          shape: shape,
          glassy: baseSigma > 0,
          sigma: baseSigma * glass,
          color: Color.alphaBlend(
            baseColor,
            // Чем меньше стекла, тем плотнее подложка того же тона.
            scheme.surfaceContainer.withValues(alpha: (1 - glass) * 0.9),
          ),
        ),
      ),
    );
  }

  Widget _build({
    required BorderRadius shape,
    required bool glassy,
    required double sigma,
    required Color color,
  }) {
    final surfaceColor = color;
    Widget surface = Material(
      color: surfaceColor,
      borderRadius: shape,
      clipBehavior: Clip.antiAlias,
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
    // Фильтр остаётся в дереве и только выключается на время прокрутки.
    // Раньше он то появлялся, то исчезал, и всё содержимое панели (навигация,
    // мини-плеер с волной прогресса) пересоздавалось на каждом свайпе.
    if (glassy) {
      final blur = sigma > 0.5;
      surface = ClipRRect(
        borderRadius: shape,
        child: BackdropFilter.grouped(
          enabled: blur,
          filter: ui.ImageFilter.blur(
            sigmaX: blur ? sigma : 1,
            sigmaY: blur ? sigma : 1,
          ),
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
  }
}
