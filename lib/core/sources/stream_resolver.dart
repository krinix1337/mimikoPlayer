import 'dart:async';
import 'dart:collection';

import '../constants.dart';
import 'music_source.dart';
import 'registry.dart';
import 'source_dto.dart';
import 'source_errors.dart';
import 'source_id.dart';
import 'stream_target.dart';

/// Разрешение потока, пригодное для плеера.
final class ResolvedPlayback {
  const ResolvedPlayback({
    required this.localTrackId,
    required this.usedSource,
    required this.quality,
    required this.target,
    required this.expiresAt,
    this.fromCache = false,
  });

  final String localTrackId;
  final SourceId usedSource;
  final Quality quality;
  final StreamTarget target;
  final DateTime expiresAt;
  final bool fromCache;

  bool canReuseAt(DateTime now) =>
      now.isBefore(expiresAt.subtract(streamTtlSafetyMargin));

  ResolvedPlayback asCached() => ResolvedPlayback(
    localTrackId: localTrackId,
    usedSource: usedSource,
    quality: quality,
    target: target,
    expiresAt: expiresAt,
    fromCache: true,
  );
}

/// Итог обхода цепочки источников.
final class ResolveResult {
  ResolveResult.ok(this.playback)
    : failures = const [],
      needsUserAction = false;

  ResolveResult.failed(this.failures)
    : playback = null,
      needsUserAction = failures.any((f) => f.needsUserAction);

  final ResolvedPlayback? playback;

  /// По одному отказу на перебранный источник — UI показывает их на debug-экране.
  final List<SourceFailure> failures;

  /// Цепочку оборвал отказ, который сам не рассосётся: нужен вход или подписка.
  final bool needsUserAction;

  bool get isOk => playback != null;

  /// Ничего не нашлось, но и пользователь ничего не должен чинить.
  bool get exhausted => !isOk && !needsUserAction;
}

/// Хранилище разрешений и негативного кэша. Реализация — DAO поверх drift;
/// в тестах подменяется фейком.
abstract interface class ResolutionStore {
  /// Скачанный файл перекрывает всю сетевую цепочку.
  Future<String?> downloadedFilePath(String localTrackId);

  Future<ResolvedPlayback?> cached(
    String localTrackId,
    SourceId source,
    Quality quality,
  );

  Future<void> put(ResolvedPlayback playback);

  Future<void> invalidate(String localTrackId, SourceId source);

  /// Причина отказа, для которой запрет ещё не истёк.
  Future<SourceFailReason?> activeFailure(String localTrackId, SourceId source);

  Future<void> noteFailure(String localTrackId, SourceFailure failure);
}

/// Обходит playable-источники по приоритету и отдаёт ссылку на поток.
final class StreamResolver {
  StreamResolver({required this.registry, required this.store});

  final SourceRegistry registry;
  final ResolutionStore store;

  final LinkedHashMap<String, ResolvedPlayback> _lru = LinkedHashMap();

  /// Совпадающие запросы (prefetch и тап из UI одновременно) не должны делать
  /// две одинаковые подписи.
  final Map<String, Future<StreamResult>> _inFlight = {};

