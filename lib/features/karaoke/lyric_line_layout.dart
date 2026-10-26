import 'package:flutter/painting.dart';

/// Разбиение строки на визуальные строки при заданной ширине.
///
/// Нужно караоке-заливке: градиент должен идти по строкам по порядку,
/// а не поперёк всего двухстрочного блока.
class LyricLineLayout {
  const LyricLineLayout({
    required this.parts,
    required this.widths,
    required this.lineHeight,
  });

  final List<String> parts;
  final List<double> widths;
  final double lineHeight;

  static LyricLineLayout measure({
    required String text,
    required TextStyle style,
    required double width,
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.start,
      textScaler: textScaler,
    )..layout(maxWidth: width);
    final metrics = painter.computeLineMetrics();
    final fallbackWidth = painter.width;
    final parts = <String>[];
    final widths = <double>[];
    for (final metric in metrics) {
      // Позиция берётся по вертикали внутри строки: на границе перевода
      // строки getLineBoundary относит её к предыдущей строке.
      final top = metric.baseline - metric.ascent;
      final position = painter.getPositionForOffset(
        Offset(0.1, top + metric.height / 2),
      );
      final range = painter.getLineBoundary(position);
      parts.add(text.substring(range.start, range.end).trimRight());
      widths.add(metric.width);
    }
    painter.dispose();
    return LyricLineLayout(
      parts: parts.isEmpty ? [text] : parts,
      widths: widths.isEmpty ? [fallbackWidth] : widths,
      lineHeight: metrics.isEmpty ? 0 : metrics.first.height,
    );
  }
}
