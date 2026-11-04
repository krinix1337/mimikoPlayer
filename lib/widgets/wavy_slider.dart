import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Полоса перемотки в духе M3 Expressive: пройденная часть — бегущая волна,
/// оставшаяся — ровная дорожка, ручка — вертикальная палочка с зазором.
/// На паузе и при перетаскивании волна плавно разглаживается в линию.
class WavySlider extends StatefulWidget {
  const WavySlider({
    super.key,
    required this.value,
    required this.playing,
    this.onChanged,
    this.onChangeEnd,
  });

  /// 0..1.
  final double value;
  final bool playing;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;

  @override
  State<WavySlider> createState() => _WavySliderState();
}

class _WavySliderState extends State<WavySlider> with TickerProviderStateMixin {
  // Фаза волны: один период за 1.6 с.
  late final AnimationController _phase = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  // Высота волны: 1 — волна, 0 — прямая.
  late final AnimationController _amp = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  bool _dragging = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(WavySlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final animated = Motion.of(context).micro(100) > Duration.zero;
    final wavy = widget.playing && !_dragging;
    if (wavy && animated) {
      if (!_phase.isAnimating) _phase.repeat();
    } else {
      _phase.stop();
    }
    if (animated) {
      wavy ? _amp.forward() : _amp.reverse();
    } else {
      _amp.value = wavy ? 1 : 0;
    }
  }

  @override
  void dispose() {
    _phase.dispose();
    _amp.dispose();
    super.dispose();
  }

  double _valueAt(Offset local, double width) =>
      ((local.dx - _WavePainter.inset) / (width - _WavePainter.inset * 2))
          .clamp(0.0, 1.0);

  void _start(Offset local, double width) {
    setState(() => _dragging = true);
    _sync();
    widget.onChanged?.call(_valueAt(local, width));
  }

  void _end(double value) {
    setState(() => _dragging = false);
    _sync();
    widget.onChangeEnd?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = widget.onChanged != null;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Semantics(
          slider: true,
          value: '${(widget.value * 100).round()}%',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: enabled
                ? (d) => _start(d.localPosition, width)
                : null,
            onHorizontalDragUpdate: enabled
                ? (d) => widget.onChanged!(_valueAt(d.localPosition, width))
                : null,
            onHorizontalDragEnd: enabled ? (_) => _end(widget.value) : null,
            onHorizontalDragCancel: enabled ? () => _end(widget.value) : null,
            onTapDown: enabled ? (d) => _start(d.localPosition, width) : null,
            onTapUp: enabled
                ? (d) => _end(_valueAt(d.localPosition, width))
                : null,
            child: SizedBox(
              height: 44,
              width: width,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _WavePainter(
                    value: widget.value,
                    phase: _phase,
                    amp: _amp,
                    dragging: _dragging,
                    active: enabled ? scheme.primary : scheme.onSurfaceVariant,
                    inactive: scheme.onSurface.withValues(alpha: 0.18),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.value,
    required this.phase,
    required this.amp,
    required this.dragging,
    required this.active,
    required this.inactive,
    this.stroke = 4,
    this.amplitude = 3.5,
    this.gap = 6,
    this.handle = true,
  }) : super(repaint: Listenable.merge([phase, amp]));

  static const double inset = 4;
  static const double _wavelength = 36;

  final double stroke;
  final double amplitude;
  final double gap;
  final bool handle;

  final double value;
  final Animation<double> phase;
  final Animation<double> amp;
  final bool dragging;
  final Color active;
  final Color inactive;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final left = handle ? inset : stroke / 2;
    final right = size.width - left;
    final x = left + (right - left) * value.clamp(0.0, 1.0);
    final paint = Paint()
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Пройденная часть — волна.
    final waveEnd = x - gap;
    if (waveEnd > left) {
      final a = amplitude * Curves.easeInOut.transform(amp.value);
      final shift = phase.value * 2 * math.pi;
      final path = Path();
      for (var px = left; px <= waveEnd; px += 1) {
        final y = cy + a * math.sin(px / _wavelength * 2 * math.pi - shift);
        px == left ? path.moveTo(px, y) : path.lineTo(px, y);
      }
      canvas.drawPath(path, paint..color = active);
    }

    // Оставшаяся часть — ровная дорожка и точка-остановка в конце.
    final restStart = x + gap;
    if (restStart < right) {
      canvas.drawLine(
        Offset(restStart, cy),
        Offset(right, cy),
        paint..color = inactive,
      );
      canvas.drawCircle(Offset(right, cy), stroke / 2, Paint()..color = active);
    }

    if (!handle) return;
    // Ручка — палочка; при перетаскивании тоньше, как в M3.
    final handleWidth = dragging ? 2.0 : 4.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, cy), width: handleWidth, height: 24),
        const Radius.circular(2),
      ),
      Paint()..color = active,
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.value != value ||
      old.dragging != dragging ||
      old.active != active ||
      old.inactive != inactive;
}

/// Волнистый индикатор прогресса без управления пальцем (мини-плеер).
class WavyProgress extends StatefulWidget {
  const WavyProgress({
    super.key,
    required this.value,
    required this.playing,
    this.height = 10,
    this.stroke = 3,
    this.amplitude = 2,
  });

  final double value;
  final bool playing;
  final double height;
  final double stroke;
  final double amplitude;

  @override
  State<WavyProgress> createState() => _WavyProgressState();
}

class _WavyProgressState extends State<WavyProgress>
    with TickerProviderStateMixin {
  late final AnimationController _phase = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  late final AnimationController _amp = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(WavyProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final animated = Motion.of(context).micro(100) > Duration.zero;
    if (widget.playing && animated) {
      if (!_phase.isAnimating) _phase.repeat();
    } else {
      _phase.stop();
    }
    if (animated) {
      widget.playing ? _amp.forward() : _amp.reverse();
    } else {
      _amp.value = widget.playing ? 1 : 0;
    }
  }

  @override
  void dispose() {
    _phase.dispose();
    _amp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _WavePainter(
            value: widget.value,
            phase: _phase,
            amp: _amp,
            dragging: false,
            active: scheme.primary,
            inactive: scheme.onSurface.withValues(alpha: 0.12),
            stroke: widget.stroke,
            amplitude: widget.amplitude,
            gap: 4,
            handle: false,
          ),
        ),
      ),
    );
  }
}
