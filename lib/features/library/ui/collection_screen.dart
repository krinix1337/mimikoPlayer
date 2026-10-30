import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phoneyandex/widgets/sliver_bottom_inset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../../../core/db/daos/library_dao.dart';
import '../../../core/prefs/prefs.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/player_launch.dart';
import '../../../router/routes.dart';
import '../../../theme/app_motion.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/track_cover.dart';

/// Коллекция: разделы сверху вниз, как в живом клиенте Яндекса, —
/// любимое, недавние обложки, артисты и сетка «ещё».
class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(playlistSyncProvider.notifier).refresh());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final liked = ref.watch(collectionProvider(CollectionKind.liked));
    final playlists = ref.watch(playlistsProvider);
    final files = ref.watch(collectionProvider(CollectionKind.files));
    final recent = ref.watch(collectionProvider(CollectionKind.recent));
    final disliked = ref.watch(collectionProvider(CollectionKind.disliked));
    final downloaded = ref.watch(collectionProvider(CollectionKind.downloaded));
    final artists = ref.watch(topArtistsProvider);
    final auth = ref.watch(yandexAuthStateProvider).value;
    // Разворачиваем AsyncValue один раз здесь: замыкания кнопок живут дольше
    // этого build, и `liked.value!` внутри onPlay падало экраном ошибки,
    // когда к тапу данные уже пересобрались.
    final likedRows = liked.value ?? const <CollectionRow>[];
    final artistRows = artists.value ?? const <ArtistPlaycount>[];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(l.collectionTitle),
            titleTextStyle: Theme.of(context).textTheme.headlineSmall,
            actions: [
              IconButton(
                tooltip: l.navSearch,
                icon: const Icon(Icons.search_rounded),
                onPressed: () => context.push(Routes.search),
              ),
              IconButton(
                tooltip: l.collectionSort,
                icon: const Icon(Icons.swap_vert_rounded),
                onPressed: () => showSortSheet(context, ref),
              ),
              if (auth?.isReady ?? false)
                IconButton(
                  tooltip: l.collectionImportPlaylists,
                  icon: const Icon(Icons.cloud_download_outlined),
                  onPressed: () => _importEverything(context, ref),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                RiseIn(
                  delay: const Duration(milliseconds: 40),
                  child: _BigSection(
                    title: l.collectionLiked,
                    count: likedRows.length,
                    icon: Icons.favorite_rounded,
                    covers: likedRows,
                    onTap: () => context.push(Routes.collectionLiked),
                    onPlay: likedRows.isEmpty
                        ? null
                        : () => _playAll(
                            ref,
                            likedRows,
                            CollectionKind.liked,
                            title: l.collectionLiked,
                          ),
                  ),
                ),
                RiseIn(
                  delay: const Duration(milliseconds: 80),
                  child: _RecentCarousel(rows: likedRows),
                ),
                if (artistRows.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SectionHeader(title: l.collectionArtists),
                  ),
                  _ArtistStrip(artists: artistRows),
                ],
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionHeader(title: l.collectionAlsoIn),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: _AlsoInGrid(
                    playlists: playlists.value?.length,
                    files: files.value?.length,
                    recent: recent.value?.length,
                    disliked: disliked.value?.length,
                    downloaded: downloaded.value?.length,
                  ),
                ),
              ],
            ),
          ),
          const SliverBottomInset(),
        ],
      ),
    );
  }

  Future<void> _importEverything(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final services = ref.read(appServicesProvider);
    final source = ref.read(yandexSourceProvider);

    try {
      final likes = await importYandexLikes(source: source, db: services.db);
      await importYandexDislikes(source: source, db: services.db);
      final lists = await importYandexPlaylists(
        source: source,
        db: services.db,
      );
      if (!ref.context.mounted) return;
      ref.invalidate(collectionProvider);
      ref.invalidate(playlistsProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${l.collectionImportedLikes(likes)} · '
            '${l.collectionImportedPlaylists(lists)}',
          ),
        ),
      );
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.collectionImportFailed('$error'))),
      );
    }
  }

  Future<void> _playAll(
    WidgetRef ref,
    List<CollectionRow> rows,
    CollectionKind kind, {
    required String title,
  }) async {
    await ref
        .read(playbackControllerProvider)
        .playQueue(
          [for (final row in rows) row.localTrackId],
          sourceHint: {'kind': kind.name, 'title': title},
        );
  }
}

class _RoundPlay extends StatelessWidget {
  const _RoundPlay({required this.size, required this.onTap});

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PressableScale(
      minScale: 0.9,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: scheme.onPrimary,
          size: size * 0.55,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.headlineMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onTap != null)
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.chevron_right_rounded),
            color: theme.colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

/// Крупная строка раздела: обложка-мозаика, название, счётчик, кнопка play.
class _BigSection extends StatelessWidget {
  const _BigSection({
    required this.title,
    required this.count,
    required this.icon,
    required this.covers,
    required this.onTap,
    this.onPlay,
  });

