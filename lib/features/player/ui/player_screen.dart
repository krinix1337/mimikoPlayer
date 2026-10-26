import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../../../core/db/daos/library_dao.dart';
import '../../../core/prefs/prefs.dart';
import '../../../features/downloads/download_service.dart';
import '../../../features/home/wave_mode_label.dart';
import '../../../features/library/library_actions.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/routes.dart';
import '../../../theme/app_motion.dart';
import '../../../wave_providers.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/track_badges.dart';
import '../../../widgets/track_cover.dart';
import '../../../widgets/track_tile.dart';
import '../player_snapshot.dart';

/// Полный экран плеера: вне нижней навигации, с кнопкой «назад».
///
/// Позиция трека приходит ~5 раз в секунду, поэтому она изолирована в
/// [_Progress] — иначе на каждом тике пересобиралось всё дерево вместе с
/// обложкой, и на бюджетном железе это заметная просадка кадров.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  double _swipeDirection = 1;

  /// Смещение обложки под пальцем: соседний трек въезжает вместе с ним.
  double _drag = 0;

  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  double _settleFrom = 0;
  double _settleTo = 0;
  bool _settling = false;

  /// Внешнее переключение трека во время свайпа: обложку не анимируем
  /// второй раз, иначе соседняя картинка успевает отъехать и вернуться.
  bool _suppressSwitch = false;
  bool _pendingTrackChange = false;
  String? _lastTrackId;
  int _lastIndex = -1;

  @override
  void initState() {
    super.initState();
    _settle.addListener(() {
      final value = Curves.easeOutCubic.transform(_settle.value);
      if (mounted) {
        setState(() => _drag = _settleFrom + (_settleTo - _settleFrom) * value);
      }
    });
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(
      playerSnapshotProviderValue.select((s) => (s.current, s.isRadio)),
    );
    final current = snapshot.$1;
    // Соседи по очереди: их обложки показываются во время свайпа.
    final place = ref.watch(
      playerSnapshotProviderValue.select((s) => (s.queue, s.index)),
    );
    final nextCover = place.$1.length > place.$2 + 1
        ? ref.watch(trackCoverProvider(place.$1[place.$2 + 1])).value
        : null;
    final prevCover = place.$2 > 0
        ? ref.watch(trackCoverProvider(place.$1[place.$2 - 1])).value
        : null;

    if (_lastTrackId != current?.localTrackId) {
      _lastTrackId = current?.localTrackId;
      if (_pendingTrackChange || _drag != 0) {
        _pendingTrackChange = false;
        _settle.stop();
        _settling = false;
        _drag = 0;
      }
    }
    if (place.$2 != _lastIndex) {
      _swipeDirection = place.$2 > _lastIndex ? 1 : -1;
      _lastIndex = place.$2;
    }
    if (_suppressSwitch && !_pendingTrackChange) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _suppressSwitch) {
          setState(() => _suppressSwitch = false);
        }
      });
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Theme.of(context).colorScheme.surface),
          BlurredCover(url: current?.coverUrl, opacity: 0.35),
          SafeArea(
            child: current == null
                ? const _EmptyPlayer()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TopBar(
                        isRadio: snapshot.$2,
                        trackId: current.localTrackId,
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, box) {
                            final artSize = _artworkSize(
                              context,
                              box.maxHeight,
                            );
                            final offset = _drag.clamp(
                              -box.maxWidth,
                              box.maxWidth,
                            );
                            final toward = offset <= 0 ? 1 : -1;
                            final neighbor = toward == 1
                                ? nextCover
                                : prevCover;
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onHorizontalDragStart: (_) {
                                if (!_settling) _settle.stop();
                              },
                              onHorizontalDragUpdate: (details) {
                                if (_settling) return;
                                setState(() => _drag += details.delta.dx);
                              },
                              onHorizontalDragCancel: () {
                                if (_settling) return;
                                _animateDragTo(0);
                              },
                              onHorizontalDragEnd: (details) => _onSwipe(
                                details,
                                box.maxWidth,
                                place.$1,
                                place.$2,
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (neighbor != null && offset != 0)
                                    Transform.translate(
                                      offset: Offset(
                                        offset + toward * box.maxWidth,
                                        0,
                                      ),
                                      child: _NeighborArt(
                                        url: neighbor,
                                        artSize: artSize,
                                      ),
                                    ),
                                  Transform.translate(
                                    offset: Offset(offset, 0),
                                    child: AnimatedSwitcher(
                                      duration: _suppressSwitch
                                          ? Duration.zero
                                          : const Duration(milliseconds: 260),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      transitionBuilder: (child, animation) {
                                        final slide = Tween<Offset>(
                                          begin: Offset(
                                            0.16 * _swipeDirection,
                                            0,
                                          ),
                                          end: Offset.zero,
                                        ).animate(animation);
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: slide,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: _Artwork(
                                        key: ValueKey(current.localTrackId),
                                        current: current,
                                        artSize: artSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const _IssueStrip(),
                      const _Progress(),
                      _Controls(playing: _playing()),
                      const SizedBox(height: 20),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  bool _playing() =>
      ref.watch(playerSnapshotProviderValue.select((s) => s.playing));

  Future<void> _onSwipe(
    DragEndDetails details,
    double width,
    List<String> queue,
    int index,
  ) async {
    if (_settling) return;
    final velocity = details.primaryVelocity ?? 0;
    final dragged = _drag;
    final forward = velocity < 0 || (velocity == 0 && dragged < 0);
    if (velocity.abs() < 160 && dragged.abs() < 90) {
      if (dragged != 0) _animateDragTo(0);
      return;
    }

    _swipeDirection = forward ? 1 : -1;
    final controller = ref.read(playbackControllerProvider);
    final neighborIndex = index + (forward ? 1 : -1);
    final hasNeighbor = neighborIndex >= 0 && neighborIndex < queue.length;
    if (!hasNeighbor) {
      _animateDragTo(0);
      if (forward) {
        await controller.skipNext();
      } else {
        await controller.skipPrevious();
      }
      return;
    }

    _settling = true;
    await _animateDragTo(forward ? -width : width);
    if (!mounted) return;
    _pendingTrackChange = true;
    _suppressSwitch = true;
    unawaited(controller.skipToIndex(neighborIndex));
    // Если current так и не сменился (очередь перестроилась или резолв
    // завис), возвращаем обложку на место, а не оставляем пустой экран.
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted || !_pendingTrackChange) return;
      _pendingTrackChange = false;
      _settling = false;
      _suppressSwitch = false;
      _animateDragTo(0);
    });
  }

  Future<void> _animateDragTo(double target) {
    _settleFrom = _drag;
    _settleTo = target;
    return _settle.forward(from: 0).whenComplete(() {});
  }
}

/// Радиус обложки в плеере: одна формула на текущий трек и на превью соседа.
double _artworkRadius(BuildContext context, double artSize) {
  final motion = Motion.of(context);
  return switch (motion.prefs.artworkShape) {
    ArtworkShape.rounded => motion.prefs.corner.radius,
    ArtworkShape.soft => 10,
    ArtworkShape.circle => artSize / 2,
  };
}

/// Размер обложки в плеере: чуть крупнее на широких экранах, без переполнения
/// на узких.
double _artworkSize(BuildContext context, double availableHeight) {
  final byWidth = (MediaQuery.sizeOf(context).width - 56).clamp(220.0, 340.0);
  // Под обложкой ещё название, артист и бейджи — примерно 170 dp.
  final byHeight = (availableHeight - 170).clamp(170.0, 340.0);
  return (byWidth < byHeight ? byWidth : byHeight).toDouble();
}

/// Обложка соседнего трека, въезжающая следом за пальцем.
class _NeighborArt extends StatelessWidget {
  const _NeighborArt({required this.url, required this.artSize});

  final String url;
  final double artSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: TrackCover(
          url: url,
          size: artSize,
          radius: _artworkRadius(context, artSize),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.isRadio, required this.trackId});

  final bool isRadio;
  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final played = ref.watch(
      playerSnapshotProviderValue.select((s) => (s.sourceTitle, s.isRadio)),
    );
    final waveMode =
        played.$2 && ref.watch(stationProvider) == WaveStationIds.myVibe
        ? waveModeLabel(ref.watch(waveSettingsProvider).value, l)
        : null;
    final label = played.$2
        ? (waveMode ?? (played.$1.isNotEmpty ? played.$1 : l.playerRadio))
        : (played.$1.isNotEmpty ? played.$1 : l.playerTitle);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: l.playerBack,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: l.playerLyrics,
            icon: const Icon(Icons.lyrics_rounded),
            onPressed: () => context.push(Routes.karaokeFor(trackId)),
          ),
          IconButton(
            tooltip: l.playerQueue,
            icon: const Icon(Icons.queue_music_rounded),
            onPressed: () => showQueueSheet(context),
          ),
          IconButton(
            tooltip: l.playerSleep,
            icon: const Icon(Icons.bedtime_rounded),
            onPressed: () => showSleepSheet(context, ref),
          ),
        ],
      ),
    );
  }
}

