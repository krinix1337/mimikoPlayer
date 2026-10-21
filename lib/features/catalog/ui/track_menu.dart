import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/routes.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/track_cover.dart';

/// Меню трека по образцу Я.Музыки: шапка с обложкой, круглые действия и
/// список. Только то, что действительно работает.
Future<void> showTrackMenu(
  BuildContext context,
  WidgetRef ref,
  String localTrackId,
) {
  final l = AppLocalizations.of(context);
  final services = ref.read(appServicesProvider);
  final controller = ref.read(playbackControllerProvider);

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: FutureBuilder(
        future: () async {
          final track = await services.db.tracksDao.byId(localTrackId);
          final liked = await services.db.libraryDao.likeState(localTrackId);
          final artist = await services.db.tracksDao.mainArtistOf(localTrackId);
          final albumId = await services.db.tracksDao.albumRemoteIdOf(
            localTrackId,
          );
          return (track, liked, artist, albumId);
        }(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final track = data?.$1;
          final liked = data?.$2 ?? 0;
          final artist = data?.$3;
          final albumId = data?.$4;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      TrackCover(url: track?.coverUrl, size: 56, radius: 12),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track?.title ?? localTrackId,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              [
                                if (artist != null) artist.name,
                                if (track != null) _duration(track.durationSec),
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MenuCircle(
                        icon: liked == 1
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        label: liked == 1 ? l.commonUnlike : l.menuLike,
                        highlighted: liked == 1,
                        onTap: () async {
                          await services.db.libraryDao.setLike(
                            localTrackId,
                            liked == 1 ? 0 : 1,
                          );
                          ref.invalidate(collectionProvider);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                      ),
                      _MenuCircle(
                        icon: Icons.lyrics_rounded,
                        label: l.menuKaraoke,
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          context.push(Routes.karaokeFor(localTrackId));
                        },
                      ),
                      _MenuCircle(
                        icon: Icons.thumb_down_alt_outlined,
                        label: l.menuDislike,
                        highlighted: liked == -1,
                        onTap: () async {
                          await services.db.libraryDao.setLike(
                            localTrackId,
                            liked == -1 ? 0 : -1,
                          );
                          ref.invalidate(collectionProvider);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.playlist_play_rounded),
                  title: Text(l.menuPlayNext),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    controller.playNext(localTrackId);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.queue_music_rounded),
                  title: Text(l.menuAddQueue),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    controller.enqueue(localTrackId);
                  },
                ),
                if (artist != null && artist.remoteId.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded),
                    title: Text(l.artistOpen),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      context.push(Routes.artistFor(artist.remoteId));
                    },
                  ),
                if (albumId != null && albumId.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.album_outlined),
                    title: Text(l.albumOpen),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      context.push(Routes.albumFor(albumId));
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(l.menuDetails),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l.menuDetails),
                        content: Text(
                          l.menuDetailsBody(
                            track?.metadataSource ?? '—',
                            '—',
                            '—',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l.waveClose),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _MenuCircle extends StatelessWidget {
  const _MenuCircle({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PressableScale(
      onTap: onTap,
      minScale: 0.9,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: highlighted ? scheme.primary : scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 76,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

String _duration(int seconds) {
  final minutes = seconds ~/ 60;
  final rest = seconds % 60;
  return '$minutes:${rest.toString().padLeft(2, '0')}';
}
