import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../../../core/prefs/prefs.dart';
import '../../../features/downloads/download_service.dart';
import '../../../features/library/library_actions.dart';
import '../../../features/player/player_snapshot.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/player_launch.dart';
import '../../../router/routes.dart';
import '../../../sources/yandex/yandex_station.dart';
import '../../../theme/app_motion.dart';
import '../../../theme/blur_settings.dart';
import '../../../wave_providers.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/track_cover.dart';
import '../wave_mode_label.dart';

/// Главная: живой цвет волны во весь экран, крупное название, круглая кнопка
/// запуска и пилюля «что играет».
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final title = ref.watch(waveStationTitleProvider);
    final stationTitle = title.isEmpty ? l.waveTitle : title;
    final station = ref.watch(stationProvider);
    final waveSoundCloud = ref.watch(
      prefsProvider.select((p) => p.waveSoundCloud),
    );
    final modeLabel = station == WaveStationIds.myVibe
        ? waveModeLabel(
            ref.watch(waveSettingsProvider).value,
            l,
            soundCloud: waveSoundCloud,
          )
        : null;
    // Что играет и откуда: «Любимое», артист, плейлист. Для волны эту роль
    // играет modeLabel, поэтому её заголовок не перекрываем.
    final played = ref.watch(
      playerSnapshotProviderValue.select(
        (s) => (s.sourceTitle, s.isRadio, s.current != null),
      ),
    );
    final contextTitle = !played.$2 && played.$3 && played.$1.isNotEmpty
        ? played.$1
        : null;
    final wave = ref.watch(waveTracksProvider);
    // select: без него весь экран перестраивался на каждый тик позиции.
    final nowPlaying = ref.watch(
      playerSnapshotProviderValue.select(
        (s) => (s.current?.localTrackId, s.current?.coverUrl),
      ),
    );
    final hasTrack = nowPlaying.$1 != null;
    final motion = Motion.of(context);
    final prefs = ref.watch(prefsProvider);
    final scheme = theme.colorScheme;

    final upcoming = wave.value ?? const <WaveTrack>[];
    // Фон ведётся за тем, что играет сейчас, — трек могли включить и из
    // коллекции. Пока играть нечего, берём ближайший трек волны.
    final cover = hasTrack
        ? nowPlaying.$2
        : (upcoming.isEmpty ? null : upcoming.first.source.coverUrl);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: scheme.surface),
          // Пятна цвета дают движение, обложка — оттенок. Силу размытия
          // обложки задаёт общий раздел «Размытие».
          if (prefs.homeBackground != HomeBackground.cover)
            ColorBlobs(
              colors: [scheme.primary, scheme.tertiary, scheme.secondary],
              speed: motion.enabled ? 1 : 0,
            ),
          if (prefs.homeBackground != HomeBackground.blobs)
            BlurredCover(
              url: cover,
              opacity: switch (prefs.homeCoverTone) {
                HomeCoverTone.darker => 0.32,
                HomeCoverTone.normal => 0.42,
                HomeCoverTone.lighter => 0.55,
              },
              blur: currentBlur.hasCover,
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.surface.withValues(
                    alpha: switch (prefs.homeCoverTone) {
                      HomeCoverTone.darker => 0.55,
                      HomeCoverTone.normal => 0.35,
                      HomeCoverTone.lighter => 0.18,
                    },
                  ),
                  Colors.transparent,
                  scheme.surface.withValues(
                    alpha: switch (prefs.homeCoverTone) {
                      // Низ раньше уходил почти в чёрный и обрезал обложку
                      // чёрной полосой у навигации. Панель и так на своей
                      // подложке, поэтому хватает лёгкого затемнения.
                      HomeCoverTone.darker => 0.30,
                      HomeCoverTone.normal => 0.18,
                      HomeCoverTone.lighter => 0.10,
                    },
                  ),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => showWaveSettingsSheet(context, ref),
                        icon: const Icon(Icons.tune_rounded),
                        tooltip: l.waveTune,
                      ),
                      Expanded(
                        child: modeLabel == null && contextTitle == null
                            ? Text(
                                stationTitle,
                                style: theme.textTheme.displaySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              )
                            : Center(
                                child: _WaveModePill(
                                  label: modeLabel ?? contextTitle!,
                                  onClear: modeLabel != null
                                      ? () => _resetWaveMode(context, ref)
                                      : () => ref
                                            .read(playbackControllerProvider)
                                            .stop(),
                                ),
                              ),
                      ),
                      IconButton(
                        tooltip: l.navSearch,
                        icon: const Icon(Icons.search_rounded),
                        onPressed: () => context.push(Routes.search),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _WaveStage(
                  busy: wave.isLoading,
                  cover: cover,
                  onStart: () => startWave(ref),
                ),
                const SizedBox(height: 16),
                _WaveControls(
                  wave: wave.value ?? const [],
                  failed: wave.hasError,
                ),
                const Spacer(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _resetWaveMode(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final source = ref.read(yandexSourceProvider);
    if (source == null) return;
    await ref.read(prefsProvider.notifier).setWaveSoundCloud(false);
    final ok = await source.station.saveSettings(
      WaveStationIds.myVibe,
      const WaveSettings(),
    );
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).waveRejectedNote)),
      );
      return;
    }
    ref.invalidate(waveSettingsProvider);
    ref.invalidate(waveTracksProvider);
    if (ref.read(playerSnapshotProviderValue).isRadio) {
      await startWave(ref);
    }
  }
}