class _Artwork extends ConsumerWidget {
  const _Artwork({super.key, required this.current, required this.artSize});

  final NowPlaying current;
  final double artSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: coverHeroTag(current.localTrackId),
              child: TrackCover(
                url: current.coverUrl,
                size: artSize,
                radius: _artworkRadius(context, artSize),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              current.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              current.artist,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (ref.watch(
              playerSnapshotProviderValue.select(
                (s) => current.explicitFlag || current.isAi || s.uncensored,
              ),
            )) ...[
              const SizedBox(height: 10),
              const _TrackFlags(),
              const SizedBox(height: 10),
            ] else
              const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _SourceBadge(),
                const SizedBox(width: 4),
                _DownloadButton(trackId: current.localTrackId),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Скачивание прямо с экрана плеера: в меню списка оно есть, но текущий
/// трек туда ещё надо найти, а офлайн обычно нужен именно он.
class _DownloadButton extends ConsumerWidget {
  const _DownloadButton({required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final status = ref.watch(downloadStatusProvider(trackId));
    final stored = ref.watch(isDownloadedProvider(trackId)).value ?? false;
    final downloading = status?.phase == DownloadPhase.downloading;
    final paused = status?.phase == DownloadPhase.paused;
    final complete =
        status?.phase == DownloadPhase.complete ||
        (status?.phase == null && stored);

    if (downloading) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            value: status?.progress,
            strokeWidth: 2.4,
            color: scheme.primary,
          ),
        ),
      );
    }

