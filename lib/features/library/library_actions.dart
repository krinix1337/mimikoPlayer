import 'dart:convert';

import '../../app_services.dart';
import '../../core/db/database.dart';
import '../../core/logging/app_logger.dart';
import '../../core/sources/source_id.dart';
import '../../sources/yandex/yandex_source.dart';

/// Единая точка смены отметки трека: локальная база и Яндекс-аккаунт.
/// 1 — нравится, -1 — не рекомендовать, 0 — снять.
final class LibraryActions {
  const LibraryActions(this.services);

  final AppServices services;

  Future<bool> setFeedback(String localTrackId, int state) async {
    var synced = false;
    final yandex = services.yandex;
    if (yandex != null) {
      final variants = await services.db.tracksDao.variantsOf(localTrackId);
      final yandexTrack = variants
          .where((track) => track.ref.source == SourceId.yandex)
          .firstOrNull;
      if (yandexTrack != null) {
        final remoteId = yandexTrack.ref.remoteId;
        final previous = await feedbackOf(localTrackId);
        synced = await yandex.setTrackFeedback(
          remoteId,
          state,
          previous: previous,
        );
        // Не дошло до Яндекса: запоминаем, иначе при ближайшей синхронизации
        // трек вернулся бы в «Любимое» из аккаунта.
        if (state == 0) {
          if (synced) {
            await PendingUnlikes.remove(services.db, remoteId);
          } else {
            await PendingUnlikes.add(services.db, remoteId);
            AppLogger.instance.warn(
              'снятие лайка $remoteId не дошло до Яндекса, повторю при синхронизации',
            );
          }
        } else {
          await PendingUnlikes.remove(services.db, remoteId);
        }
      }
    }
    await services.db.libraryDao.setLike(
      localTrackId,
      state,
      remoteSource: synced && state != 0 ? SourceId.yandex : null,
    );
    return synced;
  }

  Future<int> feedbackOf(String localTrackId) =>
      services.db.libraryDao.likeState(localTrackId);
}

/// Лайки и «не рекомендовать», поставленные без сети: при синхронизации
/// досылаем их в Яндекс, иначе они так и живут только на телефоне.
final class PendingFeedback {
  const PendingFeedback._();

  /// Возвращает, сколько отметок дошло.
  static Future<int> retry(AppDatabase db, YandexSource source) async {
    final pending = await db.libraryDao.unsyncedFeedback(SourceId.yandex);
    var sent = 0;
    var failed = 0;
    for (final (localTrackId, remoteId, state) in pending) {
      if (!await source.setTrackFeedback(remoteId, state)) {
        // Один трек, который Яндекс не принимает, не должен навсегда
        // запирать остальные; а без сети хватит и трёх попыток.
        if (++failed >= 3) break;
        continue;
      }
      await db.libraryDao.markFeedbackSynced(localTrackId, SourceId.yandex);
      sent++;
    }
    return sent;
  }
}

/// Лайки, снятые локально, но ещё не снятые в Яндексе. Пока запись здесь, она
/// и повторяется при каждой синхронизации, и скрывает трек от импорта.
final class PendingUnlikes {
  const PendingUnlikes._();

  static const _key = 'pending_unlikes';

  static Future<Set<String>> load(AppDatabase db) async {
    final raw = await db.settingsDao.value(_key);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return {for (final id in decoded) '$id'};
    } on FormatException {
      // Повреждённая запись равна пустому списку.
    }
    return {};
  }

  static Future<void> _save(AppDatabase db, Set<String> ids) =>
      db.settingsDao.setValue(_key, ids.toList());

  static Future<void> add(AppDatabase db, String remoteId) async =>
      _save(db, (await load(db))..add(remoteId));

  static Future<void> remove(AppDatabase db, String remoteId) async {
    final ids = await load(db);
    if (ids.remove(remoteId)) await _save(db, ids);
  }

  /// Повторяет снятие лайка в Яндексе; возвращает то, что осталось.
  static Future<Set<String>> retry(AppDatabase db, YandexSource source) async {
    final pending = await load(db);
    if (pending.isEmpty) return pending;
    final left = <String>{};
    for (final id in pending) {
      if (!await source.setTrackFeedback(id, 0, previous: 1)) left.add(id);
    }
    if (left.length != pending.length) await _save(db, left);
    return left;
  }
}
