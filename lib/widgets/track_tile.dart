import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_providers.dart';
import '../core/db/daos/library_dao.dart';
import '../features/catalog/ui/track_menu.dart';
import '../l10n/app_localizations.dart';
import '../router/routes.dart';
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
    final playing = ref.watch(
      playerSnapshotProviderValue.select((s) => s.current?.localTrackId),
    );
    final isCurrent = playing == row.localTrackId;

    return ListTile(
      onTap: () => _play(context, ref),
      onLongPress: () => _toggleLike(ref),
      leading: Stack(
        children: [
          Hero(
            tag: coverHeroTag(row.localTrackId),
            child: TrackCover(url: row.coverUrl, size: 52),
          ),
          if (isCurrent)
            Positioned(
              right: -2,
              bottom: -2,
              child: _PlayingDot(color: theme.colorScheme.primary),
            ),
        ],
      ),
      title: Text(
        row.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
        ),
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
            Text(
              _duration(row.durationSec),
              style: theme.textTheme.bodyMedium,
            ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: AppLocalizations.of(context).trackMenu,
            onPressed: () => showTrackMenu(context, ref, row.localTrackId),
          ),
        ],
      ),
    );
  }

  Future<void> _play(BuildContext context, WidgetRef ref) async {
    // Роутер захватываем до await: список перестраивается, и этот элемент
    // к моменту возврата уже может быть выключен.
    final router = GoRouter.of(context);
    await ref.read(playbackControllerProvider).playQueue(
      [for (final item in queue) item.localTrackId],
      startIndex: index,
      sourceHint: {'kind': kind},
    );
    router.push(Routes.player);
  }

  Future<void> _toggleLike(WidgetRef ref) async {
    final db = ref.read(appServicesProvider).db;
    final current = await db.libraryDao.likeState(row.localTrackId);
    await db.libraryDao.setLike(row.localTrackId, current == 1 ? 0 : 1);
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