    return IconButton(
      tooltip: paused
          ? l.downloadsResume
          : complete
          ? l.menuDownloaded
          : l.playerDownload,
      visualDensity: VisualDensity.compact,
      iconSize: 22,
      color: complete ? scheme.primary : scheme.onSurfaceVariant,
      icon: Icon(
        paused
            ? Icons.play_arrow_rounded
            : complete
            ? Icons.offline_pin_rounded
            : Icons.download_rounded,
      ),
      onPressed: () async {
        final downloader = ref.read(downloadControllerProvider.notifier);
        try {
          if (paused) {
            await downloader.resume(trackId);
          } else if (complete) {
            await downloader.remove(trackId);
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l.downloadRemoved)));
            }
          } else {
            await downloader.start(trackId);
          }
        } on Object catch (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l.downloadFailed('$error'))));
          }
        }
      },
    );
  }
}

/// Полоса прогресса и время — единственное, что перерисовывается на тик.
class _Progress extends ConsumerStatefulWidget {
  const _Progress();

  @override
  ConsumerState<_Progress> createState() => _ProgressState();
}

class _ProgressState extends ConsumerState<_Progress> {
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      playerSnapshotProviderValue.select((s) => (s.position, s.duration)),
    );
    final total = state.$2.inMilliseconds;
    final value =
        _drag ??
        (total == 0 ? 0.0 : (state.$1.inMilliseconds / total).clamp(0.0, 1.0));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        children: [
          Slider(
            value: value.clamp(0.0, 1.0),
            onChanged: total == 0 ? null : (v) => setState(() => _drag = v),
            onChangeEnd: total == 0
                ? null
                : (v) {
                    ref
                        .read(playbackControllerProvider)
                        .seek(Duration(milliseconds: (v * total).round()));
                    setState(() => _drag = null);
                  },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _drag == null
                      ? _format(state.$1)
                      : _format(
                          Duration(milliseconds: (_drag! * total).round()),
                        ),
                ),
                Text(total == 0 ? '—' : _format(state.$2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueStrip extends ConsumerWidget {
  const _IssueStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issue = ref.watch(playerSnapshotProviderValue.select((s) => s.issue));
    if (issue == null) return const SizedBox.shrink();
    return _IssueBanner(issue: issue);
  }
}

class _Controls extends ConsumerWidget {
  const _Controls({required this.playing});

  final bool playing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(playbackControllerProvider);
    final shuffle = ref.watch(
      playerSnapshotProviderValue.select((s) => s.shuffle),
    );
    final repeat = ref.watch(
      playerSnapshotProviderValue.select((s) => s.repeat),
    );
    final feedback = ref.watch(
      playerSnapshotProviderValue.select((s) => (s.liked, s.disliked)),
    );
    final liked = feedback.$1;
    final disliked = feedback.$2;
    ref.listen(
      playerSnapshotProviderValue.select((s) => (s.liked, s.disliked)),
      (previous, next) {
        if (previous != next) ref.invalidate(collectionProvider);
      },
    );
    final busy = ref.watch(
      playerSnapshotProviderValue.select((s) => s.buffering && !s.playing),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            active: shuffle == PlaybackShuffle.shuffled,
            icon: shuffle == PlaybackShuffle.shuffled
                ? Icons.shuffle_rounded
                : Icons.shuffle_outlined,
            tooltip: l.collectionShuffleAll,
            onPressed: () => controller.setShuffle(
              shuffle == PlaybackShuffle.shuffled
                  ? PlaybackShuffle.ordered
                  : PlaybackShuffle.shuffled,
            ),
          ),
          _ControlButton(
            icon: Icons.skip_previous_rounded,
            size: 34,
            tooltip: l.commonPrevious,
            onPressed: controller.skipPrevious,
          ),
          _PlayToggle(
            playing: playing,
            busy: busy,
            onToggle: controller.togglePlay,
          ),
          _ControlButton(
            icon: Icons.skip_next_rounded,
            size: 34,
            tooltip: l.commonNext,
            onPressed: controller.skipNext,
          ),
          _ControlButton(
            active: repeat != PlaybackRepeat.none,
            icon: _repeatIcon(repeat),
            tooltip: l.playerRepeat,
            onPressed: () => controller.setRepeat(_nextRepeat(repeat)),
          ),
          _ControlButton(
            active: liked,
            icon: liked
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            tooltip: liked ? l.commonUnlike : l.commonLike,
            onPressed: () => _toggleFeedback(context, ref, liked ? 0 : 1),
          ),
          _ControlButton(
            active: disliked,
            icon: disliked
                ? Icons.thumb_down_alt_rounded
                : Icons.thumb_down_alt_outlined,
            tooltip: disliked ? l.feedbackUndislike : l.feedbackDislike,
            onPressed: () => _toggleFeedback(context, ref, disliked ? 0 : -1),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFeedback(
    BuildContext context,
    WidgetRef ref,
    int next,
  ) async {
    final l = AppLocalizations.of(context);
    final current = ref.read(playbackControllerProvider).snapshot.current;
    if (current == null) return;
    final services = ref.read(appServicesProvider);
    final downloader = ref.read(downloadControllerProvider.notifier);
    final controller = ref.read(playbackControllerProvider);
    final synced = await LibraryActions(services).setFeedback(
      current.localTrackId,
      next,
    );
    if (next == 1) {
      await downloader.trackLiked(current.localTrackId);
    }
    await controller.refreshLikedState();
    if (!ref.context.mounted) return;
    ref.invalidate(collectionProvider);
    if (context.mounted) {
      final message = switch (next) {
        1 => l.waveLikeAdded,
        -1 => l.feedbackDislikeAdded,
        _ => l.feedbackCleared,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(synced ? message : '$message · ${l.feedbackLocalOnly}'),
        ),
      );
    }
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 26,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final button = IconButton(
      onPressed: onPressed,
      iconSize: size,
      color: active ? scheme.primary : scheme.onSurface,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 42, height: 48),
      icon: Icon(icon),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class _PlayToggle extends StatelessWidget {
  const _PlayToggle({
    required this.playing,
    required this.busy,
    required this.onToggle,
  });

  final bool playing;
  final bool busy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final motion = Motion.of(context);
    return PressableScale(
      minScale: 0.9,
      onTap: busy ? null : onToggle,
      child: AnimatedContainer(
        duration: motion.morph,
        curve: Curves.easeOutBack,
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.3),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: motion.micro(200),
          child: Icon(
            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(playing),
            size: 40,
            color: scheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _TrackFlags extends ConsumerWidget {
  const _TrackFlags();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(
      playerSnapshotProviderValue.select((s) => s.current),
    );
    final uncensored = ref.watch(
      playerSnapshotProviderValue.select((s) => s.uncensored),
    );
    if (current == null) return const SizedBox.shrink();
    return TrackBadges(
      explicit: current.explicitFlag,
      ai: current.isAi,
      uncensored: uncensored,
    );
  }
}

class _SourceBadge extends ConsumerWidget {
  const _SourceBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(
      playerSnapshotProviderValue.select(
        (s) => (s.usedSource, s.quality?.wire, s.resolving),
      ),
    );
    final label = state.$3
        ? l.commonLoading
        : state.$1 == null
        ? l.issueUnknown
        : l.playerSourceChip(state.$1!.wire, state.$2 ?? '');
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          Motion.of(context).prefs.corner.radius * 0.5,
        ),
      ),
    );
  }
}

class _EmptyPlayer extends ConsumerWidget {
  const _EmptyPlayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.playerQueueEmpty,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(l.playerBack),
          ),
        ],
      ),
    );
  }
}

