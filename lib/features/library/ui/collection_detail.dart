import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phoneyandex/widgets/sliver_bottom_inset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../playlist_cover.dart';
import '../../../core/db/daos/library_dao.dart';
import '../../../core/platform/mimiko_platform.dart';
import '../../../core/sources/source_dto.dart';
import '../../../features/player/player_snapshot.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/player_launch.dart';
import '../../../router/routes.dart';
import '../../../theme/app_motion.dart';
import '../../../features/downloads/download_service.dart';
import '../../../features/player/ui/mini_player.dart';
import '../playlist_create.dart';
import '../../../widgets/glass_top_bar.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/track_cover.dart';
import '../../../widgets/track_tile.dart';
import 'collection_screen.dart' show SectionHeader, showSortSheet;
import '../../../widgets/expressive_loader.dart';
import '../../../widgets/fab_menu.dart';

/// Один раздел коллекции на весь экран: заголовок, счётчик, play/shuffle
/// и список с тем же сортиром, что и на главной.
class CollectionKindScreen extends ConsumerWidget {
  const CollectionKindScreen({super.key, required this.kind});

  final CollectionKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final rows = ref.watch(collectionProvider(kind));

    final title = switch (kind) {
      CollectionKind.liked => l.collectionLiked,
      CollectionKind.disliked => l.collectionDisliked,
      CollectionKind.files => l.collectionFiles,
      CollectionKind.recent => l.collectionRecent,
      CollectionKind.downloaded => l.collectionDownloaded,
    };

    // Мини-плеер плавает поверх страницы, как во вкладках.
    return MiniPlayerHost(
      child: Scaffold(
        body: rows.when(
          loading: () => const Center(child: ExpressiveLoader()),
          error: (error, _) => _ErrorBox(text: l.dbError('$error')),
          data: (data) => CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: Text(title),
                actions: [
                  if (kind == CollectionKind.liked)
                    IconButton(
                      tooltip: l.collectionDownloadAllLikes,
                      icon: const Icon(Icons.download_rounded),
                      onPressed: () => _downloadAll(context, ref),
                    ),
                  IconButton(
                    tooltip: l.collectionSort,
                    icon: const Icon(Icons.swap_vert_rounded),
                    onPressed: () => showSortSheet(context, ref),
                  ),
                ],
              ),
              if (data.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Text(
                        _emptyFor(l),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: _CollectionHero(
                    kind: kind,
                    rows: data,
                    onPlay: () => _play(context, ref, data, 0),
                    onShuffle: () =>
                        _play(context, ref, data, 0, shuffle: true),
                  ),
                ),
                SliverList.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) => RiseIn(
                    delay: Duration(milliseconds: (index * 18).clamp(0, 180)),
                    offset: 12,
                    child: TrackTile(
                      row: data[index],
                      queue: data,
                      index: index,
                      kind: kind.name,
                      sourceTitle: title,
                    ),
                  ),
                ),
              ],
              const SliverBottomInset(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadAll(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final queued = await ref
        .read(downloadControllerProvider.notifier)
        .downloadAllLikes();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.collectionDownloadQueued(queued))));
  }

  String _emptyFor(AppLocalizations l) => switch (kind) {
    CollectionKind.liked => l.collectionEmptyLiked,
    CollectionKind.disliked => l.collectionEmptyDisliked,
    CollectionKind.files => l.collectionEmptyFiles,
    CollectionKind.recent => l.collectionEmptyRecent,
    CollectionKind.downloaded => l.collectionEmptyDownloaded,
  };

  Future<void> _play(
    BuildContext context,
    WidgetRef ref,
    List<CollectionRow> rows,
    int index, {
    bool shuffle = false,
  }) async {
    final router = GoRouter.of(context);
    final controller = ref.read(playbackControllerProvider);
    final title = switch (kind) {
      CollectionKind.liked => AppLocalizations.of(context).collectionLiked,
      CollectionKind.disliked => AppLocalizations.of(
        context,
      ).collectionDisliked,
      CollectionKind.files => AppLocalizations.of(context).collectionFiles,
      CollectionKind.recent => AppLocalizations.of(context).collectionRecent,
      CollectionKind.downloaded => AppLocalizations.of(
        context,
      ).collectionDownloaded,
    };
    await controller.playQueue(
      [for (final row in rows) row.localTrackId],
      startIndex: shuffle ? shuffleStartIndex(rows.length) : index,
      sourceHint: {'kind': kind.name, 'title': title},
    );
    if (shuffle) {
      await controller.setShuffle(PlaybackShuffle.shuffled);
    }
    openPlayerAfterPlay(router);
  }
}

