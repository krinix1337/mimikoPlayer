import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Форма «печенье» из набора фигур M3 Expressive: круг с мягкими
/// лепестками по краю.
Path cookiePath(Size size, {int lobes = 9, double depth = 0.06}) {
  final center = size.center(Offset.zero);
  final base = size.shortestSide / 2;
  final path = Path();
  const samples = 180;
  for (var i = 0; i <= samples; i++) {
    final a = i / samples * 2 * math.pi;
    final r = base * (1 - depth + depth * math.cos(lobes * a));
    final p = center + Offset(math.cos(a), math.sin(a)) * r;
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

class CookieClipper extends CustomClipper<Path> {
  const CookieClipper({this.lobes = 9, this.depth = 0.06});

  final int lobes;
  final double depth;

  @override
  Path getClip(Size size) => cookiePath(size, lobes: lobes, depth: depth);

  @override
  bool shouldReclip(CookieClipper old) =>
      old.lobes != lobes || old.depth != depth;
}
