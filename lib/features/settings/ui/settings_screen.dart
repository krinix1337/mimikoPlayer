import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_providers.dart';
import '../../../core/prefs/prefs.dart';
import '../../../features/downloads/download_service.dart';
import '../../../features/player/equalizer_presets.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/routes.dart';
import '../../../router/slide_up_route.dart';
import '../../../theme/app_insets.dart';
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
        padding: const EdgeInsets.only(bottom: kShellBottomInset),
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

    return _Page(
      title: l.settingsSectionAppearance,
      children: [
        SettingsSection(
          title: l.settingsAppearance,
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
                        icon: kKeyboardTestTheme
                            ? null
                            : const Icon(Icons.brightness_auto_rounded),
                        label: Text(l.themeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: kKeyboardTestTheme
                            ? null
                            : const Icon(Icons.light_mode_rounded),
                        label: Text(l.themeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: kKeyboardTestTheme
                            ? null
                            : const Icon(Icons.dark_mode_rounded),
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
            ],
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
            ChoiceRow<String>(
              label: l.settingsQuality,
              values: const ['auto', 'low', 'normal', 'high', 'lossless'],
              current: prefs.quality,
              columns: 3,
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
            SwitchRow(
              label: l.censorBypass,
              value: prefs.censorBypass,
              note: l.censorBypassNote,
              onChanged: controller.setCensorBypass,
            ),
            SwitchRow(
              label: l.djInfo,
              value: prefs.showDjInfo,
              note: l.djInfoNote,
              onChanged: controller.setShowDjInfo,
            ),
            const PriorityTile(),
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
            showDragHandle: true,
            isScrollControlled: true,
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
    final prefs = ref.watch(prefsProvider);
    final controller = ref.read(prefsProvider.notifier);
    final height = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height * 0.82),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              _EqualizerSliders(
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
              const SizedBox(height: 14),
              SizedBox(
                height: 56,
                child: Material(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(18),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _openPresetPicker,
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
        ),
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
    return SizedBox(
      height: 300,
      child: Row(
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
      ),
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
            ChoiceRow<int>(
              label: l.downloadsLimit,
              values: const [0, 2, 5, 10, 20],
              current: limitGb,
              columns: 3,
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

class _AccountPage extends ConsumerWidget {
  const _AccountPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return _Page(
      title: l.settingsSectionAccount,
      children: [
        SettingsSection(
          title: l.settingsAccount,
          children: const [AccountTile()],
        ),
      ],
    );
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _Page(
      title: l.settingsSectionAbout,
      children: [
        SettingsSection(
          title: l.settingsAbout,
          children: [
            ListTile(
              title: Text(l.appTitle),
              subtitle: Text(l.settingsAboutNote),
              trailing: Text(
                l.settingsVersion(_version),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
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
              leading: const Icon(Icons.music_note_rounded),
              title: Text(l.aboutSources),
              subtitle: Text(l.aboutSourcesNote),
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(l.settingsLyricsSource),
              subtitle: Text(l.settingsLyricsSourceNote),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: Text(l.settingsAiFilterSource),
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

  static const String _version = '1.2.2';
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
          title: Text(title),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            ...children,
            const SizedBox(height: kShellBottomInset),
          ]),
        ),
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
