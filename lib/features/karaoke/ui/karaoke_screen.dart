import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../sources/lyrics/lrclib.dart';
import '../../../theme/app_motion.dart';
import '../../../widgets/track_cover.dart';

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

  /// Пока пользователь сам крутит список, автоскролл молчит — иначе
  /// прокрутка у него под пальцем прыгает обратно.
  bool _userScrolling = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.isScrollingNotifier.value) {
        _userScrolling = true;
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lyrics = ref.watch(trackLyricsProvider(widget.trackId));
    final position = ref.watch(
      playerSnapshotProviderValue.select((s) => (s.position, s.current?.coverUrl)),
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
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
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
                    AsyncValue(:final value?) when value.isEmpty =>
                      _Notice(text: l.playerLyricsMissing),
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
                    _ => const Center(child: CircularProgressIndicator()),
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

class _LyricsBody extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final active = lyrics.lineAt(at);
    if (active != lastActive) onActiveChanged(active);

    if (active >= 0 && !userScrolling()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = keys.putIfAbsent(active, () => GlobalKey());
        if (key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            alignment: 0.32,
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }

    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
      itemCount: lyrics.lines.length,
      itemBuilder: (context, index) {
        final line = lyrics.lines[index];
        final isActive = index == active;
        return _LyricLineView(
          key: isActive ? keys.putIfAbsent(index, () => GlobalKey()) : null,
          line: line,
          active: isActive && lyrics.synced,
          dimmed: lyrics.synced && !isActive,
          progress: isActive && lyrics.synced ? line.progressAt(at) : 0,
          onTap: onSeek == null ? null : () => onSeek!(line),
        );
      },
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
    final base = Theme.of(context).textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.25,
    );

    final dimAlpha = prefs.lyricsDimOthers ? 0.38 : 0.72;
    final color = active
        ? scheme.primary
        : dimmed
        ? scheme.onSurface.withValues(alpha: dimAlpha)
        : scheme.onSurface.withValues(alpha: 0.8);

    final text = Text(
      line.text,
      style: base.copyWith(color: color),
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedDefaultTextStyle(
        duration: motion.micro(280),
        curve: Curves.easeOut,
        style: base.copyWith(
          color: color,
          fontSize: (active ? 30 : dimmed ? 24 : 26) * scale,
        ),
        child: AnimatedPadding(
          duration: motion.micro(280),
          padding: EdgeInsets.symmetric(vertical: active ? 12 : 8),
          // Маска прогресса — ClipRect с шириной, а не шейдер: на дешёвом
          // Mali это дешевле, а выглядит так же.
          child: active
              ? Stack(
                  children: [
                    Opacity(opacity: 0.32, child: text),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: text,
                      ),
                    ),
                  ],
                )
              : text,
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}
