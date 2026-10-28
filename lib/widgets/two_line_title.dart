import 'package:flutter/material.dart';

/// Название карточки, которое всегда занимает высоту двух строк: в ряду
/// карточек подпись под ним (исполнитель, год) стоит на одном уровне, даже
/// если у соседа название короткое.
class TwoLineTitle extends StatelessWidget {
  const TwoLineTitle(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final resolved = DefaultTextStyle.of(context).style.merge(style);
    final fontSize = MediaQuery.textScalerOf(
      context,
    ).scale(resolved.fontSize ?? 14);
    final lineHeight = fontSize * (resolved.height ?? 1.2);
    return SizedBox(
      height: lineHeight * 2,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: resolved,
        strutStyle: StrutStyle.fromTextStyle(resolved, forceStrutHeight: true),
      ),
    );
  }
}
