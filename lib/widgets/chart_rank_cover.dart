import 'package:flutter/material.dart';

import 'track_cover.dart';

/// Номер в чарте стоит слева от обложки, а не поверх неё.
class ChartRankCover extends StatelessWidget {
  const ChartRankCover({
    super.key,
    required this.position,
    required this.coverUrl,
    this.size = 48,
    this.radius = 9,
  });

  final int position;
  final String? coverUrl;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 26,
          child: Text(
            '$position',
            textAlign: TextAlign.center,
            maxLines: 1,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(width: 6),
        TrackCover(url: coverUrl, size: size, radius: radius),
      ],
    );
  }
}
