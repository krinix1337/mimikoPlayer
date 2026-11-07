import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phoneyandex/widgets/sliver_bottom_inset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/content/artist_blocklist.dart';
import '../artist_block_action.dart';
import '../../../app_providers.dart';
import '../../../core/sources/source_dto.dart';
import '../../../features/player/player_snapshot.dart';
import '../../../l10n/app_localizations.dart';
import '../../library/ui/collection_screen.dart' show SectionHeader;
import '../../../router/player_launch.dart';
import '../../../router/routes.dart';
import '../../../sources/yandex/yandex_source.dart';
import '../../../widgets/chart_rank_cover.dart';
import '../../../widgets/glass_top_bar.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/remote_track_actions.dart';
import '../../../widgets/track_cover.dart';
import '../../../widgets/expressive_loader.dart';

/// Проигрывание пачки удалённых треков: свести в базу, поставить очередь,
/// открыть плеер. Одно место на все карточки каталога.
Future<void> playRemoteTracks(
  BuildContext context,
  WidgetRef ref,
  List<SourceTrack> tracks, {
  int startIndex = 0,
  String kind = 'catalog',
  String? title,
  bool shuffle = false,
}) async {
  if (tracks.isEmpty) return;
  final router = GoRouter.of(context);
  final services = ref.read(appServicesProvider);
  final controller = ref.read(playbackControllerProvider);
  final ids = await services.db.tracksDao.ingestAll(tracks);
  await controller.playQueue(
    ids,
    startIndex: shuffle ? shuffleStartIndex(tracks.length) : startIndex,
    sourceHint: {
      'kind': kind,
      if (title != null && title.isNotEmpty) 'title': title,
    },
  );
  if (shuffle) await controller.setShuffle(PlaybackShuffle.shuffled);
  openPlayerAfterPlay(router);
}

class ArtistScreen extends ConsumerStatefulWidget {
  const ArtistScreen({super.key, required this.artistId});

  final String artistId;

  @override
  ConsumerState<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends ConsumerState<ArtistScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final brief = ref.watch(artistBriefProvider(widget.artistId));