class _WaveModePill extends StatelessWidget {
  const _WaveModePill({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClear,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: scheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveStage extends ConsumerWidget {
  const _WaveStage({
    required this.cover,
    required this.busy,
    required this.onStart,
  });

  final String? cover;
  final bool busy;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final motion = Motion.of(context);
    // Пока трека нет — большая кнопка запуска, как на волне в Яндекс Музыке.
    // Когда трек пошёл — обложка без наложенных кнопок: пауза живёт отдельным
    // кругом рядом с плашкой, а не поверх картинки.
    final hasTrack = ref.watch(
      playerSnapshotProviderValue.select((s) => s.current != null),
    );

    if (!hasTrack) {
      return Tooltip(
        message: busy ? l.commonLoading : l.waveStart,
        child: SizedBox(
          width: 116,
          height: 116,
          child: PressableScale(
            minScale: 0.9,
            onTap: busy ? null : onStart,
            child: AnimatedContainer(
              duration: motion.morph,
              curve: Curves.easeOutBack,
              decoration: BoxDecoration(
                color: busy ? scheme.surfaceContainerHigh : scheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: busy ? 0 : 0.35),
                    blurRadius: 34,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: busy
                  ? Padding(
                      padding: const EdgeInsets.all(34),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: scheme.onPrimary,
                      ),
                    )
                  : Icon(
                      Icons.play_arrow_rounded,
                      size: 58,
                      color: scheme.onPrimary,
                    ),
            ),
          ),
        ),
      );
    }

    // Вся обложка ведёт в плеер: отдельной кнопки поверх картинки нет.
    // Обложка квадратная со скруглением, как в плеере и карточках.
    return GestureDetector(
      onTap: () => openPlayer(context),
      child: SizedBox(
        width: 116,
        height: 116,
        child: cover == null
            ? Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  size: 44,
                  color: scheme.onSurfaceVariant,
                ),
              )
            : TrackCover(url: cover, size: 116, radius: 26),
      ),
    );
  }
}

class _WaveControls extends ConsumerWidget {
  const _WaveControls({required this.wave, required this.failed});

  final List<WaveTrack> wave;
  final bool failed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final motion = Motion.of(context);
    final scheme = theme.colorScheme;
    final state = ref.watch(
      playerSnapshotProviderValue.select(
        (s) => (s.current, s.playing, s.liked),
      ),
    );
    final current = state.$1;
    final playing = state.$2;
    final liked = state.$3;
    final next = wave.isNotEmpty ? wave.first.source : null;

