import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/blur_settings.dart';
import '../theme/keyboard_theme.dart';

/// Стеклянная шапка поверх прокручиваемой страницы: кнопки и мягкое размытие
/// без непрозрачной полосы. Заголовок проявляется, когда большая шапка ушла.
class GlassTopBar extends StatelessWidget {
  const GlassTopBar({
    super.key,
    required this.title,
    required this.controller,
    required this.revealAt,
    this.actions = const [],
    this.onBack,
  });

  final String title;
  final ScrollController controller;
  final double revealAt;
  final List<Widget> actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final top = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: top + kToolbarHeight + 20,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final offset = controller.hasClients ? controller.offset : 0.0;
          // Наверху страницы панель прозрачна: иначе над ярким hero виден
          // резкий тёмный прямоугольник. Стекло проявляется при прокрутке.
          final exposure = ((offset - 12) / 80).clamp(0.0, 1.0);
          final sigma = currentBlur.top * exposure;
          final glassColor = scheme.surface.withValues(
            alpha: kKeyboardTestTheme
                ? 0.95
                : (sigma > 0 ? 0.5 : 0.78) * exposure,
          );
          final shown = ((offset - revealAt) / 48).clamp(0.0, 1.0);

          return Stack(
            children: [
              if (exposure > 0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: _GlassBlur(sigma: sigma, tint: glassColor),
                  ),
                ),
              Positioned(
                top: top,
                left: 4,
                right: 4,
                height: kToolbarHeight,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: l.playerBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed:
                          onBack ?? () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Opacity(
                        opacity: shown,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    ...actions,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Размытие с плавным сходом к нижней кромке: одиночный BackdropFilter
/// обрывается заметной полосой. Полосы фильтруются с убывающей силой,
/// последняя - уже без размытия, поэтому переход в чёткий контент мягкий.
class _GlassBlur extends StatelessWidget {
  const _GlassBlur({required this.sigma, required this.tint});

  final double sigma;
  final Color tint;

  static const _fade = [1.0, 0.85, 0.7, 0.55, 0.4, 0.25, 0.1];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            for (final step in _fade)
              Expanded(
                child: sigma * step < 0.3
                    ? const SizedBox.expand()
                    : ClipRect(
                        // BackdropFilter не маскируется градиентом: внутри
                        // ShaderMask/Opacity он теряет подложку и не блюрит.
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(
                            sigmaX: sigma * step,
                            sigmaY: sigma * step,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
              ),
            const Expanded(child: SizedBox.expand()),
          ],
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [tint, tint.withValues(alpha: 0)],
            ),
          ),
        ),
      ],
    );
  }
}
