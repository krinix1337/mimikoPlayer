import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app_providers.dart';
import '../../../core/prefs/prefs.dart';
import '../../../core/platform/mimiko_platform.dart';
import '../../../core/sources/music_source.dart';
import '../../../core/sources/source_dto.dart';
import '../../../core/sources/source_id.dart';
import '../../../features/auth/ui/yandex_login.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_motion.dart';
import '../../../widgets/pressable.dart';

/// Карточка-секция настроек: заголовок и группа строк в общей оболочке.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.children});

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

/// Строка с набором вариантов: подписанный чип на каждый.
class ChoiceRow<T> extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.label,
    required this.values,
    required this.current,
    required this.labelOf,
    required this.onPick,
    this.note,
  });

  final String label;
  final List<T> values;
  final T current;
  final String Function(T) labelOf;
  final ValueChanged<T> onPick;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in values)
                ChoiceChip(
                  label: Text(labelOf(value)),
                  selected: value == current,
                  showCheckmark: false,
                  onSelected: (_) => onPick(value),
                ),
            ],
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
      subtitle: note == null ? null : Text(note!, style: theme.textTheme.bodySmall),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

/// Палитра акцентов: шесть кругляшей в горизонтальной ленте — на узком
/// экране рядом они влезали бы с переполнением.
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final accent in AccentColor.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: PressableScale(
                      onTap: () => onPick(accent),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: Motion.of(context).micro(180),
                            width: 34,
                            height: 34,
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
                          SizedBox(
                            width: 56,
                            child: Text(
                              labelOf(accent),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageRow extends ConsumerWidget {
  const LanguageRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final code = ref.watch(prefsProvider.select((p) => p.localeCode));
    final controller = ref.read(prefsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: Text(l.languageSystem),
            selected: code == null,
            showCheckmark: false,
            onSelected: (_) => controller.setLocaleCode(null),
          ),
          ChoiceChip(
            label: const Text('Русский'),
            selected: code == 'ru',
            showCheckmark: false,
            onSelected: (_) => controller.setLocaleCode('ru'),
          ),
          ChoiceChip(
            label: const Text('English'),
            selected: code == 'en',
            showCheckmark: false,
            onSelected: (_) => controller.setLocaleCode('en'),
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
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      // Шесть значков в строку не влезают — лента по горизонтали.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
        children: [
          for (final icon in LauncherIcon.values)
            Padding(
              padding: const EdgeInsets.only(right: 14),
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
                    Text(name(icon), style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            child: Text(l.settingsPriorityNote, style: Theme.of(context).textTheme.bodySmall),
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
      subtitle: Text(_bytes == null ? '—' : _human(_bytes!)),
      trailing: TextButton(
        onPressed: () async {
          await DefaultCacheManager().emptyCache();
          await _measure();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l.settingsCacheCleared)),
            );
          }
        },
        child: Text(l.settingsCacheClear),
      ),
    );
  }

  static String _human(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}

class AccountTile extends ConsumerWidget {
  const AccountTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(yandexAuthStateProvider).value ?? const AuthUnknown();
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.settingsSignedOut)),
              );
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
