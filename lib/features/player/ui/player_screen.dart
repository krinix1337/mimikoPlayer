import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../../../core/prefs/prefs.dart';
import '../../../core/sources/source_id.dart';
import '../../../features/downloads/download_service.dart';
import '../../../features/home/wave_mode_label.dart';
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

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  double _swipeDirection = 1;

  /// Смещение обложки под пальцем: соседний трек въезжает вместе с ним.
  double _drag = 0;

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
                              onHorizontalDragUpdate: (details) =>
                                  setState(() => _drag += details.delta.dx),
                              onHorizontalDragCancel: () =>
                                  setState(() => _drag = 0),
                              onHorizontalDragEnd: _onSwipe,
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
                                      duration: const Duration(
                                        milliseconds: 320,
                                      ),
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

  void _onSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final dragged = _drag;
    final forward = velocity < 0 || (velocity == 0 && dragged < 0);
    if (velocity.abs() < 160 && dragged.abs() < 90) {
      if (dragged != 0) setState(() => _drag = 0);
      return;
    }
    final controller = ref.read(playbackControllerProvider);
    setState(() => _drag = 0);
    _swipeDirection = forward ? 1 : -1;
    if (forward) {
      controller.skipNext();
    } else {
      controller.skipPrevious();
    }
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
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (context) => const _QueueSheet(),
            ),
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
    final liked = ref.watch(playerSnapshotProviderValue.select((s) => s.liked));
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
            onPressed: () => _toggleLike(context, ref, liked),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(
    BuildContext context,
    WidgetRef ref,
    bool liked,
  ) async {
    final l = AppLocalizations.of(context);
    final current = ref.read(playbackControllerProvider).snapshot.current;
    if (current == null) return;
    final services = ref.read(appServicesProvider);
    final downloader = ref.read(downloadControllerProvider.notifier);
    final controller = ref.read(playbackControllerProvider);
    final next = liked ? 0 : 1;
    await services.db.libraryDao.setLike(
      current.localTrackId,
      next,
      remoteSource: next == 1 ? SourceId.yandex : null,
    );
    if (next == 1) {
      await downloader.trackLiked(current.localTrackId);
    }
    await controller.refreshLikedState();
    if (!ref.context.mounted) return;
    ref.invalidate(collectionProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(next == 1 ? l.waveLikeAdded : l.waveLikeRemoved),
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

class _QueueSheet extends ConsumerWidget {
  const _QueueSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(
      playerSnapshotProviderValue.select((s) => (s.queue, s.index)),
    );
    final controller = ref.read(playbackControllerProvider);
    final l = AppLocalizations.of(context);
    final queue = snapshot.$1;
    final current = snapshot.$2;

    if (queue.isEmpty) {
      return SafeArea(child: Center(child: Text(l.playerQueueEmpty)));
    }

    return SafeArea(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: queue.length,
        itemBuilder: (context, index) {
          final id = queue[index];
          return ListTile(
            leading: Text('${index + 1}'),
            title: _QueueTitle(trackId: id),
            selected: index == current,
            onTap: () {
              // Позиция, а не id: у повтора в плейлисте одна и та же строка
              // стоит несколько раз, и поиск по id прыгал всегда на первую.
              controller.skipToIndex(index);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}

class _QueueTitle extends ConsumerWidget {
  const _QueueTitle({required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Text(
    ref.watch(trackTitleProvider(trackId)).value ?? trackId,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
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
