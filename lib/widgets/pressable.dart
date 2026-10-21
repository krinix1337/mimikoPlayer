import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Пружинное нажатие — то, чем M3 Expressive отличается от плоского M3:
/// кнопка сжимается под пальцем и отпускается с недобоем.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.minScale = 0.94,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double minScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
    reverseDuration: const Duration(milliseconds: 320),
  );
  bool _pressed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    _pressed = value;
    if (value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    if (!motion.enabled) return _gesture(child: widget.child);

    return _gesture(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeOutBack.transform(_controller.value);
          return Transform.scale(
            scale: 1 + (widget.minScale - 1) * t,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }

  Widget _gesture({required Widget child}) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: widget.onTap,
    onLongPress: widget.onLongPress,
    onTapDown: (_) => _setPressed(true),
    onTapUp: (_) => _setPressed(false),
    onTapCancel: () => _setPressed(false),
    child: child,
  );
}

/// Появление блока: снизу вверх с затуханием. Для секций коллекции и карточек.
class RiseIn extends StatelessWidget {
  const RiseIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 24,
  });

  final Widget child;
  final Duration delay;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    if (!motion.enabled) return child;

    // Задержка каскада сделана через Interval: одна анимация на элемент
    // вместо таймеров, которые надо ловить при выходе экрана из сборки.
    final total = motion.enter + delay;
    final start = total.inMilliseconds == 0
        ? 0.0
        : delay.inMilliseconds / total.inMilliseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(
        start.clamp(0.0, 0.9),
        1,
        curve: Curves.easeOutCubic,
      ),
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, offset * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
