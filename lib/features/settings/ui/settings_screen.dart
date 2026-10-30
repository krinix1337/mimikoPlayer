import 'dart:async';

import 'package:dio/dio.dart' show CancelToken, DioException;
import 'package:flutter/material.dart';
import 'package:phoneyandex/widgets/sliver_bottom_inset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_providers.dart';
import '../../../core/db/daos/library_dao.dart';
import '../../../core/platform/mimiko_platform.dart';
import '../../../core/prefs/prefs.dart';
import '../../../core/sources/source_dto.dart';
import '../../../features/auth/ui/yandex_login.dart';
import '../../../features/downloads/download_service.dart';
import '../../../features/import/track_list_sheet.dart';
import '../../../features/player/equalizer_presets.dart';
import '../../../features/updates/github_updater.dart';
import '../../../features/updates/release_notes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/routes.dart';
import '../../../router/slide_up_route.dart';
import '../../../theme/keyboard_theme.dart';
import 'settings_widgets.dart';

/// Настройки по разделам: хаб с категориями, каждая категория — отдельный
/// экран. Простыня из двадцати строк подряд читается хуже, чем шесть входа.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(prefsProvider);

    String appearanceSummary() {
      final theme = switch (prefs.themeMode) {
        ThemeMode.system => l.themeSystem,
        ThemeMode.light => l.themeLight,
        ThemeMode.dark => l.themeDark,
      };
      final language = prefs.localeCode == null
          ? l.languageSystem
          : prefs.localeCode!.toUpperCase();
      final accent = kKeyboardTestTheme
          ? 'MD3 Expressive'
          : prefs.accent.label(l);
      return '$theme · $accent · $language';
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
            child: Text(
              l.settingsTitle,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          SettingsSection(
            title: kKeyboardTestTheme ? '' : l.settingsTitle,
            children: [
              _CategoryTile(
                index: 0,
                icon: Icons.palette_outlined,
                title: l.settingsSectionAppearance,
                subtitle: appearanceSummary(),
                page: const _AppearancePage(),
              ),
              _CategoryTile(
                index: 1,
                icon: Icons.graphic_eq_rounded,
                title: l.settingsSectionSound,
                subtitle: '${l.settingsQuality}: ${prefs.qualityLabel(l)}',
                page: const _SoundPage(),
              ),
              _CategoryTile(
                index: 2,
                icon: Icons.lyrics_rounded,
                title: l.settingsSectionKaraoke,
                subtitle: l.settingsLyricsSource,
                page: const _KaraokeSettingsPage(),
              ),
              _CategoryTile(
                index: 3,
                icon: Icons.sd_storage_rounded,
                title: l.settingsSectionStorage,
                subtitle: l.settingsData,
                page: const _StoragePage(),
              ),
              _CategoryTile(
                index: 4,
                icon: Icons.account_circle_outlined,
                title: l.settingsSectionAccount,
                subtitle: l.settingsAccount,
                page: const _AccountPage(),
              ),
              _CategoryTile(
                index: 5,
                icon: Icons.move_to_inbox_rounded,
                title: l.importTitle,
                subtitle: l.importTileSubtitle,
                page: const _ImportPage(),
              ),
              FutureBuilder<String>(
                future: MimikoPlatform.appVersion(),
                builder: (context, snapshot) {
                  final version = snapshot.data;
                  return _CategoryTile(
                    index: 6,
                    icon: Icons.system_update_rounded,
                    title: l.updatesTitle,
                    subtitle: version == null || version.isEmpty
                        ? l.updatesTileSubtitle
                        : l.settingsVersion(version),
                    page: const _UpdatesPage(),
                  );
                },
              ),
              _CategoryTile(
                index: 7,
                icon: Icons.info_outline_rounded,
                title: l.settingsSectionAbout,
                subtitle: l.appTitle,
                page: const _AboutPage(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.page,
    required this.index,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget page;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (kKeyboardTestTheme) {
      final (background, foreground) = switch (index % 3) {
        0 => (scheme.primaryContainer, scheme.onPrimaryContainer),
        1 => (scheme.secondaryContainer, scheme.onSecondaryContainer),
        _ => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      };
      return SettingsGroupItem(
        onTap: () => Navigator.of(context).push(slideUpRoute(page)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: foreground, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      );
    }
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).push(slideUpRoute(page)),
    );
  }
}

class _AppearancePage extends ConsumerWidget {
  const _AppearancePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(prefsProvider);
    final controller = ref.read(prefsProvider.notifier);
    final theme = Theme.of(context);

    return _Page(
      title: l.settingsSectionAppearance,
      children: [
        SettingsSection(
          title: l.appearanceThemeLanguage,
          children: [
            if (kKeyboardTestTheme)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(
                  Localizations.localeOf(context).languageCode == 'en'
                      ? 'Test build: MD3 palette, accent and corner radius are fixed.'
                      : 'Тестовая сборка: палитра, акцент и радиусы зафиксированы.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            // Тема — сегментированная кнопка: это ровно тот M3-компонент,
            // который для взаимоисключающего выбора и предназначен.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.settingsTheme,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(l.themeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(l.themeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(l.themeDark),
                      ),
                    ],
                    selected: {prefs.themeMode},
                    showSelectedIcon: false,
                    onSelectionChanged: (value) =>
                        controller.setThemeMode(value.first),
                  ),
                ],
              ),
            ),
            ChoiceRow<String>(
              label: l.settingsLanguage,
              values: const ['system', 'ru', 'en'],
              current: prefs.localeCode ?? 'system',
              columns: 3,
              labelOf: (value) => switch (value) {
                'ru' => 'Русский',
                'en' => 'English',
                _ => l.languageSystem,
              },
              onPick: (value) =>
                  controller.setLocaleCode(value == 'system' ? null : value),
            ),
            if (!kKeyboardTestTheme) ...[
              ChoiceRow<AppPalette>(
                label: l.settingsPalette,
                values: AppPalette.values,
                current: prefs.palette,
                columns: 2,
                labelOf: (palette) => switch (palette) {
                  AppPalette.brand => l.paletteBrand,
                  AppPalette.dynamic => l.paletteDynamic,
                  AppPalette.mono => l.paletteMono,
                  AppPalette.amoled => l.paletteAmoled,
                },
                note: switch (prefs.palette) {
                  AppPalette.dynamic => l.paletteDynamicNote,
                  AppPalette.amoled => l.paletteAmoledNote,
                  _ => null,
                },
                onPick: controller.setPalette,
              ),
              AccentRow(
                label: l.settingsAccent,
                current: prefs.accent,
                labelOf: (accent) => accent.label(l),
                onPick: controller.setAccent,
              ),
              ChoiceRow<Contrast>(
                label: l.settingsContrast,
                values: Contrast.values,
                current: prefs.contrast,
                columns: 2,
                labelOf: (value) => value == Contrast.normal
                    ? l.contrastNormal
                    : l.contrastHigh,
                onPick: controller.setContrast,
              ),
            ],
          ],
        ),
        SettingsSection(
          title: l.appearanceShapeMotion,
          children: [
            if (!kKeyboardTestTheme)
              ChoiceRow<CornerRadius>(
                label: l.settingsCorners,
                values: CornerRadius.values,
                current: prefs.corner,
                columns: 3,
                labelOf: (value) => switch (value) {
                  CornerRadius.soft => l.cornerSoft,
                  CornerRadius.round => l.cornerRound,
                  CornerRadius.pill => l.cornerPill,
                },
                onPick: controller.setCorner,
              ),
            ChoiceRow<ArtworkShape>(
              label: l.artworkShape,
              values: ArtworkShape.values,
              current: prefs.artworkShape,
              columns: 3,
              labelOf: (value) => switch (value) {
                ArtworkShape.rounded => l.artworkRounded,
                ArtworkShape.soft => l.artworkSoft,
                ArtworkShape.circle => l.artworkCircle,
              },
              onPick: controller.setArtworkShape,
            ),
            ChoiceRow<AnimationsSpeed>(
              label: l.settingsMotion,
              values: AnimationsSpeed.values,
              current: prefs.animations,
              columns: kKeyboardTestTheme ? 2 : 4,
              labelOf: (value) => switch (value) {
                AnimationsSpeed.off => l.motionOff,
                AnimationsSpeed.fast => l.motionFast,
                AnimationsSpeed.normal => l.motionNormal,
                AnimationsSpeed.slow => l.motionSlow,
              },
              onPick: controller.setMotion,
            ),
          ],
        ),
        SettingsSection(
          title: l.uiSection,
          children: [
            SwitchRow(
              label: l.compactUi,
              value: prefs.compactUi,
              note: l.compactUiNote,
              onChanged: controller.setCompactUi,
            ),
            SwitchRow(
              label: l.showMiniPlayer,
              value: prefs.showMiniPlayer,
              note: l.showMiniPlayerNote,
              onChanged: controller.setShowMiniPlayer,
            ),
            SwitchRow(
              label: l.showNavLabels,
              value: prefs.showNavLabels,
              note: l.showNavLabelsNote,
              onChanged: controller.setShowNavLabels,
            ),
            SwitchRow(
              label: l.hideAi,
              value: prefs.hideAiTracks,
              note: l.hideAiNote,
              onChanged: controller.setHideAiTracks,
            ),
            ChoiceRow<HomeBackground>(
              label: l.homeBackground,
              values: HomeBackground.values,
              current: prefs.homeBackground,
              columns: 3,
              labelOf: (value) => switch (value) {
                HomeBackground.cover => l.bgCover,
                HomeBackground.blobs => l.bgBlobs,
                HomeBackground.both => l.bgBoth,
              },
              onPick: controller.setHomeBackground,
            ),
            ChoiceRow<HomeCoverTone>(
              label: l.homeCoverTone,
              values: HomeCoverTone.values,
              current: prefs.homeCoverTone,
              columns: 3,
              labelOf: (value) => switch (value) {
                HomeCoverTone.darker => l.homeCoverDarker,
                HomeCoverTone.normal => l.homeCoverNormal,
                HomeCoverTone.lighter => l.homeCoverLighter,
              },
              onPick: controller.setHomeCoverTone,
            ),
          ],
        ),
        SettingsSection(
          title: l.settingsBlur,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.speed_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.blurPerformanceNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _BlurChoice(
              label: l.blurBottom,
              note: l.blurBottomNote,
              current: prefs.blurBottom,
              onPick: controller.setBlurBottom,
            ),
            _BlurChoice(
              label: l.blurTop,
              note: l.blurTopNote,
              current: prefs.blurTop,
              onPick: controller.setBlurTop,
            ),
            _BlurChoice(
              label: l.blurCovers,
              note: l.blurCoversNote,
              current: prefs.blurCover,
              onPick: controller.setBlurCover,
            ),
          ],
        ),
        SettingsSection(
          title: l.settingsLauncherIcon,
          children: const [LauncherIconRow()],
        ),
      ],
    );
  }
}

