import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_providers.dart';
import '../../../core/prefs/prefs.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/routes.dart';
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
      return '$theme · ${prefs.accent.label(l)} · $language';
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
            child: Text(
              l.settingsTitle,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          SettingsSection(
            title: l.settingsTitle,
            children: [
              _CategoryTile(
                icon: Icons.palette_outlined,
                title: l.settingsSectionAppearance,
                subtitle: appearanceSummary(),
                page: const _AppearancePage(),
              ),
              _CategoryTile(
                icon: Icons.graphic_eq_rounded,
                title: l.settingsSectionSound,
                subtitle: '${l.settingsQuality}: ${prefs.qualityLabel(l)}',
                page: const _SoundPage(),
              ),
              _CategoryTile(
                icon: Icons.lyrics_rounded,
                title: l.settingsSectionKaraoke,
                subtitle: l.settingsLyricsSource,
                page: const _KaraokeSettingsPage(),
              ),
              _CategoryTile(
                icon: Icons.sd_storage_rounded,
                title: l.settingsSectionStorage,
                subtitle: l.settingsData,
                page: const _StoragePage(),
              ),
              _CategoryTile(
                icon: Icons.account_circle_outlined,
                title: l.settingsSectionAccount,
                subtitle: l.settingsAccount,
                page: const _AccountPage(),
              ),
              _CategoryTile(
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget page;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(title),
    subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => page),
    ),
  );
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
            // Тема — сегментированная кнопка: это ровно тот M3-компонент,
            // который для взаимоисключающего выбора и предназначен.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.settingsTheme, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.brightness_auto_rounded),
                        label: Text(l.themeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode_rounded),
                        label: Text(l.themeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode_rounded),
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
            ChoiceRow<AppPalette>(
              label: l.settingsPalette,
              values: AppPalette.values,
              current: prefs.palette,
              labelOf: (palette) => switch (palette) {
                AppPalette.brand => l.paletteBrand,
                AppPalette.dynamic => l.paletteDynamic,
                AppPalette.mono => l.paletteMono,
              },
              note: prefs.palette == AppPalette.dynamic
                  ? l.paletteDynamicNote
                  : null,
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
              labelOf: (value) =>
                  value == Contrast.normal ? l.contrastNormal : l.contrastHigh,
              onPick: controller.setContrast,
            ),
            ChoiceRow<CornerRadius>(
              label: l.settingsCorners,
              values: CornerRadius.values,
              current: prefs.corner,
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
              labelOf: (value) => switch (value) {
                HomeBackground.cover => l.bgCover,
                HomeBackground.blobs => l.bgBlobs,
                HomeBackground.both => l.bgBoth,
              },
              onPick: controller.setHomeBackground,
            ),
            // Частота кадров относится к экрану, а не к звуку: раньше она
            // лежала в разделе «Звук» и путала.
            const FrameTile(),
          ],
        ),
        SettingsSection(title: l.settingsLanguage, children: const [LanguageRow()]),
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
            const PriorityTile(),
          ],
        ),
      ],
    );
  }
}

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
    return _Page(
      title: l.settingsSectionStorage,
      children: [
        SettingsSection(
          title: l.settingsStorage,
          children: const [CacheTile()],
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.settingsResetDone)),
      );
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
          ],
        ),
      ],
    );
  }

  static const String _version = '1.1.0';
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
          backgroundColor: Theme.of(context).colorScheme.surface,
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
            const SizedBox(height: 32),
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
