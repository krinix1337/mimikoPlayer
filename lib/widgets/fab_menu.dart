import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import 'pressable.dart';

class FabMenuItem {
  const FabMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// FAB Menu из M3 Expressive: квадратная кнопка «+» раскрывается в столбик
/// пилюль-действий, а сама превращается в круглую «×».
class FabMenu extends StatefulWidget {
  const FabMenu({super.key, required this.items, this.tooltip});

  final List<FabMenuItem> items;
  final String? tooltip;

  @override
  State<FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  bool _open = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _controller.duration = Motion.of(context).micro(380);
    _open ? _controller.forward() : _controller.reverse();
  }

  void _pick(FabMenuItem item) {
    _toggle();
    item.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final count = widget.items.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < count; i++)
          // Пункты выезжают снизу вверх по очереди.
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final start = (count - 1 - i) / count * 0.4;
              final t = Curves.easeOutBack.transform(
                ((_controller.value - start) / (1 - start)).clamp(0.0, 1.0),
              );
              if (t == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, (1 - t) * 24),
                    child: Transform.scale(
                      scale: 0.8 + 0.2 * t,
                      alignment: Alignment.centerRight,
                      child: child,
                    ),
                  ),
                ),
              );
            },
            child: PressableScale(
              onTap: () => _pick(widget.items[i]),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.items[i].icon,
                      color: scheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.items[i].label,
                      style: text.titleSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Tooltip(
          message: widget.tooltip ?? '',
          child: PressableScale(
            onTap: _toggle,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = Curves.easeInOutCubic.transform(_controller.value);
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      scheme.primaryContainer,
                      scheme.primary,
                      t,
                    ),
                    borderRadius: BorderRadius.circular(16 + 12 * t),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Transform.rotate(
                    angle: t * 3.14159 * 0.75,
                    child: Icon(
                      Icons.add_rounded,
                      size: 28,
                      color: Color.lerp(
                        scheme.onPrimaryContainer,
                        scheme.onPrimary,
                        t,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