class _SoundPage extends ConsumerWidget {
  const _SoundPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(prefsProvider);
    final controller = ref.read(prefsProvider.notifier);

    return _Page(
      title: l.settingsSectionSound,
      children: [
        SettingsSection(
          title: l.settingsPlayback,
          children: [
            DiscreteSliderRow<String>(
              label: l.settingsQuality,
              values: const ['auto', 'low', 'normal', 'high', 'lossless'],
              current: prefs.quality,
              labelOf: (value) => switch (value) {
                'auto' => l.qualityAuto,
                'low' => l.qualityLow,
                'normal' => l.qualityNormal,
                'high' => l.qualityHigh,
                _ => l.qualityLossless,
              },
              onPick: controller.setQuality,
            ),
            SwitchRow(
              label: l.settingsFade,
              value: prefs.fade,
              note: l.settingsFadeNote,
              onChanged: controller.setFade,
            ),
            DiscreteSliderRow<int>(
              label: l.settingsCrossfade,
              note: l.settingsCrossfadeNote,
              values: const [0, 3, 6, 9, 12],
              current: prefs.crossfadeSeconds,
              labelOf: (value) =>
                  value == 0 ? l.crossfadeOff : l.crossfadeSecondsValue(value),
              onPick: controller.setCrossfadeSeconds,
            ),
            SwitchRow(
              label: l.censorBypass,
              value: prefs.censorBypass,
              note: l.censorBypassNote,
              onChanged: controller.setCensorBypass,
            ),
            SwitchRow(
              label: l.settingsOpenPlayer,
              value: prefs.openPlayerOnPlay,
              note: l.settingsOpenPlayerNote,
              onChanged: controller.setOpenPlayerOnPlay,
            ),
            const PriorityTile(),
            const BlockedArtistsTile(),
          ],
        ),
        const _EqualizerSection(),
      ],
    );
  }
}

