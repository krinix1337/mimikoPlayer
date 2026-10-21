import 'source_dto.dart';
import 'source_id.dart';
import 'stream_target.dart';

/// Единый контракт любого музыкального источника. Реализации живут в
/// `lib/sources/<id>/`; знать о них имеет право только `SourceRegistry`.
abstract interface class MusicSource {
  SourceId get id;

  SourceCapabilities get capabilities;

  AuthState get auth;

  Stream<AuthState> get authChanges;

  /// Ленивая инициализация: обновить токен до первого сетевого хопа.
  Future<void> warmUp();

  Future<SearchResult> search(
    String query, {
    int page = 0,
    int pageSize = 50,
  });

  Future<SourceTrack?> getTrack(RemoteTrackRef ref);

  /// Пакетное получение метаданных: у Яндекса это `POST /tracks` с
  /// `track-ids=<csv>`, у источника без батча — цикл по [getTrack].
  Future<List<SourceTrack>> getTracksByIds(List<RemoteTrackRef> refs);

  Future<PlaylistSnapshot?> getPlaylist(String remotePlaylistId);

  /// Единственный метод, который не имеет права бросать исключение на
  /// «не могу воспроизвести»: должен вернуться [StreamFailed] с причиной, по
  /// которой цепочка резервных источников решает, идти дальше или нет.
  Future<StreamResult> resolveStream(
    SourceTrack track, {
    Quality preferred = Quality.auto,
  });

  /// Прогресс прослушивания (Яндекс: rotor feedback). Источники без такого
  /// отчёта реализуют его пустым телом.
  Future<void> reportPlaybackEvent(
    SourceTrack track,
    PlaybackEventType type,
    Duration played,
  );

  Future<void> dispose();
}