class _IssueBanner extends StatelessWidget {
  const _IssueBanner({required this.issue});

  final PlayerIssue issue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(
          Motion.of(context).prefs.corner.radius * 0.5,
        ),
      ),
      child: Text(
        describeIssue(issue),
        style: TextStyle(color: scheme.onErrorContainer),
      ),
    );
  }
}

Future<void> showQueueSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      builder: (context) => const _QueueSheet(),
    );

class _QueueSheet extends ConsumerWidget {
  const _QueueSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(
      playerSnapshotProviderValue.select((s) => (s.queue, s.index)),
    );
    final l = AppLocalizations.of(context);
    final queue = snapshot.$1;
    final current = snapshot.$2;
    final rows = ref.watch(queueRowsProvider(queue));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.58,
      minChildSize: 0.32,
      maxChildSize: 0.96,
      snap: true,
      shouldCloseOnMinExtent: true,
      builder: (context, scroll) => switch (rows) {
        AsyncValue(:final error?) => ListView(
          controller: scroll,
          children: [
            const _QueueHeader(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l.dbError('$error'), textAlign: TextAlign.center),
            ),
          ],
        ),
        AsyncData() when queue.isEmpty => ListView(
          controller: scroll,
          children: [
            const _QueueHeader(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l.playerQueueEmpty, textAlign: TextAlign.center),
            ),
          ],
        ),
        AsyncValue(:final value?) => ListView.builder(
          controller: scroll,
          padding: EdgeInsets.only(
            bottom: 8 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          itemCount: value.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _QueueHeader(count: value.length);
            final position = index - 1;
            return _QueueRow(
              row: value[position],
              position: position,
              current: position == current,
              onTap: () {
                // Позиция, а не id: у повтора в плейлисте одна и та же строка
                // стоит несколько раз, и поиск по id прыгал всегда на первую.
                ref
                    .read(playbackControllerProvider)
                    .skipToIndex(position);
                Navigator.of(context).pop();
              },
            );
          },
        ),
        _ => ListView(
          controller: scroll,
          children: const [
            _QueueHeader(),
            Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      },
    );
  }
}

