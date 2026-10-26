import '../../core/sources/source_errors.dart';
import '../../core/sources/source_id.dart';
import '../../core/sources/stream_target.dart';

/// Режим повтора. Свой enum, чтобы UI не зависел от audio_service.
enum PlaybackRepeat { none, all, one }

/// Очередь перемешана или идёт по порядку.
enum PlaybackShuffle { ordered, shuffled }

/// Всё, что знает про себя плеер, — единственное, что видит UI.
final class PlayerSnapshot {
  const PlayerSnapshot({
    this.current,
    this.queue = const [],
    this.index = -1,
    this.playing = false,
    this.buffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.repeat = PlaybackRepeat.none,
    this.shuffle = PlaybackShuffle.ordered,
    this.usedSource,
    this.quality,
    this.uncensored = false,
    this.issue,
    this.resolving = false,
    this.isRadio = false,
    this.liked = false,
    this.disliked = false,
    this.sourceKind = '',
    this.sourceTitle = '',
  });

  final NowPlaying? current;

  /// localTrackId'и в порядке воспроизведения.
  final List<String> queue;

  /// Позиция текущего трека в [queue], а не исходный индекс: при shuffle и
  /// повторах они расходятся, и подсветка/соседи свайпа должны брать эту.
  final int index;

  final bool playing;
  final bool buffering;
  final Duration position;
  final Duration duration;
  final PlaybackRepeat repeat;
  final PlaybackShuffle shuffle;

  /// Откуда реально взялся звук: UI показывает это честно, включая
  /// «переключились на другой источник».
  final SourceId? usedSource;
  final Quality? quality;

  /// Сейчас играет версия из базы без цензуры, а не оригинал Яндекса.
  final bool uncensored;
  final bool resolving;

  /// Последняя типизированная ошибка цепочки, либо null.
  final PlayerIssue? issue;

  /// Очередь запущена как волна: подсказывает главной, что кнопка «играет».
  final bool isRadio;

  /// Текущий трек в любимом.
  final bool liked;

  /// Текущий трек в «Нелюбимом».
  final bool disliked;

  /// Откуда пришла очередь: library, playlist, search, chart, radio…
  final String sourceKind;

  /// Человеческий заголовок источника: «Любимое», имя артиста, название
  /// плейлиста. Пусто — UI показывает нейтральный заголовок.
  final String sourceTitle;

  PlayerSnapshot copyWith({
    NowPlaying? current,
    List<String>? queue,
    int? index,
    bool? playing,
    bool? buffering,
    Duration? position,
    Duration? duration,
    PlaybackRepeat? repeat,
    PlaybackShuffle? shuffle,
    SourceId? usedSource,
    Quality? quality,
    bool? uncensored,
    bool? resolving,
    PlayerIssue? issue,
    bool clearIssue = false,
    bool clearCurrent = false,
    bool? isRadio,
    bool? liked,
    bool? disliked,
    String? sourceKind,
    String? sourceTitle,
  }) => PlayerSnapshot(
    current: clearCurrent ? null : (current ?? this.current),
    queue: queue ?? this.queue,
    index: index ?? this.index,
    playing: playing ?? this.playing,
    buffering: buffering ?? this.buffering,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    repeat: repeat ?? this.repeat,
    shuffle: shuffle ?? this.shuffle,
    usedSource: usedSource ?? this.usedSource,
    quality: quality ?? this.quality,
    uncensored: uncensored ?? this.uncensored,
    resolving: resolving ?? this.resolving,
    issue: clearIssue ? null : (issue ?? this.issue),
    isRadio: isRadio ?? this.isRadio,
    liked: liked ?? this.liked,
    disliked: disliked ?? this.disliked,
    sourceKind: sourceKind ?? this.sourceKind,
    sourceTitle: sourceTitle ?? this.sourceTitle,
  );

  bool get hasTrack => current != null;
}

final class NowPlaying {
  const NowPlaying({
    required this.localTrackId,
    required this.title,
    required this.artist,
    this.coverUrl,
    this.explicitFlag = false,
    this.isAi = false,
  });

  final String localTrackId;
  final String title;
  final String artist;
  final String? coverUrl;

  /// Явный контент: бейдж 18+.
  final bool explicitFlag;

  /// Трек/артист есть в списке ИИ-исполнителей.
  final bool isAi;
}

final class PlayerIssue {
  const PlayerIssue(this.failures, {required this.needsUserAction});

  final List<SourceFailure> failures;

  /// true — показать, что требуется вход/подписка, а не просто ошибку сети.
  final bool needsUserAction;

  String get headline {
    if (needsUserAction) {
      final auth = failures.firstWhere(
        (f) =>
            f.reason == SourceFailReason.authRequired ||
            f.reason == SourceFailReason.authExpired,
        orElse: () => failures.first,
      );
      return 'Нужен вход: ${auth.source.wire}';
    }
    return 'Трек недоступен ни в одном источнике';
  }
}
