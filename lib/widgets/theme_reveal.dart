import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/app_motion.dart';

/// Круговое проявление новой темы: перед сменой снимаем экран, меняем тему и
/// стираем снимок расширяющимся кругом из точки нажатия.
class ThemeReveal extends StatefulWidget {
  const ThemeReveal({super.key, required this.child});

  final Widget child;

  /// Меняет тему через [change] с анимацией от [center] (глобальные коорд.).
  static Future<void> run(
    BuildContext context,
    Offset center,
    VoidCallback change,
  ) {
    final state = context.findAncestorStateOfType<_ThemeRevealState>();
    if (state == null) {
      change();
      return Future.value();
    }
    return state._run(center, change);
  }

  @override
  State<ThemeReveal> createState() => _ThemeRevealState();
}

class _ThemeRevealState extends State<ThemeReveal>
    with SingleTickerProviderStateMixin {
  final _boundary = GlobalKey();
  late final AnimationController _controller = AnimationController(vsync: this);
  ui.Image? _snapshot;
  Offset _center = Offset.zero;

  Future<void> _run(Offset center, VoidCallback change) async {
    final duration = Motion.of(context).micro(650);
    final boundary =
        _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (_snapshot != null || duration == Duration.zero || boundary == null) {
      change();
      return;
    }
    final ui.Image image;
    try {
      image = await boundary.toImage(
        pixelRatio: MediaQuery.devicePixelRatioOf(context),
      );
    } on Object {
      change();
      return;
    }
    if (!mounted) {
      image.dispose();
      return;
    }
    setState(() {
      _snapshot = image;
      _center = center;
    });
    change();
    _controller.duration = duration;
    await _controller.forward(from: 0);
    if (!mounted) return;
    setState(() => _snapshot = null);
    image.dispose();
  }

  @override
  void dispose() {
    _controller.dispose();
    _snapshot?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(key: _boundary, child: widget.child),
        if (snapshot != null)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _RevealPainter(
                    image: snapshot,
                    center: _center,
                    t: Curves.easeInOutCubic.transform(_controller.value),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RevealPainter extends CustomPainter {
  _RevealPainter({required this.image, required this.center, required this.t});

  final ui.Image image;
  final Offset center;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    double far(Offset corner) => (corner - center).distance;
    final maxRadius = [
      far(Offset.zero),
      far(Offset(size.width, 0)),
      far(Offset(0, size.height)),
      far(Offset(size.width, size.height)),
    ].reduce(math.max);
    final hole = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(Rect.fromCircle(center: center, radius: maxRadius * t));
    canvas.save();
    canvas.clipPath(hole);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RevealPainter old) =>
      old.t != t || old.image != image || old.center != center;
}
