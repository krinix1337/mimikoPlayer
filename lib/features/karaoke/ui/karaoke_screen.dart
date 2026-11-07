import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../sources/lyrics/lrclib.dart';
import '../../../theme/app_motion.dart';
import '../../../widgets/track_cover.dart';
import '../lyric_line_layout.dart';
import '../../../widgets/expressive_loader.dart';

/// Караоке в духе Apple Music: активная строка крупная и цветная, остальные
/// приглушены и уходят вверх, маска заполняется по мере строки, список сам
/// подматывается. Тап по строке — перемотка на неё.
class KaraokeScreen extends ConsumerStatefulWidget {
  const KaraokeScreen({super.key, required this.trackId});

  final String trackId;

  @override
  ConsumerState<KaraokeScreen> createState() => _KaraokeScreenState();
}

class _KaraokeScreenState extends ConsumerState<KaraokeScreen> {
  final ScrollController _scroll = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};
  int _lastActive = -1;

  /// Трек, чей текст сейчас на экране.
  String? _shownTrack;

  /// Пока пользователь сам крутит список, автоскролл молчит — иначе
  /// прокрутка у него под пальцем прыгает обратно.
  bool _userScrolling = false;

  Timer? _scrollResume;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      // Программный ensureVisible тоже поднимает isScrollingNotifier, поэтому
      // смотрим именно жест пользователя.
      if (_scroll.position.userScrollDirection == ScrollDirection.idle) return;
      _userScrolling = true;
      _scrollResume?.cancel();
      // Через несколько секунд после ручного листания автоскролл включается
      // снова, иначе текст навсегда оставался там, куда его увели.
      _scrollResume = Timer(const Duration(seconds: 4), () {
        if (mounted) _userScrolling = false;
      });
    });
  }

  @override
  void dispose() {
    _scrollResume?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Текст идёт за тем, что играет: раньше экран оставался на треке, с
    // которого его открыли, и после автоперехода подсвечивал чужие строки
    // по времени нового трека.
    final trackId =
        ref.watch(
          playerSnapshotProviderValue.select((s) => s.current?.localTrackId),
        ) ??
        widget.trackId;
    if (trackId != _shownTrack) {
      final changed = _shownTrack != null;
      _shownTrack = trackId;
      if (changed) {
        _lineKeys.clear();
        _lastActive = -1;
        _userScrolling = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
        });
      }
    }
    final lyrics = ref.watch(trackLyricsProvider(trackId));
    final position = ref.watch(
      playerSnapshotProviderValue.select(
        (s) => (s.position, s.current?.coverUrl),
      ),
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Theme.of(context).colorScheme.surface),
          BlurredCover(url: position.$2, opacity: 0.4),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: l.playerBack,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 30,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      Expanded(
                        child: Text(
                          l.playerLyrics,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: switch (lyrics) {
                    AsyncValue(:final error?) => _Notice(text: '$error'),
                    AsyncValue(:final value?) when value.isEmpty => _Notice(
                      text: l.playerLyricsMissing,
                    ),
                    AsyncValue(:final value?) => _LyricsBody(
                      lyrics: value,
                      at: position.$1,
                      scroll: _scroll,
                      keys: _lineKeys,
                      lastActive: _lastActive,
                      onActiveChanged: (index) => _lastActive = index,
                      userScrolling: () => _userScrolling,
                      clearUserScrolling: () => _userScrolling = false,
                      onSeek: value.synced
                          ? (line) => ref
                                .read(playbackControllerProvider)
                                .seek(line.start)
                          : null,
                    ),
                    _ => const Center(child: ExpressiveLoader()),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LyricsBody extends StatefulWidget {
  const _LyricsBody({
    required this.lyrics,
    required this.at,
    required this.scroll,
    required this.keys,
    required this.lastActive,
    required this.onActiveChanged,
    required this.userScrolling,
    required this.clearUserScrolling,
    required this.onSeek,
  });

  final Lyrics lyrics;
  final Duration at;
  final ScrollController scroll;
  final Map<int, GlobalKey> keys;
  final int lastActive;
  final ValueChanged<int> onActiveChanged;
  final bool Function() userScrolling;
  final VoidCallback clearUserScrolling;
  final ValueChanged<LyricLine>? onSeek;

  @override
  State<_LyricsBody> createState() => _LyricsBodyState();
}

class _LyricsBodyState extends State<_LyricsBody> {
  /// Первый переход к текущей строке — без анимации: иначе при открытии
  /// караоке список полсекунды едет от начала текста.
  bool _didInitialScroll = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.lyrics.lineAt(widget.at);
    if (active != widget.lastActive) widget.onActiveChanged(active);

    if (active >= 0 && !widget.userScrolling()) {
      final initial = !_didInitialScroll;
      _didInitialScroll = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = widget.keys.putIfAbsent(active, () => GlobalKey());
        if (key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            alignment: 0.32,
            duration: initial
                ? Duration.zero
                : const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }

    // Края списка растворяют сам текст, а не кладут чёрные полосы поверх фона:
    // у полос была видна граница, и строки под шапкой словно обрезались.
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Colors.transparent,
          Colors.transparent,
          Colors.white,
          Colors.white,
          Colors.transparent,
        ],
        stops: [
          0,
          // Первые 20 px полностью прозрачны: срез строки у шапки не виден.
          (20 / bounds.height).clamp(0.0, 0.2),
          (96 / bounds.height).clamp(0.0, 0.5),
          (1 - 104 / bounds.height).clamp(0.5, 1.0),
          1,
        ],
      ).createShader(bounds),
      child: ListView.builder(
        controller: widget.scroll,
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
        itemCount: widget.lyrics.lines.length,
        itemBuilder: (context, index) {
          final line = widget.lyrics.lines[index];
          final isActive = index == active;
          return _LyricLineView(
            // Ключ у каждой строки постоянный: когда он появлялся только у
            // активной, строка пересоздавалась и анимация обрывалась рывком.
            key: widget.keys.putIfAbsent(index, () => GlobalKey()),
            line: line,
            active: isActive && widget.lyrics.synced,
            dimmed: widget.lyrics.synced && !isActive,
            progress: isActive && widget.lyrics.synced
                ? line.progressAt(widget.at)
                : 0,
            onTap: widget.onSeek == null ? null : () => widget.onSeek!(line),
          );
        },
      ),
    );
  }
}

