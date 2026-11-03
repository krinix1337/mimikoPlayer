import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/blur_settings.dart';
import '../theme/keyboard_theme.dart';
import '../theme/scroll_activity.dart';

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
    final barHeight = top + kToolbarHeight;
    const fadeHeight = 22.0;

    return SizedBox(
      height: barHeight + fadeHeight,
      child: ValueListenableBuilder<bool>(
        valueListenable: appScrollActive,
        builder: (context, scrolling, _) => AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final offset = controller.hasClients ? controller.offset : 0.0;
            // Наверху страницы панель прозрачна: иначе над ярким hero виден
            // резкий тёмный прямоугольник. Стекло проявляется при прокрутке.
            final exposure = ((offset - 12) / 80).clamp(0.0, 1.0);
            final sigma = currentBlur.top;
            // Стекло не выключается на время прокрутки: подмена на плотную
            // подложку и обратно читалась как моргание панели.
            final useBlur = sigma > 0.3;
            final baseAlpha = kKeyboardTestTheme
                ? 0.95
                : (sigma > 0 ? 0.5 : 0.78);
            final tintTop = scheme.surface.withValues(
              alpha: baseAlpha * exposure,
            );
            // Тон на срезе фильтра и сразу под ним одинаковый: так кромка
            // размытия не читается отдельной полосой. Ниже тон сходит на нет.
            final tintCut = scheme.surface.withValues(
              alpha: baseAlpha * 0.7 * exposure,
            );
            final shown = ((offset - revealAt) / 48).clamp(0.0, 1.0);
            final blurGlass = DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [tintTop, tintCut],
                ),
              ),
            );
            final fadeGlass = DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [tintCut, tintCut.withValues(alpha: 0)],
                ),
              ),
            );

            return Stack(
              children: [
                if (exposure > 0) ...[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: barHeight,
                    child: IgnorePointer(
                      child: ClipRect(
                        child: useBlur
                            ? BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                  sigmaX: sigma,
                                  sigmaY: sigma,
                                ),
                                child: blurGlass,
                              )
                            : blurGlass,
                      ),
                    ),
                  ),
                  Positioned(
                    top: barHeight,
                    left: 0,
                    right: 0,
                    height: fadeHeight,
                    child: IgnorePointer(child: fadeGlass),
                  ),
                ],
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
      ),
    );
  }
}
