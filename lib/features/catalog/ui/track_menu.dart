import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_providers.dart';
import '../../../core/content/artist_blocklist.dart';
import '../artist_block_action.dart';
import '../../../core/db/daos/library_dao.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/sources/source_id.dart';
import '../../../features/downloads/download_service.dart';
import '../../../features/library/library_actions.dart';
import '../../../features/library/playlist_create.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/routes.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/track_cover.dart';
import 'track_details_sheet.dart';

/// Меню трека по образцу Я.Музыки: шапка с обложкой, круглые действия и
/// список. Только то, что действительно работает.
Future<void> showTrackMenu(
  BuildContext context,
  WidgetRef ref,
  String localTrackId, {
  String? title,
  String? artistName,
  String? coverUrl,
  int? durationSec,
}) {
  final l = AppLocalizations.of(context);
  final services = ref.read(appServicesProvider);
  final controller = ref.read(playbackControllerProvider);
  // Меню закрывается до сетевого запроса; контекст его билдера к тому
  // моменту уже не смонтирован, поэтому запоминаем контекст страницы.
  final hostContext = context;

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
          final variants = await services.db.tracksDao.variantsOf(localTrackId);
          final hasRemote = variants.any((v) => v.ref.source != SourceId.local);
          final remoteRefs = variants
              .where((v) => v.ref.source != SourceId.local)
              .toList();
          final remoteTrackId = remoteRefs.isEmpty
              ? null
              : remoteRefs.first.ref.remoteId;
          final remoteSource = remoteRefs.isEmpty
              ? null
              : remoteRefs.first.ref.source.wire;
          // Яндекс принимает в свои плейлисты только свои треки.
          final yandexTrackId = variants
              .where((v) => v.ref.source == SourceId.yandex)
              .map((v) => v.ref.remoteId)
              .firstOrNull;
          final downloaded = await services.db.streamsDao.downloadedFilePath(
            localTrackId,
          );
          return (
            track,
            liked,
            artist,
            albumId,
            hasRemote,
            downloaded != null,
            remoteTrackId,
            remoteSource,
            yandexTrackId,
          );
        }(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final track = data?.$1;
          final liked = data?.$2 ?? 0;
          final artist = data?.$3;
          final albumId = data?.$4;
          final hasRemote = data?.$5 ?? false;
          final wasDownloaded = data?.$6 ?? false;
          final remoteTrackId = data?.$7;
          final remoteSource = data?.$8;
          final yandexTrackId = data?.$9;
          final shownTitle = track?.title.isNotEmpty == true
              ? track!.title
              : (title?.isNotEmpty == true ? title! : localTrackId);
          final shownArtist = artist?.name.isNotEmpty == true
              ? artist!.name
              : (artistName ?? '');
          final shownDuration = track?.durationSec ?? durationSec ?? 0;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      TrackCover(
                        url: track?.coverUrl ?? coverUrl,
                        size: 56,
                        radius: 12,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shownTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              [
                                if (shownArtist.isNotEmpty) shownArtist,
                                if (shownDuration > 0) _duration(shownDuration),
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
                    // По верху: подпись в две строки («Убрать из любимого»)
                    // иначе опускала соседние кружки ниже.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MenuCircle(
                        icon: liked == 1
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        label: liked == 1 ? l.commonUnlike : l.menuLike,
                        highlighted: liked == 1,
                        onTap: () async {
                          await LibraryActions(services)
                              .setFeedback(localTrackId, liked == 1 ? 0 : 1);
                          await controller.refreshLikedState();
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
                          await LibraryActions(services)
                              .setFeedback(localTrackId, liked == -1 ? 0 : -1);
                          await controller.refreshLikedState();
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
                if (shownArtist.isNotEmpty)
                  ListenableBuilder(
                    listenable: ArtistBlocklist.instance,
                    builder: (context, _) {
                      final blocked = ArtistBlocklist.instance.isBlockedName(
                        shownArtist,
                      );
                      return ListTile(
                        leading: const Icon(Icons.block_rounded),
                        title: Text(blocked ? l.artistUnblock : l.artistBlock),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          unawaited(
                            toggleArtistBlock(hostContext, ref, shownArtist),
                          );
                        },
                      );
                    },
                  ),
                // Для любого трека, включая файлы из памяти: они уходят в
                // плейлисты на устройстве.
                ListTile(
                  leading: const Icon(Icons.playlist_add_rounded),
                  title: Text(l.menuAddToPlaylist),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    unawaited(
                      _showAddToPlaylist(
                        hostContext,
                        ref,
                        localTrackId,
                        yandexTrackId: yandexTrackId,
                        albumId: albumId,
                        linkSource: remoteSource ?? SourceId.local.wire,
                        linkRemoteId: remoteTrackId ?? localTrackId,
                      ),
                    );
                  },
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final status = ref.watch(
                      downloadStatusProvider(localTrackId),
                    );
                    final downloading =
                        status?.phase == DownloadPhase.downloading;
                    final paused = status?.phase == DownloadPhase.paused;
                    final complete =
                        status?.phase == DownloadPhase.complete ||
                        (status == null && wasDownloaded);
                    final percent = status?.progress == null
                        ? null
                        : (status!.progress! * 100).round();

                    final label = switch (status?.phase) {
                      DownloadPhase.downloading =>
                        percent == null
                            ? l.menuDownloading
                            : l.downloadProgress(percent),
                      DownloadPhase.complete => l.menuDownloaded,
                      DownloadPhase.failed => l.menuDownloadRetry,
                      // Пропущенный трек всё равно можно попробовать вручную,
                      // а причину показывает подзаголовок.
                      DownloadPhase.skipped => l.playerDownload,
                      DownloadPhase.paused => l.downloadsPaused,
                      null => complete ? l.menuDownloaded : l.playerDownload,
                    };
                    final icon = downloading
                        ? Icons.downloading_rounded
                        : paused
                        ? Icons.pause_circle_outline_rounded
                        : complete
                        ? Icons.offline_pin_rounded
                        : Icons.download_rounded;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          enabled: hasRemote && !downloading,
                          leading: Icon(icon),
                          title: Text(label),
                          subtitle: downloading
                              ? LinearProgressIndicator(
                                  value: status?.progress,
                                  minHeight: 3,
                                )
                              : status?.phase == DownloadPhase.failed ||
                                    status?.phase == DownloadPhase.skipped
                              ? Text(
                                  status?.error ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          onTap: !hasRemote
                              ? null
                              : () async {
                                  final downloader = ref.read(
                                    downloadControllerProvider.notifier,
                                  );
                                  if (complete) {
                                    await downloader.remove(localTrackId);
                                    if (sheetContext.mounted) {
                                      Navigator.of(sheetContext).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(l.downloadRemoved),
                                            ),
                                          );
                                    }
                                  } else {
                                    try {
                                      if (paused) {
                                        await downloader.resume(localTrackId);
                                      } else {
                                        await downloader.start(localTrackId);
                                      }
                                    } on Object catch (error) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l.downloadFailed('$error'),
                                                ),
                                              ),
                                            );
                                      }
                                    }
                                  }
                                },
                        ),
                      ],
                    );
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
                    showTrackDetails(context, ref, localTrackId);
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

