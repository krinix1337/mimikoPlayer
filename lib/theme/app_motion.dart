import 'package:flutter/material.dart';

import '../core/prefs/prefs.dart';

/// Длительности и кривые движения. Значения берёт из [Prefs], поэтому
/// «Анимации: выключены/быстрые/плавные» влияет на всё приложение сразу.
@immutable
class Motion {
  const Motion({required this.prefs});

  final Prefs prefs;

  static Motion of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MotionScope>();
    return scope?.motion ?? Motion(prefs: const Prefs());
  }

  bool get enabled => prefs.animations != AnimationsSpeed.off;

  Duration micro([int ms = 120]) => prefs.scaleMs(ms);

  // M3: emphasized 500 мс, decelerate 400 (вход), accelerate 200 (выход).
  Duration get enter => micro(400);
  Duration get exit => micro(200);
  Duration get sharedAxis => micro(500);
  Duration get morph => micro(400);
}

class MotionScope extends InheritedWidget {
  const MotionScope({super.key, required this.motion, required super.child});

  final Motion motion;

  @override
  bool updateShouldNotify(MotionScope oldWidget) =>
      oldWidget.motion.prefs != motion.prefs;
}

/// Держатель для мест вне дерева виджетов — pageBuilder роутера строит
/// анимацию без BuildContext темы. Обновляется вместе с [MotionScope].
Motion currentMotion = Motion(prefs: const Prefs());

/// Морфинг формы: круг ↔ скруглённый квадрат, как в Expressive-кнопках.
class MorphShape extends StatelessWidget {
  const MorphShape({
    super.key,
    required this.progress,
    required this.size,
    required this.color,
    this.cornerRadius,
  });

  /// 0 = круг, 1 = квадрат со скруглением.
  final double progress;
  final double size;
  final Color color;
  final double? cornerRadius;

  @override
  Widget build(BuildContext context) {
    final radius = lerpDouble(
      size / 2,
      cornerRadius ?? Motion.of(context).prefs.corner.radius * 0.6,
      progress,
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

double lerpDouble(double a, double b, double t) =>
    a + (b - a) * t.clamp(0.0, 1.0);