class _EqualizerSection extends ConsumerWidget {
  const _EqualizerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(prefsProvider);
    final controller = ref.read(prefsProvider.notifier);
    final presetLabel = prefs.eqPreset == equalizerCustomId
        ? l.equalizerCustom
        : _presetLabel(l, prefs.eqPreset);

    return SettingsSection(
      title: l.settingsEqualizer,
      children: [
        SwitchRow(
          label: l.equalizerEnabled,
          value: prefs.eqEnabled,
          note: l.equalizerNote,
          onChanged: controller.setEqEnabled,
        ),
        ListTile(
          title: Text(l.equalizerTune),
          subtitle: Text(presetLabel),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => showModalBottomSheet<void>(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => const _EqualizerSheet(),
          ),
        ),
      ],
    );
  }
}

class _EqualizerSheet extends ConsumerStatefulWidget {
  const _EqualizerSheet();

  @override
  ConsumerState<_EqualizerSheet> createState() => _EqualizerSheetState();
}

class _EqualizerSheetState extends ConsumerState<_EqualizerSheet> {
  late String _preset;
  late List<double> _gains;
  late double _level;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(prefsProvider);
    _preset = prefs.eqPreset;
    if (_preset == equalizerCustomId) {
      _gains = List.of(prefs.eqCustomGains);
      _level = prefs.eqCustomLevel;
    } else {
      final preset = equalizerPresetById(_preset);
      _gains = List.of(preset.gainsDb);
      _level = preset.preampDb;
    }
  }

  /// Первое движение любого слайдера превращает пресет в свою настройку:
  /// дальше полосы живут отдельно от выбранного пресета.
  void _touch() {
    if (_preset != equalizerCustomId) _preset = equalizerCustomId;
  }

  Future<void> _commitCustom() async {
    if (_preset != equalizerCustomId) return;
    await ref.read(prefsProvider.notifier).setEqCustom(List.of(_gains), _level);
  }

  void _pickPreset(String? id) {
    if (id == null) return;
    final prefs = ref.read(prefsProvider);
    final controller = ref.read(prefsProvider.notifier);
    if (id == equalizerCustomId) {
      setState(() {
        _preset = id;
        _gains = List.of(prefs.eqCustomGains);
        _level = prefs.eqCustomLevel;
      });
    } else {
      final preset = equalizerPresetById(id);
      setState(() {
        _preset = id;
        _gains = List.of(preset.gainsDb);
        _level = preset.preampDb;
      });
    }
    controller.setEqPreset(id);
  }

  Future<void> _openPresetPicker() async {
    final l = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                l.equalizerPreset,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final id in [
                    equalizerCustomId,
                    for (final preset in equalizerPresets) preset.id,
                  ])
                    ListTile(
                      title: Text(
                        id == equalizerCustomId
                            ? l.equalizerCustom
                            : _presetLabel(l, id),
                      ),
                      trailing: id == _preset
                          ? Icon(
                              Icons.check_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () => Navigator.of(sheetContext).pop(id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted || picked == null) return;
    _pickPreset(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final prefs = ref.watch(prefsProvider);
    final controller = ref.read(prefsProvider.notifier);

    return DraggableScrollableSheet(
      expand: false,
      // Фиксированная высота: потянуть лист на весь экран нельзя, лишнее
      // содержимое просто прокручивается внутри.
      initialChildSize: 0.78,
      minChildSize: 0.35,
      maxChildSize: 0.78,
      snap: true,
      shouldCloseOnMinExtent: true,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          24 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.settingsEqualizer,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Switch(
                value: prefs.eqEnabled,
                onChanged: controller.setEqEnabled,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: _EqualizerSliders(
              gains: _gains,
              level: _level,
              onGain: (index, value) {
                _touch();
                setState(() => _gains[index] = value);
              },
              onLevel: (value) {
                _touch();
                setState(() => _level = value);
              },
              onCommit: _commitCustom,
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _openPresetPicker,
              child: SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _preset == equalizerCustomId
                              ? l.equalizerCustom
                              : _presetLabel(l, _preset),
                        ),
                      ),
                      const Icon(Icons.expand_more_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Слайдеры: уровень слева и десять полос; значение сверху, частота снизу.
class _EqualizerSliders extends StatelessWidget {
  const _EqualizerSliders({
    required this.gains,
    required this.level,
    required this.onGain,
    required this.onLevel,
    required this.onCommit,
  });

  final List<double> gains;
  final double level;
  final void Function(int index, double value) onGain;
  final ValueChanged<double> onLevel;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VerticalBand(
          label: l.equalizerLevel,
          value: level,
          onChanged: onLevel,
          onCommit: onCommit,
        ),
        for (var i = 0; i < gains.length; i++)
          _VerticalBand(
            label: _hzLabel(equalizerBandHz[i]),
            value: gains[i],
            onChanged: (value) => onGain(i, value),
            onCommit: onCommit,
          ),
      ],
    );
  }
}

class _VerticalBand extends StatelessWidget {
  const _VerticalBand({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onCommit,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = value.clamp(-12.0, 12.0).toDouble();
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 18,
            child: Text(
              _dbLabel(clamped),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                  showValueIndicator: ShowValueIndicator.never,
                ),
                child: Slider(
                  value: clamped,
                  min: -12,
                  max: 12,
                  divisions: 48,
                  onChanged: onChanged,
                  onChangeEnd: (_) => onCommit(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 16,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _dbLabel(double value) {
  if (value.abs() < 0.05) return '0';
  final rounded = value.round();
  return rounded > 0 ? '+$rounded' : '$rounded';
}

String _hzLabel(double hz) {
  if (hz >= 1000) {
    final k = hz / 1000;
    return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}k';
  }
  return hz.toInt().toString();
}

String _presetLabel(AppLocalizations l, String id) => switch (id) {
  'bass' => l.eqPresetBass,
  'treble' => l.eqPresetTreble,
  'rock' => l.eqPresetRock,
  'electronic' => l.eqPresetElectronic,
  'pop' => l.eqPresetPop,
  'vocal' => l.eqPresetVocal,
  'acoustic' => l.eqPresetAcoustic,
  _ => l.eqPresetFlat,
};

class _KaraokeSettingsPage extends ConsumerWidget {
  const _KaraokeSettingsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(prefsProvider);
    final controller = ref.read(prefsProvider.notifier);

    return _Page(
      title: l.settingsSectionKaraoke,
      children: [
        SettingsSection(
          title: l.settingsSectionKaraoke,
          children: [
            ChoiceRow<LyricsSize>(
              label: l.lyricsSize,
              values: LyricsSize.values,
              current: prefs.lyricsSize,
              labelOf: (value) => switch (value) {
                LyricsSize.small => l.lyricsSizeSmall,
                LyricsSize.normal => l.lyricsSizeNormal,
                LyricsSize.large => l.lyricsSizeLarge,
              },
              onPick: controller.setLyricsSize,
            ),
            SwitchRow(
              label: l.lyricsDim,
              value: prefs.lyricsDimOthers,
              onChanged: controller.setLyricsDim,
            ),
            ListTile(
              title: Text(l.settingsLyricsSource),
              subtitle: Text(l.settingsLyricsSourceNote),
            ),
          ],
        ),
      ],
    );
  }
}

class _StoragePage extends ConsumerWidget {
  const _StoragePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(prefsProvider);
    final controller = ref.read(prefsProvider.notifier);
    final limitGb = prefs.downloadLimitBytes == null
        ? 0
        : (prefs.downloadLimitBytes! / (1024 * 1024 * 1024)).round();
    return _Page(
      title: l.settingsSectionStorage,
      children: [
        SettingsSection(
          title: l.settingsStorage,
          children: const [CacheTile()],
        ),
        SettingsSection(
          title: l.settingsDownloads,
          children: [
            const DownloadsTile(),
            SwitchRow(
              label: l.downloadsAutoLikes,
              value: prefs.autoDownloadLikes,
              note: l.downloadsAutoLikesNote,
              onChanged: (value) async {
                await controller.setAutoDownloadLikes(value);
                final downloads = ref.read(downloadControllerProvider.notifier);
                if (value) {
                  unawaited(downloads.kickAutoDownloads());
                } else {
                  unawaited(downloads.cancelAutoQueue());
                }
              },
            ),
            if (prefs.autoDownloadLikes && !prefs.autoDownloadAllApproved)
              ListTile(
                leading: const Icon(Icons.playlist_add_check_rounded),
                title: Text(l.downloadsDownloadAll),
                subtitle: Text(l.downloadsDownloadAllNote),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await controller.setAutoDownloadAllApproved(true);
                  unawaited(
                    ref
                        .read(downloadControllerProvider.notifier)
                        .kickAutoDownloads(),
                  );
                },
              ),
            SwitchRow(
              label: l.downloadsWifiOnly,
              value: prefs.autoDownloadWifiOnly,
              note: l.downloadsWifiOnlyNote,
              onChanged: controller.setAutoDownloadWifiOnly,
            ),
            DiscreteSliderRow<int>(
              label: l.downloadsLimit,
              values: const [0, 2, 5, 10, 20],
              current: limitGb,
              labelOf: (gb) =>
                  gb == 0 ? l.downloadsUnlimited : l.downloadsGb(gb),
              note: l.downloadsLimitNote,
              onPick: (gb) => controller.setDownloadLimitBytes(
                gb == 0 ? null : gb * 1024 * 1024 * 1024,
              ),
            ),
            ChoiceRow<String>(
              label: l.downloadsQuality,
              values: const ['low', 'normal', 'high'],
              current: prefs.autoDownloadQuality,
              columns: 3,
              labelOf: (quality) => switch (quality) {
                'low' => l.qualityLow,
                'high' => l.qualityHigh,
                _ => l.qualityNormal,
              },
              note: l.downloadsQualityNote,
              onPick: controller.setAutoDownloadQuality,
            ),
            const DeleteDownloadsTile(),
          ],
        ),
        SettingsSection(
          title: l.settingsData,
          children: [
            const DatabaseTile(),
            ListTile(
              title: Text(l.settingsLogs),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(Routes.logs),
            ),
            ListTile(
              title: Text(l.settingsReset),
              textColor: Theme.of(context).colorScheme.error,
              onTap: () => _confirmReset(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.settingsReset),
        content: Text(l.settingsResetDone),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.settingsReset),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(prefsProvider.notifier).reset();
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.settingsResetDone)));
    }
  }
}

class _ImportPage extends StatelessWidget {
  const _ImportPage();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return _Page(
      title: l.importTitle,
      children: [
        _ProfileHero(
          leading: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.move_to_inbox_rounded,
              size: 32,
              color: scheme.primary,
            ),
          ),
          title: l.importHeroTitle,
          subtitle: l.importHeroNote,
          status: l.importHeroStatus,
          statusOk: true,
        ),
        SettingsSection(
          title: l.importOther,
          children: [
            ListTile(
              leading: const Icon(Icons.format_list_bulleted_rounded),
              title: Text(l.importList),
              subtitle: Text(l.importListFormat),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                final result = await showTrackListImportSheet(context);
                if (result?.playlistId != null && context.mounted) {
                  context.push(Routes.playlist(result!.playlistId!));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note_rounded),
              title: const Text('Яндекс Музыка'),
              subtitle: Text(l.importOtherYandex),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_rounded),
              title: const Text('SoundCloud'),
              subtitle: Text(l.importOtherSoundCloud),
            ),
          ],
        ),
      ],
    );
  }
}

