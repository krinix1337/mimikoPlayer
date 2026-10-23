import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app_providers.dart';
import '../../../core/db/daos/downloads_dao.dart';
import '../../../core/prefs/prefs.dart';
import '../../../core/platform/mimiko_platform.dart';
import '../../../core/sources/music_source.dart';
import '../../../core/sources/source_dto.dart';
import '../../../core/sources/source_id.dart';
import '../../../features/auth/ui/yandex_login.dart';
import '../../../features/downloads/download_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_motion.dart';
import '../../../widgets/pressable.dart';

/// Карточка-секция настроек: заголовок и группа строк в общей оболочке.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(
                Motion.of(context).prefs.corner.radius * 0.7,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// Строка с набором вариантов. Ячейки одинаковой ширины и высоты, поэтому
/// подписи не скачут от строки к строке, а короткие наборы влезают в один ряд.
class ChoiceRow<T> extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.label,
    required this.values,
    required this.current,
    required this.labelOf,
    required this.onPick,
    this.note,
    this.columns,
  });

  final String label;
  final List<T> values;
  final T current;
  final String Function(T) labelOf;
  final ValueChanged<T> onPick;
  final String? note;
  final int? columns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = columns ?? values.length.clamp(1, 4);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 8.0;
              final width = (constraints.maxWidth - gap * (count - 1)) / count;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final value in values)
                    _ChoicePill(
                      width: width,
                      label: labelOf(value),
                      selected: value == current,
                      onTap: () => onPick(value),
                    ),
                ],
              );
            },
          ),
          if (note != null) ...[
            const SizedBox(height: 8),
            Text(
              note!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.width,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = Motion.of(context).prefs.corner.radius * 0.7;
    return SizedBox(
      width: width,
      height: 46,
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.note,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(label, style: theme.textTheme.titleMedium),
      subtitle: note == null
          ? null
          : Text(note!, style: theme.textTheme.bodySmall),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class SliderRow extends StatefulWidget {
  const SliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChangedEnd,
    this.divisions,
    this.note,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double value) display;
  final ValueChanged<double> onChangedEnd;
  final String? note;

  @override
  State<SliderRow> createState() => _SliderRowState();
}

class _SliderRowState extends State<SliderRow> {
  late double _value = widget.value;
  bool _dragging = false;

  @override
  void didUpdateWidget(SliderRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging && oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(widget.label, style: theme.textTheme.titleMedium),
              ),
              Text(
                widget.display(_value),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: _value.clamp(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: (value) => setState(() {
              _dragging = true;
              _value = value;
            }),
            onChangeEnd: (value) {
              _dragging = false;
              widget.onChangedEnd(value);
            },
          ),
          if (widget.note != null)
            Text(
              widget.note!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

/// Палитра акцентов: по пять кругляшей в ряд, как иконки лаунчера.
class AccentRow extends StatelessWidget {
  const AccentRow({
    super.key,
    required this.label,
    required this.current,
    required this.labelOf,
    required this.onPick,
  });

  final String label;
  final AccentColor current;
  final String Function(AccentColor) labelOf;
  final ValueChanged<AccentColor> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 8.0;
              final width = (constraints.maxWidth - gap * 4) / 5;
              return Wrap(
                spacing: gap,
                runSpacing: 10,
                children: [
                  for (final accent in AccentColor.values)
                    SizedBox(
                      width: width,
                      child: PressableScale(
                        onTap: () => onPick(accent),
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: Motion.of(context).micro(180),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: accent.color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: accent == current
                                      ? theme.colorScheme.onSurface
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: accent == current
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: Colors.black87,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              labelOf(accent),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class LauncherIconRow extends ConsumerWidget {
  const LauncherIconRow({super.key});

  static const _assetFor = <LauncherIcon, String>{
    LauncherIcon.defaultIcon: 'assets/icon/variants/default.png',
    LauncherIcon.acid: 'assets/icon/variants/acid.png',
    LauncherIcon.mono: 'assets/icon/variants/mono.png',
    LauncherIcon.night: 'assets/icon/variants/night.png',
    LauncherIcon.sunset: 'assets/icon/variants/sunset.png',
    LauncherIcon.mint: 'assets/icon/variants/mint.png',
    LauncherIcon.violet: 'assets/icon/variants/violet.png',
    LauncherIcon.ice: 'assets/icon/variants/ice.png',
    LauncherIcon.amber: 'assets/icon/variants/amber.png',
    LauncherIcon.forest: 'assets/icon/variants/forest.png',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(prefsProvider.select((p) => p.launcherIcon));
    final theme = Theme.of(context);

    String name(LauncherIcon icon) => switch (icon) {
      LauncherIcon.defaultIcon => l.paletteBrand,
      LauncherIcon.acid => l.accentAcid,
      LauncherIcon.mono => l.paletteMono,
      LauncherIcon.night => l.themeDark,
      LauncherIcon.sunset => l.accentCoral,
      LauncherIcon.mint => l.accentTeal,
      LauncherIcon.violet => l.accentViolet,
      LauncherIcon.ice => l.accentIce,
      LauncherIcon.amber => l.accentAmber,
      LauncherIcon.forest => l.launcherForest,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 8.0;
          final width = (constraints.maxWidth - gap * 4) / 5;
          return Wrap(
            spacing: gap,
            runSpacing: 12,
            children: [
              for (final icon in LauncherIcon.values)
                SizedBox(
                  width: width,
                  child: PressableScale(
                    onTap: () => _apply(context, ref, icon),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: icon == current
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              _assetFor[icon]!,
                              width: 46,
                              height: 46,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name(icon),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _apply(
    BuildContext context,
    WidgetRef ref,
    LauncherIcon icon,
  ) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await MimikoPlatform.setLauncherIcon(icon.component);
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.launcherIconFailed('android'))),
      );
      return;
    }
    await ref.read(prefsProvider.notifier).setLauncherIcon(icon);
    messenger.showSnackBar(SnackBar(content: Text(l.launcherIconApplied)));
  }
}

/// Частота кадров: запрос уходит в окно, но показываем и то, что система
/// реально дала — на бюджетных HyperOS сторонние приложения держат на 60.
class FrameTile extends ConsumerStatefulWidget {
  const FrameTile({super.key});

  @override
  ConsumerState<FrameTile> createState() => _FrameTileState();
}

class _FrameTileState extends ConsumerState<FrameTile> {
  double _actual = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final value = await MimikoPlatform.actualRefreshRate();
      if (mounted) setState(() => _actual = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(prefsProvider);

    return ChoiceRow<double>(
      label: l.settingsFrame,
      values: const [0, 60, 90, 120],
      current: prefs.frameHz,
      labelOf: (value) => switch (value.toInt()) {
        0 => l.frameSystem,
        60 => l.frame60,
        90 => l.frame90,
        _ => l.frame120,
      },
      note: _actual == 0 ? null : '${l.settingsFrame}: ${_actual.round()} Гц',
      onPick: (value) async {
        await ref.read(prefsProvider.notifier).setFrameHz(value);
        final actual = await MimikoPlatform.requestFrameRate(value);
        if (mounted) setState(() => _actual = actual);
      },
    );
  }
}

/// Порядок источников перетаскиванием — по нему цепочка идёт при отказе.
class PriorityTile extends ConsumerWidget {
  const PriorityTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final priority = ref.watch(sourcePriorityProvider);
    final services = ref.read(appServicesProvider);

    return priority.when(
      loading: () => ListTile(title: Text(l.commonLoading)),
      error: (error, _) => ListTile(title: Text(l.dbError('$error'))),
      data: (order) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              l.settingsPriority,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Text(
              l.settingsPriorityNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          _ReorderList(
            order: order,
            labelFor: (id) => _name(context, id),
            roleFor: (id) => _role(context, services.registry.byId(id)),
            onReorder: (next) async {
              await services.db.settingsDao.setPlaybackPriority(next);
              await services.applyPreferences();
              ref.invalidate(sourcePriorityProvider);
            },
          ),
        ],
      ),
    );
  }

  static String _name(BuildContext context, SourceId id) => switch (id) {
    SourceId.yandex => 'Яндекс',
    SourceId.soundcloud => 'SoundCloud',
    SourceId.youtube => 'YouTube',
    SourceId.local => AppLocalizations.of(context).collectionFiles,
    SourceId.spotify => 'Spotify',
    SourceId.deezer => 'Deezer',
  };

  static String _role(BuildContext context, MusicSource? source) {
    final l = AppLocalizations.of(context);
    if (source == null) return l.roleAbsent;
    return source.capabilities.canStream ? l.roleStream : l.roleCatalog;
  }
}

class _ReorderList extends StatefulWidget {
  const _ReorderList({
    required this.order,
    required this.labelFor,
    required this.roleFor,
    required this.onReorder,
  });

  final List<SourceId> order;
  final String Function(SourceId) labelFor;
  final String Function(SourceId) roleFor;
  final Future<void> Function(List<SourceId>) onReorder;

  @override
  State<_ReorderList> createState() => _ReorderListState();
}

class _ReorderListState extends State<_ReorderList> {
  late List<SourceId> _items = List.of(widget.order);

  @override
  void didUpdateWidget(_ReorderList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order != widget.order) _items = List.of(widget.order);
  }

  @override
  Widget build(BuildContext context) => ReorderableListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    buildDefaultDragHandles: false,
    itemCount: _items.length,
    onReorderItem: (oldIndex, newIndex) async {
      setState(() {
        final moved = _items.removeAt(oldIndex);
        _items.insert(newIndex, moved);
      });
      await widget.onReorder(List.of(_items));
    },
    itemBuilder: (context, index) => ReorderableDragStartListener(
      key: ValueKey(_items[index]),
      index: index,
      child: ListTile(
        leading: const Icon(Icons.drag_handle_rounded),
        title: Text(widget.labelFor(_items[index])),
        subtitle: Text(widget.roleFor(_items[index])),
      ),
    ),
  );
}

class DownloadsTile extends ConsumerWidget {
  const DownloadsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stats =
        ref.watch(downloadQueueStatsProvider).value ??
        const DownloadQueueStats();
    final summary =
        ref.watch(downloadedFilesSummaryProvider).value ??
        const DownloadedFilesSummary(count: 0, bytes: 0);
    final active = stats.downloading + stats.queued;
    final canPause = stats.downloading > 0 || stats.queued > 0;
    final canResume = stats.paused > 0;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.download_done_rounded),
          title: Text(
            l.downloadsSummary(summary.count, _humanBytes(summary.bytes)),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.downloadsQueueSummary(active, stats.paused)),
              if (stats.skipped > 0) Text(l.downloadsSkipped(stats.skipped)),
            ],
          ),
          trailing: canPause || canResume
              ? IconButton(
                  tooltip: canResume && !canPause
                      ? l.downloadsResume
                      : l.downloadsPause,
                  icon: Icon(
                    canResume && !canPause
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                  ),
                  onPressed: () {
                    final controller = ref.read(
                      downloadControllerProvider.notifier,
                    );
                    if (canResume && !canPause) {
                      unawaited(controller.resumeAll());
                    } else {
                      unawaited(controller.pauseAll());
                    }
                  },
                )
              : null,
        ),
        FutureBuilder<int>(
          future: MimikoPlatform.freeBytes(),
          builder: (context, snapshot) {
            final free = snapshot.data;
            if (free == null || free <= 0) return const SizedBox.shrink();
            return ListTile(
              dense: true,
              leading: const Icon(Icons.sd_storage_rounded, size: 20),
              title: Text(l.downloadsFreeSpace(_humanBytes(free))),
            );
          },
        ),
      ],
    );
  }
}