class _QueueHeader extends StatelessWidget {
  const _QueueHeader({this.count});

  final int? count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).playerQueue,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (count != null)
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.row,
    required this.position,
    required this.current,
    required this.onTap,
  });

  final CollectionRow row;
  final int position;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: current
          ? scheme.primary.withValues(alpha: 0.10)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 7, 16, 7),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '${position + 1}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: current ? scheme.primary : scheme.onSurfaceVariant,
                    fontWeight: current ? FontWeight.w700 : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TrackCover(
                url: row.coverPath ?? row.coverUrl,
                size: 44,
                radius: 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: current ? scheme.primary : scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      row.artist.isEmpty ? row.source.wire : row.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                row.durationSec > 0
                    ? _format(Duration(seconds: row.durationSec))
                    : '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Таймер сна живёт в плеере, а не в экране: закрытие страницы его не сбрасывает.
Future<void> showSleepSheet(BuildContext context, WidgetRef ref) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      // Без этого лист обрезался по 9/16 высоты и нижние пункты таймера
      // оставались недоступны на низких экранах.
      isScrollControlled: true,
      builder: (context) {
        final l = AppLocalizations.of(context);
        final controller = ref.read(playbackControllerProvider);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  l.playerSleep,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              for (final minutes in const [15, 30, 45, 60, 90])
                ListTile(
                  title: Text(l.playerSleepMinutes(minutes)),
                  onTap: () {
                    controller.sleepAfter(Duration(minutes: minutes));
                    Navigator.of(context).pop();
                  },
                ),
              ListTile(
                title: Text(l.playerSleepOff),
                onTap: () {
                  controller.sleepAfter(null);
                  Navigator.of(context).pop();
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Text(
                  l.playerSleepNote,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      },
    );

IconData _repeatIcon(PlaybackRepeat mode) => switch (mode) {
  PlaybackRepeat.none => Icons.repeat_rounded,
  PlaybackRepeat.all => Icons.repeat_rounded,
  PlaybackRepeat.one => Icons.repeat_one_rounded,
};

PlaybackRepeat _nextRepeat(PlaybackRepeat mode) => switch (mode) {
  PlaybackRepeat.none => PlaybackRepeat.all,
  PlaybackRepeat.all => PlaybackRepeat.one,
  PlaybackRepeat.one => PlaybackRepeat.none,
};

String _format(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
