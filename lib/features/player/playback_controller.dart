import 'player_snapshot.dart';

/// Единственная граница между UI и плеером. UI не импортирует audio_service:
/// если 0.18 не вывезет Android 17, замена (MediaSessionService поверх media3,
/// который уже в сборке через just_audio) останется внутри lib/features/player.
abstract interface class PlaybackController {
  Stream<PlayerSnapshot> get snapshots;

  PlayerSnapshot get snapshot;

  Future<void> playQueue(
    List<String> localTrackIds, {
    int startIndex = 0,
    Map<String, Object?>? sourceHint,
  });

  Future<void> togglePlay();

  Future<void> seek(Duration position);

  Future<void> skipNext();

  Future<void> skipPrevious();

  Future<void> skipTo(String localTrackId);

  Future<void> setRepeat(PlaybackRepeat value);

  Future<void> setShuffle(PlaybackShuffle value);

  Future<void> stop();

  /// Пауза через [delay]; null отменяет уже поставленный таймер сна.
  Future<void> sleepAfter(Duration? delay);

  /// Добавить трек в конец очереди, ничего не прерывая.
  Future<void> enqueue(String localTrackId);

  /// Поставить трек сразу после текущего.
  Future<void> playNext(String localTrackId);
}
