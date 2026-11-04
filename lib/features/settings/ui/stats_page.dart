import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/db/daos/stats_dao.dart';
import '../../../core/platform/mimiko_platform.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/connected_button_group.dart';
import '../../../widgets/sliver_bottom_inset.dart';
import '../../../widgets/track_cover.dart';
import 'settings_widgets.dart';

enum StatsPeriod { week, month, year, all }

class _StatsData {
  const _StatsData({
    required this.summary,
    required this.daily,
    required this.days,
    required this.tracks,
    required this.artists,
  });

  final StatsSummary summary;
  final Map<DateTime, Duration> daily;
  final int days;
  final List<StatsEntry> tracks;
  final List<StatsEntry> artists;
}

/// Статистика прослушиваний: сводка за период, столбики по дням и топы.
class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  StatsPeriod _period = StatsPeriod.month;
  late Future<_StatsData> _data = _load();

  DateTime? _since() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (_period) {
      StatsPeriod.week => today.subtract(const Duration(days: 6)),
      StatsPeriod.month => today.subtract(const Duration(days: 29)),
      StatsPeriod.year => DateTime(now.year - 1, now.month, now.day + 1),
      StatsPeriod.all => null,
    };
  }

  Future<_StatsData> _load() async {
    final dao = ref.read(appServicesProvider).db.statsDao;
    final since = _since();
    // График на «год» и «всё» слишком мелкий по дням — показываем 30 дней.
    final days = _period == StatsPeriod.week ? 7 : 30;
    final now = DateTime.now();
    final chartFrom = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));
    return _StatsData(
      summary: await dao.summary(since),
      daily: await dao.daily(chartFrom),
      days: days,
      tracks: await dao.topTracks(since),
      artists: await dao.topArtists(since),
    );
  }

  void _reload() => setState(() => _data = _load());

  Future<void> _export() async {
    final rows = await ref.read(appServicesProvider).db.statsDao.exportRows();
    await MimikoPlatform.shareText(
      const JsonEncoder.withIndent('  ').convert({
        'app': 'mimikoPlayer',
        'exportedAt': DateTime.now().toIso8601String(),
        'plays': rows,
      }),
    );
  }

  Future<void> _clear() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l.statsClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.statsClear),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ref.read(appServicesProvider).db.statsDao.clear();
    _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.statsCleared)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final prefs = ref.watch(prefsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: scheme.surface,
            leading: IconButton(
              tooltip: l.playerBack,
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text(l.statsTitle),
          ),
          SliverToBoxAdapter(
            child: SettingsSection(
              title: '',
              children: [
                SwitchRow(
                  label: l.statsCollect,
                  note: l.statsCollectNote,
                  value: prefs.collectStats,
                  onChanged: ref.read(prefsProvider.notifier).setCollectStats,
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: ConnectedButtonGroup<StatsPeriod>(
                options: [
                  ConnectedOption(value: StatsPeriod.week, label: l.stats7d),
                  ConnectedOption(value: StatsPeriod.month, label: l.stats30d),
                  ConnectedOption(value: StatsPeriod.year, label: l.statsYear),
                  ConnectedOption(value: StatsPeriod.all, label: l.statsAll),
                ],
                selected: _period,
                onPick: (value) {
                  _period = value;
                  _reload();
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<_StatsData>(
              future: _data,
              builder: (context, snapshot) {
                final data = snapshot.data;
                if (data == null) {
                  return const SizedBox(height: 240);
                }
                return _StatsBody(data: data);
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 56,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.ios_share_rounded,
                        label: l.statsExport,
                        background: scheme.secondaryContainer,
                        foreground: scheme.onSecondaryContainer,
                        onTap: _export,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: l.statsClear,
                        background: scheme.errorContainer,
                        foreground: scheme.onErrorContainer,
                        onTap: _clear,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverBottomInset(),
        ],
      ),
    );
  }
}

String formatListened(AppLocalizations l, Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  return h > 0 ? l.statsHours(h, m) : l.statsMinutes(m);
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.data});

  final _StatsData data;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget metric(String label, String value) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: theme.textTheme.headlineSmall),
            ),
          ],
        ),
      ),
    );

    final summary = data.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              metric(l.statsTime, formatListened(l, summary.listened)),
              const SizedBox(width: 6),
              metric(l.statsPlays, '${summary.plays}'),
              const SizedBox(width: 6),
              metric(l.statsTracks, '${summary.tracks}'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.statsByDay,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 96,
                  child: _DailyBars(daily: data.daily, days: data.days),
                ),
              ],
            ),
          ),
        ),
        if (summary.plays == 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
            child: Text(
              l.statsEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        if (data.tracks.isNotEmpty)
          SettingsSection(
            title: l.statsTopTracks,
            children: [
              for (final (i, e) in data.tracks.indexed)
                _TopRow(rank: i + 1, entry: e, round: false),
            ],
          ),
        if (data.artists.isNotEmpty)
          SettingsSection(
            title: l.statsTopArtists,
            children: [
              for (final (i, e) in data.artists.indexed)
                _TopRow(rank: i + 1, entry: e, round: true),
            ],
          ),
      ],
    );
  }
}

class _DailyBars extends StatelessWidget {
  const _DailyBars({required this.daily, required this.days});

  final Map<DateTime, Duration> daily;
  final int days;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final values = [
      for (var i = days - 1; i >= 0; i--)
        (daily[DateTime(today.year, today.month, today.day - i)] ??
                Duration.zero)
            .inSeconds,
    ];
    final peak = values.fold<int>(1, (a, b) => b > a ? b : a);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0) SizedBox(width: days > 7 ? 3 : 8),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: values[i] / peak),
              duration: Duration(milliseconds: 500 + i * 12),
              curve: Curves.easeOutBack,
              builder: (context, t, _) => FractionallySizedBox(
                heightFactor: (0.04 + 0.96 * t).clamp(0.04, 1.0),
                alignment: Alignment.bottomCenter,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: i == values.length - 1
                        ? scheme.primary
                        : values[i] == 0
                        ? scheme.surfaceContainerHighest
                        : scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.rank, required this.entry, required this.round});

  final int rank;
  final StatsEntry entry;
  final bool round;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            child: Text(
              '$rank',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TrackCover(url: entry.coverUrl, size: 44, radius: round ? 22 : 10),
        ],
      ),
      title: Text(entry.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      // У артистов вместо исполнителя — число прослушиваний: строки обоих
      // топов одной высоты.
      subtitle: Text(
        entry.subtitle ?? l.statsPlaysCount(entry.plays),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        formatListened(l, entry.listened),
        style: theme.textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Кнопка действия статистики: пилюля одной высоты для обеих кнопок.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: background,
    shape: const StadiumBorder(),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    ),
  );
}
