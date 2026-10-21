import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Обложка трека: кэш на диск, заглушка-конверт, скругление по токенам M3.
///
/// URL бывает трёх видов: http(s) из каталога, `file://` — вынутая из тега
/// картинка локального файла, `data:` — то же самое, но без временного файла.
class TrackCover extends StatelessWidget {
  const TrackCover({
    super.key,
    required this.url,
    this.size = 48,
    this.radius,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final double size;

  /// null = взять скругление из темы.
  final double? radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        radius ?? _defaultRadius(context, size),
      ),
      child: SizedBox(width: size, height: size, child: _image(scheme)),
    );
  }

  static double _defaultRadius(BuildContext context, double size) {
    final corner = Theme.of(context).cardTheme.shape;
    final base = corner is RoundedRectangleBorder
        ? (corner.borderRadius as BorderRadius).topLeft.x
        : 12.0;
    // Маленькие обложки в списках не должны превращаться в мыло из-за
    // карточного радиуса.
    return size < 56 ? (base * 0.45).clamp(6.0, 14.0) : (base * 0.55).clamp(8.0, 24.0);
  }

  Widget _image(ColorScheme scheme) {
    final value = url;
    if (value == null || value.isEmpty) return _Fallback(scheme: scheme, size: size);

    if (value.startsWith('data:')) {
      final comma = value.indexOf(',');
      final bytes = comma == -1
          ? null
          : base64Decode(value.substring(comma + 1));
      if (bytes == null) return _Fallback(scheme: scheme, size: size);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        cacheWidth: (size * 3).round(),
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _Fallback(scheme: scheme, size: size),
      );
    }

    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      final path = Uri.parse(value).toFilePath();
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        cacheWidth: (size * 3).round(),
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _Fallback(scheme: scheme, size: size),
      );
    }

    return CachedNetworkImage(
      imageUrl: value,
      fit: BoxFit.cover,
      memCacheWidth: (size * 3).round(),
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (context, _) =>
          ColoredBox(color: scheme.surfaceContainerHighest),
      errorWidget: (context, _, _) => _Fallback(scheme: scheme, size: size),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.scheme, required this.size});

  final ColorScheme scheme;
  final double size;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: scheme.surfaceContainerHighest,
    child: Icon(
      Icons.graphic_eq_rounded,
      size: size * 0.5,
      color: scheme.onSurfaceVariant,
    ),
  );
}

/// Фон из обложки. Реального блюра нет: картинка берётся в 24 пикселя и
/// растягивается — на дешёвом железе это дешевле ImageFilter в разы, а
/// выглядит как тот же размытый цветной фон.
class BlurredCover extends StatelessWidget {
  const BlurredCover({super.key, this.url, this.opacity = 0.55});

  final String? url;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final value = url;
    if (value == null || value.isEmpty) {
      return ColoredBox(color: scheme.surface);
    }

    return RepaintBoundary(
      child: Opacity(
        opacity: opacity,
        child: CachedNetworkImage(
          imageUrl: value,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          // 32 пикселя на всю ширину: растянутая картинка и есть «размытие»,
          // только без дорогого ImageFilter на каждый кадр.
          memCacheWidth: 32,
          filterQuality: FilterQuality.low,
          placeholder: (context, _) => ColoredBox(color: scheme.surface),
          errorWidget: (context, _, _) => ColoredBox(color: scheme.surface),
        ),
      ),
    );
  }
}

/// Медленно живущие цветовые пятна поверх фона.
///
/// Никакого CustomPaint: каждый слой — готовый градиент в RepaintBoundary,
/// который аниматор только сдвигает. Перерисовка шейдера на весь экран каждый
/// кадр — то, из-за чего на Mali в бюджетном Xiaomi и начинались подтормаживания.
class ColorBlobs extends StatefulWidget {
  const ColorBlobs({
    super.key,
    required this.colors,
    this.speed = 1,
  });

  final List<Color> colors;

  /// 0 = неподвижно (пользователь выключил анимации).
  final double speed;

  @override
  State<ColorBlobs> createState() => _ColorBlobsState();
}

class _ColorBlobsState extends State<ColorBlobs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  );

  @override
  void initState() {
    super.initState();
    if (widget.speed > 0) _controller.repeat();
  }

  @override
  void didUpdateWidget(ColorBlobs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.speed == 0) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.colors.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value * 6.2831853 * widget.speed;
            return Stack(
              children: [
                for (var i = 0; i < widget.colors.length; i++)
                  _Blob(
                    color: widget.colors[i],
                    size: size,
                    index: i,
                    dx: 60 * _sin(t + i * 2.1),
                    dy: 70 * _cos((t + i * 2.1) * 0.8),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  static double _sin(double x) {
    var v = x % 6.2831853;
    if (v > 3.14159265) v -= 6.2831853;
    return 0.63661977 * v + 0.36761248 * v * (v < 0 ? -v : v);
  }

  static double _cos(double x) => _sin(x + 1.5707963);
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.color,
    required this.size,
    required this.index,
    required this.dx,
    required this.dy,
  });

  final Color color;
  final Size size;
  final int index;
  final double dx;
  final double dy;

  @override
  Widget build(BuildContext context) {
    final radius = size.shortestSide * (0.62 + 0.1 * index);
    return Transform.translate(
      offset: Offset(
        size.width * (0.3 + 0.22 * index) - radius / 2 + dx,
        size.height * (0.18 + 0.2 * index) - radius / 2 + dy,
      ),
      child: RepaintBoundary(
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0)],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
