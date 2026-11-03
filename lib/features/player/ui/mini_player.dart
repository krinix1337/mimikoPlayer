import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../features/downloads/download_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/player_launch.dart';
import '../../../theme/app_motion.dart';
import '../../../theme/blur_settings.dart';
import '../../../theme/keyboard_theme.dart';
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
    // Те же поля, что у нижней панели: иначе пилюля шире на пару пикселей.
    final compact = ref.watch(prefsProvider.select((p) => p.compactUi));
    final side = compact ? 16.0 : 12.0;

    return AnimatedSize(
      duration: motion.morph,
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: TweenAnimationBuilder<double>(
        // Пилюля выезжает из-за навигации и проявляется: без этого слот
        // просто вырастал полоской.
        tween: Tween(begin: 0, end: 1),
        duration: motion.morph,
        curve: Curves.easeOutCubic,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 28),
            child: child,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 6, side, 4),
          child: AppSurface(
            radius: kKeyboardTestTheme ? 28 : radius,
            // С размытием пилюля прозрачнее, без него — плотная: иначе
            // белый текст трека просвечивает сквозь неё.
            color: kKeyboardTestTheme
                ? scheme.surfaceContainerHigh
                : scheme.surfaceContainerHigh.withValues(
                    alpha: currentBlur.hasBottom ? 0.7 : 0.98,
                  ),
            shadow: false,
            child: GestureDetector(
              // Свайп вверх по пилюле разворачивает плеер — до кнопки в
              // углу экрана не нужно тянуться.
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) < -250) openPlayer(context);
              },
              child: InkWell(
                onTap: () => openPlayer(context),
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
                            TrackCover(
                              url: current.coverUrl,
                              size: 44,
                              radius: 12,
                            ),
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
                                    snapshot.$3
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
                              tooltip: snapshot.$2
                                  ? l.commonPause
                                  : l.commonPlay,
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
    // Полоса внутри пилюли, с отступами от краёв: прижатая к низу, она
    // вылезала розовым хвостом из-под скруглённого угла.
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 3,
        borderRadius: BorderRadius.circular(2),
        backgroundColor: scheme.onSurface.withValues(alpha: 0.10),
        color: scheme.primary,
      ),
    );
  }
}

/// Обёртка для страниц поверх вкладок (поиск, «Любимое», плейлисты): у них
/// нет нижней панели, поэтому мини-плеер стоит у нижнего края. Раскладка
/// одна и та же всегда — иначе при появлении клавиатуры страница
/// пересоздавалась бы и теряла фокус в поле.
class MiniPlayerHost extends ConsumerWidget {
  const MiniPlayerHost({super.key, required this.child});

  final Widget child;

  /// Пилюля 64 + полоса прогресса 9 + поля 6/4 и запас.
  static const double _pillHeight = 90;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(prefsProvider.select((p) => p.showMiniPlayer));
    final hasTrack = ref.watch(
      playerSnapshotProviderValue.select((s) => s.current != null),
    );
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    final visible = enabled && hasTrack && !keyboard;
    final media = MediaQuery.of(context);
    // Пилюля плавает поверх страницы, как во вкладках: список уходит под
    // неё, а не обрывается сплошной полосой. Её высоту страница получает
    // нижним отступом — SliverBottomInset добавляет хвост под последний ряд.
    return Stack(
      children: [
        MediaQuery(
          data: media.copyWith(
            padding: media.padding.copyWith(
              bottom: media.padding.bottom + (visible ? _pillHeight : 0),
            ),
          ),
          child: child,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 4),
            child: MiniPlayer(hidden: !visible),
          ),
        ),
      ],
    );
  }
}
