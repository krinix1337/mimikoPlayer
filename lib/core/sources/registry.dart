import 'music_source.dart';
import 'source_id.dart';

/// Единственное место, которое импортирует конкретные источники.
final class SourceRegistry {
  SourceRegistry(Iterable<MusicSource> sources)
    : _byId = {for (final s in sources) s.id: s};

  final Map<SourceId, MusicSource> _byId;

  /// Порядок перебора при воспроизведении. По умолчанию: подписочный каталог,
  /// затем бесплатные запасные, затем локальные файлы.
  static const List<SourceId> defaultPlaybackPriority = [
    SourceId.yandex,
    SourceId.soundcloud,
    SourceId.youtube,
    SourceId.local,
  ];

  List<SourceId> _playbackPriority = defaultPlaybackPriority;

  List<SourceId> get playbackPriority => List.unmodifiable(_playbackPriority);

  /// Источники, которых нет в сборке, отбрасываются, поэтому список из
  /// настроек безопасен.
  void setPlaybackPriority(List<SourceId> order) {
    final known = order.where(_byId.containsKey).toList();
    for (final id in _byId.keys) {
      if (!known.contains(id) && _byId[id]!.capabilities.canStream) {
        known.add(id);
      }
    }
    _playbackPriority = known;
  }

  Iterable<MusicSource> get all => _byId.values;

  MusicSource? byId(SourceId id) => _byId[id];

  /// Только те, что реально умеют отдавать поток.
  List<MusicSource> get streamableSources => [
    for (final id in _playbackPriority)
      if (_byId[id] case final s? when s.capabilities.canStream) s,
  ];

  Future<void> dispose() async {
    for (final s in _byId.values) {
      await s.dispose();
    }
  }
}
