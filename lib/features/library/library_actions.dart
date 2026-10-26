import '../../app_services.dart';
import '../../core/sources/source_id.dart';

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
        synced = await yandex.setTrackFeedback(
          yandexTrack.ref.remoteId,
          state,
        );
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