/// Шапка раздела: крупная мозаика, счётчик, длительность и действия.
/// Обложка живёт на световом ореоле — это даёт глубину без тяжёлого блюра.
class _CollectionHero extends StatelessWidget {
  const _CollectionHero({
    required this.kind,
    required this.rows,
    required this.onPlay,
    required this.onShuffle,
  });

  final CollectionKind kind;
  final List<CollectionRow> rows;
  final VoidCallback onPlay;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final covers = rows
        .map((row) => row.coverPath ?? row.coverUrl)
        .whereType<String>()
        .toList();
    final totalSec = rows.fold<int>(0, (sum, row) => sum + row.durationSec);
    final minutes = totalSec ~/ 60;
    final duration = minutes < 60
        ? l.listenedMinutes(minutes)
        : '${l.listenedHours(minutes ~/ 60)} ${l.listenedMinutes(minutes % 60)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
      child: Column(
        children: [
          _HeroArtwork(covers: covers, kind: kind),
          const SizedBox(height: 20),
          Text(
            l.collectionCount(rows.length),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (rows.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                duration,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _HeroButton(
                  primary: true,
                  icon: Icons.play_arrow_rounded,
                  label: l.collectionPlayAll,
                  onTap: onPlay,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: _HeroButton(
                  primary: false,
                  icon: Icons.shuffle_rounded,
                  label: l.collectionShuffleAll,
                  onTap: onShuffle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Стопка обложек с бликом по стеклу и жетоном раздела. Задние карточки
/// выглядывают из-под основной и добавляют объём, не превращаясь в кашу.
class _HeroArtwork extends StatelessWidget {
  const _HeroArtwork({required this.covers, required this.kind});

  final List<String> covers;
  final CollectionKind kind;

  static const _size = 176.0;

  IconData get _icon => switch (kind) {
    CollectionKind.liked => Icons.favorite_rounded,
    CollectionKind.disliked => Icons.thumb_down_alt_rounded,
    CollectionKind.files => Icons.folder_rounded,
    CollectionKind.recent => Icons.history_rounded,
    CollectionKind.downloaded => Icons.offline_pin_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = Motion.of(context).prefs.corner.radius + 6;
    final shown = covers.take(4).toList();

    return SizedBox(
      width: _size + 28,
      height: _size + 28,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    scheme.primary.withValues(alpha: 0.30),
                    scheme.tertiary.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
          ),
          if (shown.length > 1)
            Transform.rotate(
              angle: -0.055,
              child: Container(
                width: _size - 6,
                height: _size - 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  color: scheme.surfaceContainerHighest,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: TrackCover(
                  url: shown[1],
                  size: double.infinity,
                  radius: radius,
                ),
              ),
            ),
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.42),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (shown.isEmpty)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.primary.withValues(alpha: 0.65),
                          scheme.tertiary.withValues(alpha: 0.40),
                        ],
                      ),
                    ),
                    child: Icon(
                      _icon,
                      size: 64,
                      color: scheme.onPrimary.withValues(alpha: 0.92),
                    ),
                  )
                else
                  _CoverMosaic(covers: shown, size: _size),
                // Стеклянный блик по диагонали: верхняя левая четверть
                // светлее, к центру растворяется.
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.20),
                          Colors.white.withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.38, 0.72],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.primary, scheme.tertiary],
                ),
                border: Border.all(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.9),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(_icon, size: 26, color: scheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Пара действий под шапкой. Основная — заливка акцентом с мягким свечением,
/// вторичная — стеклянная капсула.
class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.primary,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool primary;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(
      Motion.of(context).prefs.corner.radius * 1.4,
    );
    final foreground = primary ? scheme.onPrimary : scheme.onSurface;

    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: primary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary,
                    Color.lerp(scheme.primary, scheme.tertiary, 0.35) ??
                        scheme.primary,
                  ],
                )
              : null,
          color: primary ? null : scheme.surfaceContainerHigh,
          border: primary
              ? Border.all(color: Colors.white.withValues(alpha: 0.20))
              : Border.all(color: scheme.outlineVariant),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: foreground),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverMosaic extends StatelessWidget {
  const _CoverMosaic({required this.covers, required this.size});

  final List<String> covers;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (covers.length == 1) {
      return TrackCover(url: covers.first, size: size, radius: 0);
    }
    final empty = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget cell(int index) => Expanded(
      child: covers.length > index
          ? TrackCover(url: covers[index], size: double.infinity, radius: 0)
          : ColoredBox(color: empty),
    );
    return Column(
      children: [
        Expanded(child: Row(children: [cell(0), cell(1)])),
        Expanded(child: Row(children: [cell(2), cell(3)])),
      ],
    );
  }
}

