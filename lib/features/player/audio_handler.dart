import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../app_services.dart';
import '../../core/constants.dart';
import '../../core/content/ai_filter.dart';
import '../../core/db/daos/queue_dao.dart';
import '../../core/logging/app_logger.dart';
import '../../core/sources/source_dto.dart';
import '../../core/sources/source_errors.dart';
import '../../core/sources/source_id.dart';
import '../../core/sources/stream_resolver.dart';
import '../../core/sources/stream_target.dart';
import 'playback_controller.dart';
import 'player_snapshot.dart';
import 'queue_manager.dart';

/// Фоновый плеер. Один экземпляр на процесс: audio_service поднимает `main()`
/// заново после смерти процесса по media-кнопке, поэтому очередь берётся из
/// `queue_snapshots`, а не из памяти.
class MusicBackgroundAudioHandler extends BaseAudioHandler
    with SeekHandler
    implements PlaybackController {
  MusicBackgroundAudioHandler(this._services) {
    instance = this;
    _bindPlayer();
  }

  static MusicBackgroundAudioHandler? instance;

  final AppServices _services;
  final AudioPlayer _player = AudioPlayer();
  final QueueManager _queue = QueueManager();
  final StreamController<PlayerSnapshot> _snapshots =
      StreamController<PlayerSnapshot>.broadcast();

  PlayerSnapshot _snapshot = const PlayerSnapshot();
  Map<String, Object?>? _sourceHint;
  int _consecutiveFailures = 0;
  Duration _pendingSeek = Duration.zero;

  Timer? _pauseWatchdog;
  Timer? _snapshotTimer;
  Timer? _periodicSnapshot;
  Timer? _stallProbe;
  Timer? _sleepTimer;
  int _stallSeconds = 0;
  bool _radioRefillInFlight = false;

  /// Таймер сна: пауза после текущего трека, когда время вышло.
  /// null — выключить. Ставится только на реальное воспроизведение,
  /// поэтому «до конца трека» = до конца того, что играет сейчас.
  @override
  Future<void> sleepAfter(Duration? delay) async {
    _sleepTimer?.cancel();
    if (delay == null) {
      AppLogger.instance.info('таймер сна выключен');
      return;
    }
    _sleepTimer = Timer(delay, () async {
      AppLogger.instance.info('таймер сна: пауза');
      await pause();
    });
    AppLogger.instance.info('таймер сна: ${delay.inMinutes} мин');
  }

  @override
  Stream<PlayerSnapshot> get snapshots => _snapshots.stream;

  @override
  PlayerSnapshot get snapshot => _snapshot;

  @override
  Future<void> playQueue(
    List<String> localTrackIds, {
    int startIndex = 0,
    Map<String, Object?>? sourceHint,
  }) async {
    if (localTrackIds.isEmpty) return;
    AppLogger.instance.info(
      'playQueue x${localTrackIds.length} idx=$startIndex hint=$sourceHint',
    );
    _sourceHint = sourceHint;
    _publish(
      _snapshot.copyWith(
        sourceKind: '${sourceHint?['kind'] ?? ''}',
        isRadio: sourceHint?['kind'] == 'radio',
      ),
    );
    _pendingSeek = Duration.zero;
    _queue.setQueue(localTrackIds, startIndex: startIndex);
    _consecutiveFailures = 0;
    await _playCurrent();
  }

  @override
  Future<void> togglePlay() => _snapshot.playing ? pause() : play();

  @override
  Future<void> playNext(String localTrackId) async {
    if (_snapshot.current == null) {
      await playQueue([localTrackId]);
      return;
    }
    final track = await _services.db.tracksDao.byId(localTrackId);
    final artists = await _services.db.tracksDao.artistNamesOf(localTrackId);
    _queue.insertNext(localTrackId);
    addQueueItem(
      MediaItem(
        id: localTrackId,
        title: track?.title ?? localTrackId,
        artist: artists.isEmpty ? 'Локальный файл' : artists.join(', '),
        artUri: track?.coverUrl == null ? null : Uri.tryParse(track!.coverUrl!),
        duration: Duration(seconds: track?.durationSec ?? 0),
      ),
    );
  }

  @override
  Future<void> enqueue(String localTrackId) async {
    if (_snapshot.current == null) {
      await playQueue([localTrackId]);
      return;
    }
    final track = await _services.db.tracksDao.byId(localTrackId);
    final artists = await _services.db.tracksDao.artistNamesOf(localTrackId);
    _queue.append(localTrackId);
    addQueueItem(
      MediaItem(
        id: localTrackId,
        title: track?.title ?? localTrackId,
        artist: artists.isEmpty ? 'Локальный файл' : artists.join(', '),
        artUri: track?.coverUrl == null ? null : Uri.tryParse(track!.coverUrl!),
        duration: Duration(seconds: track?.durationSec ?? 0),
      ),
    );
  }

  @override
  Future<void> skipNext() async {
    await _reportCurrent(PlaybackEventType.skip);
    final id = _queue.advance();
    if (id == null) {
      await stop();
      return;
    }
    _pendingSeek = Duration.zero;
    await _playCurrent();
  }

  @override
  Future<void> skipPrevious() async {
    if (_player.position > previousRestartThreshold) {
      await _player.seek(Duration.zero);
      return;
    }
    final id = _queue.rewind();
    if (id == null) return;
    _pendingSeek = Duration.zero;
    await _playCurrent();
  }

  @override
  Future<void> skipTo(String localTrackId) async {
    final id = _queue.jumpTo(localTrackId);
    if (id == null) return;
    _pendingSeek = Duration.zero;
    await _playCurrent();
  }

  @override
  Future<void> setRepeat(PlaybackRepeat value) async {
    _queue.setRepeat(value);
    _emitServiceState();
    _scheduleSnapshot();
  }

  @override
  Future<void> setShuffle(PlaybackShuffle value) async {
    _queue.setShuffle(value);
    _publish(
      _snapshot.copyWith(queue: _queue.displayOrder, index: _queue.displayPosition),
    );
    _emitServiceState();
    _scheduleSnapshot();
  }

  @override
  Future<void> stop() async {
    _pauseWatchdog?.cancel();
    _stallProbe?.cancel();
    final played = _player.position;
    await _fadeOut();
    await _player.setVolume(1);
    await _player.stop();
    await _reportCurrent(PlaybackEventType.skip, forcePlayed: played);
    mediaItem.add(null);
    _publish(
      _snapshot.copyWith(
        playing: false,
        buffering: false,
        position: Duration.zero,
        resolving: false,
        clearCurrent: true,
      ),
    );
    _emitServiceState(stopped: true);
    await _saveSnapshotNow();
  }

  // --- overrides audio_service -------------------------------------------
  // Уведомление, блокировка экрана и media-кнопки попадают ровно в эти методы,
  // поэтому они тонкие: вся логика — в методах интерфейса выше.

  @override
  Future<void> play() async {
    if (_queue.currentId == null && !(await _restoreSnapshot())) return;
    if (_player.processingState == ProcessingState.idle) {
      await _playCurrent();
      return;
    }
    _pauseWatchdog?.cancel();
    await _player.setVolume(0);
    // just_audio резолвит play() только на паузе или в конце трека: ждать
    // его — значит повесить вызов на всю длину песни.
    unawaited(_player.play());
    unawaited(_fadeIn());
  }

  @override
  Future<void> pause() async {
    // Гасим до паузы, а громкость возвращаем сразу: следующий старт
    // делает собственный фейд-ин с нуля.
    await _fadeOut();
    await _player.setVolume(1);
    await _player.pause();
    _startPauseWatchdog();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => skipNext();

  @override
  Future<void> skipToPrevious() => skipPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    final order = _queue.displayOrder;
    if (index < 0 || index >= order.length) return;
    await skipTo(order[index]);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    _queue.append(mediaItem.id);
    _publish(_snapshot.copyWith(queue: _queue.displayOrder));
    _emitServiceState();
    _scheduleSnapshot();
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    for (final item in mediaItems) {
      await addQueueItem(item);
    }
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    _queue.remove(mediaItem.id);
    _publish(_snapshot.copyWith(queue: _queue.displayOrder));
    _emitServiceState();
    _scheduleSnapshot();
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    final order = _queue.displayOrder;
    if (index < 0 || index >= order.length) return;
    await removeQueueItem(
      MediaItem(id: order[index], title: order[index]),
    );
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) =>
      setRepeat(_repeatFromService(repeatMode));

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) =>
      setShuffle(_shuffleFromService(shuffleMode));

  @override
  Future<void> onTaskRemoved() async {
    await _saveSnapshotNow();
    await super.onTaskRemoved();
  }

  // --- внутреннее ---------------------------------------------------------

  void _bindPlayer() {
    _player.playerStateStream.listen((state) {
      final completed = state.processingState == ProcessingState.completed;
      _publish(
        _snapshot.copyWith(
          playing: state.playing,
          buffering: state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering,
        ),
      );
      _emitServiceState();
      if (completed) unawaited(_onTrackFinished());
    });

    _player.positionStream.listen(
      (position) => _publish(_snapshot.copyWith(position: position)),
    );

    _player.durationStream.listen(
      (duration) =>
          _publish(_snapshot.copyWith(duration: duration ?? Duration.zero)),
    );

    _player.sequenceStateStream.listen((_) => _scheduleSnapshot());

    // just_audio сообщает о протухшей ссылке ошибком в потоке событий, а не
    // исключением: на Android 17 это ещё и молчаливый отказ аудио-API.
    _player.playbackEventStream.listen(
      null,
      onError: (Object error, StackTrace _) {
        _publishIssue(
          PlayerIssue(
            [
              SourceFailure(
                source: _snapshot.usedSource ?? SourceId.local,
                reason: SourceFailReason.network,
                message: '$error',
              ),
            ],
            needsUserAction: false,
          ),
        );
        unawaited(_revalidate(resume: _snapshot.playing));
      },
    );
  }

  /// Плавное затухание. Шаги по 16 мс: media3 меняет громкость дёшево, а
  /// короче 250 мс фейд на колонках уже слыщен как щелчок.
  static const Duration _fadeUp = Duration(milliseconds: 320);
  static const Duration _fadeDown = Duration(milliseconds: 240);

  Future<void> _ramp(double from, double to, Duration over) async {
    if (!_services.fadeEnabled || from == to) {
      await _player.setVolume(to);
      return;
    }
    final steps = (over.inMilliseconds / 16).ceil().clamp(4, 40);
    for (var step = 1; step <= steps; step++) {
      final t = step / steps;
      await _player.setVolume(from + (to - from) * t);
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    await _player.setVolume(to);
  }

  Future<void> _fadeIn() => _ramp(0, 1, _fadeUp);

  Future<void> _fadeOut() => _ramp(1, 0, _fadeDown);

  Future<void> _playCurrent() async {
    final localTrackId = _queue.currentId;
    if (localTrackId == null) return;

    final db = _services.db;
    final track = await db.tracksDao.byId(localTrackId);
    final artists = await db.tracksDao.artistNamesOf(localTrackId);
    final title = track?.title ?? localTrackId;
    final artist = artists.isEmpty ? 'Локальный файл' : artists.join(', ');

    mediaItem.add(
      MediaItem(
        id: localTrackId,
        title: title,
        artist: artist,
        artUri: track?.coverUrl == null ? null : Uri.parse(track!.coverUrl!),
        duration: Duration(seconds: track?.durationSec ?? 0),
        extras: {'source': track?.metadataSource ?? SourceId.local.wire},
      ),
    );

    _publish(
      _snapshot.copyWith(
        current: NowPlaying(
          localTrackId: localTrackId,
          title: title,
          artist: artist,
          coverUrl: track?.coverUrl,
        ),
        queue: _queue.displayOrder,
        index: _queue.currentBaseIndex,
        resolving: true,
        duration: Duration(seconds: track?.durationSec ?? 0),
        clearIssue: true,
      ),
    );

    final variants = await db.tracksDao.variantsOf(localTrackId);
    final result = await _services.resolver.resolve(
      localTrackId: localTrackId,
      variants: variants,
      quality: _services.defaultQuality,
    );

    final playback = result.playback;
    if (playback == null) {
      _consecutiveFailures++;
      AppLogger.instance.warn(
        'цепочка отказала ($localTrackId): ${result.failures.join(', ')}',
      );
      _publishIssue(
        PlayerIssue(result.failures, needsUserAction: result.needsUserAction),
      );
      if (_consecutiveFailures >= maxConsecutivePlaybackFailures) {
        // Не идём дальше по очереди из двухсот позиций без сети.
        await _player.pause();
        _publish(_snapshot.copyWith(resolving: false, playing: false));
        return;
      }
      await skipNext();
      return;
    }

    _consecutiveFailures = 0;
    AppLogger.instance.info(
      'playback: ${playback.usedSource.wire}/${playback.quality.wire} '
      '$localTrackId',
    );
    // Если что-то уже играет, старую песню гасим до подмены источника,
    // иначе слышен щелчок на склейке.
    if (_player.playing) await _fadeOut();
    await _load(playback.target, initialPosition: _pendingSeek);
    _pendingSeek = Duration.zero;
    await _player.setVolume(0);
    _publish(
      _snapshot.copyWith(
        resolving: false,
        usedSource: playback.usedSource,
        quality: playback.quality,
      ),
    );
    unawaited(_player.play());
    unawaited(_fadeIn());

    await _reportEvent(
      variants,
      playback.usedSource,
      PlaybackEventType.trackStarted,
      Duration.zero,
    );
    _startStallProbe(playback);
    _scheduleSnapshot();
    unawaited(_prefetchRadio());
  }

  Future<void> _load(
    StreamTarget target, {
    Duration initialPosition = Duration.zero,
  }) async {
    final position = initialPosition > Duration.zero ? initialPosition : null;
    switch (target) {
      case StreamFile(:final path):
        await _player.setFilePath(path, initialPosition: position);
      case StreamUrl(:final url, :final headers):
        await _player.setUrl(
          '$url',
          headers: headers.isEmpty ? null : headers,
          initialPosition: position,
        );
    }
  }

  Future<void> _onTrackFinished() async {
    await _reportCurrent(PlaybackEventType.trackFinished);
    await _saveSnapshotNow();
    if (_queue.repeat == PlaybackRepeat.one) {
      await _player.seek(Duration.zero);
      unawaited(_player.play());
      return;
    }
    final id = _queue.advance(manual: false);
    if (id == null) {
      // Волна не заканчивается: добираем следующую пачку у ротора, иначе
      // после пяти треков очередь упиралась в конец и стартовала заново.
      if (await _refillRadio(moveToFirstNew: true)) {
        await _playCurrent();
        return;
      }
      _emitServiceState(stopped: true);
      return;
    }
    _pendingSeek = Duration.zero;
    await _playCurrent();
  }

  /// Фоновая докачка волны, пока очередь ещё играет. Один запрос за раз,
  /// только когда до конца осталось мало треков.
  Future<void> _prefetchRadio() async {
    if (_sourceHint?['kind'] != 'radio') return;
    if (_queue.remainingAfterCurrent >= 3) return;
    await _refillRadio(moveToFirstNew: false);
  }

  /// Докачка очереди радио. Возвращает true, если появились новые треки.
  Future<bool> _refillRadio({bool moveToFirstNew = false}) async {
    if (_sourceHint?['kind'] != 'radio') return false;
    if (_radioRefillInFlight) return false;
    final source = _services.yandex;
    if (source == null) return false;

    _radioRefillInFlight = true;
    final station = '${_sourceHint?['station'] ?? 'user:onyourwave'}';
    try {
      final fetched = await source.station.waveMany(
        station: station,
        batches: 3,
        target: 15,
      );
      final tracks = _services.hideAiTracks
          ? [
              for (final track in fetched)
                if (!AiFilter.matches(track.title, track.artists)) track,
            ]
          : fetched;
      if (tracks.isEmpty) return false;
      final ids = await _services.db.tracksDao.ingestAll(tracks);
      if (!_queue.appendBatch(ids, moveToFirstNew: moveToFirstNew)) {
        // Ротор вернул то же самое — пробуем ещё раз на следующем треке.
        return false;
      }
      _publish(
        _snapshot.copyWith(
          queue: _queue.displayOrder,
          index: _queue.currentBaseIndex,
        ),
      );
      _emitServiceState();
      _saveSnapshotNow();
      return true;
    } on Object catch (error) {
      AppLogger.instance.warn('волна не докачалась: $error');
      return false;
    } finally {
      _radioRefillInFlight = false;
    }
  }

  Future<void> _reportCurrent(
    PlaybackEventType type, {
    Duration? forcePlayed,
  }) async {
    final localTrackId = _queue.currentId;
    final used = _snapshot.usedSource;
    if (localTrackId == null || used == null) return;

    final played = forcePlayed ?? _player.position;
    final variants = await _services.db.tracksDao.variantsOf(localTrackId);
    await _reportEvent(variants, used, type, played);

    await _services.db.historyDao.record(
      localTrackId: localTrackId,
      source: used,
      quality: _snapshot.quality ?? Quality.auto,
      played: played,
      completed: type == PlaybackEventType.trackFinished,
      skipReason: type == PlaybackEventType.skip ? 'manual' : null,
    );
  }

  Future<void> _reportEvent(
    List<SourceTrack> variants,
    SourceId usedSource,
    PlaybackEventType type,
    Duration played,
  ) async {
    final source = _services.registry.byId(usedSource);
    final variant = variants.where((v) => v.ref.source == usedSource).firstOrNull;
    if (source == null || variant == null || !source.capabilities.canReportPlay) {
      return;
    }
    try {
      await source.reportPlaybackEvent(variant, type, played);
    } on Object {
      // Отчёт прослушивания не имеет права ронять воспроизведение.
    }
  }

  /// Watchdog буфера: на Android 17 аудио-API отказывают молча, поэтому
  /// «тихо и бафферится» считаем симптомом протухшей подписи и перевалидируем.
  void _startStallProbe(ResolvedPlayback playback) {
    _stallProbe?.cancel();
    _stallSeconds = 0;
    _stallProbe = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_snapshot.playing || !_snapshot.buffering) return;
      final ahead = _player.bufferedPosition - _player.position;
      if (ahead >= bufferStallThreshold) {
        _stallSeconds = 0;
        return;
      }
      _stallSeconds++;
      if (_stallSeconds < bufferStallWindow.inSeconds) return;

      timer.cancel();
      _stallSeconds = 0;
      await _revalidate(resume: true);
    });
  }

  /// Самоизлечение: подпись ссылки могла истечь — выбрасываем кэш этого
  /// источника, перевалидируем и продолжаем с той же позиции.
  Future<void> _revalidate({required bool resume}) async {
    final localTrackId = _queue.currentId;
    if (localTrackId == null) return;
    final used = _snapshot.usedSource;
    if (used != null) {
      await _services.resolver.didLoseTrust(localTrackId, used);
    }

    final position = _player.position;
    final result = await _services.resolver.resolve(
      localTrackId: localTrackId,
      variants: await _services.db.tracksDao.variantsOf(localTrackId),
      quality: _services.defaultQuality,
      bypassCache: true,
    );
    final fresh = result.playback;
    if (fresh == null) {
      _publishIssue(
        PlayerIssue(result.failures, needsUserAction: result.needsUserAction),
      );
      return;
    }

    await _load(fresh.target);
    if (position > Duration.zero) await _player.seek(position);
    if (resume) unawaited(_player.play());
    _publish(
      _snapshot.copyWith(
        usedSource: fresh.usedSource,
        quality: fresh.quality,
      ),
    );
  }

  void _startPauseWatchdog() {
    _pauseWatchdog?.cancel();
    _pauseWatchdog = Timer(maxPausedServiceDuration, () async {
      // Держать mediaPlayback-сервис на паузе дольше 10 минут нельзя.
      await _player.stop();
      _emitServiceState(stopped: true);
      await _saveSnapshotNow();
    });
  }

  Future<bool> _restoreSnapshot() async {
    final row = await _services.db.queueDao.load(QueueDao.kindPlayer);
    final items = row == null ? const <String>[] : QueueDao.itemsOf(row);
    if (items.isEmpty || row == null) return false;

    _queue.setQueue(items, startIndex: row.queueIndex);
    _queue.setRepeat(_repeatFromWire(row.repeatMode));
    _queue.setShuffle(
      row.shuffleEnabled ? PlaybackShuffle.shuffled : PlaybackShuffle.ordered,
    );
    _sourceHint = QueueDao.hintOf(row);
    _pendingSeek = Duration(milliseconds: row.positionMs);
    _publish(
      _snapshot.copyWith(queue: _queue.displayOrder, index: _queue.displayPosition),
    );
    return true;
  }

  void _scheduleSnapshot() {
    _snapshotTimer?.cancel();
    _snapshotTimer = Timer(const Duration(seconds: 1), _saveSnapshotNow);
    _periodicSnapshot ??= Timer.periodic(
      const Duration(seconds: 30),
      (_) => _saveSnapshotNow(),
    );
  }

  Future<void> _saveSnapshotNow() async {
    if (_queue.items.isEmpty) return;
    await _services.db.queueDao.save(
      kind: QueueDao.kindPlayer,
      localTrackIds: _queue.items,
      index: _queue.currentBaseIndex,
      position: _player.position,
      repeatMode: _repeatToWire(_queue.repeat),
      shuffleEnabled: _queue.shuffle == PlaybackShuffle.shuffled,
      sourceHint: _sourceHint,
    );
  }

  void _publishIssue(PlayerIssue issue) =>
      _publish(_snapshot.copyWith(resolving: false, issue: issue));

  void _publish(PlayerSnapshot value) {
    _snapshot = value;
    if (!_snapshots.isClosed) _snapshots.add(value);
  }

  /// Наружу: состояние уведомления, транспорта и блокировки экрана.
  void _emitServiceState({bool stopped = false}) {
    final playing = stopped ? false : _snapshot.playing;
    playbackState.add(
      PlaybackState(
        processingState: switch (stopped) {
          true => AudioProcessingState.idle,
          false => switch (_snapshot.buffering) {
            true => AudioProcessingState.buffering,
            false => _snapshot.current == null
                ? AudioProcessingState.idle
                : AudioProcessingState.ready,
          },
        },
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: 1.0,
        repeatMode: _repeatToService(_queue.repeat),
        shuffleMode: _shuffleToService(_queue.shuffle),
        queueIndex: _queue.displayPosition < 0 ? null : _queue.displayPosition,
        controls: [
          MediaControl.skipToPrevious,
          if (stopped || !playing) MediaControl.play else MediaControl.pause,
          MediaControl.skipToNext,
          if (!stopped) MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
      ),
    );
  }

  Future<void> dispose() async {
    _stallProbe?.cancel();
    _pauseWatchdog?.cancel();
    _sleepTimer?.cancel();
    _snapshotTimer?.cancel();
    _periodicSnapshot?.cancel();
    await _saveSnapshotNow();
    await _snapshots.close();
    await _player.dispose();
    instance = null;
  }

  static AudioServiceRepeatMode _repeatToService(PlaybackRepeat value) =>
      switch (value) {
        PlaybackRepeat.none => AudioServiceRepeatMode.none,
        PlaybackRepeat.all => AudioServiceRepeatMode.all,
        PlaybackRepeat.one => AudioServiceRepeatMode.one,
      };

  static AudioServiceShuffleMode _shuffleToService(PlaybackShuffle value) =>
      value == PlaybackShuffle.shuffled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none;

  static PlaybackRepeat _repeatFromService(AudioServiceRepeatMode mode) =>
      switch (mode) {
        AudioServiceRepeatMode.all => PlaybackRepeat.all,
        AudioServiceRepeatMode.one => PlaybackRepeat.one,
        _ => PlaybackRepeat.none,
      };

  static PlaybackShuffle _shuffleFromService(AudioServiceShuffleMode mode) =>
      mode == AudioServiceShuffleMode.all
          ? PlaybackShuffle.shuffled
          : PlaybackShuffle.ordered;

  static String _repeatToWire(PlaybackRepeat value) => value.name;

  static PlaybackRepeat _repeatFromWire(String value) =>
      PlaybackRepeat.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PlaybackRepeat.none,
      );
}
