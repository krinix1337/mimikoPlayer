import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/prefs/prefs.dart';
import '../../../core/sources/source_id.dart';
import '../../../features/player/player_snapshot.dart';
import '../../../l10n/app_localizations.dart';
import '../../../sources/yandex/yandex_station.dart';
import '../../../theme/app_motion.dart';
import '../../../wave_providers.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/track_cover.dart';

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
    final wave = ref.watch(waveTracksProvider);
    // select: без него весь экран перестраивался на каждый тик позиции.
    final radio = ref.watch(
      playerSnapshotProviderValue.select(
        (s) => (s.isRadio, s.current?.localTrackId, s.current?.coverUrl),
      ),
    );
    final radioPlaying = radio.$1 && radio.$2 != null;
    final motion = Motion.of(context);
    final prefs = ref.watch(prefsProvider);
    final scheme = theme.colorScheme;

    final upcoming = wave.value ?? const <WaveTrack>[];
    String? cover;
    if (radioPlaying) {
      cover = radio.$3;
    } else if (upcoming.isNotEmpty) {
      cover = upcoming.first.source.coverUrl;
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: scheme.surface),
          // Пятна цвета дают движение, обложка — оттенок. Ни там, ни там нет
          // блюр-шейдера, и на дешёвом железе кадр не проседает.
          if (prefs.homeBackground != HomeBackground.cover)
            ColorBlobs(
              colors: [scheme.primary, scheme.tertiary, scheme.secondary],
              speed: motion.enabled ? 1 : 0,
            ),
          if (prefs.homeBackground != HomeBackground.blobs)
            BlurredCover(url: cover, opacity: 0.42),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.surface.withValues(alpha: 0.35),
                  Colors.transparent,
                  scheme.surface.withValues(alpha: 0.88),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Заголовок ниже кромки экрана и с крестиком возврата на
                // «мою волну»: у выбранной станции крестик виден, у волны — нет.
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
                        child: Text(
                          stationTitle,
                          style: theme.textTheme.displaySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (station != WaveStationIds.myVibe)
                        IconButton(
                          tooltip: l.switchToWave,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => _backToMyWave(ref),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),
                const Spacer(),
                _PlayButton(busy: wave.isLoading, onPlay: () => startWave(ref)),
                const SizedBox(height: 16),
                _NowPlayingPill(
                  wave: wave.value ?? const [],
                  failed: wave.hasError,
                ),
                const Spacer(),
                const _StationStrip(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _backToMyWave(WidgetRef ref) async {
    final wasRadio = ref.read(playerSnapshotProviderValue).isRadio;
    ref.read(stationProvider.notifier).select(WaveStationIds.myVibe);
    ref.invalidate(waveTracksProvider);
    ref.invalidate(waveSettingsProvider);
    if (wasRadio) await startWave(ref);
  }
}

class _PlayButton extends ConsumerWidget {
  const _PlayButton({required this.busy, required this.onPlay});

  final bool busy;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final motion = Motion.of(context);
    final playing = ref.watch(
      playerSnapshotProviderValue.select(
        (s) => s.isRadio && s.playing && s.current != null,
      ),
    );

    return Tooltip(
      message: playing ? l.commonPause : l.waveStart,
      child: SizedBox(
        width: 116,
        height: 116,
        child: PressableScale(
          minScale: 0.9,
          onTap: busy
              ? null
              : () => playing
                    ? ref.read(playbackControllerProvider).togglePlay()
                    : onPlay(),
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
                : AnimatedSwitcher(
                    duration: motion.micro(220),
                    child: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      key: ValueKey(playing),
                      size: 58,
                      color: scheme.onPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _NowPlayingPill extends ConsumerWidget {
  const _NowPlayingPill({required this.wave, required this.failed});

  final List<WaveTrack> wave;
  final bool failed;

  /// Подпись источника: откуда пришла очередь. Волна подписана названием
  /// станции, остальное — человеческим именем раздела.
  static String _sourceLabel(
    AppLocalizations l,
    PlayerSnapshot snapshot,
    String stationTitle,
  ) {
    if (snapshot.isRadio) return stationTitle;
    return switch (snapshot.sourceKind) {
      'library' => l.sourceLibrary,
      'playlist' => l.sourcePlaylist,
      'search' => l.sourceSearch,
      'chart' => l.sourceChart,
      'album' => l.sourceAlbum,
      'artist' => l.sourceArtist,
      '' => l.sourceLibrary,
      _ => l.sourceLibrary,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final snapshot = ref.watch(playerSnapshotProviderValue);
    final current = snapshot.current;
    final next = wave.isNotEmpty ? wave.first.source : null;
    final stationTitle = ref.watch(waveStationTitleProvider);

    final text =
        current?.title ??
        next?.title ??
        (failed ? l.waveQueueFailed : l.waveNotStarted);
    final subtitle = current?.artist ?? next?.artists.join(', ');
    final coverUrl = current?.coverUrl ?? next?.coverUrl;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.75,
        ),
        borderRadius: BorderRadius.circular(
          Motion.of(context).prefs.corner.radius,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  current == null
                      ? l.waveTitle
                      : _sourceLabel(
                          l,
                          snapshot,
                          stationTitle.isEmpty ? l.waveTitle : stationTitle,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (coverUrl != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TrackCover(url: coverUrl, size: 44, radius: 10),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              if (current != null)
                IconButton(
                  tooltip: snapshot.playing ? l.commonPause : l.commonPlay,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    snapshot.playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  onPressed: () =>
                      ref.read(playbackControllerProvider).togglePlay(),
                ),
              IconButton(
                tooltip: snapshot.liked ? l.commonUnlike : l.commonLike,
                visualDensity: VisualDensity.compact,
                onPressed: current == null
                    ? null
                    : () => _toggleLike(context, ref, current, snapshot.liked),
                icon: Icon(
                  snapshot.liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                ),
                color: snapshot.liked ? theme.colorScheme.error : null,
              ),
            ],
          ),
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
    final next = liked ? 0 : 1;

    await services.db.libraryDao.setLike(
      current.localTrackId,
      next,
      remoteSource: next == 1 ? SourceId.yandex : null,
    );
    await ref.read(playbackControllerProvider).refreshLikedState();
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

class _StationStrip extends ConsumerWidget {
  const _StationStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stations = ref.watch(waveStationsProvider);
    final selected = ref.watch(stationProvider);

    return SizedBox(
      height: 64,
      child: stations.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (error, _) => Center(
          child: Text(
            l.waveStationsFailed('$error'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        data: (list) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          itemCount: list.length + 1,
          separatorBuilder: (context, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _StationChip(
                title: l.waveTitle,
                selected: selected == WaveStationIds.myVibe,
                onTap: () => ref
                    .read(stationProvider.notifier)
                    .select(WaveStationIds.myVibe),
              );
            }
            final station = list[index - 1];
            return _StationChip(
              title: station.title,
              iconUrl: station.iconUrl,
              selected: selected == station.id,
              onTap: () =>
                  ref.read(stationProvider.notifier).select(station.id),
            );
          },
        ),
      ),
    );
  }
}

class _StationChip extends StatelessWidget {
  const _StationChip({
    required this.title,
    required this.selected,
    required this.onTap,
    this.iconUrl,
  });

  final String title;
  final String? iconUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final motion = Motion.of(context);
    return PressableScale(
      minScale: 0.96,
      onTap: onTap,
      child: AnimatedContainer(
        duration: motion.micro(220),
        curve: Curves.easeOutCubic,
        height: 52,
        constraints: const BoxConstraints(minWidth: 92, maxWidth: 168),
        padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer
              : scheme.surfaceContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(motion.prefs.corner.radius * 0.8),
          border: selected
              ? Border.all(color: scheme.primary, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 36,
                height: 36,
                child: iconUrl == null
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [scheme.primary, scheme.tertiary],
                          ),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: scheme.onPrimary,
                        ),
                      )
                    : TrackCover(url: iconUrl, size: 36, radius: 10),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  height: 1.15,
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
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
      builder: (context) => const _WaveSettingsSheet(),
    );

class _WaveSettingsSheet extends ConsumerStatefulWidget {
  const _WaveSettingsSheet();

  @override
  ConsumerState<_WaveSettingsSheet> createState() => _WaveSettingsSheetState();
}

class _WaveSettingsSheetState extends ConsumerState<_WaveSettingsSheet> {
  WaveSettings? _draft;
  bool _saving = false;
  String? _note;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loaded = await ref.read(waveSettingsProvider.future);
      if (mounted) setState(() => _draft = loaded ?? const WaveSettings());
    });
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final station = ref.watch(waveStationTitleProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.waveSettingsTitle, style: theme.textTheme.titleLarge),
            Text(
              station.isEmpty ? l.waveTitle : station,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(l.waveStation, style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            _StationPicker(
              current: ref.watch(stationProvider),
              onPick: (id) {
                ref.read(stationProvider.notifier).select(id);
                // Настройки у каждой станции свои — перечитываем черновик.
                setState(() => _draft = null);
                ref.read(waveSettingsProvider.future).then((loaded) {
                  if (mounted) {
                    setState(() => _draft = loaded ?? const WaveSettings());
                  }
                });
              },
            ),
            const SizedBox(height: 14),
            if (draft == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _levels(draft),
            if (_note != null) ...[
              const SizedBox(height: 8),
              Text(_note!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton(
                  onPressed: draft == null || _saving ? null : _save,
                  child: Text(l.waveApply),
                ),
                const SizedBox(width: 12),
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

  Widget _levels(WaveSettings draft) {
    final l = AppLocalizations.of(context);
    String mood(int value) => switch (value) {
      <= 1 => l.moodCalm,
      2 => l.moodEven,
      _ => l.moodActive,
    };
    String energy(int value) => switch (value) {
      <= 1 => l.energyLow,
      2 => l.energyMid,
      _ => l.energyHigh,
    };
    String diversity(String value) => switch (value) {
      'maximum_diversity' => l.diversityMore,
      'minimum_diversity' => l.diversityLess,
      _ => l.diversityUsual,
    };
    String language(String value) => switch (value) {
      'ru' => l.langRu,
      'en' => l.langEn,
      'nonrank' => l.langNonrank,
      _ => l.langAny,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.wavePresets, style: _labelStyle),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            for (final preset in const [
              (label: 'Спокойная', mood: 1, energy: 1),
              (label: 'Обычная', mood: 2, energy: 2),
              (label: 'Активная', mood: 3, energy: 3),
            ])
              ChoiceChip(
                label: Text(preset.label),
                selected:
                    (draft.mood ?? 2) == preset.mood &&
                    (draft.energy ?? 2) == preset.energy,
                onSelected: (_) => setState(
                  () => _draft = draft.copyWith(
                    mood: preset.mood,
                    energy: preset.energy,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(l.waveMood, style: _labelStyle),
        Slider(
          value: (draft.mood ?? 2).toDouble(),
          max: 4,
          divisions: 4,
          label: mood(draft.mood ?? 2),
          onChanged: (v) =>
              setState(() => _draft = draft.copyWith(mood: v.round())),
        ),
        Text(l.waveEnergy, style: _labelStyle),
        Slider(
          value: (draft.energy ?? 2).toDouble(),
          max: 4,
          divisions: 4,
          label: energy(draft.energy ?? 2),
          onChanged: (v) =>
              setState(() => _draft = draft.copyWith(energy: v.round())),
        ),
        const SizedBox(height: 8),
        Text(l.waveDiversity, style: _labelStyle),
        Wrap(
          spacing: 8,
          children: [
            for (final value in WaveSettings.diversityValues)
              ChoiceChip(
                label: Text(diversity(value)),
                selected: (draft.diversity ?? 'default') == value,
                onSelected: (_) =>
                    setState(() => _draft = draft.copyWith(diversity: value)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(l.waveLanguage, style: _labelStyle),
        Wrap(
          spacing: 8,
          children: [
            for (final value in WaveSettings.languageValues)
              ChoiceChip(
                label: Text(language(value)),
                selected: (draft.language ?? 'any') == value,
                onSelected: (_) =>
                    setState(() => _draft = draft.copyWith(language: value)),
              ),
          ],
        ),
      ],
    );
  }

  TextStyle? get _labelStyle => Theme.of(context).textTheme.labelLarge;

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final source = ref.read(yandexSourceProvider);
    final draft = _draft;
    if (source == null || draft == null) return;

    setState(() {
      _saving = true;
      _note = null;
    });
    final ok = await source.station.saveSettings(
      ref.read(stationProvider),
      draft,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _note = ok ? l.waveSavedNote : l.waveRejectedNote;
    });
    ref.invalidate(waveSettingsProvider);
    ref.invalidate(waveTracksProvider);
  }
}

/// Выбор станции прямо в настройках волны: у каждой станции свой набор
/// настроек, и переключать её из листа удобнее, чем закрывать лист.
class _StationPicker extends ConsumerWidget {
  const _StationPicker({required this.current, required this.onPick});

  final String current;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stations =
        ref.watch(waveStationsProvider).value ?? const <WaveStation>[];
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        ChoiceChip(
          label: Text(l.waveTitle),
          selected: current == WaveStationIds.myVibe,
          onSelected: (_) => onPick(WaveStationIds.myVibe),
        ),
        for (final station in stations.take(8))
          ChoiceChip(
            label: Text(station.title),
            selected: current == station.id,
            onSelected: (_) => onPick(station.id),
          ),
      ],
    );
  }
}
