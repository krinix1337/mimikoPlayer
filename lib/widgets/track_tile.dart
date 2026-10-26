import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_providers.dart';
import '../core/content/ai_filter.dart';
import '../core/db/daos/library_dao.dart';
import '../core/sources/source_id.dart';
import '../features/catalog/ui/track_menu.dart';
import '../features/downloads/download_service.dart';
import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import 'track_badges.dart';
import 'track_cover.dart';

/// Общий тег hero для обложки: список, мини-плеер и большой экран
/// переносят одну и ту же картинку, а не рисуют новую.
String coverHeroTag(String localTrackId) => 'cover:$localTrackId';

/// Строка трека в списках: обложка, название, исполнитель, длительность.
/// Подзаголовок — именно исполнитель, а не служебное имя источника.
class TrackTile extends ConsumerWidget {
  const TrackTile({
    super.key,
    required this.row,
    required this.queue,
    required this.index,
    this.kind = 'library',
    this.trailing,
    this.showDuration = true,
  });

  final CollectionRow row;

  /// Полный список, из которого запускается воспроизведение.
  final List<CollectionRow> queue;
  final int index;
  final String kind;
  final Widget? trailing;
  final bool showDuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final player = ref.watch(
      playerSnapshotProviderValue.select(
        (s) => (s.current?.localTrackId, s.uncensored),
      ),
    );
    final isCurrent = player.$1 == row.localTrackId;
    final uncensored = isCurrent && player.$2;
    final aiReady = ref.watch(aiBadgeReadyProvider).hasValue;
    final isAi =
        aiReady &&
        AiFilter.instance.isAiRow(row.title, row.artist, row.artistRemoteIds);
    final hasBadges = row.explicitFlag || isAi || uncensored;
    // Повтор трека в плейлисте даёт два одинаковых Hero-тега и падение при
    // переходе. Анимацию оставляем первой копии, остальным — обычную обложку.
    final heroTag =
        queue.indexWhere((item) => item.localTrackId == row.localTrackId) ==
            index
        ? coverHeroTag(row.localTrackId)
        : null;
    final cover = TrackCover(url: row.coverPath ?? row.coverUrl, size: 52);

    return ListTile(
      onTap: () => _play(context, ref),
      onLongPress: () => _toggleLike(ref),
      leading: Stack(
        children: [
          if (heroTag == null) cover else Hero(tag: heroTag, child: cover),
          if (isCurrent)
            Positioned(
              right: -2,
              bottom: -2,
              child: _PlayingDot(color: theme.colorScheme.primary),
            ),
        ],
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              row.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isCurrent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          if (hasBadges) ...[
            const SizedBox(width: 6),
            TrackBadges(
              explicit: row.explicitFlag,
              ai: isAi,
              uncensored: uncensored,
            ),
          ],
        ],
      ),
      subtitle: Text(
        row.artist.isEmpty ? _sourceLabel(context, row) : row.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            trailing!
          else if (showDuration && row.durationSec > 0)
            Text(_duration(row.durationSec), style: theme.textTheme.bodyMedium),
          if (row.source != SourceId.local)
            kind == 'liked'
                ? _DownloadAction(trackId: row.localTrackId)
                : _DownloadedMark(trackId: row.localTrackId),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: AppLocalizations.of(context).trackMenu,
            onPressed: () => showTrackMenu(
              context,
              ref,
              row.localTrackId,
              title: row.title,
              artistName: row.artist,
              coverUrl: row.coverUrl,
              durationSec: row.durationSec,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _play(BuildContext context, WidgetRef ref) async {
    // Роутер захватываем до await: список перестраивается, и этот элемент
    // к моменту возврата уже может быть выключен.
    final router = GoRouter.of(context);
    await ref
        .read(playbackControllerProvider)
        .playQueue(
          [for (final item in queue) item.localTrackId],
          startIndex: index,
          sourceHint: {'kind': kind},
        );
    router.push(Routes.player);
  }

  Future<void> _toggleLike(WidgetRef ref) async {
    final db = ref.read(appServicesProvider).db;
    final downloader = ref.read(downloadControllerProvider.notifier);
    final controller = ref.read(playbackControllerProvider);
    final current = await db.libraryDao.likeState(row.localTrackId);
    final next = current == 1 ? 0 : 1;
    await db.libraryDao.setLike(row.localTrackId, next);
    if (next == 1) {
      await downloader.trackLiked(row.localTrackId);
    }
    await controller.refreshLikedState();
    if (!ref.context.mounted) return;
    ref.invalidate(collectionProvider);
  }

  static String _sourceLabel(BuildContext context, CollectionRow row) {
    final l = AppLocalizations.of(context);
    return row.source.wire == 'local' ? l.collectionLocalTag : '';
  }

  static String _duration(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }
}

/// Тихая метка «трек уже на устройстве» для списков, где нет кнопки
/// скачивания: плейлисты, недавние, загрузки.
class _DownloadedMark extends ConsumerWidget {
  const _DownloadedMark({required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stored = ref.watch(isDownloadedProvider(trackId)).value ?? false;
    if (!stored) return const SizedBox.shrink();
    return Tooltip(
      message: AppLocalizations.of(context).trackDownloaded,
      child: SizedBox(
        width: 30,
        height: 40,
        child: Center(
          child: Icon(
            Icons.offline_pin_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Загрузка офлайн прямо из строки: та же кнопка, что в меню, но без
/// открытия шторки. Скачанный трек показывает офлайн-пин, как в Я.Музыке.
class _DownloadAction extends ConsumerWidget {
  const _DownloadAction({required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final status = ref.watch(downloadStatusProvider(trackId));
    final stored = ref.watch(isDownloadedProvider(trackId)).value ?? false;
    final downloading = status?.phase == DownloadPhase.downloading;
    final paused = status?.phase == DownloadPhase.paused;
    final complete =
        status?.phase == DownloadPhase.complete ||
        (status?.phase == null && stored);

    if (downloading) {
      return SizedBox(
        width: 36,
        height: 40,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              value: status?.progress,
              strokeWidth: 2.2,
            ),
          ),
        ),
      );
    }

    if (complete) {
      return Tooltip(
        message: l.trackDownloaded,
        child: SizedBox(
          width: 36,
          height: 40,
          child: Center(
            child: Icon(
              Icons.offline_pin_rounded,
              size: 20,
              color: scheme.primary,
            ),
          ),
        ),
      );
    }

    final failed =
        status?.phase == DownloadPhase.failed ||
        status?.phase == DownloadPhase.skipped;
    return IconButton(
      tooltip: paused
          ? l.downloadsResume
          : failed
          ? l.menuDownloadRetry
          : l.playerDownload,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 36, height: 40),
      padding: EdgeInsets.zero,
      icon: Icon(
        paused
            ? Icons.play_arrow_rounded
            : failed
            ? Icons.refresh_rounded
            : Icons.download_rounded,
        size: 20,
      ),
      onPressed: () async {
        try {
          final downloader = ref.read(downloadControllerProvider.notifier);
          if (paused) {
            await downloader.resume(trackId);
          } else {
            await downloader.start(trackId);
          }
        } on Object catch (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l.downloadFailed('$error'))));
          }
        }
      },
    );
  }
}

class _PlayingDot extends StatelessWidget {
  const _PlayingDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: const CircleBorder(),
    child: SizedBox(
      width: 18,
      height: 18,
      child: Icon(Icons.equalizer_rounded, size: 12, color: Colors.black87),
    ),
  );
}
