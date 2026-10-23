import 'package:flutter/material.dart';

/// Панель поверх фона экрана: скругление, тонировка из цветовой схемы и мягкая
/// тень. Размытие подложки через BackdropFilter здесь не используется — оно
/// стоило кадров на бюджетном железе.
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    required this.radius,
    this.color,
    this.padding,
    this.shadow = true,
  });

  final Widget child;
  final double radius;
  final Color? color;
  final EdgeInsets? padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.30),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: color ?? scheme.surfaceContainerHigh,
        borderRadius: shape,
        clipBehavior: Clip.antiAlias,
        child: padding == null
            ? child
            : Padding(padding: padding!, child: child),
      ),
    );
  }
}
