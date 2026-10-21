import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../../../core/sources/source_id.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/routes.dart';
import '../../../theme/app_motion.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/track_cover.dart';
import '../../../widgets/track_tile.dart';
import '../player_snapshot.dart';

/// Полный экран плеера: вне нижней навигации, с кнопкой «назад».
///
/// Позиция трека приходит ~5 раз в секунду, поэтому она изолирована в
/// [_Progress] — иначе на каждом тике пересобиралось всё дерево вместе с
/// обложкой, и на бюджетном железе это заметная просадка кадров.
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(
      playerSnapshotProviderValue.select((s) => (s.current, s.isRadio)),
    );
    final current = snapshot.$1;

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
                      _TopBar(isRadio: snapshot.$2, trackId: current.localTrackId),
                      Expanded(child: _Artwork(current: current)),
                      const _IssueStrip(),
                      const _Progress(),
                      _Controls(playing: _playing(ref)),
                      const SizedBox(height: 20),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static bool _playing(WidgetRef ref) =>
      ref.watch(playerSnapshotProviderValue.select((s) => s.playing));
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.isRadio, required this.trackId});

  final bool isRadio;
  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

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
              isRadio ? l.playerRadio : l.playerTitle,
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

class _Artwork extends StatelessWidget {
  const _Artwork({required this.current});

  final NowPlaying current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motion = Motion.of(context);

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
                size: 300,
                radius: motion.prefs.corner.radius,
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
            const SizedBox(height: 12),
            const _SourceBadge(),
          ],
        ),
      ),
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
      playerSnapshotProviderValue.select(
        (s) => (s.position, s.duration),
      ),
    );
    final total = state.$2.inMilliseconds;
    final value = _drag ??
        (total == 0 ? 0.0 : (state.$1.inMilliseconds / total).clamp(0.0, 1.0));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        children: [
          Slider(
            value: value.clamp(0.0, 1.0),
            onChanged: total == 0
                ? null
                : (v) => setState(() => _drag = v),
            onChangeEnd: total == 0
                ? null
                : (v) {
                    ref.read(playbackControllerProvider).seek(
                      Duration(milliseconds: (v * total).round()),
                    );
                    setState(() => _drag = null);
                  },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_drag == null ? _format(state.$1) : _format(
                  Duration(milliseconds: (_drag! * total).round()),
                )),
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
    final issue = ref.watch(
      playerSnapshotProviderValue.select((s) => s.issue),
    );
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
    final liked = ref.watch(
      playerSnapshotProviderValue.select((s) => s.liked),
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
            icon: liked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
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
    final next = liked ? 0 : 1;
    await services.db.libraryDao.setLike(
      current.localTrackId,
      next,
      remoteSource: next == 1 ? SourceId.yandex : null,
    );
    ref.invalidate(collectionProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next == 1 ? l.waveLikeAdded : l.waveLikeRemoved)),
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
          Text(l.playerQueueEmpty, style: Theme.of(context).textTheme.bodyLarge),
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
    final snapshot = ref.watch(playerSnapshotProviderValue);
    final controller = ref.read(playbackControllerProvider);
    final l = AppLocalizations.of(context);

    if (snapshot.queue.isEmpty) {
      return SafeArea(child: Center(child: Text(l.playerQueueEmpty)));
    }

    return SafeArea(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: snapshot.queue.length,
        itemBuilder: (context, index) {
          final id = snapshot.queue[index];
          return ListTile(
            leading: Text('${index + 1}'),
            title: _QueueTitle(trackId: id),
            selected: index == snapshot.index,
            onTap: () {
              controller.skipTo(id);
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
