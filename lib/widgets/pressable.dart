import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.haptic = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double minScale;

  /// Короткий отклик вибрацией: палец чувствует, что попал.
  final bool haptic;

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

  void _tap() {
    if (widget.haptic) HapticFeedback.selectionClick();
    widget.onTap?.call();
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

  Offset? _down;

  /// Нажатие рисуем по сырому касанию, а не по onTapDown: в прокручиваемых
  /// списках Flutter придерживает onTapDown ~100 мс, чтобы отличить тап от
  /// прокрутки, и кнопка реагировала заметно позже пальца. Если палец
  /// поехал — это прокрутка, отпускаем.
  Widget _gesture({required Widget child}) => Listener(
    onPointerDown: (event) {
      if (widget.onTap == null && widget.onLongPress == null) return;
      _down = event.position;
      _setPressed(true);
    },
    onPointerMove: (event) {
      final down = _down;
      if (down != null && (event.position - down).distance > 12) {
        _down = null;
        _setPressed(false);
      }
    },
    onPointerUp: (_) {
      _down = null;
      _setPressed(false);
    },
    onPointerCancel: (_) {
      _down = null;
      _setPressed(false);
    },
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap == null ? null : _tap,
      onLongPress: widget.onLongPress,
      child: child,
    ),
  );
}

/// Иконка, которая не прыгает, а перетекает: старая сжимается с поворотом,
/// новая выпрыгивает с недобоем. Для play/pause, лайка и похожих кнопок.
class MorphIcon extends StatelessWidget {
  const MorphIcon(this.icon, {super.key, this.size, this.color});

  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    final child = Icon(icon, key: ValueKey(icon), size: size, color: color);
    if (!motion.enabled) return child;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: Tween(begin: 0.4, end: 1.0).animate(animation),
        child: RotationTransition(
          turns: Tween(begin: -0.12, end: 0.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
      ),
      child: child,
    );
  }
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
      curve: Interval(start.clamp(0.0, 0.9), 1, curve: Curves.easeOutCubic),
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