class DeleteDownloadsTile extends ConsumerWidget {
  const DeleteDownloadsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final summary = ref.watch(downloadedFilesSummaryProvider).value;
    final stats =
        ref.watch(downloadQueueStatsProvider).value ??
        const DownloadQueueStats();
    final count = summary?.count ?? 0;
    final hasAnything = count > 0 || stats.pending > 0;

    return ListTile(
      leading: const Icon(Icons.delete_sweep_rounded),
      title: Text(l.downloadsDeleteAll),
      enabled: hasAnything,
      textColor: Theme.of(context).colorScheme.error,
      onTap: !hasAnything
          ? null
          : () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l.downloadsDeleteAll),
                  content: Text(l.downloadsDeleteAllQuestion),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l.commonCancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(l.downloadsDeleteAll),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              await ref.read(downloadControllerProvider.notifier).removeAll();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l.downloadsDeletedAll)));
              }
            },
    );
  }
}

String _humanBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
  return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
}

class CacheTile extends ConsumerStatefulWidget {
  const CacheTile({super.key});

  @override
  ConsumerState<CacheTile> createState() => _CacheTileState();
}

class _CacheTileState extends ConsumerState<CacheTile> {
  int? _bytes;

  @override
  void initState() {
    super.initState();
    _measure();
  }

