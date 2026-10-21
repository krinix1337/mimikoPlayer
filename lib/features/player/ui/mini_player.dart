import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/routes.dart';
import '../../../theme/app_motion.dart';
import '../../../widgets/track_cover.dart';
import '../../../widgets/track_tile.dart' show coverHeroTag;

/// Полоска «сейчас играет» над навигацией — пилюля фиксированной высоты.
/// Нет трека — нет полоски.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(playerSnapshotProviderValue);
    final current = snapshot.current;
    if (current == null) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    final controller = ref.read(playbackControllerProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = Motion.of(context).prefs.corner.radius;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Material(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
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
                      Hero(
                        tag: coverHeroTag(current.localTrackId),
                        child: TrackCover(
                          url: current.coverUrl,
                          size: 44,
                          radius: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              current.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              snapshot.buffering
                                  ? l.commonLoading
                                  : current.artist,
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
                        tooltip: snapshot.playing
                            ? l.commonPause
                            : l.commonPlay,
                        icon: snapshot.playing
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