  final String title;
  final int? count;
  final IconData icon;
  final List<CollectionRow> covers;
  final VoidCallback onTap;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = AppLocalizations.of(context);
    final urls = covers
        .map((row) => row.coverPath ?? row.coverUrl)
        .whereType<String>()
        .take(4)
        .toList();
    final radius = Motion.of(context).prefs.corner.radius * 0.6;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: PressableScale(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 84,
              height: 84,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: urls.isEmpty
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            scheme.primary.withValues(alpha: 0.85),
                            scheme.tertiary.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: Icon(icon, size: 40, color: scheme.onPrimary),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        _BigCoverMosaic(covers: urls),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.surface.withValues(alpha: 0.82),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Icon(icon, size: 15, color: scheme.primary),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.headlineSmall),
                  if (count != null)
                    Text(
                      l.commonTrackCount(count!),
                      style: theme.textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
            if (onPlay != null) _RoundPlay(size: 48, onTap: onPlay!),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

/// Мозаика 2×2 из обложек раздела, как обложка «Мне нравится» в Яндексе.
class _BigCoverMosaic extends StatelessWidget {
  const _BigCoverMosaic({required this.covers});

  final List<String> covers;

  @override
  Widget build(BuildContext context) {
    if (covers.length == 1) {
      return TrackCover(url: covers.first, size: double.infinity, radius: 0);
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

/// Горизонтальная лента свежих обложек раздела.
class _RecentCarousel extends StatelessWidget {
  const _RecentCarousel({required this.rows});

  final List<CollectionRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final shown = rows.take(12).toList();
    final theme = Theme.of(context);

    return SizedBox(
      // Обложка 118 + две строки текста; на 172 колонок не хватало высоты.
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: shown.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final row = shown[index];
          return SizedBox(
            width: 118,
            child: PressableScale(
              onTap: () => _play(context, row, shown),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TrackCover(
                    url: row.coverPath ?? row.coverUrl,
                    size: 118,
                    radius: 18,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    row.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    row.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _play(
    BuildContext context,
    CollectionRow row,
    List<CollectionRow> rows,
  ) {
    final router = GoRouter.of(context);
    final ref = ProviderScope.containerOf(context);
    ref
        .read(playbackControllerProvider)
        .playQueue(
          [for (final item in rows) item.localTrackId],
          startIndex: rows.indexOf(row),
          sourceHint: {
            'kind': 'library',
            'title': AppLocalizations.of(context).collectionLiked,
          },
        );
    openPlayerAfterPlay(router);
  }
}

class _ArtistStrip extends StatelessWidget {
  const _ArtistStrip({required this.artists});

  final List<ArtistPlaycount> artists;

  static String _listened(AppLocalizations l, ArtistPlaycount artist) {
    final minutes = (artist.listenedMs / 60000).round();
    if (minutes < 1) return l.artistPlays(artist.plays);
    if (minutes < 60) return l.listenedMinutes(minutes);
    return '${l.listenedHours(minutes ~/ 60)} ${l.listenedMinutes(minutes % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: artists.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final artist = artists[index];
          // Карточка артиста сейчас есть только у Яндекса: чужой id
          // и суррогат `name:…` откроют пустую страницу.
          final canOpen = RegExp(r'^\d+$').hasMatch(artist.remoteId);
          return SizedBox(
            width: 104,
            child: PressableScale(
              onTap: canOpen
                  ? () => context.push(Routes.artistFor(artist.remoteId))
                  : null,
              child: Column(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: artist.coverUrl == null
                          ? ColoredBox(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.person_rounded,
                                size: 40,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          : TrackCover(
                              url: artist.coverUrl,
                              size: 96,
                              radius: 48,
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(_listened(l, artist), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AlsoInGrid extends StatelessWidget {
  const _AlsoInGrid({
    required this.playlists,
    required this.files,
    required this.recent,
    required this.disliked,
    required this.downloaded,
  });

  final int? playlists;
  final int? files;
  final int? recent;
  final int? disliked;
  final int? downloaded;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tiles = [
      (
        title: l.collectionPlaylists,
        count: playlists,
        icon: Icons.queue_music_rounded,
        route: Routes.collectionPlaylists,
      ),
      (
        title: l.collectionFiles,
        count: files,
        icon: Icons.folder_rounded,
        route: Routes.collectionFiles,
      ),
      (
        title: l.collectionRecent,
        count: recent,
        icon: Icons.history_rounded,
        route: Routes.collectionRecent,
      ),
      (
        title: l.collectionDownloaded,
        count: downloaded,
        icon: Icons.offline_pin_rounded,
        route: Routes.collectionDownloaded,
      ),
      (
        title: l.collectionDisliked,
        count: disliked,
        icon: Icons.thumb_down_alt_rounded,
        route: Routes.collectionDisliked,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final tile in tiles)
              SizedBox(
                width: width,
                // Высота обязательна: внутри _GridTile есть Spacer, а Wrap
                // отдаёт детям неограниченную высоту.
                height: 122,
                child: _GridTile(
                  title: tile.title,
                  count: tile.count,
                  icon: tile.icon,
                  onTap: () => context.push(tile.route),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({
    required this.title,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final int? count;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(
            Motion.of(context).prefs.corner.radius * 0.75,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 30),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
            if (count != null) Text('$count', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Лист сортировки — один на все разделы, значение живёт в [Prefs].
Future<void> showSortSheet(BuildContext context, WidgetRef ref) {
  final l = AppLocalizations.of(context);
  final current = ref.read(prefsProvider).collectionSort;

  String label(CollectionSort sort) => switch (sort) {
    CollectionSort.added => l.sortAdded,
    CollectionSort.title => l.sortTitle,
    CollectionSort.artist => l.sortArtist,
    CollectionSort.duration => l.sortDuration,
  };

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              l.collectionSort,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final sort in CollectionSort.values)
            ListTile(
              title: Text(label(sort)),
              trailing: sort == current
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : const Icon(Icons.circle_outlined),
              onTap: () {
                ref.read(prefsProvider.notifier).setCollectionSort(sort);
                ref.invalidate(collectionProvider);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    ),
  );
}