    return Scaffold(
      body: brief.when(
        loading: () => const Center(child: ExpressiveLoader()),
        error: (error, _) => Center(child: Text(l.dbError('$error'))),
        data: (artist) {
          if (artist == null) {
            return Center(child: Text(l.searchNoResults));
          }
          return Stack(
            children: [
              CustomScrollView(
                controller: _scroll,
                slivers: [
                  SliverToBoxAdapter(
                    child: _ArtistHero(
                      title: artist.name,
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
                                    title: artist.name,
                                  ),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Text(l.collectionPlayAll),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              [
                                if (artist.trackCount != null)
                                  l.commonTrackCount(artist.trackCount!),
                                if (artist.listeners != null)
                                  l.artistListeners(
                                    _compact(artist.listeners!.toInt()),
                                  ),
                              ].join(' · '),
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ListenableBuilder(
                            listenable: ArtistBlocklist.instance,
                            builder: (context, _) {
                              final blocked = ArtistBlocklist.instance
                                  .isBlockedName(artist.name);
                              return IconButton(
                                tooltip: blocked
                                    ? l.artistUnblock
                                    : l.artistBlock,
                                isSelected: blocked,
                                icon: const Icon(Icons.block_rounded),
                                selectedIcon: Icon(
                                  Icons.block_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                onPressed: () => toggleArtistBlock(
                                  context,
                                  ref,
                                  artist.name,
                                ),
                              );
                            },
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
                            onPressed: () => context.push(
                              Routes.artistTracksFor(widget.artistId),
                            ),
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
                      title: artist.name,
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
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push(
                                Routes.artistAlbumsFor(widget.artistId),
                              ),
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
                  const SliverBottomInset(),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: GlassTopBar(
                  title: artist.name,
                  controller: _scroll,
                  revealAt: 170,
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
                ),
              ),
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

class _ArtistHero extends StatelessWidget {
  const _ArtistHero({required this.title, this.coverUrl, this.onAvatarTap});

  final String title;
  final String? coverUrl;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: _ArtistBackdrop(
              coverUrl: coverUrl,
              onAvatarTap: onAvatarTap,
            ),
          ),
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
              child: Center(child: ExpressiveLoader()),
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
          const SliverBottomInset(),
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
              child: Center(child: ExpressiveLoader()),
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
          const SliverBottomInset(),
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

class AlbumScreen extends ConsumerStatefulWidget {
  const AlbumScreen({super.key, required this.albumId});

  final String albumId;

  @override
  ConsumerState<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends ConsumerState<AlbumScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final album = ref.watch(albumProvider(widget.albumId));

    return Scaffold(
      body: album.when(
        loading: () => const Center(child: ExpressiveLoader()),
        error: (error, _) => Center(child: Text(l.dbError('$error'))),
        data: (value) {
          if (value == null) return Center(child: Text(l.searchNoResults));
          return Stack(
            children: [
              CustomScrollView(
                controller: _scroll,
                slivers: [
                  SliverToBoxAdapter(child: _AlbumHero(album: value)),
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
                                    title: value.title,
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
                                l.commonTrackCount(value.tracks.length),
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
                      title: value.title,
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
                  title: value.title,
                  controller: _scroll,
                  revealAt: 210,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AlbumHero extends StatelessWidget {
  const _AlbumHero({required this.album});

  final AlbumSnapshot album;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(child: _AlbumBackdrop(album: album)),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Text(
              album.title,
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

class ChartScreen extends ConsumerStatefulWidget {
  const ChartScreen({super.key});

  @override
  ConsumerState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final chart = ref.watch(chartProvider);

    if (chart.isLoading && chart.value == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.chartTitle)),
        body: const Center(child: ExpressiveLoader()),
      );
    }
    if (chart.hasError && chart.value == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.chartTitle)),
        body: Center(child: Text(l.dbError('${chart.error}'))),
      );
    }

    final entries = chart.value ?? const <ChartEntry>[];
    if (entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l.chartTitle)),
        body: Center(child: Text(l.searchNoResults)),
      );
    }
    final covers = [
      for (final entry in entries)
        if (entry.track.coverUrl != null) entry.track.coverUrl!,
    ].take(4).toList();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (covers.isNotEmpty) BlurredCover(url: covers.first, opacity: 0.14),
          // Тот же мост, что и на плейлисте: иначе низ hero обрывается
          // тёмной полосой над списком.
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
                child: _ChartHero(entries: entries, covers: covers),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: l.collectionCount(entries.length)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: () => playRemoteTracks(
                              context,
                              ref,
                              [for (final entry in entries) entry.track],
                              kind: 'chart',
                              title: l.discoverChart,
                            ),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Text(l.collectionPlayAll),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () => playRemoteTracks(
                              context,
                              ref,
                              [for (final entry in entries) entry.track],
                              kind: 'chart',
                              title: l.discoverChart,
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
                itemCount: entries.length,
                itemBuilder: (context, index) => ListTile(
                  leading: ChartRankCover(
                    position: entries[index].position,
                    coverUrl: entries[index].track.coverUrl,
                    size: 56,
                    radius: 10,
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
                  trailing: RemoteTrackActions(
                    track: entries[index].track,
                    showDownload: false,
                  ),
                  onTap: () => playRemoteTracks(
                    context,
                    ref,
                    [for (final entry in entries) entry.track],
                    startIndex: index,
                    kind: 'chart',
                    title: l.discoverChart,
                  ),
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
              title: l.discoverChart,
              controller: _scroll,
              revealAt: 260,
            ),
          ),
        ],
      ),
    );
  }
}

/// Шапка чарта как у плейлиста: большая обложка на размытом фоне.
class _ChartHero extends StatelessWidget {
  const _ChartHero({required this.entries, required this.covers});

  final List<ChartEntry> entries;
  final List<String> covers;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 380,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (covers.isNotEmpty)
            ClipRect(child: BlurredCover(url: covers.first, opacity: 0.5)),
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
          Positioned(
            top: 76,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: covers.isEmpty
                    ? Icon(
                        Icons.trending_up_rounded,
                        color: scheme.primary,
                        size: 56,
                      )
                    : _ChartMosaic(covers: covers),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.discoverChart,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  l.chartSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
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
    this.title,
  });

  final SourceTrack track;
  final List<SourceTrack> queue;
  final int index;
  final String kind;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () => playRemoteTracks(
        context,
        ref,
        queue,
        startIndex: index,
        kind: kind,
        title: title,
      ),
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
