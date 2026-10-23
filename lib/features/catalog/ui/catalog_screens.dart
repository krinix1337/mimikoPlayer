import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../../../core/sources/source_dto.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/routes.dart';
import '../../../sources/yandex/yandex_source.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/remote_track_actions.dart';
import '../../../widgets/track_cover.dart';

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
  final controller = ref.read(playbackControllerProvider);
  final ids = await services.db.tracksDao.ingestAll(tracks);
  await controller.playQueue(
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
                actions: [
                  if (artist.coverUrl != null)
                    IconButton(
                      tooltip: l.artistPhoto,
                      icon: const Icon(Icons.open_in_full_rounded),
                      onPressed: () => _showArtistPhoto(
                        context,
                        artist.coverUrl!,
                        artist.name,
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
                  title: Text(
                    artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: _ArtistBackdrop(
                    coverUrl: artist.coverUrl,
                    onAvatarTap: artist.coverUrl == null
                        ? null
                        : () => _showArtistPhoto(
                            context,
                            artist.coverUrl!,
                            artist.name,
                          ),
                  ),
                ),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.artistPopularTracks,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.push(Routes.artistTracksFor(artistId)),
                        child: Text(l.artistAllTracks),
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
              if (artist.albums.isNotEmpty || (artist.albumCount ?? 0) > 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.albumsTitle,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push(Routes.artistAlbumsFor(artistId)),
                          child: Text(l.artistAllAlbums),
                        ),
                      ],
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
  const _ArtistBackdrop({this.coverUrl, this.onAvatarTap});

  final String? coverUrl;
  final VoidCallback? onAvatarTap;

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
              child: PressableScale(
                minScale: 0.96,
                onTap: onAvatarTap,
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

/// Все треки артиста отдельным экраном: полный список вместо популярной
/// пятёрки на карточке.
class ArtistTracksScreen extends ConsumerWidget {
  const ArtistTracksScreen({super.key, required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tracks = ref.watch(artistTracksProvider(artistId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
              tooltip: l.playerBack,
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(l.artistAllTracks),
            titleTextStyle: Theme.of(context).textTheme.headlineSmall,
          ),
          tracks.when(
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(l.dbError('$error'))),
            ),
            data: (list) => list.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(l.searchNoResults)),
                  )
                : SliverList.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) => _RemoteTrackTile(
                      track: list[index],
                      queue: list,
                      index: index,
                      kind: 'artist',
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

/// Вся дискография артиста: сетка обложек, а не обрезанная лента на карточке.
class ArtistAlbumsScreen extends ConsumerWidget {
  const ArtistAlbumsScreen({super.key, required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final albums = ref.watch(artistAlbumsProvider(artistId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
              tooltip: l.playerBack,
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(l.artistAllAlbums),
            titleTextStyle: Theme.of(context).textTheme.headlineSmall,
          ),
          albums.when(
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(l.dbError('$error'))),
            ),
            data: (list) => list.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(l.searchNoResults)),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        childCount: list.length,
                        (context, index) =>
                            _ArtistAlbumTile(album: list[index]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ArtistAlbumTile extends StatelessWidget {
  const _ArtistAlbumTile({required this.album});

  final AlbumBrief album;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressableScale(
      onTap: () => context.push(Routes.albumFor(album.remoteId)),
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TrackCover(url: album.coverUrl, size: constraints.maxWidth),
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

Future<void> _showArtistPhoto(BuildContext context, String url, String name) =>
    showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: url,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (_, _, _) => const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 52,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  tooltip: AppLocalizations.of(dialogContext).playerBack,
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

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
            child: TrackCover(url: album.coverUrl, size: 168, radius: 18),
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
            SliverAppBar(
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: IconButton(
                tooltip: l.playerBack,
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
              title: Text(l.chartTitle),
              titleTextStyle: Theme.of(context).textTheme.headlineSmall,
            ),
            if (entries.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text(l.searchNoResults)),
              )
            else ...[
              SliverToBoxAdapter(child: _ChartHero(entries: entries)),
              SliverList.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) => ListTile(
                  leading: SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: TrackCover(
                            url: entries[index].track.coverUrl,
                            size: 56,
                            radius: 10,
                          ),
                        ),
                        Positioned(
                          left: 2,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.62),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${entries[index].position}',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
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
                  trailing: RemoteTrackActions(track: entries[index].track),
                  onTap: () => playRemoteTracks(
                    context,
                    ref,
                    [for (final entry in entries) entry.track],
                    startIndex: index,
                    kind: 'chart',
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

/// Шапка чарта с обложкой-мозаикой: не просто список без контекста.
class _ChartHero extends ConsumerWidget {
  const _ChartHero({required this.entries});

  final List<ChartEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final covers = [
      for (final entry in entries)
        if (entry.track.coverUrl != null) entry.track.coverUrl!,
    ].take(4).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Container(
            width: 108,
            height: 108,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: covers.isEmpty
                ? Icon(
                    Icons.trending_up_rounded,
                    color: scheme.primary,
                    size: 44,
                  )
                : _ChartMosaic(covers: covers),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l.discoverChart} · ${entries.length}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  l.chartSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => playRemoteTracks(context, ref, [
                    for (final entry in entries) entry.track,
                  ], kind: 'chart'),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l.collectionPlayAll),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartMosaic extends StatelessWidget {
  const _ChartMosaic({required this.covers});

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
    return ListTile(
      onTap: () =>
          playRemoteTracks(context, ref, queue, startIndex: index, kind: kind),
      leading: TrackCover(url: track.coverUrl, size: 52),
      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        track.artists.join(', '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: RemoteTrackActions(track: track),
    );
  }
}