/// Выбор плейлиста для трека. Свои плейлисты Яндекса принимают только треки
/// Яндекса (запись идёт на сервер), а плейлисты на устройстве — любые, в том
/// числе локальные файлы.
Future<void> _showAddToPlaylist(
  BuildContext context,
  WidgetRef ref,
  String localTrackId, {
  String? yandexTrackId,
  String? albumId,
  required String linkSource,
  required String linkRemoteId,
}) async {
  final l = AppLocalizations.of(context);
  final services = ref.read(appServicesProvider);
  final all = await services.db.libraryDao.playlistsOverview();
  final canYandex = yandexTrackId != null && (albumId?.isNotEmpty ?? false);
  final yandexOwn = [
    if (canYandex)
      for (final playlist in all)
        if (playlist.source == SourceId.yandex.wire &&
            !playlist.id.substring('yandex:'.length).contains(':'))
          playlist,
  ];
  final device = [
    for (final playlist in all)
      if (playlist.source == SourceId.local.wire) playlist,
  ];
  if (!context.mounted) return;

  Widget section(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
    child: Text(
      title,
      style: Theme.of(context).textTheme.labelLarge
          ?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );

  final choice =
      await showModalBottomSheet<({PlaylistOverview? playlist, bool create})>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    l.menuAddToPlaylist,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.add_rounded),
                  title: Text(l.playlistCreate),
                  onTap: () =>
                      Navigator.of(sheetContext)
                          .pop((playlist: null, create: true)),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      if (device.isNotEmpty) section(l.playlistTargetDevice),
                      for (final playlist in device)
                        ListTile(
                          leading: const Icon(Icons.smartphone_rounded),
                          title: Text(
                            playlist.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text('${playlist.trackCount}'),
                          onTap: () =>
                              Navigator.of(sheetContext)
                                  .pop((playlist: playlist, create: false)),
                        ),
                      if (yandexOwn.isNotEmpty) section(l.playlistTargetYandex),
                      for (final playlist in yandexOwn)
                        ListTile(
                          leading: const Icon(Icons.queue_music_rounded),
                          title: Text(
                            playlist.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text('${playlist.trackCount}'),
                          onTap: () =>
                              Navigator.of(sheetContext)
                                  .pop((playlist: playlist, create: false)),
                        ),
                      if (device.isEmpty && yandexOwn.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          child: Text(
                            l.addToPlaylistEmpty,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  if (choice == null || !context.mounted) return;

  var playlistId = choice.playlist?.id;
  var title = choice.playlist?.title;
  var isLocal = choice.playlist?.source == SourceId.local.wire;
  String? yandexKind = playlistId != null && !isLocal
      ? playlistId.substring('yandex:'.length)
      : null;
  if (choice.create) {
    final draft = await showCreatePlaylistSheet(context, ref);
    if (draft == null || !context.mounted) return;
    playlistId = draft.id;
    title = draft.title;
    isLocal = draft.local;
    yandexKind = draft.local ? null : draft.kind;
  }
  if (playlistId == null || title == null) return;

  var ok = false;
  if (isLocal) {
    await services.db.libraryDao.appendPlaylistTrack(
      playlistId: playlistId,
      localTrackId: localTrackId,
      sourceId: linkSource,
      remoteId: linkRemoteId,
    );
    ok = true;
  } else if (yandexKind != null && canYandex) {
    ok =
        await services.yandex?.addTrackToPlaylist(
          kind: yandexKind,
          trackId: yandexTrackId,
          albumId: albumId!,
        ) ??
        false;
    if (ok) {
      await services.db.libraryDao.appendPlaylistTrack(
        playlistId: playlistId,
        localTrackId: localTrackId,
        sourceId: SourceId.yandex.wire,
        remoteId: yandexTrackId,
      );
    }
  }
  if (!context.mounted) return;
  if (ok) {
    ref.invalidate(playlistProvider(playlistId));
    ref.invalidate(playlistsProvider);
    AppLogger.instance.info('в плейлист $playlistId добавлен $localTrackId');
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.addToPlaylistDone(title))));
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.addToPlaylistFailed)));
  }
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