class _AccountPage extends ConsumerWidget {
  const _AccountPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final auth =
        ref.watch(yandexAuthStateProvider).value ?? const AuthUnknown();
    final account = auth is AuthReady ? auth : null;
    final ready = account != null;
    final liked = ref.watch(collectionProvider(CollectionKind.liked)).value;
    final disliked = ref
        .watch(collectionProvider(CollectionKind.disliked))
        .value;
    final playlists = ref.watch(playlistsProvider).value;
    final services = ref.read(appServicesProvider);

    return _Page(
      title: l.settingsSectionAccount,
      children: [
        _ProfileHero(
          leading: _YandexAvatar(url: account?.avatarUrl),
          title: account?.login ?? 'Яндекс Музыка',
          subtitle: account == null
              ? l.authNotSignedIn
              : (account.hasPlus ? l.accountPlus : l.accountFree),
          status: ready ? l.accountConnected : l.authNotSignedIn,
          statusOk: ready,
          action: ready
              ? OutlinedButton.icon(
                  onPressed: () async {
                    await services.yandexAuth?.logout();
                    ref.invalidate(collectionProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.settingsSignedOut)),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(l.accountSignOut),
                )
              : FilledButton.icon(
                  onPressed: () => showYandexLogin(context, ref),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: Text(l.waveSignIn),
                ),
          stats: [
            (label: l.collectionLiked, value: '${liked?.length ?? 0}'),
            (label: l.collectionDisliked, value: '${disliked?.length ?? 0}'),
            (label: l.collectionPlaylists, value: '${playlists?.length ?? 0}'),
          ],
        ),
        SettingsSection(
          title: l.accountServices,
          children: [
            ListTile(
              leading: const Icon(Icons.music_note_rounded),
              title: const Text('Яндекс Музыка'),
              subtitle: Text(ready ? l.accountConnected : l.authNotSignedIn),
              trailing: Icon(
                ready
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                color: ready
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_rounded),
              title: const Text('SoundCloud'),
              subtitle: Text(l.accountSoundCloudNote),
              trailing: Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lyrics_rounded),
              title: Text(l.settingsLyricsSource),
              subtitle: Text(l.settingsLyricsSourceNote),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_rounded),
              title: Text(l.settingsAiFilter),
              subtitle: Text(l.settingsAiFilterSource),
            ),
            ListTile(
              leading: const Icon(Icons.explicit_rounded),
              title: Text(l.settingsCensorSource),
              subtitle: Text(l.censorBypassNote),
            ),
          ],
        ),
      ],
    );
  }
}

