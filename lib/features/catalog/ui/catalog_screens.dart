import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../../../core/sources/source_dto.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/routes.dart';
import '../../../sources/yandex/yandex_source.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/track_cover.dart';
import 'track_menu.dart';

/// Проигрывание пачки удалённых треков: свести в базу, поставить очередь,
/// открыть плеер. Одно место на все карточки каталога.
Future<void> playRemoteTracks(
  BuildContext context,
  WidgetRef ref,
  List<SourceTrack> tracks, {
  int startIndex = 0,
  String kind = 'catalog',
}) async {
  if (tracks.isEmpty) return;
  final router = GoRouter.of(context);
  final services = ref.read(appServicesProvider);
  final ids = await services.db.tracksDao.ingestAll(tracks);
  await ref.read(playbackControllerProvider).playQueue(
    ids,
    startIndex: startIndex,
    sourceHint: {'kind': kind},
  );
  router.push(Routes.player);
}

class ArtistScreen extends ConsumerWidget {
  const ArtistScreen({super.key, required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final brief = ref.watch(artistBriefProvider(artistId));

    return Scaffold(
      body: brief.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l.dbError('$error'))),
        data: (artist) {
          if (artist == null) {
            return Center(child: Text(l.searchNoResults));
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 260,
                backgroundColor: Theme.of(context).colorScheme.surface,
                leading: IconButton(
                  tooltip: l.playerBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
                  title: Text(
                    artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: _ArtistBackdrop(coverUrl: artist.coverUrl),                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      FilledButton.icon(
                        onPressed: artist.popular.isEmpty
                            ? null
                            : () => playRemoteTracks(
                                context,
                                ref,
                                artist.popular,
                                kind: 'artist',
                              ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(l.collectionPlayAll),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          [
                            if (artist.trackCount != null)
                              '${artist.trackCount} ${l.commonTracks}',
                            if (artist.listeners != null)
                              '${_compact(artist.listeners!.toInt())} / ${l.playerTitle}',
                          ].join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: artist.popular.length,
                itemBuilder: (context, index) => _RemoteTrackTile(
                  track: artist.popular[index],
                  queue: artist.popular,
                  index: index,
                  kind: 'artist',
                ),
              ),
              if (artist.albums.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(
                      l.albumsTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
              if (artist.albums.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: artist.albums.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) =>
                          _AlbumCard(album: artist.albums[index]),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  static String _compact(int value) {
    if (value < 1000) return '$value';
    if (value < 1000000) return '${(value / 1000).toStringAsFixed(0)}K';
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
}

class _ArtistBackdrop extends StatelessWidget {
  const _ArtistBackdrop({this.coverUrl});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        BlurredCover(url: coverUrl, opacity: 0.6),
        // Крупный чёткий аватар: раньше на карточке был только размытый фон,
        // из-за чего фото артиста выглядело как цветное пятно.
        if (coverUrl != null)
          Positioned(
            top: 34,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.surface.withValues(alpha: 0.55),
                  border: Border.all(
                    color: scheme.onSurface.withValues(alpha: 0.18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: TrackCover(url: coverUrl, size: 132, radius: 66),
              ),
            ),
          ),
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

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.album});

  final AlbumBrief album;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 140,
      child: PressableScale(
        onTap: () => context.push(Routes.albumFor(album.remoteId)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TrackCover(url: album.coverUrl, size: 140, radius: 16),
            const SizedBox(height: 8),
            Text(
              album.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
            Text(
              [
                if (album.year != null) '${album.year}',
                if (album.trackCount != null) '${album.trackCount}',
              ].join(' · '),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class AlbumScreen extends ConsumerWidget {
  const AlbumScreen({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final album = ref.watch(albumProvider(albumId));

    return Scaffold(
      body: album.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l.dbError('$error'))),
        data: (value) {
          if (value == null) return Center(child: Text(l.searchNoResults));
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 300,
                backgroundColor: Theme.of(context).colorScheme.surface,
                leading: IconButton(
                  tooltip: l.playerBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
                  title: Text(
                    value.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: _AlbumBackdrop(album: value),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      FilledButton.icon(
                        onPressed: value.tracks.isEmpty
                            ? null
                            : () => playRemoteTracks(
                                context,
                                ref,
                                value.tracks,
                                kind: 'album',
                              ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(l.collectionPlayAll),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          [
                            value.artists.join(', '),
                            if (value.year != null) '${value.year}',
                            '${value.tracks.length} ${l.commonTracks}',
                          ].where((part) => part.isNotEmpty).join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: value.tracks.length,
                itemBuilder: (context, index) => _RemoteTrackTile(
                  track: value.tracks[index],
                  queue: value.tracks,
                  index: index,
                  kind: 'album',
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

class _AlbumBackdrop extends StatelessWidget {
  const _AlbumBackdrop({required this.album});

  final AlbumSnapshot album;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        BlurredCover(url: album.coverUrl, opacity: 0.55),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: TrackCover(
              url: album.coverUrl,
              size: 168,
              radius: 18,
            ),
          ),
        ),
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

class ChartScreen extends ConsumerWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final chart = ref.watch(chartProvider);

    return Scaffold(
      body: chart.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l.dbError('$error'))),
        data: (entries) => CustomScrollView(
          slivers: [
            SliverAppBar.large(
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: IconButton(
                tooltip: l.playerBack,
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: Text(l.chartTitle),
            ),
            if (entries.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text(l.searchNoResults)),
              )
            else
              SliverList.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) => ListTile(
                  leading: SizedBox(
                    width: 28,
                    child: Text(
                      '${entries[index].position}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  title: Text(
                    entries[index].track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    entries[index].track.artists.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: TrackCover(
                    url: entries[index].track.coverUrl,
                    size: 46,
                  ),
                  onTap: () => playRemoteTracks(
                    context,
                    ref,
                    [for (final entry in entries) entry.track],
                    startIndex: index,
                    kind: 'chart',
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

/// Строка удалённого трека с меню «три точки» справа, как в Я.Музыке.
class _RemoteTrackTile extends ConsumerWidget {
  const _RemoteTrackTile({
    required this.track,
    required this.queue,
    required this.index,
    required this.kind,
  });

  final SourceTrack track;
  final List<SourceTrack> queue;
  final int index;
  final String kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.read(appServicesProvider);
    return ListTile(
      onTap: () => playRemoteTracks(
        context,
        ref,
        queue,
        startIndex: index,
        kind: kind,
      ),
      leading: TrackCover(url: track.coverUrl, size: 52),
      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        track.artists.join(', '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert_rounded),
        onPressed: () async {
          final ingested = await services.db.tracksDao.ingest(track);
          if (!context.mounted) return;
          showTrackMenu(context, ref, ingested.localTrackId);
        },
      ),
    );
  }
}
