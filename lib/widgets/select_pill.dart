import 'package:flutter/material.dart';

import 'pressable.dart';

/// Пилюля выбора M3 Expressive: тональная подложка, у выбранной — заливка
/// акцентом и галочка вместо иконки. Цвет и галочка перетекают плавно,
/// пилюля пружинит под пальцем. Заменяет FilterChip, у которого фон
/// сливался с карточкой, а выбор переключался рывком.
class SelectPill extends StatelessWidget {
  const SelectPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  /// Число справа (сколько треков под фильтром); null — не показывать.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const duration = Duration(milliseconds: 220);
    final foreground = selected ? scheme.onPrimary : scheme.onSurface;
    final shownIcon = selected ? Icons.check_rounded : icon;

    return PressableScale(
      minScale: 0.92,
      onTap: onTap,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOutCubic,
        height: 40,
        padding: EdgeInsets.only(left: shownIcon == null ? 16 : 12, right: 16),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(selected ? 12 : 20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (shownIcon != null) ...[
              AnimatedSwitcher(
                duration: duration,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Icon(
                  shownIcon,
                  key: ValueKey(shownIcon),
                  size: 18,
                  color: selected ? scheme.onPrimary : scheme.primary,
                ),
              ),
              const SizedBox(width: 6),
            ],
            AnimatedDefaultTextStyle(
              duration: duration,
              style: theme.textTheme.labelLarge!.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
              child: Text(label),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: duration,
                style: theme.textTheme.labelMedium!.copyWith(
                  color: foreground.withValues(alpha: 0.7),
                ),
                child: Text('$count'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
