import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Один вариант в [ConnectedButtonGroup].
class ConnectedOption<T> {
  const ConnectedOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Группа соединённых кнопок в духе M3 Expressive: сегменты одного ряда с
/// зазором 2 px, снаружи скругление полное, внутри небольшое; выбранный
/// сегмент становится пилюлей целиком и получает галочку.
class ConnectedButtonGroup<T> extends StatelessWidget {
  const ConnectedButtonGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onPick,
    this.expand = true,
  });

  final List<ConnectedOption<T>> options;
  final T selected;
  final ValueChanged<T> onPick;

  /// true — сегменты делят ширину поровну; false — по содержимому.
  final bool expand;

  static const double height = 40;
  static const double _gap = 2;
  static const double _outer = height / 2;
  static const double _inner = 8;

  @override
  Widget build(BuildContext context) {
    // Галочка влезает, только пока сегментов немного.
    final showCheck = options.length <= 3;
    final children = <Widget>[];
    for (var i = 0; i < options.length; i++) {
      if (i > 0) children.add(const SizedBox(width: _gap));
      final option = options[i];
      final segment = _Segment(
        option: option,
        selected: option.value == selected,
        first: i == 0,
        last: i == options.length - 1,
        showCheck: showCheck,
        onTap: () => onPick(option.value),
      );
      children.add(expand ? Expanded(child: segment) : segment);
    }
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.option,
    required this.selected,
    required this.first,
    required this.last,
    required this.showCheck,
    required this.onTap,
  });

  final ConnectedOption<T> option;
  final bool selected;
  final bool first;
  final bool last;
  final bool showCheck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final motion = Motion.of(context);
    const outer = Radius.circular(ConnectedButtonGroup._outer);
    const inner = Radius.circular(ConnectedButtonGroup._inner);
    final radius = selected
        ? const BorderRadius.all(outer)
        : BorderRadius.horizontal(
            left: first ? outer : inner,
            right: last ? outer : inner,
          );
    final background = selected
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;
    final foreground = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    final icon = selected && showCheck ? Icons.check_rounded : option.icon;
    final duration = motion.micro(220);
    final style = theme.textTheme.labelLarge?.copyWith(
      color: foreground,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
    );
    final hPad = showCheck ? 12.0 : 6.0;

    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(
          minHeight: ConnectedButtonGroup.height,
        ),
        decoration: BoxDecoration(color: background, borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSize(
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    child: icon == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(icon, size: 18, color: foreground),
                          ),
                  ),
                  Flexible(
                    // Короткие подписи держим в одну строку и ужимаем, только
                    // если не влезают; длинные фразы переносим по словам.
                    child: option.label.length > 14
                        ? Text(
                            option.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: style,
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              option.label,
                              maxLines: 1,
                              softWrap: false,
                              style: style,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
