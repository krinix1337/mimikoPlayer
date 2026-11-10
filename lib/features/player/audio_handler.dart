import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../../app_services.dart';
import '../../core/constants.dart';
import '../../core/content/ai_filter.dart';
import '../../core/content/artist_blocklist.dart';
import 'wave_mix.dart';
import '../../core/content/censor_base.dart';
import '../../core/db/daos/tracks_dao.dart';
import '../../core/db/daos/queue_dao.dart';
import '../../core/logging/app_logger.dart';
import '../../core/sources/cross_source.dart';
import '../../core/sources/source_dto.dart';
import '../../core/sources/source_errors.dart';
import '../../core/sources/source_id.dart';
import '../../core/sources/stream_resolver.dart';
import '../../core/sources/stream_target.dart';
import '../../sources/soundcloud/soundcloud_source.dart';
import '../library/library_actions.dart';
import 'equalizer_presets.dart';
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
    _services.onEqualizerChanged = _syncEqualizer;
    unawaited(_syncEqualizer());
    _restoring = _restoreState();
    unawaited(_bindAudioSession());
  }

  /// Восстановление прошлой сессии: режимы, очередь, источник и позиция.
  /// play() ждёт его, чтобы кнопка гарнитуры на холодном старте не
  /// разошлась с ним.
  late final Future<void> _restoring;

  /// После перезапуска плеер сразу знает прошлую очередь: мини-плеер
  /// показывает трек, «играть» продолжает с сохранённой позиции, а заголовок
  /// источника («Любимое», волна) не теряется. Звук при этом не грузится.
  Future<void> _restoreState() async {
    try {
      final row = await _services.db.queueDao.load(QueueDao.kindPlayer);
      if (row == null) return;
      final repeat = _repeatFromWire(row.repeatMode);
      final shuffle = row.shuffleEnabled
          ? PlaybackShuffle.shuffled
          : PlaybackShuffle.ordered;
      final items = QueueDao.itemsOf(row);
      final index = row.queueIndex;
      final currentId = index >= 0 && index < items.length
          ? items[index]
          : null;
      final now = currentId == null ? null : await _nowPlayingOf(currentId);
      // Пока читали базу, пользователь мог уже включить что-то своё.
      if (_queue.items.isNotEmpty) {
        _queue.setRepeat(repeat);
        _publish(_snapshot.copyWith(repeat: repeat));
        return;
      }
      _queue.setRepeat(repeat);
      _queue.setShuffle(shuffle);
      if (now != null) {
        final hint = QueueDao.hintOf(row);
        _queue.setQueue(items, startIndex: index);
        _sourceHint = hint;
        _pendingSeek = Duration(milliseconds: row.positionMs);
      }
      _publish(
        _snapshot.copyWith(
          repeat: repeat,
          shuffle: shuffle,
          queue: _queue.displayOrder,
          index: _queue.displayPosition,
          current: now?.$1,
          duration: now?.$2,
          position: now == null ? null : _pendingSeek,
          liked: now?.$3,
          disliked: now?.$4,
          sourceKind: now == null ? null : '${_sourceHint?['kind'] ?? ''}',
          sourceTitle: now == null ? null : '${_sourceHint?['title'] ?? ''}',
          isRadio: now == null ? null : _isRadio,
        ),
      );
    } on Object catch (error) {
      AppLogger.instance.warn('прошлая очередь не восстановилась: $error');
    }
  }

  // --- аудиофокус ---------------------------------------------------------
  // Другое приложение заиграло (TikTok, YouTube, звонок) — встаём на паузу.
  // Сами возвращаемся только после звонка или совсем короткого звука
  // (уведомление): TikTok отпускает фокус между роликами, и со встроенной
  // логикой just_audio музыка каждый раз включалась поверх него.

  bool _resumeAfterInterruption = false;
  bool _interruptedByCall = false;
  bool _focusLost = false;
  DateTime? _interruptedAt;
  Timer? _resumeTimer;
  static const Duration _shortInterruption = Duration(seconds: 6);

  Future<void> _bindAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      session.interruptionEventStream.listen(_onInterruption);
      // Выдернули наушники — пауза, а не музыка из динамика.
      session.becomingNoisyEventStream.listen((_) {
        if (_wantPlaying) unawaited(pause());
      });
    } on Object catch (error) {
      AppLogger.instance.warn('аудиосессия не настроена: $error');
    }
  }

  void _onInterruption(AudioInterruptionEvent event) {
    final what = event.begin ? 'потерян' : 'вернулся';
    AppLogger.instance.info('аудиофокус: $what (${event.type.name})');
    if (event.begin) {
      _resumeTimer?.cancel();
      // Приглушение (навигатор, уведомление) система делает сама.
      if (event.type == AudioInterruptionType.duck) return;
      _focusLost = true;
      if (!_wantPlaying) return;
      // unknown — фокус забрали насовсем, возвращать музыку некому.
      _resumeAfterInterruption = event.type == AudioInterruptionType.pause;
      _interruptedAt = DateTime.now();
      _interruptedByCall = false;
      unawaited(_noteCall());
      unawaited(_pause());
      return;
    }
    if (event.type == AudioInterruptionType.duck) return;
    _focusLost = false;
    if (!_resumeAfterInterruption) return;
    _resumeAfterInterruption = false;
    final began = _interruptedAt;
    final short =
        began != null && DateTime.now().difference(began) <= _shortInterruption;
    if (!short && !_interruptedByCall) return;
    // Небольшая задержка: приложения нередко отпускают фокус и тут же берут
    // его снова — музыка не должна успеть моргнуть.
    _resumeTimer = Timer(const Duration(milliseconds: 700), () {
      if (!_wantPlaying && !_focusLost) unawaited(play());
    });
  }

  /// Звонок отличаем по режиму звука телефона: после него музыка
  /// возвращается, сколько бы он ни длился.
  Future<void> _noteCall() async {
    try {
      final mode = await AndroidAudioManager().getMode();
      _interruptedByCall = mode != AndroidAudioHardwareMode.normal;
    } on Object {
      // Не узнали — считаем обычным приложением.
    }
  }

  /// Пользователь сам включил музыку, пока фокус у другого приложения:
  /// прошлый запрос ещё числится «в ожидании», и новый системе не уходил —
  /// обе программы играли разом. Сбрасываем его, чтобы плеер запросил заново.
  Future<void> _reclaimFocus() async {
    if (!_focusLost) return;
    _focusLost = false;
    try {
      await (await AudioSession.instance).setActive(false);
    } on Object {
      // Фокус — вежливость, а не условие воспроизведения.
    }
  }

  /// Карточка трека для мини-плеера без загрузки звука.
  Future<(NowPlaying, Duration, bool, bool)?> _nowPlayingOf(String id) async {
    final db = _services.db;
    final track = await db.tracksDao.byId(id);
    if (track == null) return null;
    final artists = await db.tracksDao.artistNamesOf(id);
    final feedback = await db.libraryDao.likeState(id);
    return (
      NowPlaying(
        localTrackId: id,
        title: track.title.trim().isNotEmpty ? track.title : id,
        artist: artists.isEmpty ? _localFileLabel : artists.join(', '),
        coverUrl: track.coverUrl,
        explicitFlag: track.explicitFlag,
      ),
      Duration(seconds: track.durationSec),
      feedback == 1,
      feedback == -1,
    );
  }

  /// Язык подписей, которые видит система (уведомление, блокировка): у
  /// фонового плеера нет BuildContext, поэтому читаем настройку напрямую.
  bool get _english {
    final code =
        _services.localeCode ?? PlatformDispatcher.instance.locale.languageCode;
    return code == 'en';
  }

  String get _localFileLabel => _english ? 'Local file' : 'Локальный файл';

  static MusicBackgroundAudioHandler? instance;

  final AppServices _services;
  late AndroidEqualizer _equalizer;
  late AudioPlayer _player = _newPlayer();

  /// Плеер, который доигрывает конец прошлого трека, пока звучит следующий
  /// (кроссфейд). Живёт только на время перекрытия.
  AudioPlayer? _outgoing;
  final List<StreamSubscription<dynamic>> _playerSubs = [];

  /// Поколение, для которого кроссфейд уже запускался или отклонён: второй
  /// раз за один трек не пробуем.
  int _crossfadeHandledFor = -1;
  int _finishReportedFor = -1;
  static const Duration _crossfadeLead = Duration(milliseconds: 1800);

  /// Точки сведения текущего трека; null — сводим по длине трека.
  FadePoints? _currentFade;

  /// Длина перекрытия, выбранная при старте кроссфейда.
  Duration? _overlap;

  /// У каждого плеера свой эквалайзер: эффект привязан к аудиосессии плеера.
  AudioPlayer _newPlayer() {
    final equalizer = AndroidEqualizer();
    _equalizer = equalizer;
    return AudioPlayer(
      // Прерывания (звонок, другое приложение со звуком) разбирает сам
      // обработчик — см. [_onInterruption]: встроенная логика just_audio
      // возвращала музыку, как только другое приложение отпускало фокус.
      handleInterruptions: false,
      audioPipeline: AudioPipeline(androidAudioEffects: [equalizer]),
    );
  }

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
  Future<bool>? _radioRefill;

  /// Чего хочет пользователь, а не что сейчас делает just_audio: пауза,
  /// нажатая во время резолва, иначе терялась — трек догружался и играл.
  bool _wantPlaying = false;

  /// just_audio шлёт `completed` повторно (например, на pause() в конце
  /// очереди) — без флага трек засчитывался дважды.
  bool _completionHandled = false;

  /// Таймер сна вышел: встаём на паузу в конце текущего трека.
  bool _sleepAtTrackEnd = false;
  final Map<String, SourceTrack> _crossSourceMatches = {};
  final Set<String> _crossSourceSearched = {};

  /// Таймер сна: пауза после текущего трека, когда время вышло.
  /// null — выключить. Ставится только на реальное воспроизведение,
  /// поэтому «до конца трека» = до конца того, что играет сейчас.
  @override
  Future<void> sleepAfter(Duration? delay) async {
    _sleepTimer?.cancel();
    _sleepAtTrackEnd = false;
    if (delay == null) {
      AppLogger.instance.info('таймер сна выключен');
      _publish(_snapshot.copyWith(clearSleep: true));
      return;
    }
    _sleepTimer = Timer(delay, () {
      if (!_wantPlaying) {
        // Музыка уже стоит — цель таймера достигнута, отметку снимаем.
        _publish(_snapshot.copyWith(clearSleep: true));
        return;
      }
      AppLogger.instance.info('таймер сна: пауза после текущего трека');
      _sleepAtTrackEnd = true;
    });
    // Отметка видна в плеере: раньше нельзя было понять, включён ли таймер.
    _publish(_snapshot.copyWith(sleepAt: DateTime.now().add(delay)));
    AppLogger.instance.info('таймер сна: ${delay.inMinutes} мин');
  }

  /// Сколько трек реально звучал. Раньше в историю писалась позиция в
  /// момент перехода: перемотал на 3:00 — засчитано три минуты.
  final Stopwatch _listened = Stopwatch();
  String? _listenedTrack;

  /// Забрать накопленное время прослушивания текущего трека и обнулить его.
  Duration _takeListened() {
    final value = _listened.elapsed;
    _listened.reset();
    return value;
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
    _wantPlaying = true;
    AppLogger.instance.info(
      'playQueue x${localTrackIds.length} idx=$startIndex hint=$sourceHint',
    );
    _sourceHint = sourceHint;
    _publish(
      _snapshot.copyWith(
        sourceKind: '${sourceHint?['kind'] ?? ''}',
        sourceTitle: '${sourceHint?['title'] ?? ''}',
        isRadio: sourceHint?['kind'] == 'radio',
      ),
    );
    // Тот же трек, который уже стоит в плеере: очередь переставляем под него,
    // а позицию не трогаем. Иначе повторный тап по строке сбрасывает минуту
    // прослушанного в ноль.
    final started = startIndex >= 0 && startIndex < localTrackIds.length
        ? localTrackIds[startIndex]
        : null;
    if (started != null &&
        started == _snapshot.current?.localTrackId &&
        _player.processingState != ProcessingState.idle) {
      _queue.setQueue(localTrackIds, startIndex: startIndex);
      _publish(
        _snapshot.copyWith(
          queue: _queue.displayOrder,
          index: _queue.displayPosition,
        ),
      );
      if (!_snapshot.playing) await play();
      return;
    }

    // Трек, который играл до нового списка, тоже прослушан: без отчёта он
    // пропадал из истории, статистики и рекомендаций.
    if (_snapshot.current != null) _reportCurrent(PlaybackEventType.skip);
    _pendingSeek = Duration.zero;
    _queue.setQueue(localTrackIds, startIndex: startIndex);
    _consecutiveFailures = 0;
    _generation++;
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
        artist: artists.isEmpty ? _localFileLabel : artists.join(', '),
        artUri: _artUri(await _coverFor(localTrackId, track?.coverUrl)),
        duration: Duration(seconds: track?.durationSec ?? 0),
      ),
    );
  }

  static Uri? _artUri(String? value) =>
      value == null || value.isEmpty ? null : Uri.tryParse(value);

  /// Обложка трека: у скачанного — файл на диске, иначе ссылка каталога.
  /// Так картинка не качается заново, и без интернета не пропадает.
  Future<String?> _coverFor(String localTrackId, String? remote) async {
    final row = await _services.db.streamsDao.downloadedFile(localTrackId);
    final path = row?.coverPath;
    if (row != null &&
        row.state == 'complete' &&
        path != null &&
        File(path).existsSync()) {
      return Uri.file(path).toString();
    }
    return remote;
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
        artist: artists.isEmpty ? _localFileLabel : artists.join(', '),
        artUri: _artUri(await _coverFor(localTrackId, track?.coverUrl)),
        duration: Duration(seconds: track?.durationSec ?? 0),
      ),
    );
  }

  @override
  Future<void> refreshLikedState() async {
    final localTrackId = _queue.currentId;
    if (localTrackId == null) return;
    final feedback = await _services.db.libraryDao.likeState(localTrackId);
    final liked = feedback == 1;
    final disliked = feedback == -1;
    if (_snapshot.liked != liked || _snapshot.disliked != disliked) {
      _publish(_snapshot.copyWith(liked: liked, disliked: disliked));
      _emitServiceState();
    }
  }

  @override
  Future<void> skipNext() async {
    _wantPlaying = true;
    _reportCurrent(PlaybackEventType.skip);
    final id = await _nextTrack();
    if (id == null) {
      // Пропуск уже записан выше — второй отчёт из stop() давал дубль.
      await _stop(report: false);
      return;
    }
    _pendingSeek = Duration.zero;
    _generation++;
    await _playCurrent();
  }

  @override
  Future<void> dropCurrent() async {
    final position = _queue.displayPosition;
    if (position < 0) return;
    _reportCurrent(PlaybackEventType.skip);
    final next = await _nextTrack();
    // Дизлайкнутый трек уходит из очереди в любом случае; позиция
    // следующего сдвигается сама, если он стоял ниже.
    _queue.removeAt(position);
    if (next == null || _queue.currentId == null) {
      await _stop(report: false);
      return;
    }
    _pendingSeek = Duration.zero;
    _generation++;
    await _playCurrent();
  }

  bool get _isRadio => _sourceHint?['kind'] == 'radio';

  /// Следующий трек для «вперёд» и автоперехода. Волна в конце очереди
  /// докачивает новую пачку, а не заворачивает на первый трек (с повтором
  /// очереди она так и крутила одни и те же песни). Дизлайкнутые треки
  /// сами не играют — их пропускаем в любой очереди.
  Future<String?> _nextTrack() async {
    final limit = _queue.items.length + 1;
    for (var guard = 0; guard <= limit; guard++) {
      final String? id;
      if (_isRadio && _queue.remainingAfterCurrent == 0) {
        id = await _refillRadio(moveToFirstNew: true) ? _queue.currentId : null;
      } else {
        id = _queue.advance();
      }
      if (id == null) return null;
      if (await _services.db.libraryDao.likeState(id) == -1) continue;
      // Исполнитель в чёрном списке: трек пропускаем, как и дизлайкнутый.
      final artists = await _services.db.tracksDao.artistNamesOf(id);
      if (ArtistBlocklist.instance.isBlocked(artists)) continue;
      return id;
    }
    return null;
  }

  /// Трек не зарезолвился: идём дальше, не трогая [_wantPlaying] и не
  /// записывая «пропуск» — трек не играл ни секунды.
  Future<void> _skipFailed() async {
    final id = await _nextTrack();
    if (id == null) {
      await _stop(report: false);
      return;
    }
    _pendingSeek = Duration.zero;
    _generation++;
    await _playCurrent();
  }

  @override
  Future<void> skipPrevious() async {
    if (_player.position > previousRestartThreshold) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_queue.isEmpty) return;
    _reportCurrent(PlaybackEventType.skip);
    final id = _queue.rewind();
    if (id == null) return;
    _wantPlaying = true;
    _pendingSeek = Duration.zero;
    _generation++;
    await _playCurrent();
  }

  @override
  Future<void> skipToIndex(int displayIndex) async {
    if (displayIndex < 0 || displayIndex >= _queue.items.length) return;
    // Свайп обложки и выбор в очереди — такой же переход, как «дальше»:
    // прослушанный трек должен попасть в историю и в статистику.
    if (displayIndex != _queue.displayPosition) {
      _reportCurrent(PlaybackEventType.skip);
    }
    final id = _queue.jumpToPosition(displayIndex);
    if (id == null) return;
    _wantPlaying = true;
    _pendingSeek = Duration.zero;
    _generation++;
    await _playCurrent();
  }

  @override
  Future<void> setRepeat(PlaybackRepeat value) async {
    _queue.setRepeat(value);
    _publish(_snapshot.copyWith(repeat: value));
    _emitServiceState();
    // Сразу, без debounce: приложение могли закрыть через секунду.
    await _saveSnapshotNow();
  }

  @override
  Future<void> setShuffle(PlaybackShuffle value) async {
    _queue.setShuffle(value);
    _publish(
      _snapshot.copyWith(
        queue: _queue.displayOrder,
        index: _queue.displayPosition,
        shuffle: value,
      ),
    );
    _emitServiceState();
    await _saveSnapshotNow();
  }

  @override
  Future<void> stop() => _stop();

  Future<void> _stop({bool report = true}) async {
    _generation++;
    _wantPlaying = false;
    _killOutgoing();
    _sleepTimer?.cancel();
    _sleepAtTrackEnd = false;
    _pauseWatchdog?.cancel();
    _stallProbe?.cancel();
    await _fadeOut();
    await _player.stop();
    await _setVolume(1);
    if (report) _reportCurrent(PlaybackEventType.skip);
    mediaItem.add(null);
    _publish(
      _snapshot.copyWith(
        playing: false,
        buffering: false,
        position: Duration.zero,
        resolving: false,
        clearCurrent: true,
        sourceKind: '',
        sourceTitle: '',
        clearSleep: true,
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
    _resumeAfterInterruption = false;
    _resumeTimer?.cancel();
    await _restoring;
    if (_queue.currentId == null && !(await _restoreSnapshot())) return;
    _wantPlaying = true;
    // Новый трек ещё резолвится: он сам стартует, увидев [_wantPlaying].
    // Иначе play() запускал старый трек, который ещё стоит в плеере.
    if (_snapshot.resolving) return;
    if (_player.processingState == ProcessingState.idle) {
      await _playCurrent();
      return;
    }
    // Очередь доиграла: play() на конце файла ничего не воспроизводит,
    // а кнопка застревала в «играет». Начинаем трек сначала.
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    _pauseWatchdog?.cancel();
    await _reclaimFocus();
    if (!_wantPlaying) return;
    if (_player.playing) {
      // «Играть» нажали, пока пауза ещё гасила звук: плеер не успел
      // остановиться — просто возвращаем громкость с того же места.
      _publish(_snapshot.copyWith(playing: true));
      _emitServiceState();
      unawaited(_fadeIn());
      return;
    }
    await _setVolume(0);
    // Пауза успела прийти, пока ставилась громкость: без проверки трек
    // всё равно запускался, и быстрое «играть→пауза» оставляло музыку.
    if (!_wantPlaying) {
      await _setVolume(1);
      return;
    }
    // just_audio резолвит play() только на паузе или в конце трека: ждать
    // его — значит повесить вызов на всю длину песни.
    _startPlayback();
    unawaited(_fadeIn());
  }

  /// Пауза по воле пользователя (кнопка, уведомление, гарнитура): после неё
  /// музыка сама не возвращается, даже если её прервало другое приложение.
  @override
  Future<void> pause() {
    _resumeAfterInterruption = false;
    _resumeTimer?.cancel();
    return _pause();
  }

  Future<void> _pause() async {
    _wantPlaying = false;
    // Пауза посреди кроссфейда останавливает и уходящий трек.
    _killOutgoing();
    // Кнопка меняется сразу, а не после затухания: раньше значок паузы
    // переключался на четверть секунды позже нажатия.
    _publish(_snapshot.copyWith(playing: false));
    _emitServiceState();
    // Гасим до паузы и возвращаем громкость уже после неё: в обратном
    // порядке между вызовами проскакивал кусок на полной громкости.
    await _fadeOut();
    // Пока гасили, снова нажали «играть».
    if (_wantPlaying) return;
    await _player.pause();
    if (_wantPlaying) return;
    await _setVolume(1);
    _startPauseWatchdog();
    // Позиция паузы сразу в базу: процесс могут убить раньше 30-секундного
    // автосохранения.
    _scheduleSnapshot();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _scheduleSnapshot();
  }

  @override
  Future<void> skipToNext() => skipNext();

  @override
  Future<void> skipToPrevious() => skipPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    await skipToIndex(index);
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    final localTrackId = _queue.currentId;
    if (localTrackId == null) return null;
    final actions = LibraryActions(_services);
    final state = await actions.feedbackOf(localTrackId);
    final next = switch (name) {
      'like' => state == 1 ? 0 : 1,
      'dislike' => state == -1 ? 0 : -1,
      _ => null,
    };
    if (next == null) return null;
    await actions.setFeedback(localTrackId, next);
    if (next == -1) {
      // Дизлайк из уведомления работает так же, как в плеере: трек уходит.
      await dropCurrent();
      return null;
    }
    await refreshLikedState();
    _emitServiceState();
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // playNext уже вставил трек в очередь — повторный append давал дубль.
    if (!_queue.items.contains(mediaItem.id)) _queue.append(mediaItem.id);
    _publish(
      _snapshot.copyWith(
        queue: _queue.displayOrder,
        index: _queue.displayPosition,
      ),
    );
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
  Future<void> removeQueueItem(MediaItem mediaItem) =>
      _afterRemoval(_queue.remove(mediaItem.id));

  @override
  Future<void> removeQueueItemAt(int index) =>
      _afterRemoval(_queue.removeAt(index));

  /// Убрали текущий трек — переключаемся на тот, что встал на его место,
  /// иначе плеер доигрывал уже удалённую песню.
  Future<void> _afterRemoval(bool removedCurrent) async {
    if (removedCurrent) {
      if (_queue.currentId == null) {
        await _stop(report: false);
        return;
      }
      _pendingSeek = Duration.zero;
      _generation++;
      await _playCurrent();
      return;
    }
    _publish(
      _snapshot.copyWith(
        queue: _queue.displayOrder,
        index: _queue.displayPosition,
      ),
    );
    _emitServiceState();
    _scheduleSnapshot();
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

  void _unbindPlayer() {
    for (final subscription in _playerSubs) {
      unawaited(subscription.cancel());
    }
    _playerSubs.clear();
  }

  void _bindPlayer() {
    _unbindPlayer();
    final player = _player;
    _playerSubs.addAll([
      player.playerStateStream.listen((state) {
        final completed = state.processingState == ProcessingState.completed;
        if (state.playing && state.processingState == ProcessingState.ready) {
          _listened.start();
        } else {
          _listened.stop();
        }
        _publish(
          _snapshot.copyWith(
            // Пока пауза гасит звук, плеер ещё «играет», а кнопка уже нет.
            playing: state.playing && _wantPlaying,
            buffering:
                state.processingState == ProcessingState.loading ||
                state.processingState == ProcessingState.buffering,
          ),
        );
        _emitServiceState();
        if (!completed) {
          _completionHandled = false;
        } else if (!_completionHandled) {
          _completionHandled = true;
          unawaited(_onTrackFinished());
        }
      }),
      player.positionStream.listen((position) {
        _publish(_snapshot.copyWith(position: position));
        _maybeCrossfade(position);
      }),
      player.durationStream.listen(
        (duration) =>
            _publish(_snapshot.copyWith(duration: duration ?? Duration.zero)),
      ),
      player.sequenceStateStream.listen((_) => _scheduleSnapshot()),
      // just_audio сообщает об ошибке уже загруженного потока в errorStream
      // (плюс дублирует её в errorCode события). Без этой подписки обрыв
      // стриминга проходил молча: обработчик ниже ловил только ошибки загрузки.
      player.errorStream.listen(
        _onStreamError,
        onError: (Object error, StackTrace _) => _onStreamError(error),
      ),
      player.playbackEventStream.listen(
        null,
        onError: (Object error, StackTrace _) => _onStreamError(error),
      ),
    ]);
  }

  // --- кроссфейд ----------------------------------------------------------
  // Конец трека перекрывается началом следующего: за несколько секунд до
  // конца следующий трек резолвится и стартует во втором плеере, громкости
  // сводятся, и второй плеер становится основным.

  void _maybeCrossfade(Duration position) {
    final seconds = _services.crossfadeSeconds;
    if (seconds <= 0 || !_wantPlaying || !_snapshot.playing) return;
    if (_snapshot.resolving || _crossfadeHandledFor == _generation) return;
    if (_crossfadeStarting) return;
    if (_queue.repeat == PlaybackRepeat.one || _sleepAtTrackEnd) return;
    if (_queue.items.length < 2) return;
    if (!_isRadio &&
        _queue.repeat == PlaybackRepeat.none &&
        _queue.remainingAfterCurrent == 0) {
      return;
    }
    final duration = _player.duration;
    // Короткие треки целиком не перекрываем.
    if (duration == null || duration < Duration(seconds: seconds * 3)) return;
    final setting = Duration(seconds: seconds);
    // Сводим там, где у трека начинается концовка, а не по таймеру от конца:
    // иначе перекрытие приходится на последний припев или на тишину.
    final out = _currentFade?.outStart;
    final useFade =
        out != null &&
        out > duration * 0.5 &&
        out < duration - const Duration(milliseconds: 500);
    final Duration startAt;
    final Duration overlap;
    if (useFade) {
      final end = _currentFade!.outStop;
      final last = end != null && end > out && end <= duration ? end : duration;
      final tail = last - out;
      overlap = tail < const Duration(seconds: 2)
          ? const Duration(seconds: 2)
          : tail > setting
          ? setting
          : tail;
      // Концовка длиннее перекрытия — сводим в её конце, а не в начале:
      // иначе трек обрывался, не доиграв остаток.
      startAt = last - overlap;
    } else {
      overlap = setting;
      startAt = duration - setting;
    }
    // Резолв следующего трека занимает время: начинаем чуть раньше.
    if (position < startAt - _crossfadeLead || position >= duration) return;
    _overlap = overlap;
    _crossfadeHandledFor = _generation;
    unawaited(_startCrossfade());
  }

  /// Сведение уже готовится: следующий трек выбран, но ещё не загружен.
  /// В этот промежуток поколение уже новое, а играет ещё старый трек — без
  /// флага сведение иногда запускалось второй раз и перескакивало через трек.
  bool _crossfadeStarting = false;

  Future<void> _startCrossfade() async {
    _crossfadeStarting = true;
    try {
      await _crossfadeToNext();
    } finally {
      _crossfadeStarting = false;
    }
  }

  Future<void> _crossfadeToNext() async {
    // Отчёт о прослушанном делаем до перехода очереди: он берёт текущий трек.
    _finishReportedFor = _generation;
    _reportCurrent(PlaybackEventType.trackFinished);
    final next = await _nextTrack();
    // Следующего нет — трек доиграет сам, обычным путём.
    if (next == null) return;
    // Тишину в начале следующего трека пропускаем: иначе первые секунды
    // сведения уходят в пустоту, и кажется, что трек просто стих.
    final inStart = (await _services.db.tracksDao.fadePointsOf(next))?.inStart;
    _pendingSeek =
        inStart != null &&
            inStart > const Duration(milliseconds: 300) &&
            inStart < const Duration(seconds: 8)
        ? inStart
        : Duration.zero;
    _generation++;
    await _playCurrent(crossfade: true);
  }

  /// Основной плеер уходит в [_outgoing], а вместо него встаёт новый.
  AudioPlayer _swapToFreshPlayer() {
    _killOutgoing();
    final old = _player;
    _unbindPlayer();
    _player = _newPlayer();
    _rampToken++;
    _volume = 1;
    _outgoing = old;
    _completionHandled = false;
    _bindPlayer();
    return old;
  }

  void _killOutgoing() {
    final old = _outgoing;
    if (old == null) return;
    _outgoing = null;
    unawaited(() async {
      try {
        await old.stop();
        await old.dispose();
      } on Object {
        // Уходящий плеер уже ничего не значит.
      }
    }());
  }

  /// Сведение: новый трек выходит на полную громкость быстро (к концу своего
  /// вступления или к 40% перекрытия), а старый плавно уходит под него.
  /// Раньше обе кривые шли симметрично на всю длину, и вокал в начале
  /// следующего трека тонул: казалось, что старый просто стих.
  Future<void> _crossRamp(AudioPlayer old, AudioPlayer incoming) async {
    var length = _overlap ?? Duration(seconds: _services.crossfadeSeconds);
    _overlap = null;
    final left = (old.duration ?? Duration.zero) - old.position;
    // Прошлый трек кончается раньше — сводим за оставшееся время.
    if (left > Duration.zero && left < length) length = left;
    if (length < const Duration(milliseconds: 400)) {
      length = const Duration(milliseconds: 400);
    }
    // Доля перекрытия, за которую новый трек набирает полную громкость.
    // _currentFade к этому моменту уже от нового трека.
    final intro = _currentFade?.inStop;
    var rise = 0.4;
    if (intro != null && intro > Duration.zero) {
      rise = (intro.inMilliseconds / length.inMilliseconds).clamp(0.25, 0.8);
    }
    const stepMs = 30;
    final started = DateTime.now();
    final token = _rampToken;
    while (true) {
      // Паузу, стоп или другой трек нажали посреди сведения — прекращаем.
      if (_outgoing != old || _player != incoming || token != _rampToken) {
        return;
      }
      // Время берём по часам: setVolume на канале не мгновенный, и счёт по
      // шагам растягивал сведение.
      final t =
          (DateTime.now().difference(started).inMilliseconds /
                  length.inMilliseconds)
              .clamp(0.0, 1.0);
      final inV = math.sin((t / rise).clamp(0.0, 1.0) * math.pi / 2);
      final outV = math.pow(math.cos(t * math.pi / 2), 1.6).toDouble();
      // Пауза или пропуск посреди сведения гасят звук от этой громкости.
      _volume = inV;
      await Future.wait([old.setVolume(outV), incoming.setVolume(inV)]);
      if (t >= 1) break;
      await Future<void>.delayed(const Duration(milliseconds: stepMs));
    }
    if (_outgoing == old) _killOutgoing();
    if (_player == incoming && token == _rampToken) await _setVolume(1);
  }

  /// Перевалидировать протухшую ссылку и продолжить с той же позиции.
  /// Во время первого резолва ошибку уже обрабатывает `_playCurrent`.
  void _onStreamError(Object error) {
    if (_snapshot.resolving || _snapshot.current == null) return;
    AppLogger.instance.warn('поток прервался: $error');
    _publishIssue(
      PlayerIssue([
        SourceFailure(
          source: _snapshot.usedSource ?? SourceId.local,
          reason: SourceFailReason.network,
          message: '$error',
        ),
      ], needsUserAction: false),
    );
    unawaited(_revalidate(resume: _snapshot.playing));
  }

  /// `play()` резолвится только на паузе или в конце трека, поэтому ждать его
  /// нельзя; но и оставлять future без обработчика нельзя — ошибка платформы
  /// уходила в необработанный async error.
  void _startPlayback() {
    unawaited(
      _player.play().catchError((Object error, StackTrace _) {
        _onStreamError(error);
      }),
    );
  }

  /// Плавное затухание. Шаги по 16 мс: media3 меняет громкость дёшево, а
  /// короче 250 мс фейд на колонках уже слыщен как щелчок.
  static const Duration _fadeUp = Duration(milliseconds: 320);
  static const Duration _fadeDown = Duration(milliseconds: 240);

  /// Громкость, выставленная основному плееру последней. Затухание всегда
  /// идёт от неё, а не от «единицы»: раньше пауза или новый трек посреди
  /// нарастания (или поверх тихо загруженного трека) сначала дёргали
  /// громкость на максимум — на долю секунды звук становился резким.
  double _volume = 1;

  /// Номер последней команды громкости: начатое раньше изменение, увидев
  /// чужой номер, останавливается, а не спорит с новым.
  int _rampToken = 0;

  Future<void> _setVolume(double value) {
    _rampToken++;
    _volume = value;
    return _player.setVolume(value);
  }

  /// Плавно довести громкость до [to]. false — изменение перебили другим.
  Future<bool> _rampTo(double to, Duration over) async {
    final token = ++_rampToken;
    final player = _player;
    final from = _volume;
    final span = (to - from).abs();
    if (!_services.fadeEnabled || span < 0.01) {
      _volume = to;
      await player.setVolume(to);
      return token == _rampToken;
    }
    // Часть пути — та же часть времени: с полпути гасим вдвое быстрее.
    final lengthMs = (over.inMilliseconds * span).clamp(40, 2000);
    final started = DateTime.now();
    while (true) {
      if (token != _rampToken || !identical(player, _player)) return false;
      // По часам, а не по шагам: вызов громкости не мгновенный.
      final t = (DateTime.now().difference(started).inMilliseconds / lengthMs)
          .clamp(0.0, 1.0);
      _volume = from + (to - from) * t;
      await player.setVolume(_volume);
      if (t >= 1) return token == _rampToken;
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  Future<bool> _fadeIn() => _rampTo(1, _fadeUp);

  Future<bool> _fadeOut() => _rampTo(0, _fadeDown);

  /// Растёт на каждый новый старт/стоп: поздний резолв старого трека видит
  /// чужое поколение и молча выходит, а не играет поверх паузы.
  int _generation = 0;

  Future<void> _playCurrent({bool crossfade = false}) async {
    final generation = _generation;
    _pauseWatchdog?.cancel();
    // Обычный переход (тап, пропуск) обрывает перекрытие, а не ждёт его.
    if (!crossfade) _killOutgoing();
    final localTrackId = _queue.currentId;
    if (localTrackId == null) return;
    // Новый трек копит своё время с нуля; тот же (после долгой паузы) —
    // продолжает.
    if (_listenedTrack != localTrackId) {
      _listened.reset();
      _listenedTrack = localTrackId;
    }

    final db = _services.db;
    final track = await db.tracksDao.byId(localTrackId);
    final artists = await db.tracksDao.artistNamesOf(localTrackId);
    final title = track?.title.trim().isNotEmpty == true
        ? track!.title
        : localTrackId;
    final artist = artists.isEmpty ? _localFileLabel : artists.join(', ');
    final feedback = await db.libraryDao.likeState(localTrackId);
    final liked = feedback == 1;
    final disliked = feedback == -1;
    final artistRemoteIds =
        (await db.libraryDao.artistRemoteIdsForTracks([
          localTrackId,
        ]))[localTrackId] ??
        const <String>[];
    final isAi = AiFilter.instance.isAiLocal(title, artists, artistRemoteIds);
    // У скачанного трека обложка уже лежит файлом: берём её, а не качаем
    // картинку заново (и без интернета плеер не остаётся с заглушкой).
    final coverUrl = await _coverFor(localTrackId, track?.coverUrl);
    // Пока читали базу, могли переключить трек: не перетираем его карточку.
    if (generation != _generation) return;

    mediaItem.add(
      MediaItem(
        id: localTrackId,
        title: title,
        artist: artist,
        // tryParse: битая ссылка на обложку не должна ронять запуск трека.
        artUri: coverUrl == null ? null : Uri.tryParse(coverUrl),
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
          coverUrl: coverUrl,
          explicitFlag: track?.explicitFlag ?? false,
          isAi: isAi,
        ),
        queue: _queue.displayOrder,
        index: _queue.displayPosition,
        resolving: true,
        uncensored: false,
        // Источник прошлого трека не должен попасть в отчёт об этом:
        // без сброса несыгравший трек писался в историю как «пропуск».
        clearSource: true,
        duration: Duration(seconds: track?.durationSec ?? 0),
        liked: liked,
        disliked: disliked,
        clearIssue: true,
      ),
    );

    _currentFade = await db.tracksDao.fadePointsOf(localTrackId);
    final variants = await db.tracksDao.variantsOf(localTrackId);
    final result = await _services.resolver.resolve(
      localTrackId: localTrackId,
      variants: variants,
      quality: _services.defaultQuality,
    );

    // Пока резолвили, пользователь мог включить другой трек: отказ этого
    // не должен пропускать уже выбранный.
    if (generation != _generation) return;

    var playback = result.playback;
    if (playback == null &&
        !result.needsUserAction &&
        result.failures.any(worthCrossSource)) {
      playback = await _crossSourcePlayback(
        localTrackId,
        title: title,
        artists: artists,
        duration: Duration(seconds: track?.durationSec ?? 0),
        skip: {for (final failure in result.failures) failure.source},
      );
    }

    if (generation != _generation) return;

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
        _wantPlaying = false;
        await _player.pause();
        _publish(_snapshot.copyWith(resolving: false, playing: false));
        return;
      }
      await _skipFailed();
      return;
    }

    _consecutiveFailures = 0;
    AppLogger.instance.info(
      'playback: ${playback.usedSource.wire}/${playback.quality.wire} '
      '$localTrackId',
    );
    // Если что-то уже играет, старую песню гасим до подмены источника,
    // иначе слышен щелчок на склейке. При кроссфейде старый трек не гасим:
    // он доигрывает в отдельном плеере.
    if (!crossfade && _player.playing) await _fadeOut();
    // Пока резолвили/грузили, могли нажать паузу, стоп или другой трек.
    if (generation != _generation) return;
    final faded = crossfade ? _swapToFreshPlayer() : null;
    try {
      await _load(playback.target, initialPosition: _pendingSeek);
    } on Object catch (error) {
      // Без этого исключение уходило наружу: `resolving` висел true,
      // громкость оставалась на нуле, а плеер — на прошлом треке.
      AppLogger.instance.warn('playback: не загрузился $localTrackId: $error');
      _pendingSeek = Duration.zero;
      if (faded != null) {
        // Уходящий плеер уже отвязан и сам не продолжит очередь.
        _killOutgoing();
        if (generation == _generation) await _skipFailed();
        return;
      }
      await _setVolume(1);
      if (generation == _generation) {
        _publish(_snapshot.copyWith(resolving: false));
      }
      return;
    }
    if (generation != _generation) {
      _killOutgoing();
      return;
    }
    _pendingSeek = Duration.zero;
    // Скачанный файл мог лечь до того, как трек появился в базе без цензуры:
    // тогда в нём цензура, и метку берём из пометки загрузки.
    final uncensored = playback.usedSource == SourceId.local
        ? _playsUncensored(variants) &&
              await db.streamsDao.downloadIsUncensored(localTrackId)
        : _playsUncensored(variants);
    if (generation != _generation) return;
    _publish(
      _snapshot.copyWith(
        resolving: false,
        usedSource: playback.usedSource,
        quality: playback.quality,
        uncensored: uncensored,
      ),
    );
    if (!_wantPlaying) {
      // Паузу нажали, пока трек грузился: оставляем его готовым, но тихим.
      _killOutgoing();
      await _setVolume(1);
      _startPauseWatchdog();
      _startStallProbe();
      _scheduleSnapshot();
      return;
    }
    // Новый плеер (кроссфейд, первый запуск) — новая аудиосессия: пока
    // эквалайзер на неё не встал, первая секунда звучала без него и
    // громкость прыгала. Ждём применения, но не дольше 800 мс.
    if (!identical(_equalizerSyncedFor, _player)) {
      await _syncEqualizer().timeout(
        const Duration(milliseconds: 800),
        onTimeout: () {},
      );
      if (generation != _generation) return;
    }
    await _reclaimFocus();
    await _setVolume(0);
    if (generation != _generation) return;
    _startPlayback();
    if (faded != null) {
      unawaited(_crossRamp(faded, _player));
    } else {
      unawaited(_fadeIn());
    }

    final startedFrom = playback.usedSource;
    _enqueueReport(
      () => _reportEvent(
        variants,
        startedFrom,
        PlaybackEventType.trackStarted,
        Duration.zero,
      ),
    );
    _startStallProbe();
    _scheduleSnapshot();
    unawaited(_prefetchRadio().whenComplete(() => _prefetchNext(generation)));
  }

  /// Пока играет текущий трек, заранее резолвим следующий и прогреваем
  /// начало файла: на переходе ссылка берётся из кэша резолвера, и трек
  /// не молчит пару секунд, пока идут download-info и первый буфер.
  Future<void> _prefetchNext(int generation) async {
    // Даём текущему треку спокойно набрать буфер.
    await Future<void>.delayed(const Duration(seconds: 4));
    if (generation != _generation) return;
    for (final id in _queue.peekAhead(3)) {
      if (await _services.db.libraryDao.likeState(id) == -1) continue;
      final artists = await _services.db.tracksDao.artistNamesOf(id);
      if (ArtistBlocklist.instance.isBlocked(artists)) continue;
      try {
        final variants = await _services.db.tracksDao.variantsOf(id);
        final result = await _services.resolver.resolve(
          localTrackId: id,
          variants: variants,
          quality: _services.defaultQuality,
        );
        if (generation != _generation) return;
        if (result.playback?.target case StreamUrl(
          :final url,
          :final headers,
        )) {
          await _warmStream(url, headers);
        }
      } on Object catch (error) {
        AppLogger.instance.warn('предзагрузка $id: $error');
      }
      return;
    }
  }

  /// Первые ~512 КБ следующего трека: соединение с CDN и его кэш уже
  /// прогреты, когда плеер попросит файл.
  Future<void> _warmStream(Uri url, Map<String, String> headers) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.getUrl(url);
      headers.forEach(request.headers.set);
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-524287');
      final response = await request.close();
      await response.drain<void>();
    } on Object {
      // Прогрев — подсказка, не обязанность.
    } finally {
      client.close(force: true);
    }
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
    // Кроссфейд уже записал окончание этого трека, не дублируем.
    if (_finishReportedFor != _generation) {
      _reportCurrent(PlaybackEventType.trackFinished);
    }
    await _saveSnapshotNow();
    if (_sleepAtTrackEnd) {
      // Таймер сна: следующий трек ставим, но не запускаем.
      _sleepAtTrackEnd = false;
      _wantPlaying = false;
      _publish(_snapshot.copyWith(clearSleep: true));
      AppLogger.instance.info('таймер сна: пауза');
      final next = _queue.repeat == PlaybackRepeat.one
          ? _queue.currentId
          : await _nextTrack();
      await _player.pause();
      if (next == null) {
        await _player.seek(Duration.zero);
        _publish(_snapshot.copyWith(playing: false));
        _emitServiceState(stopped: true);
        return;
      }
      _pendingSeek = Duration.zero;
      _generation++;
      await _playCurrent();
      return;
    }
    if (_queue.repeat == PlaybackRepeat.one) {
      await _player.seek(Duration.zero);
      _startPlayback();
      return;
    }
    // Волна в конце очереди докачивается внутри [_nextTrack].
    final id = await _nextTrack();
    if (id == null) {
      // just_audio оставляет playing=true после конца очереди, и кнопка
      // play дальше ничего не делала.
      _wantPlaying = false;
      await _player.pause();
      _publish(_snapshot.copyWith(playing: false));
      _emitServiceState(stopped: true);
      return;
    }
    _pendingSeek = Duration.zero;
    _generation++;
    await _playCurrent();
  }

  /// Фоновая докачка волны, пока очередь ещё играет. Один запрос за раз,
  /// только когда до конца осталось мало треков.
  Future<void> _prefetchRadio() async {
    if (_sourceHint?['kind'] != 'radio') return;
    if (_queue.remainingAfterCurrent >= 3) return;
    await _refillRadio(moveToFirstNew: false);
  }

  /// Докачка волны «SoundCloud»: похожие на последние треки SoundCloud в
  /// очереди. Пустой список — пусть волна докачается Яндексом, но не встанет.
  Future<List<SourceTrack>> _soundCloudRefill() async {
    final source = _services.registry.byId(SourceId.soundcloud);
    if (source is! SoundCloudSource) return const [];
    final order = _queue.displayOrder;
    final seeds = <String>[];
    for (var i = order.length - 1; i >= 0 && seeds.length < 3; i--) {
      if (order.length - i > 10) break;
      final variants = await _services.db.tracksDao.variantsOf(order[i]);
      for (final variant in variants) {
        if (variant.ref.source == SourceId.soundcloud) {
          seeds.add(variant.ref.remoteId);
          break;
        }
      }
    }
    final queued = <String>{};
    for (final id in order.skip(order.length > 60 ? order.length - 60 : 0)) {
      final track = await _services.db.tracksDao.byId(id);
      if (track == null) continue;
      final artists = await _services.db.tracksDao.artistNamesOf(id);
      queued.addAll(SoundCloudSource.songKeys(track.title, artists));
    }
    final tracks = await source.radio(
      seedIds: seeds,
      target: 15,
      excludeSongs: queued,
    );
    AppLogger.instance.info(
      'волна SoundCloud докачала ${tracks.length} от ${seeds.length} затравок',
    );
    return tracks;
  }

  Future<bool> _refillRadio({bool moveToFirstNew = false}) async {
    if (!_isRadio) return false;
    final pending = _radioRefill;
    if (pending != null) {
      // Фоновая докачка уже идёт: раньше второй вызов сразу получал false,
      // и волна, доиграв трек в этот момент, останавливалась.
      final added = await pending;
      if (!moveToFirstNew) return added;
      return _queue.remainingAfterCurrent > 0 && _queue.advance() != null;
    }
    final future = _doRefillRadio(moveToFirstNew: moveToFirstNew);
    _radioRefill = future;
    try {
      return await future;
    } finally {
      _radioRefill = null;
    }
  }

  Future<bool> _doRefillRadio({required bool moveToFirstNew}) async {
    final source = _services.yandex;
    if (source == null) return false;

    final station = '${_sourceHint?['station'] ?? 'user:onyourwave'}';
    try {
      final soundCloud =
          _sourceHint?['soundcloud'] == true &&
          !station.startsWith('playlist:');
      final fromSoundCloud = soundCloud
          ? await _soundCloudRefill()
          : const <SourceTrack>[];
      final fetched = fromSoundCloud.isNotEmpty
          ? fromSoundCloud
          : station.startsWith('playlist:')
          ? (List<SourceTrack>.of(
              await source.playlistTracks(station.substring(9)),
            )..shuffle())
          : await source.station.waveMany(
              station: station,
              batches: 3,
              target: 15,
              queue: await _lastYandexTrackId(),
            );
      if (_services.hideAiTracks) {
        // Волна может стартовать раньше, чем фоновая загрузка списка.
        await AiFilter.instance.ensureLoaded();
      }
      final tracks = _services.hideAiTracks
          ? [
              for (final track in fetched)
                if (!AiFilter.instance.isAiTrack(track)) track,
            ]
          : fetched;
      if (tracks.isEmpty) return false;
      final ids = await _services.db.tracksDao.ingestAll(tracks);
      final disliked = await _services.db.libraryDao.dislikedAmong(ids);
      final recent = await _services.db.historyDao.recentlyHeardIds(
        limit: 400,
        minPlayedMs: 3000,
      );
      // Уже стоящие в очереди треки считаем «недавними»: докачка не должна
      // возвращать то, что сейчас играет или только что сыграло.
      final picked = pickWaveIndexes(
        tracks: tracks,
        ids: ids,
        recent: {...recent, ..._queue.items},
        disliked: disliked,
        minFresh: 4,
      );
      final playableIds = [for (final i in picked) ids[i]];
      if (!_queue.appendBatch(playableIds, moveToFirstNew: moveToFirstNew)) {
        // Ротор вернул то же самое — пробуем ещё раз на следующем треке.
        return false;
      }
      _publish(
        _snapshot.copyWith(
          queue: _queue.displayOrder,
          index: _queue.displayPosition,
        ),
      );
      _emitServiceState();
      _saveSnapshotNow();
      return true;
    } on Object catch (error) {
      AppLogger.instance.warn('волна не докачалась: $error');
      return false;
    }
  }

  /// Последний трек Яндекса в очереди: ротор строит продолжение от него.
  /// С постоянным `queue=1` он отдавал похожие пачки, и песни повторялись.
  Future<String?> _lastYandexTrackId() async {
    final order = _queue.displayOrder;
    for (var i = order.length - 1; i >= 0 && i >= order.length - 5; i--) {
      final variants = await _services.db.tracksDao.variantsOf(order[i]);
      for (final variant in variants) {
        if (variant.ref.source == SourceId.yandex) return variant.ref.remoteId;
      }
    }
    return null;
  }

  /// Отчёты о прослушанном идут в фоне и строго по очереди. Раньше каждый
  /// переход ждал ответа сервера: кнопка «дальше» и свайп срабатывали с
  /// задержкой, а экран плеера всё это время показывал прошлый трек.
  Future<void> _reportChain = Future<void>.value();

  void _enqueueReport(Future<void> Function() job) {
    _reportChain = _reportChain.then((_) async {
      try {
        await job().timeout(const Duration(seconds: 20), onTimeout: () {});
      } on Object catch (error) {
        AppLogger.instance.warn('отчёт о прослушивании: $error');
      }
    });
  }

  /// Записать текущий трек в историю и сообщить источнику. Всё нужное
  /// забираем синхронно: следующий трек уже может начать копить своё время.
  void _reportCurrent(PlaybackEventType type) {
    final localTrackId = _queue.currentId;
    final used = _snapshot.usedSource;
    if (localTrackId == null || used == null) return;

    final played = _takeListened();
    final quality = _snapshot.quality ?? Quality.auto;
    final inStats = _services.collectStats;
    _enqueueReport(() async {
      // История раньше сети: она нужна сразу (волна не повторяет недавнее).
      await _services.db.historyDao.record(
        localTrackId: localTrackId,
        source: used,
        quality: quality,
        played: played,
        completed: type == PlaybackEventType.trackFinished,
        skipReason: type == PlaybackEventType.skip ? 'manual' : null,
        inStats: inStats,
      );
      final variants = await _services.db.tracksDao.variantsOf(localTrackId);
      await _reportEvent(variants, used, type, played);
    });
  }

  Future<void> _reportEvent(
    List<SourceTrack> variants,
    SourceId usedSource,
    PlaybackEventType type,
    Duration played,
  ) async {
    final source = _services.registry.byId(usedSource);
    final variant = variants
        .where((v) => v.ref.source == usedSource)
        .firstOrNull;
    if (source == null ||
        variant == null ||
        !source.capabilities.canReportPlay) {
      return;
    }
    try {
      await source.reportPlaybackEvent(variant, type, played);
    } on Object {
      // Отчёт прослушивания не имеет права ронять воспроизведение.
    }
  }

  /// Ищет ту же песню в других playable-источниках (SoundCloud/Яндекс),
  /// когда трек снят или источник его не отдаёт. Сравнение строгое:
  /// название + исполнитель + близкая длительность.
  Future<ResolvedPlayback?> _crossSourcePlayback(
    String localTrackId, {
    required String title,
    required List<String> artists,
    required Duration duration,
    required Set<SourceId> skip,
  }) async {
    if (_crossSourceMatches[localTrackId] case final cached?) {
      return _playCrossMatch(localTrackId, cached);
    }
    if (_crossSourceSearched.contains(localTrackId)) return null;

    final query = crossSourceQuery(title, artists);
    for (final source in _services.registry.streamableSources) {
      if (skip.contains(source.id)) continue;
      if (source.capabilities.requiresAuth && !source.auth.isReady) continue;
      try {
        final found = await source
            .search(query, pageSize: 10)
            .timeout(const Duration(seconds: 10));
        final match = pickCrossSourceMatch(
          found.tracks,
          title: title,
          artists: artists,
          duration: duration,
        );
        if (match == null) continue;
        final playback = await _playCrossMatch(localTrackId, match);
        if (playback != null) {
          _crossSourceMatches[localTrackId] = match;
          return playback;
        }
      } on Object catch (error) {
        AppLogger.instance.warn(
          'cross-source ${source.id.wire}: поиск не удался: $error',
        );
      }
    }
    _crossSourceSearched.add(localTrackId);
    AppLogger.instance.info('cross-source: нигде не нашлось');
    return null;
  }

  /// У трека есть незацензуренная версия в базе и переключатель включён:
  /// плеер показывает это бейджем.
  static bool _playsUncensored(List<SourceTrack> variants) =>
      CensorBase.instance.enabled &&
      variants.any(
        (variant) =>
            variant.ref.source == SourceId.yandex &&
            CensorBase.instance.hasReplacement(variant.ref.remoteId),
      );

  Future<ResolvedPlayback?> _playCrossMatch(
    String localTrackId,
    SourceTrack match,
  ) async {
    final source = _services.registry.byId(match.ref.source);
    if (source == null) return null;
    try {
      final ready = await source.resolveStream(
        match,
        preferred: _services.defaultQuality,
      );
      if (ready is StreamReady) {
        AppLogger.instance.info(
          'cross-source: играю ${match.ref.source.wire} ${match.ref.remoteId}',
        );
        return ResolvedPlayback(
          localTrackId: localTrackId,
          usedSource: ready.source,
          quality: ready.quality,
          target: ready.target,
          expiresAt: DateTime.now().add(ready.ttlHint ?? defaultStreamTtl),
        );
      }
    } on Object catch (error) {
      AppLogger.instance.warn('cross-source: поток не получен: $error');
    }
    return null;
  }

  void _startStallProbe() {
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
  bool _revalidating = false;

  Future<void> _revalidate({required bool resume}) async {
    if (_revalidating) return;
    _revalidating = true;
    final generation = _generation;
    try {
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
      // Пока резолвили, могли переключить трек: чужую ссылку не подставляем.
      if (generation != _generation) return;
      final fresh = result.playback;
      if (fresh == null) {
        _publishIssue(
          PlayerIssue(result.failures, needsUserAction: result.needsUserAction),
        );
        return;
      }

      await _load(fresh.target);
      if (generation != _generation) return;
      if (position > Duration.zero) await _player.seek(position);
      if (resume) _startPlayback();
      _publish(
        _snapshot.copyWith(
          usedSource: fresh.usedSource,
          quality: fresh.quality,
        ),
      );
      // Проба гасит себя перед перевалидацией: без перезапуска второе
      // зависание на том же треке уже не лечилось.
      _startStallProbe();
    } on Object catch (error) {
      AppLogger.instance.warn('перевалидация не удалась: $error');
    } finally {
      _revalidating = false;
    }
  }

  void _startPauseWatchdog() {
    _pauseWatchdog?.cancel();
    _pauseWatchdog = Timer(maxPausedServiceDuration, () async {
      // Держать mediaPlayback-сервис на паузе дольше 10 минут нельзя.
      // Позицию запоминаем: после stop() «играть» грузит трек заново, и без
      // этого он начинался с нуля.
      _pendingSeek = _player.position;
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
      _snapshot.copyWith(
        queue: _queue.displayOrder,
        index: _queue.displayPosition,
        repeat: _queue.repeat,
        shuffle: _queue.shuffle,
        // Без этого после перезапуска главная писала «Моя волна» поверх
        // «Любимого», а волна переставала считаться волной.
        sourceKind: '${_sourceHint?['kind'] ?? ''}',
        sourceTitle: '${_sourceHint?['title'] ?? ''}',
        isRadio: _isRadio,
      ),
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
    // Звук не загружен (после перезапуска или долгой паузы): позиция плеера
    // тут ноль, а настоящая ждёт в [_pendingSeek]. Без этого смена повтора
    // или закрытие приложения до нажатия «играть» затирали место в треке.
    final idle = _player.processingState == ProcessingState.idle;
    await _services.db.queueDao.save(
      kind: QueueDao.kindPlayer,
      localTrackIds: _queue.items,
      index: _queue.currentBaseIndex,
      position: idle && _pendingSeek > Duration.zero
          ? _pendingSeek
          : _player.position,
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
            false =>
              _snapshot.current == null
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
          if (!stopped)
            MediaControl.custom(
              name: 'like',
              label: _english ? 'Like' : 'Нравится',
              androidIcon: _snapshot.liked
                  ? 'drawable/ic_like_filled'
                  : 'drawable/ic_like',
            ),
          if (!stopped)
            MediaControl.custom(
              name: 'dislike',
              label: _english ? 'Dislike' : 'Не нравится',
              androidIcon: _snapshot.disliked
                  ? 'drawable/ic_dislike_filled'
                  : 'drawable/ic_dislike',
            ),
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
    _services.onEqualizerChanged = null;
    _killOutgoing();
    _unbindPlayer();
    await _saveSnapshotNow();
    await _snapshots.close();
    await _player.dispose();
    instance = null;
  }

  /// Пресет пересчитывается под реальные полосы устройства. `parameters`
  /// разрешается после активации аудиосессии, поэтому вызов можно делать
  /// до старта воспроизведения: гейны применятся, как только появится плеер.
  /// Плеер, к сессии которого эквалайзер уже применён.
  AudioPlayer? _equalizerSyncedFor;

  Future<void> _syncEqualizer() async {
    final player = _player;
    final enabled = _services.eqEnabled;
    await _equalizer.setEnabled(enabled);
    if (!enabled) {
      _equalizerSyncedFor = player;
      return;
    }
    final custom = _services.eqPreset == equalizerCustomId;
    try {
      final params = await _equalizer.parameters;
      final centers = [for (final band in params.bands) band.centerFrequency];
      final gains = custom
          ? equalizerGainsFromCurve(
              _services.eqCustomGains,
              level: _services.eqCustomLevel,
              centersHz: centers,
              minDb: params.minDecibels,
              maxDb: params.maxDecibels,
            )
          : equalizerGains(
              equalizerPresetById(_services.eqPreset),
              centersHz: centers,
              minDb: params.minDecibels,
              maxDb: params.maxDecibels,
            );
      for (var i = 0; i < params.bands.length && i < gains.length; i++) {
        await params.bands[i].setGain(gains[i]);
      }
      _equalizerSyncedFor = player;
    } on Object catch (error) {
      AppLogger.instance.warn('эквалайзер не применился: $error');
    }
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

  static PlaybackRepeat _repeatFromWire(String value) => PlaybackRepeat.values
      .firstWhere((e) => e.name == value, orElse: () => PlaybackRepeat.none);
}