    final text =
        current?.title ??
        next?.title ??
        (failed ? l.waveQueueFailed : l.waveNotStarted);
    final subtitle = current?.artist ?? next?.artists.join(', ');
    final controller = ref.read(playbackControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Пока волна не запущена, единственный play — большая кнопка выше;
          // маленький пульт появляется только у играющего трека, как в Яндексе.
          if (current != null) ...[
            _RoundAction(
              icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              tooltip: playing ? l.commonPause : l.commonPlay,
              onTap: controller.togglePlay,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 11, 20, 11),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
              child: AnimatedSwitcher(
                duration: motion.micro(240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.12),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Column(
                  key: ValueKey('${current?.localTrackId}:$text'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (current != null) ...[
            const SizedBox(width: 8),
            _RoundAction(
              icon: liked
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
              tooltip: liked ? l.commonUnlike : l.commonLike,
              active: liked,
              onTap: () => _toggleLike(context, ref, current, liked),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggleLike(
    BuildContext context,
    WidgetRef ref,
    NowPlaying current,
    bool liked,
  ) async {
    final l = AppLocalizations.of(context);
    final services = ref.read(appServicesProvider);
    final downloader = ref.read(downloadControllerProvider.notifier);
    final controller = ref.read(playbackControllerProvider);
    final next = liked ? 0 : 1;

    await LibraryActions(services).setFeedback(current.localTrackId, next);
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

/// Круглая стеклянная кнопка пульта волны: play/pause и «любимое» стоят
/// по бокам плашки трека.
class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 52,
        height: 52,
        child: Material(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Icon(
              icon,
              size: 26,
              color: active ? scheme.primary : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Настройки волны так же, как в Яндексе: спокойное ↔ активное, знакомое ↔
/// новое, язык. Пишется прямо в станцию — рекомендации меняются на аккаунте.
Future<void> showWaveSettingsSheet(BuildContext context, WidgetRef ref) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _WaveSettingsSheet(),
    );

class _WaveSettingsSheet extends ConsumerStatefulWidget {
  const _WaveSettingsSheet();

  @override
  ConsumerState<_WaveSettingsSheet> createState() => _WaveSettingsSheetState();
}

class _WaveSettingsSheetState extends ConsumerState<_WaveSettingsSheet> {
  bool _loaded = false;
  bool _saving = false;
  String? _note;

  /// Абсолютная позиция в бесконечной ленте: остаток от числа режимов даёт
  /// выбранный режим, поэтому крутить можно в обе стороны без упора.
  int _page = _ring;
  late final PageController _wheel = PageController(
    // 0.2 — в кадре пять карточек: видно, что пресетов больше трёх.
    viewportFraction: 0.2,
    initialPage: _page,
  );

  /// Стартуем в середине ленты: первый свайп назад не должен упираться в край.
  /// Кратно числу режимов: 5400 % 12 == 0, поэтому в центре «Обычная волна».
  static const int _ring = 5400;

  @override
  void initState() {
    super.initState();
    // Лист всегда открывается на «обычной волне»: настройки на сервере могли
    // остаться от другого клиента, и показывать их выбранными нечестно.
    _page = _ring;
    _loaded = true;
  }

  @override
  void dispose() {
    _wheel.dispose();
    super.dispose();
  }

  List<_WaveModeOption> _modes(AppLocalizations l) => [
    _WaveModeOption(
      label: l.waveBackToUsual,
      icon: Icons.restart_alt_rounded,
      color: const Color(0xFF8E8E93),
      settings: const WaveSettings(),
    ),
    // Обычная волна с подмешанными треками SoundCloud — режим колеса, а не
    // отдельный переключатель: выбирается и сбрасывается как остальные.
    _WaveModeOption(
      label: l.waveModeSoundCloud,
      icon: Icons.cloud_rounded,
      color: const Color(0xFFFF5500),
      settings: const WaveSettings(),
      soundCloud: true,
    ),
    _WaveModeOption(
      label: l.diversityFavorite,
      icon: Icons.favorite_rounded,
      color: const Color(0xFFE85D75),
      settings: const WaveSettings(diversity: 'favorite'),
    ),
    _WaveModeOption(
      label: l.diversityDiscover,
      icon: Icons.explore_rounded,
      color: const Color(0xFF5B7CFA),
      settings: const WaveSettings(diversity: 'discover'),
    ),
    _WaveModeOption(
      label: l.diversityPopular,
      icon: Icons.trending_up_rounded,
      color: const Color(0xFFF08A3C),
      settings: const WaveSettings(diversity: 'popular'),
    ),
    _WaveModeOption(
      label: l.moodEnergyActive,
      icon: Icons.bolt_rounded,
      color: const Color(0xFFE3A21A),
      settings: const WaveSettings(moodEnergy: 'active'),
    ),
    _WaveModeOption(
      label: l.moodEnergyFun,
      icon: Icons.sentiment_very_satisfied_rounded,
      color: const Color(0xFFF3C344),
      settings: const WaveSettings(moodEnergy: 'fun'),
    ),
    _WaveModeOption(
      label: l.moodEnergyCalm,
      icon: Icons.self_improvement_rounded,
      color: const Color(0xFF3FAE9A),
      settings: const WaveSettings(moodEnergy: 'calm'),
    ),
    _WaveModeOption(
      label: l.moodEnergySad,
      icon: Icons.water_drop_rounded,
      color: const Color(0xFF6C86B8),
      settings: const WaveSettings(moodEnergy: 'sad'),
    ),
    _WaveModeOption(
      label: l.languageRussian,
      icon: Icons.translate_rounded,
      color: const Color(0xFFD65A5A),
      settings: const WaveSettings(language: 'russian'),
    ),
    _WaveModeOption(
      label: l.languageForeign,
      icon: Icons.public_rounded,
      color: const Color(0xFF7A6CE0),
      settings: const WaveSettings(language: 'not-russian'),
    ),
    _WaveModeOption(
      label: l.languageInstrumental,
      icon: Icons.music_off_rounded,
      color: const Color(0xFF6E8A8A),
      settings: const WaveSettings(language: 'without-words'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final modes = _modes(l);
    final selected = modes[_page % modes.length];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.waveSettingsTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(
              '${l.waveTitle} · ${selected.label}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            if (!_loaded)
              const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SizedBox(
                height: 160,
                child: PageView.builder(
                  controller: _wheel,
                  // itemCount: null — лента бесконечная в обе стороны.
                  onPageChanged: (index) => setState(() => _page = index),
                  itemBuilder: (context, index) => _ModeCard(
                    controller: _wheel,
                    index: index,
                    option: modes[index % modes.length],
                    onTap: () => _wheel.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              l.waveWheelHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (_note != null) ...[
              const SizedBox(height: 8),
              Text(_note!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _loaded && !_saving
                        ? () => _start(selected)
                        : null,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow_rounded),
                    label: Text(l.waveListen),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l.waveClose),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _start(_WaveModeOption option) async {
    final l = AppLocalizations.of(context);
    final source = ref.read(yandexSourceProvider);
    if (source == null) return;

    setState(() {
      _saving = true;
      _note = null;
    });
    final ok = await source.station.saveSettings(
      WaveStationIds.myVibe,
      option.settings,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _saving = false;
        _note = l.waveRejectedNote;
      });
      return;
    }
    await ref
        .read(prefsProvider.notifier)
        .setWaveSoundCloud(option.soundCloud);
    if (!mounted) return;
    ref.read(stationProvider.notifier).select(WaveStationIds.myVibe);
    ref.invalidate(waveSettingsProvider);
    ref.invalidate(waveTracksProvider);
    final started = await startWave(ref);
    if (!mounted) return;
    setState(() => _saving = false);
    if (started) {
      Navigator.of(context).pop();
    } else {
      setState(() => _note = l.waveNotStarted);
    }
  }
}

class _WaveModeOption {
  const _WaveModeOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.settings,
    this.soundCloud = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final WaveSettings settings;
  final bool soundCloud;
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.controller,
    required this.index,
    required this.option,
    required this.onTap,
  });

  final PageController controller;
  final int index;
  final _WaveModeOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final page = controller.hasClients
            ? (controller.page ?? controller.initialPage.toDouble())
            : controller.initialPage.toDouble();
        final delta = (page - index).abs();
        // Крайние карточки гаснут сильнее: намёк, что колесо продолжается.
        // Живое размытие было здесь же, но на каждом кадре свайпа оно
        // пересчитывалось для пяти карточек — 65% кадров не успевали.
        return Transform.scale(
          scale: 1 - 0.08 * delta.clamp(0.0, 2.0),
          child: Opacity(
            opacity: (1 - 0.22 * delta).clamp(0.25, 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                option.color.withValues(alpha: 0.55),
                option.color.withValues(alpha: 0.16),
                scheme.surfaceContainerHigh,
              ],
            ),
            border: Border.all(color: option.color.withValues(alpha: 0.45)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(option.icon, size: 20, color: Colors.white),
              ),
              const SizedBox(height: 7),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                // Одиночное слово ужимаем целиком, фразу переносим по словам:
                // пять карточек оставляют мало ширины.
                child: option.label.contains(' ')
                    ? Text(
                        option.label,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 11,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          option.label,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
