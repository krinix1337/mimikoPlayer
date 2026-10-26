import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Компактные пометки трека: 18+, ИИ, версия без цензуры.
///
/// Высота фиксированная (18), чтобы строки списка не дёргались от появления
/// бейджа; цвета — тональные, на полупрозрачной подложке.
class TrackBadges extends StatelessWidget {
  const TrackBadges({
    super.key,
    this.explicit = false,
    this.ai = false,
    this.uncensored = false,
  });

  final bool explicit;
  final bool ai;
  final bool uncensored;

  bool get hasBadges => explicit || ai || uncensored;

  @override
  Widget build(BuildContext context) {
    if (!hasBadges) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 4,
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (explicit)
          _Badge(
            label: l.badgeExplicit,
            foreground: scheme.error,
            background: scheme.error.withValues(alpha: 0.14),
            border: scheme.error.withValues(alpha: 0.3),
          ),
        if (ai)
          _Badge(
            label: l.badgeAi,
            foreground: scheme.tertiary,
            background: scheme.tertiary.withValues(alpha: 0.16),
            border: scheme.tertiary.withValues(alpha: 0.32),
          ),
        if (uncensored)
          _Badge(
            label: l.badgeUncensored,
            foreground: scheme.primary,
            background: scheme.primary.withValues(alpha: 0.14),
            border: scheme.primary.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });

  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) => Container(
    height: 18,
    padding: const EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: border, width: 0.8),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10,
        height: 1,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: foreground,
      ),
    ),
  );
}