  Future<void> _measure() async {
    final dir = await _cacheDir();
    if (dir == null || !mounted) return;
    var total = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) total += await entity.length();
    }
    if (mounted) setState(() => _bytes = total);
  }

  static Future<Directory?> _cacheDir() async {
    try {
      final base = await getTemporaryDirectory();
      final dir = Directory('${base.path}/libCachedImageData');
      return await dir.exists() ? dir : null;
    } on FileSystemException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      title: Text(l.settingsCache),
      subtitle: Text(_bytes == null ? '—' : _humanBytes(_bytes!)),
      trailing: TextButton(
        onPressed: () async {
          await DefaultCacheManager().emptyCache();
          await _measure();
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(l.settingsCacheCleared)));
          }
        },
        child: Text(l.settingsCacheClear),
      ),
    );
  }
}

class AccountTile extends ConsumerWidget {
  const AccountTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final auth =
        ref.watch(yandexAuthStateProvider).value ?? const AuthUnknown();
    final services = ref.read(appServicesProvider);

    if (auth case final AuthReady ready) {
      return ListTile(
        leading: const Icon(Icons.account_circle_rounded),
        title: Text(ready.login),
        subtitle: Text(ready.hasPlus ? l.accountPlus : l.accountFree),
        trailing: TextButton(
          onPressed: () async {
            await services.yandexAuth?.logout();
            ref.invalidate(collectionProvider);
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l.settingsSignedOut)));
            }
          },
          child: Text(l.settingsSignOut),
        ),
      );
    }

    return ListTile(
      leading: const Icon(Icons.account_circle_rounded),
      title: const Text('Яндекс'),
      subtitle: Text(switch (auth) {
        AuthFailed(:final message) => message,
        AuthExpired() => l.authExpired,
        _ => l.authNotSignedIn,
      }),
      trailing: FilledButton.tonal(
        onPressed: () => showYandexLogin(context, ref),
        child: Text(l.waveSignIn),
      ),
    );
  }
}

class DatabaseTile extends ConsumerWidget {
  const DatabaseTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final info = ref.watch(databaseInfoProvider);

    return info.when(
      loading: () => ListTile(title: Text(l.commonLoading)),
      error: (error, _) => ListTile(title: Text(l.dbError('$error'))),
      data: (data) => ExpansionTile(
        title: Text(l.settingsSchema(data.schemaVersion)),
        subtitle: Text(
          l.settingsRows(
            data.rows.values.fold<int>(0, (sum, value) => sum + value),
          ),
        ),
        children: [
          for (final entry in data.rows.entries)
            ListTile(
              dense: true,
              title: Text(entry.key),
              trailing: Text('${entry.value}'),
            ),
        ],
      ),
    );
  }
}