class _LyricLineView extends StatelessWidget {
  const _LyricLineView({
    super.key,
    required this.line,
    required this.active,
    required this.dimmed,
    required this.progress,
    this.onTap,
  });

  final LyricLine line;
  final bool active;
  final bool dimmed;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    final prefs = motion.prefs;
    final scheme = Theme.of(context).colorScheme;
    final scale = prefs.lyricsSize.scale;
    final base = Theme.of(context).textTheme.headlineSmall!
        .copyWith(height: 1.35, letterSpacing: -0.1);
    final dimAlpha = prefs.lyricsDimOthers ? 0.5 : 0.74;
    final inactive = base.copyWith(
      fontSize: 23 * scale,
      fontWeight: FontWeight.w500,
      color: dimmed
          ? scheme.onSurface.withValues(alpha: dimAlpha)
          : scheme.onSurface.withValues(alpha: 0.82),
    );
    final activeStyle = base.copyWith(
      fontSize: 29 * scale,
      fontWeight: FontWeight.w700,
      color: scheme.primary,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: active ? 1 : 0),
      duration: motion.micro(300),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        // Размер шрифта не анимируем: каждый кадр текст переносился заново,
        // высота строки скакала, и соседние строки дёргались. Шрифт сразу
        // конечный, рост показывает масштаб, а высоту плавно ведёт AnimatedSize.
        final style = (active ? activeStyle : inactive).copyWith(
          color: Color.lerp(inactive.color, activeStyle.color, t),
        );
        final grow = (23 + 6 * t) / (active ? 29 : 23);
        final dimColor = Color.lerp(
          inactive.color!,
          scheme.primary.withValues(alpha: 0.42),
          t,
        )!;
        // Заливка идёт по визуальным строкам: на переносе градиент не
        // закрашивает обе строки одновременно. Прогресс сглаживается
        // тикером между редкими обновлениями позиции плеера.
        final content = active
            ? _SmoothProgress(
                value: progress,
                builder: (smooth) => _ProgressText(
                  text: line.text,
                  progress: smooth,
                  style: style.copyWith(color: Colors.white),
                  dimColor: dimColor,
                  accent: scheme.primary,
                ),
              )
            : Text(line.text, style: style);

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedSize(
            duration: motion.micro(300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: active ? 11 : 7),
              child: Transform.scale(
                scale: grow,
                alignment: Alignment.centerLeft,
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Плавно догоняет очередное значение прогресса: позиция плеера приходит
/// пять раз в секунду, а заливка должна двигаться каждый кадр.
class _SmoothProgress extends StatefulWidget {
  const _SmoothProgress({required this.value, required this.builder});

  final double value;
  final Widget Function(double value) builder;

  @override
  State<_SmoothProgress> createState() => _SmoothProgressState();
}

class _SmoothProgressState extends State<_SmoothProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    lowerBound: 0,
    upperBound: 1,
    value: widget.value.clamp(0.0, 1.0),
  );

  @override
  void didUpdateWidget(_SmoothProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.value - widget.value).abs() < 0.0001) return;
    _controller.animateTo(
      widget.value.clamp(0.0, 1.0),
      duration: const Duration(milliseconds: 260),
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => widget.builder(_controller.value),
  );
}

