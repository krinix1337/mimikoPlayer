import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Индикатор загрузки M3 Expressive: вращающаяся фигура, которая перетекает
/// между формами («печенье» с разным числом лепестков) и слегка пульсирует.
class ExpressiveLoader extends StatefulWidget {
  const ExpressiveLoader({super.key, this.color, this.size});

  final Color? color;

  /// Сторона квадрата; по умолчанию занимает всё доступное место (до 48).
  final double? size;

  @override
  State<ExpressiveLoader> createState() => _ExpressiveLoaderState();
}

class _ExpressiveLoaderState extends State<ExpressiveLoader>
    with SingleTickerProviderStateMixin {
  // Один цикл — смена всех форм и полный оборот.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.of(context).enabled) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final child = RepaintBoundary(
      child: CustomPaint(
        painter: _LoaderPainter(animation: _controller, color: color),
      ),
    );
    final size = widget.size;
    if (size != null) return SizedBox.square(dimension: size, child: child);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 48, maxHeight: 48),
      child: AspectRatio(aspectRatio: 1, child: child),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  _LoaderPainter({required this.animation, required this.color})
    : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  // Число лепестков у форм по очереди: 0 — почти круг.
  static const _lobes = [7, 4, 9, 5, 0, 6];

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final steps = _lobes.length;
    final pos = t * steps;
    final index = pos.floor() % steps;
    final next = (index + 1) % steps;
    // Форма держится, потом быстро перетекает в следующую.
    final local = pos - pos.floor();
    final m = Curves.easeInOutCubic.transform(
      ((local - 0.55) / 0.45).clamp(0.0, 1.0),
    );
    final center = size.center(Offset.zero);
    final pulse = 1 + 0.06 * math.sin(t * 2 * math.pi * steps);
    final base = size.shortestSide / 2 * 0.82 * pulse;
    final rotation = t * 2 * math.pi * 1.5;

    double lobe(int k, double angle) =>
        k == 0 ? 0 : math.cos(k * angle) * (k >= 8 ? 0.09 : 0.13);

    final path = Path();
    const samples = 120;
    for (var i = 0; i <= samples; i++) {
      final a = i / samples * 2 * math.pi;
      final wave = (1 - m) * lobe(_lobes[index], a) + m * lobe(_lobes[next], a);
      final r = base * (1 - 0.13 + wave);
      final p =
          center + Offset(math.cos(a + rotation), math.sin(a + rotation)) * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_LoaderPainter old) => old.color != color;
}