  Future<ResolveResult> resolve({
    required String localTrackId,
    required List<SourceTrack> variants,
    Quality quality = Quality.auto,
    bool bypassCache = false,
  }) async {
    if (await store.downloadedFilePath(localTrackId) case final path?) {
      return ResolveResult.ok(
        ResolvedPlayback(
          localTrackId: localTrackId,
          usedSource: SourceId.local,
          quality: quality,
          target: StreamFile(path),
          expiresAt: DateTime.now().add(const Duration(days: 3650)),
        ),
      );
    }

    final bySource = {for (final v in variants) v.ref.source: v};
    final failures = <SourceFailure>[];

    for (final source in registry.streamableSources) {
      final track = bySource[source.id];
      if (track == null) continue;

      if (!bypassCache) {
        final blocked = await store.activeFailure(localTrackId, source.id);
        if (blocked != null) {
          failures.add(SourceFailure(source: source.id, reason: blocked));
          continue;
        }
      }

      if (bypassCache) {
        await store.invalidate(localTrackId, source.id);
      } else if (await _fromCache(localTrackId, source.id, quality)
          case final ResolvedPlayback cached) {
        return ResolveResult.ok(cached);
      }

      final outcome = await _askSource(
        source,
        track,
        localTrackId,
        quality,
        bypassCache,
      );

      switch (outcome) {
        case final StreamReady ready:
          final playback = _pin(localTrackId, ready);
          _remember(_key(localTrackId, source.id, quality), playback);
          await store.put(playback);
          return ResolveResult.ok(playback);

        case StreamFailed(:final failure):
          await store.noteFailure(localTrackId, failure);
          failures.add(failure);
          // Не сжигаем квоты остальных источников на чужом просроченном токене.
          if (!failure.fallbackToNextSource) {
            return ResolveResult.failed(failures);
          }
      }
    }

    return ResolveResult.failed(failures);
  }

  Future<ResolvedPlayback?> _fromCache(
    String localTrackId,
    SourceId source,
    Quality quality,
  ) async {
    final now = DateTime.now();
    if (_lru[_key(localTrackId, source, quality)] case final hit?) {
      if (hit.canReuseAt(now)) return hit.asCached();
      _lru.remove(_key(localTrackId, source, quality));
    }
    if (await store.cached(localTrackId, source, quality) case final stored?) {
      if (stored.canReuseAt(now)) return stored.asCached();
      await store.invalidate(localTrackId, source);
    }
    return null;
  }

  Future<StreamResult> _askSource(
    MusicSource source,
    SourceTrack track,
    String localTrackId,
    Quality quality,
    bool bypassCache,
  ) {
    final key = _key(localTrackId, source.id, quality);
    if (bypassCache) {
      _lru.remove(key);
    } else if (_inFlight[key] case final pending?) {
      return pending;
    }

    final request = () async {
      try {
        await source.warmUp();
        return await source.resolveStream(track, preferred: quality);
      } on Object catch (e) {
        return StreamFailed(
          SourceFailure(
            source: source.id,
            reason: SourceFailReason.network,
            message: '$e',
          ),
        );
      }
    }();

    if (!bypassCache) _inFlight[key] = request;
    request.whenComplete(() => _inFlight.remove(key));
    return request;
  }

  ResolvedPlayback _pin(String localTrackId, StreamReady ready) {
    final shortest = [
      ready.ttlHint ?? streamTtlMax,
      defaultStreamTtl,
    ].reduce((a, b) => a.compareTo(b) < 0 ? a : b);
    final ttl = shortest.compareTo(streamTtlMax) > 0 ? streamTtlMax : shortest;

    return ResolvedPlayback(
      localTrackId: localTrackId,
      usedSource: ready.source,
      quality: ready.quality,
      target: ready.target,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  void _remember(String key, ResolvedPlayback playback) {
    _lru[key] = playback;
    while (_lru.length > streamLruSize) {
      _lru.remove(_lru.keys.first);
    }
  }

  /// Сброс памяти при смене режима цензуры: иначе закэшированная ссылка
  /// продолжит играть после переключателя.
  void clearMemoryCache() {
    _lru.clear();
    _inFlight.clear();
  }

  /// Только резолв, без аудио-I/O: вызывается на старте трека N для N+1.
  Future<void> prefetch({
    required String localTrackId,
    required List<SourceTrack> variants,
    Quality quality = Quality.auto,
  }) =>
      resolve(localTrackId: localTrackId, variants: variants, quality: quality);

  /// Self-heal: 401/403 от хранилища означает протухшую подпись — сбрасываем
  /// кэш и в следующий раз подписываем заново.
  Future<void> didLoseTrust(String localTrackId, SourceId source) =>
      store.invalidate(localTrackId, source);

  static String _key(String localTrackId, SourceId source, Quality quality) =>
      '$localTrackId|${source.wire}|${quality.wire}';
}