/// Сетка импортированных плейлистов.
class PlaylistsScreen extends ConsumerStatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  ConsumerState<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends ConsumerState<PlaylistsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(playlistSyncProvider.notifier).refresh());
      }
    });
  }

  Future<void> _create() async {
    final draft = await showCreatePlaylistSheet(context, ref);
    if (draft != null && mounted) {
      context.push(Routes.playlist(draft.id));
    }
  }

  Future<void> _importFromYandex() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final lists = await importYandexPlaylists(
        source: ref.read(yandexSourceProvider),
        db: ref.read(appServicesProvider).db,
      );
      if (!mounted) return;
      ref.invalidate(playlistsProvider);
      messenger.showSnackBar(
        SnackBar(content: Text(l.collectionImportedPlaylists(lists))),
      );
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.collectionImportFailed('$error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final playlists = ref.watch(playlistsProvider);

    // Мини-плеер плавает поверх страницы, как во вкладках.
    final yandexReady =
        ref.watch(yandexAuthStateProvider).value?.isReady ?? false;

    return MiniPlayerHost(
      child: Builder(
        builder: (hostContext) => Scaffold(
          // Scaffold ставит FAB над системной полосой, а не над мини-плеером:
          // добираем высоту пилюли, которую MiniPlayerHost кладёт в padding.
          // Читаем её снаружи Scaffold — внутри он этот отступ обнуляет.
          floatingActionButton: Builder(
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom:
                    (MediaQuery.paddingOf(hostContext).bottom -
                            MediaQuery.viewPaddingOf(hostContext).bottom)
                        .clamp(0.0, double.infinity),
              ),
              child: FabMenu(
                tooltip: l.playlistCreate,
                items: [
                  if (yandexReady)
                    FabMenuItem(
                      icon: Icons.cloud_download_outlined,
                      label: l.importTitle,
                      onTap: _importFromYandex,
                    ),
                  FabMenuItem(
                    icon: Icons.playlist_add_rounded,
                    label: l.playlistCreate,
                    onTap: _create,
                  ),
                ],
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () =>
                ref.read(playlistSyncProvider.notifier).refresh(force: true),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Крупный заголовок; создание плейлиста — в FAB-меню.
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 72,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  title: Text(l.collectionPlaylists),
                  titleTextStyle: Theme.of(context).textTheme.headlineMedium,
                ),
                switch (playlists) {
                  AsyncError(:final error) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorBox(text: l.dbError('$error')),
                  ),
                  AsyncData(:final value) when value.isEmpty =>
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l.collectionEmptyPlaylists,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.tonalIcon(
                                onPressed: _create,
                                icon: const Icon(Icons.add_rounded),
                                label: Text(l.playlistCreate),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  AsyncData(:final value) => SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.78,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        childCount: value.length,
                        (context, index) => RiseIn(
                          delay: Duration(
                            milliseconds: (index * 24).clamp(0, 200),
                          ),
                          child: _PlaylistCard(playlist: value[index]),
                        ),
                      ),
                    ),
                  ),
                  _ => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: ExpressiveLoader()),
                    ),
                  ),
                },
                const SliverBottomInset(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist});

  final PlaylistOverview playlist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressableScale(
      onTap: () => context.push(Routes.playlist(playlist.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TrackCover(
              url: playlist.coverUrl,
              size: double.infinity,
              radius: Motion.of(context).prefs.corner.radius * 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            playlist.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          Text('${playlist.trackCount}', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Плейлист целиком: обложка, кнопки, треки в порядке источника.
class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final detail = ref.watch(playlistProvider(widget.playlistId));

    // Мини-плеер плавает поверх страницы, как во вкладках.
    return MiniPlayerHost(
      child: Scaffold(
        body: detail.when(
          loading: () =>
              _statusView(context, l, const Center(child: ExpressiveLoader())),
          error: (error, _) =>
              _statusView(context, l, Center(child: Text(l.dbError('$error')))),
          data: (value) {
            if (value == null) {
              return _statusView(
                context,
                l,
                Center(child: Text(l.playlistNotFound)),
              );
            }
            final rows = value.rows;
            final scheme = Theme.of(context).colorScheme;
            return Stack(
              fit: StackFit.expand,
              children: [
                // Лёгкий оттенок обложки на всей странице: низ больше не
                // выглядит чёрной дырой вокруг мини-плеера и панели.
                BlurredCover(url: value.overview.coverUrl, opacity: 0.16),
                // Hero заканчивается плотной поверхностью, а страница под ним
                // подсвечена обложкой: без моста на стыке видна тёмная полоса.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 470,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            scheme.surface,
                            scheme.surface,
                            scheme.surface.withValues(alpha: 0),
                          ],
                          stops: const [0, 380 / 470, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                CustomScrollView(
                  controller: _scroll,
                  slivers: [
                    SliverToBoxAdapter(
                      child: _PlaylistHero(
                        title: value.overview.title,
                        coverUrl: value.overview.coverUrl,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: l.collectionCount(rows.length),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                FilledButton.icon(
                                  onPressed: rows.isEmpty
                                      ? null
                                      : () => _play(
                                          context,
                                          ref,
                                          rows,
                                          0,
                                          title: value.overview.title,
                                        ),
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  label: Text(l.collectionPlayAll),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  onPressed: rows.isEmpty
                                      ? null
                                      : () => _play(
                                          context,
                                          ref,
                                          rows,
                                          0,
                                          title: value.overview.title,
                                          shuffle: true,
                                        ),
                                  icon: const Icon(Icons.shuffle_rounded),
                                  label: Text(l.collectionShuffleAll),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: rows.length,
                      itemBuilder: (context, index) => TrackTile(
                        row: rows[index],
                        queue: rows,
                        index: index,
                        kind: 'playlist',
                        sourceTitle: value.overview.title,
                      ),
                    ),
                    const SliverBottomInset(),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: GlassTopBar(
                    title: value.overview.title,
                    controller: _scroll,
                    revealAt: 300,
                    actions: [
                      if (value.overview.source == 'yandex')
                        IconButton(
                          tooltip: l.collectionShare,
                          icon: const Icon(Icons.share_rounded),
                          onPressed: () => _share(context, ref, value.overview),
                        ),
                      IconButton(
                        tooltip: l.playlistCoverChange,
                        icon: const Icon(Icons.image_outlined),
                        onPressed: () => changePlaylistCover(
                          context,
                          ref,
                          widget.playlistId,
                        ),
                      ),
                      if (value.overview.source == 'local')
                        IconButton(
                          tooltip: l.playlistDeleteLocal,
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () =>
                              _deleteLocal(context, ref, value.overview),
                        ),
                      IconButton(
                        tooltip: l.collectionDownloadAllLikes,
                        icon: const Icon(Icons.download_rounded),
                        onPressed: rows.isEmpty
                            ? null
                            : () => _downloadAll(context, ref, rows),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Ветки загрузки/ошибки раньше оставались без шапки: уйти с экрана можно
  /// было только системным «назад», кнопки на самом экране не было.
  Widget _statusView(BuildContext context, AppLocalizations l, Widget child) =>
      CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
              tooltip: l.playerBack,
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          SliverFillRemaining(hasScrollBody: false, child: child),
          const SliverBottomInset(),
        ],
      );

  Future<void> _play(
    BuildContext context,
    WidgetRef ref,
    List<CollectionRow> rows,
    int index, {
    required String title,
    bool shuffle = false,
  }) async {
    final router = GoRouter.of(context);
    final controller = ref.read(playbackControllerProvider);
    await controller.playQueue(
      [for (final row in rows) row.localTrackId],
      startIndex: shuffle ? shuffleStartIndex(rows.length) : index,
      sourceHint: {
        'kind': 'playlist',
        'playlist': widget.playlistId,
        'title': title,
      },
    );
    if (shuffle) {
      await controller.setShuffle(PlaybackShuffle.shuffled);
    }
    openPlayerAfterPlay(router);
  }

  /// Ссылка на плейлист Яндекса: `ownerUid:kind` уже внутри локального id,
  /// а для своих плейлистов владелец - текущий аккаунт.
  String? _shareLink(WidgetRef ref, PlaylistOverview overview) {
    if (overview.source != 'yandex') return null;
    final raw = overview.id.startsWith('yandex:')
        ? overview.id.substring(7)
        : overview.id;
    final parts = raw.split(':');
    final String owner;
    final String kind;
    if (parts.length == 2) {
      owner = parts.first;
      kind = parts.last;
    } else {
      final auth = ref.read(appServicesProvider).yandex?.auth;
      if (auth is! AuthReady) return null;
      owner = auth.uid;
      kind = raw;
    }
    return 'https://music.yandex.ru/users/$owner/playlists/$kind';
  }

  Future<void> _deleteLocal(
    BuildContext context,
    WidgetRef ref,
    PlaylistOverview overview,
  ) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.playlistDeleteLocal),
        content: Text(l.playlistDeleteConfirm(overview.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(appServicesProvider)
        .db
        .libraryDao
        .deleteLocalPlaylist(overview.id);
    ref.invalidate(playlistsProvider);
    if (!context.mounted) return;
    Navigator.of(context).maybePop();
    messenger.showSnackBar(SnackBar(content: Text(l.playlistDeleted)));
  }

  Future<void> _share(
    BuildContext context,
    WidgetRef ref,
    PlaylistOverview overview,
  ) async {
    final link = _shareLink(ref, overview);
    if (link == null) return;
    await MimikoPlatform.shareText('${overview.title}\n$link');
  }

  Future<void> _downloadAll(
    BuildContext context,
    WidgetRef ref,
    List<CollectionRow> rows,
  ) async {
    final l = AppLocalizations.of(context);
    final queued = await ref
        .read(downloadControllerProvider.notifier)
        .downloadAllTracks([for (final row in rows) row.localTrackId]);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.collectionDownloadQueued(queued))));
  }
}

class _PlaylistHero extends StatelessWidget {
  const _PlaylistHero({required this.title, this.coverUrl});

  final String title;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    // Высота с учётом статус-бара: обложка встаёт под панелью с кнопками,
    // а не под ней.
    return SizedBox(
      height: MediaQuery.paddingOf(context).top + 350,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // BlurredCover растянут на 1.2 и без клипа вылезает за героя.
          ClipRect(child: _PlaylistBackdrop(coverUrl: coverUrl)),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistBackdrop extends StatelessWidget {
  const _PlaylistBackdrop({this.coverUrl});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        BlurredCover(url: coverUrl, opacity: 0.5),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, scheme.surface],
              stops: const [0.62, 1],
            ),
          ),
        ),
        // Сама обложка — чёткая и поверх затемнения: в списках плейлистов
        // раньше был только blur, и обложку было не разглядеть.
        if (coverUrl != null)
          Positioned(
            top: MediaQuery.paddingOf(context).top + kToolbarHeight + 8,
            left: 0,
            right: 0,
            child: Center(
              child: TrackCover(url: coverUrl, size: 200, radius: 22),
            ),
          ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
