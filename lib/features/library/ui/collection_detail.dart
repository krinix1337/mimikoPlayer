import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../../../core/db/daos/library_dao.dart';
import '../../../features/player/player_snapshot.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/routes.dart';
import '../../../theme/app_motion.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/track_cover.dart';
import '../../../widgets/track_tile.dart';
import 'collection_screen.dart' show SectionHeader, showSortSheet;

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
    };

    return Scaffold(
      body: rows.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorBox(text: l.dbError('$error')),
        data: (data) => CustomScrollView(
          slivers: [
            SliverAppBar.large(
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(title),
              actions: [
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      FilledButton.icon(
                        onPressed: () => _play(context, ref, data, 0),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(l.collectionPlayAll),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l.collectionCount(data.length),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
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
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  String _emptyFor(AppLocalizations l) => switch (kind) {
    CollectionKind.liked => l.collectionEmptyLiked,
    CollectionKind.disliked => l.collectionEmptyDisliked,
    CollectionKind.files => l.collectionEmptyFiles,
    CollectionKind.recent => l.collectionEmptyRecent,
  };

  Future<void> _play(
    BuildContext context,
    WidgetRef ref,
    List<CollectionRow> rows,
    int index,
  ) async {
    final router = GoRouter.of(context);
    await ref.read(playbackControllerProvider).playQueue(
      [for (final row in rows) row.localTrackId],
      startIndex: index,
      sourceHint: {'kind': kind.name},
    );
    router.push(Routes.player);
  }
}

/// Сетка импортированных плейлистов.
class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final playlists = ref.watch(playlistsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(l.collectionPlaylists),
          ),
          switch (playlists) {
            AsyncError(:final error) => SliverFillRemaining(
              hasScrollBody: false,
              child: _ErrorBox(text: l.dbError('$error')),
            ),
            AsyncData(:final value) when value.isEmpty => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text(
                    l.collectionEmptyPlaylists,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
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
                    delay: Duration(milliseconds: (index * 24).clamp(0, 200)),
                    child: _PlaylistCard(playlist: value[index]),
                  ),
                ),
              ),
            ),
            _ => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          },
        ],
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
          Text(
            '${playlist.trackCount}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Плейлист целиком: обложка, кнопки, треки в порядке источника.
class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final detail = ref.watch(playlistProvider(playlistId));

    return Scaffold(
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorBox(text: l.dbError('$error')),
        data: (value) {
          if (value == null) {
            return Center(child: Text(l.collectionEmptyPlaylists));
          }
          final rows = value.rows;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 210,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  title: Text(
                    value.overview.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: _PlaylistBackdrop(coverUrl: value.overview.coverUrl),
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
                                : () => _play(context, ref, rows, 0),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Text(l.collectionPlayAll),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: rows.isEmpty
                                ? null
                                : () => _play(context, ref, rows, 0, shuffle: true),
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
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _play(
    BuildContext context,
    WidgetRef ref,
    List<CollectionRow> rows,
    int index, {
    bool shuffle = false,
  }) async {
    final router = GoRouter.of(context);
    final controller = ref.read(playbackControllerProvider);
    await controller.playQueue(
      [for (final row in rows) row.localTrackId],
      startIndex: index,
      sourceHint: {'kind': 'playlist', 'playlist': playlistId},
    );
    if (shuffle) {
      await controller.setShuffle(PlaybackShuffle.shuffled);
    }
    router.push(Routes.player);
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
            ),
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
