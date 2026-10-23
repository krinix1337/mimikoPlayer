import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../../../core/db/daos/library_dao.dart';
import '../../../core/sources/source_dto.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/routes.dart';
import '../../../sources/yandex/yandex_source.dart';
import '../../../sources/yandex/yandex_station.dart';
import '../../../wave_providers.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/remote_track_actions.dart';
import '../../../widgets/track_cover.dart';

/// «Что послушать» — обзорный раздел как вторая вкладка Яндекса: волна,
/// чарт, новинки, станции и артисты. Только реальные данные каталога.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(chartProvider);
          ref.invalidate(newReleasesProvider);
          ref.invalidate(waveStationsProvider);
          ref.invalidate(topArtistsProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(l.discoverTitle),
              titleTextStyle: Theme.of(context).textTheme.headlineSmall,
              actions: [
                IconButton(
                  tooltip: l.navSearch,
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () => context.push(Routes.search),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ChartSection(),
                  const _NewReleasesSection(),
                  const _StationsSection(),
                  const _ArtistsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartSection extends ConsumerWidget {
  const _ChartSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final chart = ref.watch(chartProvider);
    final entries = chart.value ?? const <ChartEntry>[];
    if (entries.isEmpty) return const SizedBox.shrink();

    final top = entries.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: l.discoverChart,
          action: l.discoverAll,
          onAction: () => context.push(Routes.chart),
        ),
        for (var i = 0; i < top.length; i++)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: TrackCover(
                      url: top[i].track.coverUrl,
                      size: 48,
                      radius: 9,
                    ),
                  ),
                  Positioned(
                    left: 2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '${top[i].position}',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              top[i].track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              top[i].track.artists.join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: RemoteTrackActions(track: top[i].track),
            onTap: () => _play(
              context,
              ref,
              [for (final entry in entries) entry.track],
              i,
              'chart',
            ),
          ),
      ],
    );
  }
}

class _NewReleasesSection extends ConsumerWidget {
  const _NewReleasesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final albums = ref.watch(newReleasesProvider).value ?? const <AlbumBrief>[];
    if (albums.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _SectionTitle(
          title: l.discoverNewReleases,
          action: l.discoverAll,
          onAction: () => context.push(Routes.newReleases),
        ),
        SizedBox(
          height: 208,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: albums.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final album = albums[index];
              return SizedBox(
                width: 136,
                child: PressableScale(
                  onTap: () => context.push(Routes.albumFor(album.remoteId)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TrackCover(url: album.coverUrl, size: 136),
                      const SizedBox(height: 6),
                      Text(
                        album.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        album.artists.join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StationsSection extends ConsumerWidget {
  const _StationsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stations =
        ref.watch(waveStationsProvider).value ?? const <WaveStation>[];
    if (stations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _SectionTitle(title: l.discoverStations),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final station = stations[index];
              return ActionChip(
                avatar: station.iconUrl == null
                    ? null
                    : ClipOval(
                        child: TrackCover(url: station.iconUrl, size: 24),
                      ),
                label: Text(station.title),
                onPressed: () => _startStation(context, ref, station.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ArtistsSection extends ConsumerWidget {
  const _ArtistsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final artists =
        ref.watch(topArtistsProvider).value ?? const <ArtistPlaycount>[];
    if (artists.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _SectionTitle(title: l.discoverArtists),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: artists.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final artist = artists[index];
              return SizedBox(
                width: 104,
                child: PressableScale(
                  onTap: artist.remoteId.isEmpty
                      ? null
                      : () => context.push(Routes.artistFor(artist.remoteId)),
                  child: Column(
                    children: [
                      ClipOval(
                        child: TrackCover(url: artist.coverUrl, size: 96),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        artist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Все новинки сеткой по три в ряд — сюда ведёт «Все» из обзора.
class NewReleasesScreen extends ConsumerWidget {
  const NewReleasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final albums = ref.watch(newReleasesPageProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: scheme.surface,
            leading: IconButton(
              tooltip: l.playerBack,
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(l.discoverNewReleases),
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
            data: (list) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  childCount: list.length,
                  (context, index) => RiseIn(
                    delay: Duration(milliseconds: (index * 18).clamp(0, 220)),
                    child: _AlbumGridCard(album: list[index]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumGridCard extends StatelessWidget {
  const _AlbumGridCard({required this.album});

  final AlbumBrief album;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressableScale(
      onTap: () => context.push(Routes.albumFor(album.remoteId)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TrackCover(url: album.coverUrl, size: size),
              const SizedBox(height: 6),
              Text(
                album.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              Text(
                album.artists.join(', '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
          if (action != null)
            TextButton(onPressed: onAction, child: Text(action!)),
        ],
      ),
    );
  }
}

Future<void> _startStation(
  BuildContext context,
  WidgetRef ref,
  String station,
) async {
  ref.read(stationProvider.notifier).select(station);
  ref.invalidate(waveTracksProvider);
  ref.invalidate(waveSettingsProvider);
  if (await startWave(ref) && context.mounted) context.go(Routes.home);
}

Future<void> _play(
  BuildContext context,
  WidgetRef ref,
  List<SourceTrack> tracks,
  int index,
  String kind,
) async {
  final services = ref.read(appServicesProvider);
  final ids = await services.db.tracksDao.ingestAll(tracks);
  if (!context.mounted) return;
  await ref
      .read(playbackControllerProvider)
      .playQueue(ids, startIndex: index, sourceHint: {'kind': kind});
  if (context.mounted) context.push(Routes.player);
}
