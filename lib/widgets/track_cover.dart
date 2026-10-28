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
/// из настроек «Размытие».
///
/// Размытие считается один раз: обложка декодируется в крошечную копию,
/// размывается в офскрин-картинку и кэшируется. На экран идёт обычная
/// картинка. Живой `ImageFiltered` пересчитывался на каждом кадре любой
/// анимации (переход в плеер, свайпы) и давал до 80 мс отрисовки на кадр.
class BlurredCover extends StatefulWidget {
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
  State<BlurredCover> createState() => _BlurredCoverState();
}

class _BlurredCoverState extends State<BlurredCover> {
  /// Готовые размытые картинки: фон главной, плеера и каталога часто
  /// показывает одну и ту же обложку.
  static final Map<String, ui.Image> _cache = {};
  static const int _cacheSize = 16;

  /// Сторона уменьшенной копии. Уменьшение само по себе размывает, а
  /// растягивание уже размытой картинки не даёт видимых артефактов.
  static const int _side = 96;

  ui.Image? _blurred;
  String? _key;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  double get _sigma => currentBlur.cover;

  bool get _wantsBlur => widget.blur && _sigma > 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(BlurredCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url || oldWidget.blur != widget.blur) {
      _resolve();
    }
  }

  @override
  void dispose() {
    _unlisten();
    super.dispose();
  }

  void _unlisten() {
    final listener = _listener;
    if (listener != null) _stream?.removeListener(listener);
    _stream = null;
    _listener = null;
  }

  void _resolve() {
    final value = widget.url;
    if (!_wantsBlur || value == null || value.isEmpty) {
      _unlisten();
      _key = null;
      return;
    }
    final key = '$value|$_sigma';
    if (key == _key) return;
    _key = key;
    _unlisten();

    final cached = _cache[key];
    if (cached != null) {
      // Свежесть в LRU: недавно показанные обложки вытесняются последними.
      _cache
        ..remove(key)
        ..[key] = cached;
      _blurred = cached;
      return;
    }

    final provider = _provider(value);
    if (provider == null) return;
    final screen = MediaQuery.sizeOf(context);
    final stream = ResizeImage(
      provider,
      width: _side,
      height: _side,
      policy: ResizeImagePolicy.fit,
    ).resolve(createLocalImageConfiguration(context));
    final listener = ImageStreamListener((info, _) async {
      _unlisten();
      final blurred = await _blur(info.image, screen);
      info.dispose();
      if (blurred == null) return;
      _cache[key] = blurred;
      if (_cache.length > _cacheSize) _cache.remove(_cache.keys.first);
      if (!mounted || _key != key) return;
      setState(() => _blurred = blurred);
    }, onError: (_, _) => _unlisten());
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  /// Сила размытия задана в логических пикселях экрана; на маленькой копии
  /// её пересчитываем пропорционально. Край тянем clamp-ом, чтобы фон не
  /// темнел к границам, как было с прозрачной кромкой фильтра.
  Future<ui.Image?> _blur(ui.Image source, Size screen) async {
    try {
      final width = source.width;
      final height = source.height;
      final sigma = (_sigma * height / screen.height.clamp(1, 10000)).clamp(
        1.0,
        12.0,
      );
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawImage(
        source,
        Offset.zero,
        Paint()
          ..imageFilter = ui.ImageFilter.blur(
            sigmaX: sigma,
            sigmaY: sigma,
            tileMode: TileMode.clamp,
          ),
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(width, height);
      picture.dispose();
      return image;
    } on Object {
      return null;
    }
  }

  ImageProvider? _provider(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return CachedNetworkImageProvider(value);
    }
    if (value.startsWith('data:')) {
      final comma = value.indexOf(',');
      if (comma == -1) return null;
      return MemoryImage(base64Decode(value.substring(comma + 1)));
    }
    try {
      return FileImage(File(Uri.parse(value).toFilePath()));
    } on Object {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final value = widget.url;
    if (value == null || value.isEmpty) {
      return ColoredBox(color: scheme.surface);
    }

    if (_wantsBlur) {
      final blurred = _blurred;
      // Пока новая обложка готовится, держим прошлую: без мигания фона.
      if (blurred == null) return ColoredBox(color: scheme.surface);
      return RepaintBoundary(
        child: SizedBox.expand(
          child: RawImage(
            image: blurred,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            // Прозрачность самой картинки, без слоя Opacity на весь экран.
            opacity: AlwaysStoppedAnimation(widget.opacity),
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: Opacity(
        opacity: widget.opacity,
        child: _image(value, scheme, cacheWidth: 512),
      ),
    );
  }

  Widget _image(String value, ColorScheme scheme, {required int cacheWidth}) {
    final fallback = ColoredBox(color: scheme.surface);
    const quality = FilterQuality.medium;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: value,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        memCacheWidth: cacheWidth,
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
        cacheWidth: cacheWidth,
        filterQuality: quality,
        gaplessPlayback: true,
      );
    } else {
      image = Image.file(
        File(Uri.parse(value).toFilePath()),
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
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
    _syncAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  /// Плеер открывается прозрачным листом поверх главной: экран под ним
  /// продолжает рисоваться, и пятна крутились бы впустую. Пока сверху
  /// другой маршрут — стоим.
  void _syncAnimation() {
    final covered = !(ModalRoute.isCurrentOf(context) ?? true);
    if (widget.speed == 0 || covered) {
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
