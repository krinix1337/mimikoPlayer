import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/blur_settings.dart';

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
    final value = url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        radius ?? _defaultRadius(context, size),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: _image(
          scheme,
          value == null || value.isEmpty ? value : _sizedUrl(context, value),
        ),
      ),
    );
  }

  /// Яндекс отдаёт обложку любого размера: 400×400 в плеере на 340 dp — это
  /// почти трёхкратное растяжение и мыло. Просим размер под то, как обложка
  /// реально рисуется (с учётом плотности экрана).
  String _sizedUrl(BuildContext context, String value) {
    if (!value.startsWith('http') ||
        !value.contains('avatars.yandex.net') ||
        !RegExp(r'\d+x\d+$').hasMatch(value)) {
      return value;
    }
    final px = size.isFinite
        ? (size * MediaQuery.devicePixelRatioOf(context)).round()
        : 700;
    final target = px <= 200
        ? '200x200'
        : px <= 400
        ? '400x400'
        : px <= 700
        ? '700x700'
        : '1000x1000';
    return value.replaceFirst(RegExp(r'\d+x\d+$'), target);
  }

  static double _defaultRadius(BuildContext context, double size) {
    final corner = Theme.of(context).cardTheme.shape;
    final base = corner is RoundedRectangleBorder
        ? (corner.borderRadius as BorderRadius).topLeft.x
        : 12.0;
    // Маленькие обложки в списках не должны превращаться в мыло из-за
    // карточного радиуса.
    return size < 56
        ? (base * 0.45).clamp(6.0, 14.0)
        : (base * 0.55).clamp(8.0, 24.0);
  }

  Widget _image(ColorScheme scheme, String? value) {
    if (value == null || value.isEmpty) {
      return _Fallback(scheme: scheme, size: size);
    }

    if (value.startsWith('data:')) {
      final comma = value.indexOf(',');
      final bytes = comma == -1
          ? null
          : base64Decode(value.substring(comma + 1));
      if (bytes == null) return _Fallback(scheme: scheme, size: size);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        cacheWidth: _cacheWidth,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _Fallback(scheme: scheme, size: size),
      );
    }

    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      final path = Uri.parse(value).toFilePath();
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        cacheWidth: _cacheWidth,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _Fallback(scheme: scheme, size: size),
      );
    }

    return CachedNetworkImage(
      imageUrl: value,
      fit: BoxFit.cover,
      memCacheWidth: _cacheWidth,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (context, _) =>
          ColoredBox(color: scheme.surfaceContainerHighest),
      errorWidget: (context, _, _) => _Fallback(scheme: scheme, size: size),
    );
  }

  /// У карточек плейлистов размер приходит `double.infinity`: размеры для
  /// декодера и заглушки в этом случае брать неоткуда. Без этой проверки
  /// картинка не декодировалась, и плитки оставались серыми квадратами.
  int? get _cacheWidth =>
      size.isFinite ? (size * 3).round().clamp(48, 1024) : null;
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
      size: size.isFinite ? size * 0.5 : 40,
      color: scheme.onSurfaceVariant,
    ),
  );
}

/// Фон из обложки: копия картинки с настоящим `ImageFilter.blur`, сила берётся
/// из настроек «Размытие». Слой кэшируется, чтобы не пересчитывать blur.
class BlurredCover extends StatelessWidget {
  const BlurredCover({
    super.key,
    this.url,
    this.opacity = 0.55,
    this.blur = true,
  });

  final String? url;
  final double opacity;

  /// true — мягкий размытый фон; false — резкая обложка.
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final value = url;
    if (value == null || value.isEmpty) {
      return ColoredBox(color: scheme.surface);
    }

    // Раньше «размытием» было растяжение картинки 168 px на весь экран:
    // на большой обложке это давало видимые квадраты. Теперь картинка
    // декодируется крупнее, а мягкость даёт настоящий blur; слой кэшируется
    // в RepaintBoundary и не перерисовывается на каждом кадре.
    final sigma = currentBlur.cover;
    final content = blur && sigma > 0
        ? Transform.scale(
            // Чуть крупнее экрана, чтобы прозрачные края после blur не
            // проступали полосами у границ.
            scale: 1.2,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: _image(value, scheme),
            ),
          )
        : _image(value, scheme);

    return RepaintBoundary(
      child: Opacity(opacity: opacity, child: content),
    );
  }

  Widget _image(String value, ColorScheme scheme) {
    final fallback = ColoredBox(color: scheme.surface);
    const width = 512;
    const quality = FilterQuality.medium;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: value,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        memCacheWidth: width,
        filterQuality: quality,
        placeholder: (context, _) => fallback,
        errorWidget: (context, _, _) => fallback,
      );
    }

    // Локальные файлы и офлайн-обложки: у них нет http-адреса, а фон нужен.
    final Image image;
    if (value.startsWith('data:')) {
      final comma = value.indexOf(',');
      if (comma == -1) return fallback;
      image = Image.memory(
        base64Decode(value.substring(comma + 1)),
        fit: BoxFit.cover,
        cacheWidth: width,
        filterQuality: quality,
        gaplessPlayback: true,
      );
    } else {
      image = Image.file(
        File(Uri.parse(value).toFilePath()),
        fit: BoxFit.cover,
        cacheWidth: width,
        filterQuality: quality,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: image,
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
    this.strength = 0.5,
  });

  final List<Color> colors;

  /// 0 = неподвижно (пользователь выключил анимации).
  final double speed;

  /// Плотность пятен: 0.5 — как на главной, 0.38 — деликатный фон стекла.
  final double strength;

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
                    strength: widget.strength,
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
    this.strength = 0.5,
  });

  final Color color;
  final Size size;
  final int index;
  final double dx;
  final double dy;
  final double strength;

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
              colors: [
                color.withValues(alpha: strength),
                color.withValues(alpha: 0),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