class _YandexAvatar extends StatelessWidget {
  const _YandexAvatar({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fallback = Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person_rounded, size: 34, color: scheme.primary),
    );
    final source = url;
    if (source == null || source.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        source,
        width: 62,
        height: 62,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}

/// Общая верхняя карточка «Аккаунт» и «О приложении»: та же пластика,
/// что у раздела обновлений, но с показателями и действием.
class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusOk,
    this.action,
    this.stats = const [],
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final String status;
  final bool statusOk;
  final Widget? action;
  final List<({String label, String value})> stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.30),
            scheme.surfaceContainerHigh,
            scheme.surfaceContainerLow,
          ],
        ),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              leading,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (action != null) ...[const SizedBox(width: 8), action!],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                statusOk
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                size: 17,
                color: statusOk ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  status,
                  style: text.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: statusOk ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final stat in stats)
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: 0.65,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          stat.value,
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          stat.label,
                          style: text.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AboutPage extends ConsumerStatefulWidget {
  const _AboutPage();

  @override
  ConsumerState<_AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<_AboutPage> {
  late final Future<String> _version = MimikoPlatform.appVersion();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(prefsProvider);
    final check = Icon(
      Icons.check_circle_rounded,
      color: Theme.of(context).colorScheme.primary,
    );
    return _Page(
      title: l.settingsSectionAbout,
      children: [
        FutureBuilder<String>(
          future: _version,
          builder: (context, snapshot) {
            final version = snapshot.data;
            return _ProfileHero(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  prefs.launcherIcon.asset,
                  width: 62,
                  height: 62,
                  fit: BoxFit.cover,
                ),
              ),
              title: l.appTitle,
              subtitle: l.settingsAboutNote,
              status: l.settingsVersion(
                version == null || version.isEmpty ? '…' : version,
              ),
              statusOk: true,
            );
          },
        ),
        SettingsSection(
          title: l.settingsAbout,
          children: [
            ListTile(
              leading: const Icon(Icons.code_rounded),
              title: const Text('GitHub'),
              subtitle: const Text('github.com/krinix1337'),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () => launchUrl(
                Uri.parse('https://github.com/krinix1337'),
                mode: LaunchMode.externalApplication,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android_rounded),
              title: Text(l.appTitle),
              subtitle: const Text('Flutter · Material 3 · Android'),
            ),
          ],
        ),
        SettingsSection(
          title: l.aboutSources,
          children: [
            ListTile(
              leading: const Icon(Icons.music_note_rounded),
              title: const Text('Яндекс Музыка'),
              subtitle: Text(l.aboutYandexNote),
              // Как у соседних источников: без галочки казалось, что
              // Яндекс не подключён.
              trailing: ref.watch(yandexReadyProvider) ? check : null,
            ),
            ListTile(
              leading: const Icon(Icons.cloud_rounded),
              title: const Text('SoundCloud'),
              subtitle: Text(l.accountSoundCloudNote),
              trailing: check,
            ),
            ListTile(
              leading: const Icon(Icons.folder_rounded),
              title: Text(l.collectionFiles),
              subtitle: Text(l.collectionLocalTag),
              trailing: check,
            ),
            ListTile(
              leading: const Icon(Icons.lyrics_rounded),
              title: Text(l.settingsLyricsSource),
              subtitle: Text(l.settingsLyricsSourceNote),
              trailing: check,
            ),
          ],
        ),
        SettingsSection(
          title: l.settingsData,
          children: [
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: Text(l.settingsAiFilter),
              subtitle: const Text('github.com/alexeyfv/slopless · GPL-3.0'),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () => launchUrl(
                Uri.parse('https://github.com/alexeyfv/slopless'),
                mode: LaunchMode.externalApplication,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.explicit_outlined),
              title: Text(l.settingsCensorSource),
              subtitle: const Text('github.com/Hazzz895/FckCensorData'),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () => launchUrl(
                Uri.parse('https://github.com/Hazzz895/FckCensorData'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UpdatesPage extends ConsumerStatefulWidget {
  const _UpdatesPage();

  @override
  ConsumerState<_UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends ConsumerState<_UpdatesPage> {
  static const _buildToken = String.fromEnvironment('GITHUB_TOKEN');

  final GithubUpdater _updater = GithubUpdater();
  late final TextEditingController _tokenController;
  CancelToken? _cancelToken;
  String _version = '';
  bool _checking = false;
  bool _downloading = false;
  bool _showToken = false;
  bool _upToDate = false;
  bool? _tokenValid;
  double _progress = 0;
  UpdateRelease? _latest;
  UpdateRelease? _release;
  UpdateFailure? _failure;
  String? _downloadedPath;

  String get _token =>
      _buildToken.isNotEmpty ? _buildToken : _tokenController.text.trim();

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(
      text: ref.read(prefsProvider).githubToken,
    );
    unawaited(_init());
  }

  Future<void> _init() async {
    final version = await MimikoPlatform.appVersion();
    if (!mounted) return;
    setState(() => _version = version);
    if (_token.isNotEmpty) await _check(silent: true);
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    _tokenController.dispose();
    super.dispose();
  }

  void _show(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String? _failureText(AppLocalizations l) => switch (_failure) {
    null => null,
    UpdateFailure.unauthorized => l.updatesErrorUnauthorized,
    UpdateFailure.notFound => l.updatesErrorNotFound,
    UpdateFailure.noAsset => l.updatesErrorNoAsset,
    UpdateFailure.noDigest => l.updatesErrorNoDigest,
    UpdateFailure.checksum => l.updatesErrorChecksum,
    UpdateFailure.network => l.updatesErrorNetwork,
    UpdateFailure.unknown => l.updatesErrorUnknown,
  };

  Future<void> _check({bool silent = false}) async {
    if (_checking || _downloading) return;
    final l = AppLocalizations.of(context);
    final token = _token;
    if (token.isEmpty) {
      if (_buildToken.isEmpty &&
          ref.read(prefsProvider).githubToken.isNotEmpty) {
        await ref.read(prefsProvider.notifier).setGithubToken('');
      }
      if (mounted) {
        setState(() {
          _tokenValid = null;
          _failure = null;
          _latest = null;
          _release = null;
          _upToDate = false;
          _downloadedPath = null;
        });
      }
      if (!silent) _show(l.updatesTokenNeeded);
      return;
    }
    setState(() {
      _checking = true;
      _failure = null;
      _latest = null;
      _release = null;
      _upToDate = false;
      _downloadedPath = null;
    });
    try {
      var version = _version;
      if (version.isEmpty) {
        version = await MimikoPlatform.appVersion();
        if (mounted) setState(() => _version = version);
      }
      if (version.isEmpty) {
        throw const UpdateException(UpdateFailure.unknown);
      }
      if (_buildToken.isEmpty && token != ref.read(prefsProvider).githubToken) {
        await ref.read(prefsProvider.notifier).setGithubToken(token);
      }
      final latest = await _updater.latest(token: token);
      if (!mounted) return;
      final release = latest != null && latest.isNewerThan(version)
          ? latest
          : null;
      setState(() {
        _latest = latest;
        _release = release;
        _upToDate = release == null;
        _tokenValid = true;
      });
    } on UpdateException catch (error) {
      if (!mounted) return;
      final kind = error.kind;
      setState(() {
        _failure = kind;
        if (kind == UpdateFailure.unauthorized ||
            kind == UpdateFailure.notFound) {
          _tokenValid = false;
        } else if (kind == UpdateFailure.noAsset) {
          _tokenValid = true;
        }
      });
      if (!silent) _show(_failureText(l) ?? l.updatesErrorUnknown);
    } catch (_) {
      if (!mounted) return;
      setState(() => _failure = UpdateFailure.unknown);
      if (!silent) _show(l.updatesErrorUnknown);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _downloadAndInstall() async {
    final release = _release;
    if (release == null) return;
    final l = AppLocalizations.of(context);
    final token = _token;
    if (token.isEmpty) {
      _show(l.updatesTokenNeeded);
      return;
    }
    setState(() {
      _downloading = true;
      _progress = 0;
      _failure = null;
      _downloadedPath = null;
    });
    final cancel = CancelToken();
    _cancelToken = cancel;
    try {
      final file = await _updater.download(
        release: release,
        token: token,
        cancelToken: cancel,
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _progress = total > 0 ? received / total : 0;
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _downloadedPath = file.path;
      });
      await _install();
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        if (mounted) {
          setState(() {
            _downloading = false;
            _progress = 0;
          });
        }
      } else {
        _fail(UpdateFailure.network, l);
      }
    } on UpdateException catch (error) {
      _fail(error.kind, l);
    } catch (_) {
      _fail(UpdateFailure.unknown, l);
    } finally {
      if (mounted && _downloading) {
        setState(() {
          _downloading = false;
          _progress = 0;
        });
      }
      _cancelToken = null;
    }
  }

  Future<void> _install() async {
    final path = _downloadedPath;
    if (path == null) return;
    final started = await MimikoPlatform.installApk(path);
    if (!mounted) return;
    if (!started) {
      _show(AppLocalizations.of(context).updatesInstallPermission);
    }
  }

  void _cancelDownload() {
    _cancelToken?.cancel();
  }

  void _fail(UpdateFailure kind, AppLocalizations l) {
    if (!mounted) return;
    setState(() {
      _downloading = false;
      _progress = 0;
      _failure = kind;
      if (kind == UpdateFailure.unauthorized ||
          kind == UpdateFailure.notFound) {
        _tokenValid = false;
      }
    });
    _show(_failureText(l) ?? l.updatesErrorUnknown);
  }

  Future<void> _clearToken() async {
    _tokenController.clear();
    if (_buildToken.isEmpty) {
      await ref.read(prefsProvider.notifier).setGithubToken('');
    }
    if (!mounted) return;
    setState(() {
      _tokenValid = null;
      _failure = null;
      _latest = null;
      _release = null;
      _upToDate = false;
      _downloadedPath = null;
    });
  }

  Future<void> _showNotes(UpdateRelease release) async {
    final notes = release.notes;
    if (notes == null || notes.isEmpty) return;
    // Заголовок шторки уже говорит «Что нового»; первый такой же заголовок
    // из тела релиза убираем, чтобы не дублировать.
    final body = notes.replaceFirst(
      RegExp(r"^\s*##\s+(Что нового|What's new)\s*\n+", caseSensitive: false),
      '',
    );
    await Navigator.of(context, rootNavigator: true).push(
      slideUpRoute(_ReleaseNotesPage(version: release.version, body: body)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authFailure =
        _failure == UpdateFailure.unauthorized ||
        _failure == UpdateFailure.notFound;
    // При отказе доступа статус токена уже красный; второй такой же
    // ошибки в блоке обновлений не нужно.
    final failure = authFailure ? null : _failureText(l);
    final release = _release;
    final action = _downloadedPath != null ? _install : _downloadAndInstall;
    final actionLabel = _downloading
        ? l.updatesDownloading((_progress * 100).round())
        : _downloadedPath != null
        ? l.updatesInstall
        : l.updatesDownload;
    final tokenStatus = _token.isEmpty
        ? l.updatesTokenMissing
        : _checking
        ? l.updatesChecking
        : _tokenValid == true
        ? l.updatesTokenValid
        : _tokenValid == false
        ? l.updatesTokenInvalid
        : l.updatesTokenUnchecked;
    final tokenColor = _tokenValid == false
        ? theme.colorScheme.error
        : _tokenValid == true
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    final tokenIcon = _tokenValid == false
        ? Icons.error_rounded
        : _tokenValid == true
        ? Icons.check_circle_rounded
        : _token.isEmpty
        ? Icons.key_off_rounded
        : Icons.info_outline_rounded;
    final latest = _latest;
    final iconAsset = LauncherIconRow.assetFor(
      ref.watch(prefsProvider.select((p) => p.launcherIcon)),
    );
    final heroStatus = _checking
        ? l.updatesChecking
        : release != null
        ? l.updatesAvailable(release.version)
        : authFailure
        ? l.updatesTokenInvalid
        : _upToDate
        ? l.updatesUpToDate
        : _token.isEmpty
        ? l.updatesTokenMissing
        : l.updatesTokenUnchecked;
    final heroColor = authFailure
        ? theme.colorScheme.error
        : release != null || _upToDate
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    final heroIcon = authFailure
        ? Icons.error_rounded
        : release != null
        ? Icons.new_releases_rounded
        : _upToDate
        ? Icons.check_circle_rounded
        : _token.isEmpty
        ? Icons.key_off_rounded
        : Icons.info_outline_rounded;

    return _Page(
      title: l.updatesTitle,
      children: [
        _UpdatesHero(
          appTitle: l.appTitle,
          versionLabel: _version.isEmpty ? '…' : l.settingsVersion(_version),
          status: heroStatus,
          statusIcon: heroIcon,
          statusColor: heroColor,
          iconAsset: iconAsset,
          checking: _checking,
          checkLabel: l.updatesCheckShort,
          onCheck: _checking || _downloading ? null : () => _check(),
        ),
        if (_buildToken.isEmpty)
          SettingsSection(
            title: l.updatesTokenTitle,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                child: TextField(
                  controller: _tokenController,
                  enabled: !_checking && !_downloading,
                  obscureText: !_showToken,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l.updatesTokenLabel,
                    hintText: l.updatesTokenHint,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_tokenController.text.isNotEmpty)
                          IconButton(
                            tooltip: l.updatesTokenDelete,
                            onPressed: _checking || _downloading
                                ? null
                                : _clearToken,
                            icon: const Icon(
                              Icons.backspace_outlined,
                              size: 20,
                            ),
                          ),
                        IconButton(
                          onPressed: () =>
                              setState(() => _showToken = !_showToken),
                          icon: Icon(
                            _showToken
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {
                      _latest = null;
                      _release = null;
                      _upToDate = false;
                      _failure = null;
                      _tokenValid = null;
                      _downloadedPath = null;
                    });
                  },
                  onSubmitted: (_) => _check(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Row(
                  children: [
                    if (_checking)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(tokenIcon, size: 16, color: tokenColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tokenStatus,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokenColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  '${l.updatesTokenHelp}\n${l.updatesTokenCheckHint}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.open_in_new_rounded),
                title: Text(l.updatesTokenCreate),
                onTap: () => launchUrl(
                  Uri.parse('https://github.com/settings/tokens?type=beta'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          )
        else
          SettingsSection(
            title: l.updatesTokenTitle,
            children: [
              ListTile(
                leading: const Icon(Icons.key_rounded),
                title: Text(l.updatesTokenLabel),
                subtitle: Text(
                  _tokenValid == false
                      ? l.updatesTokenInvalid
                      : _tokenValid == true
                      ? l.updatesTokenValid
                      : l.updatesBuildToken,
                ),
              ),
            ],
          ),
        SettingsSection(
          title: l.updatesReleases,
          children: [
            if (failure != null)
              ListTile(
                leading: Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.error,
                ),
                title: Text(failure),
              ),
            if (release != null) ...[
              ListTile(
                leading: Icon(
                  Icons.new_releases_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(l.updatesAvailable(release.version)),
                subtitle: Text(
                  '${release.assetName} · '
                  '${l.updatesSize(GithubUpdater.formatMb(release.size))}',
                ),
              ),
              if (release.notes != null && release.notes!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: Text(l.updatesWhatsNew(release.version)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                  onTap: () => _showNotes(release),
                ),
              if (release.webUrl != null)
                ListTile(
                  leading: const Icon(Icons.open_in_new_rounded),
                  title: Text(l.updatesOpenGithub),
                  onTap: () => launchUrl(
                    Uri.parse(release.webUrl!),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              if (_downloadedPath != null && !_downloading)
                ListTile(
                  leading: Icon(
                    Icons.verified_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l.updatesReady),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _downloading ? null : action,
                        icon: Icon(
                          _downloading
                              ? Icons.downloading_rounded
                              : _downloadedPath != null
                              ? Icons.system_update_alt_rounded
                              : Icons.download_rounded,
                        ),
                        label: Text(actionLabel),
                      ),
                    ),
                    if (_downloading) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _cancelDownload,
                        child: Text(l.updatesCancel),
                      ),
                    ],
                  ],
                ),
              ),
              if (_downloading)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: LinearProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    minHeight: 4,
                  ),
                ),
            ] else if (latest != null) ...[
              ListTile(
                leading: Icon(
                  Icons.history_rounded,
                  color: theme.colorScheme.primary,
                ),
                title: Text(l.updatesLatestRelease(latest.version)),
                subtitle: Text(
                  '${latest.assetName} · '
                  '${l.updatesSize(GithubUpdater.formatMb(latest.size))}',
                ),
              ),
              if (latest.notes != null && latest.notes!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: Text(l.updatesWhatsNew(latest.version)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                  onTap: () => _showNotes(latest),
                ),
              if (latest.webUrl != null)
                ListTile(
                  leading: const Icon(Icons.open_in_new_rounded),
                  title: Text(l.updatesOpenGithub),
                  onTap: () => launchUrl(
                    Uri.parse(latest.webUrl!),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
            ] else if (!_checking && !authFailure && !_upToDate)
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(l.updatesNotChecked),
              ),
          ],
        ),
      ],
    );
  }
}

class _UpdatesHero extends StatelessWidget {
  const _UpdatesHero({
    required this.appTitle,
    required this.versionLabel,
    required this.status,
    required this.statusIcon,
    required this.statusColor,
    required this.iconAsset,
    required this.checking,
    required this.checkLabel,
    required this.onCheck,
  });

  final String appTitle;
  final String versionLabel;
  final String status;
  final IconData statusIcon;
  final Color statusColor;
  final String iconAsset;
  final bool checking;
  final String checkLabel;
  final VoidCallback? onCheck;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.30),
            scheme.surfaceContainerHigh,
            scheme.surfaceContainerLow,
          ],
        ),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        iconAsset,
                        width: 62,
                        height: 62,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            versionLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(
                      onPressed: onCheck,
                      icon: checking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(checkLabel),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (checking)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(statusIcon, size: 18, color: statusColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReleaseNotesPage extends StatelessWidget {
  const _ReleaseNotesPage({required this.version, required this.body});

  final String version;
  final String body;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l.playerBack,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          l.updatesWhatsNew(version),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: ReleaseNotes(body),
        ),
      ),
    );
  }
}

/// Общая оболочка страницы раздела: крупный заголовок и кнопка назад.
class _Page extends StatelessWidget {
  const _Page({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: kKeyboardTestTheme
              ? Theme.of(context).colorScheme.surfaceContainer
              : Theme.of(context).colorScheme.surface,
          leading: IconButton(
            tooltip: AppLocalizations.of(context).playerBack,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          // Длинные названия («Звук и воспроизведение») уменьшаются, а не
          // обрезаются многоточием.
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(title),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            ...children,
            const SizedBox(height: 24),
          ]),
        ),
        const SliverBottomInset(),
      ],
    ),
  );
}

extension on AccentColor {
  String label(AppLocalizations l) => switch (this) {
    AccentColor.acid => l.accentAcid,
    AccentColor.violet => l.accentViolet,
    AccentColor.coral => l.accentCoral,
    AccentColor.teal => l.accentTeal,
    AccentColor.amber => l.accentAmber,
    AccentColor.ice => l.accentIce,
    AccentColor.sky => l.accentSky,
    AccentColor.rose => l.accentRose,
    AccentColor.leaf => l.accentLeaf,
    AccentColor.orchid => l.accentOrchid,
  };
}

extension on Prefs {
  String qualityLabel(AppLocalizations l) => switch (quality) {
    'auto' => l.qualityAuto,
    'low' => l.qualityLow,
    'normal' => l.qualityNormal,
    'high' => l.qualityHigh,
    _ => l.qualityLossless,
  };
}

class _BlurChoice extends StatelessWidget {
  const _BlurChoice({
    required this.label,
    required this.note,
    required this.current,
    required this.onPick,
  });

  final String label;
  final String note;
  final double current;
  final ValueChanged<double> onPick;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ChoiceRow<double>(
      label: label,
      note: note,
      values: const [0, 16, 24, 36],
      current: current,
      columns: 4,
      labelOf: (value) => value == 0
          ? l.blurOff
          : value <= 16
          ? l.blurSoft
          : value <= 24
          ? l.blurMedium
          : l.blurStrong,
      onPick: onPick,
    );
  }
}