/// Непрерывная заливка спетой части строки. Текст раскладывается тем же
/// TextPainter, что и обычная строка, и режется на визуальные строки: иначе
/// на переносе градиент заливал обе строки одновременно.
class _ProgressText extends StatefulWidget {
  const _ProgressText({
    required this.text,
    required this.progress,
    required this.style,
    required this.dimColor,
    required this.accent,
  });

  final String text;
  final double progress;
  final TextStyle style;
  final Color dimColor;
  final Color accent;

  @override
  State<_ProgressText> createState() => _ProgressTextState();
}

class _ProgressTextState extends State<_ProgressText> {
  String? _cachedText;
  TextStyle? _cachedStyle;
  double? _cachedWidth;
  double? _cachedScale;
  List<String> _parts = const [];
  List<double> _widths = const [];
  double _lineHeight = 0;

  void _layout(String text, TextStyle style, double width, TextScaler scaler) {
    final scale = scaler.scale(10);
    if (_cachedText == text &&
        _cachedStyle == style &&
        _cachedWidth == width &&
        _cachedScale == scale) {
      return;
    }
    final layout = LyricLineLayout.measure(
      text: text,
      style: style,
      width: width,
      textScaler: scaler,
    );
    _cachedText = text;
    _cachedStyle = style;
    _cachedWidth = width;
    _cachedScale = scale;
    _parts = layout.parts;
    _widths = layout.widths;
    _lineHeight = layout.lineHeight;
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        _layout(widget.text, widget.style, width, scaler);
        final total = _widths.fold(0.0, (sum, value) => sum + value);
        final target = widget.progress.clamp(0.0, 1.0) * total;
        final dim = widget.dimColor;
        var consumed = 0.0;
        final lines = <Widget>[];
        for (var i = 0; i < _parts.length; i++) {
          final lineWidth = _widths[i];
          if (_parts[i].isEmpty) {
            lines.add(SizedBox(height: _lineHeight));
            consumed += lineWidth;
            continue;
          }
          final local = lineWidth <= 0
              ? 1.0
              : ((target - consumed) / lineWidth).clamp(0.0, 1.0);
          lines.add(
            _fillLine(_parts[i], local, widget.style, widget.accent, dim),
          );
          consumed += lineWidth;
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines,
        );
      },
    );
  }

  Widget _fillLine(
    String text,
    double value,
    TextStyle style,
    Color accent,
    Color dim,
  ) {
    if (value >= 0.995) {
      return Text(text, style: style.copyWith(color: accent));
    }
    if (value <= 0.001) {
      return Text(text, style: style.copyWith(color: dim));
    }
    const edge = 0.07;
    final start = (value - edge).clamp(0.0, 1.0);
    final end = (value + edge).clamp(0.0, 1.0);
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: [accent, accent, dim, dim],
        stops: [0.0, start, end, 1.0],
      ).createShader(bounds),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
