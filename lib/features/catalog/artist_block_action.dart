import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/content/artist_blocklist.dart';
import '../../l10n/app_localizations.dart';

/// «Не рекомендовать исполнителя» / «Снова рекомендовать» — одно действие
/// для страницы артиста и меню трека. Если сейчас играет трек этого
/// исполнителя, плеер сразу переходит к следующему.
Future<void> toggleArtistBlock(
  BuildContext context,
  WidgetRef ref,
  String artist,
) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final db = ref.read(appServicesProvider).db;
  final blocklist = ArtistBlocklist.instance;

  if (blocklist.isBlockedName(artist)) {
    await blocklist.unblock(db, artist);
    messenger.showSnackBar(
      SnackBar(content: Text(l.artistUnblockedDone(artist))),
    );
    return;
  }

  await blocklist.block(db, artist);
  messenger.showSnackBar(SnackBar(content: Text(l.artistBlockedDone(artist))));

  final controller = ref.read(playbackControllerProvider);
  final current = controller.snapshot.current;
  if (current != null &&
      blocklist.isBlocked(
        await db.tracksDao.artistNamesOf(current.localTrackId),
      )) {
    await controller.skipNext();
  }
}
