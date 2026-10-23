import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../../../features/downloads/download_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/routes.dart';
import '../../../theme/app_motion.dart';
import '../../../theme/surface.dart';
import '../../../widgets/track_cover.dart';

/// Полоска «сейчас играет» над навигацией — пилюля фиксированной высоты.
/// Нет трека — нет полоски.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key, this.hidden = false});

  /// true — пилюля не нужна на этом экране (волна во время игры). Слот при
  /// этом остаётся в дереве и высота уходит анимацией, без скачка.
  final bool hidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // select: позиция меняется несколько раз в секунду, и без него пилюля
    // пересобиралась целиком на каждом тике.
    final snapshot = ref.watch(
      playerSnapshotProviderValue.select(
        (s) => (s.current, s.playing, s.buffering),
      ),
    );
    final current = snapshot.$1;
    final motion = Motion.of(context);
    if (current == null || hidden) {
      return AnimatedSize(
        duration: motion.morph,
        curve: Curves.easeOutCubic,
        alignment: Alignment.bottomCenter,
        child: const SizedBox(width: double.infinity),
      );
    }

    final l = AppLocalizations.of(context);
    final controller = ref.read(playbackControllerProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = Motion.of(context).prefs.corner.radius;

    return AnimatedSize(
      duration: motion.morph,
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(11, 6, 11, 4),
        child: AppSurface(
          radius: radius,
          color: scheme.surfaceContainerHigh.withValues(alpha: 0.92),
          shadow: false,
          child: InkWell(
            onTap: () => context.push(Routes.player),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  // Фиксированная высота: обложка, две строки и кнопки считаются
                  // от одной оси, поэтому строка не «плавает» по вертикали.
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TrackCover(url: current.coverUrl, size: 44, radius: 12),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      current.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                  _MiniDownloadPin(
                                    trackId: current.localTrackId,
                                  ),
                                ],
                              ),
                              Text(
                                snapshot.$3 ? l.commonLoading : current.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _TinyButton(
                          tooltip: snapshot.$2 ? l.commonPause : l.commonPlay,
                          icon: snapshot.$2
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          onPressed: controller.togglePlay,
                        ),
                        _TinyButton(
                          tooltip: l.commonNext,
                          icon: Icons.skip_next_rounded,
                          onPressed: controller.skipNext,
                        ),
                      ],
                    ),
                  ),
                ),
                const _MiniProgress(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniDownloadPin extends ConsumerWidget {
  const _MiniDownloadPin({required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stored = ref.watch(isDownloadedProvider(trackId)).value ?? false;
    if (!stored) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Icon(
        Icons.offline_pin_rounded,
        size: 14,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _TinyButton extends StatelessWidget {
  const _TinyButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon, size: 22),
    visualDensity: VisualDensity.compact,
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints.tightFor(width: 38, height: 38),
  );
}

/// Тонкая полоса прогресса под пилюлей: на тик перестраивается только она.
class _MiniProgress extends ConsumerWidget {
  const _MiniProgress();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(
      playerSnapshotProviderValue.select((s) => (s.position, s.duration)),
    );
    final total = data.$2.inMilliseconds;
    final value = total == 0
        ? 0.0
        : (data.$1.inMilliseconds / total).clamp(0.0, 1.0);
    return SizedBox(
      height: 2,
      child: LinearProgressIndicator(
        value: value,
        minHeight: 2,
        backgroundColor: Colors.transparent,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
