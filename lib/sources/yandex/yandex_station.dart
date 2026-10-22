import '../../core/sources/source_dto.dart';
import 'yandex_api.dart';
import 'yandex_dto.dart';

/// «Моя волна» и отчёты о прослушивании (rotor).
class YandexStation {
  YandexStation(this._api);

  static const defaultStation = 'user:onyourwave';

  final YandexApi _api;

  /// Станции волн: `genre:pop`, `user:onyourwave` и т.д.
  Future<List<WaveStation>> stations({int limit = 40}) async {
    final result = await _api.get('/rotor/stations/list');
    if (!result.isOk) return const [];

    final found = <WaveStation>[];
    for (final item in result.asList) {
      final station = item['station'];
      if (station is! Map) continue;
      final id = station['id'];
      if (id is! Map) continue;
      final type = '${id['type'] ?? ''}';
      final tag = '${id['tag'] ?? ''}';
      if (type.isEmpty || tag.isEmpty) continue;

      final name = station['name']?.toString();
      found.add(
        WaveStation(
          id: '$type:$tag',
          title: (name == null || name.isEmpty) ? tag : name,
          iconUrl: (station['icon'] as Map?)?['imageUrl']?.toString(),
        ),
      );
      if (found.length >= limit) break;
    }
    return found;
  }

  /// Настройки волны: настроение, энергия, разнообразие, язык.
  Future<WaveSettings?> settings(String station) async {
    final json = (await _api.get('/rotor/station/$station/settings')).asMap;
    if (json == null) return null;
    return WaveSettings(
      mood: (json['mood'] as num?)?.toInt(),
      energy: (json['energy'] as num?)?.toInt(),
      diversity: json['diversity']?.toString(),
      language: json['language']?.toString(),
    );
  }

  /// Меняет рекомендации реальной станции — то есть трогает аккаунт.
  Future<bool> saveSettings(String station, WaveSettings settings) async =>
      (await _api.post(
        '/rotor/station/$station/settings',
        body: {
          'language': settings.language ?? 'any',
          'mood': settings.mood ?? 2,
          'energy': settings.energy ?? 2,
          'diversity': settings.diversity ?? 'default',
          'signal': DateTime.now().millisecondsSinceEpoch,
        },
      ))
          .isOk;

  Future<List<SourceTrack>> wave({String station = defaultStation}) async {
    final result = await _api.get('/rotor/station/$station/tracks', {
      'queue': '1',
    });
    if (!result.isOk) return const [];

    final sequence = result.asMap?['sequence'];
    if (sequence is! List) return const [];

    return [
      for (final item in sequence)
        if (item is Map && item['track'] is Map)
          YandexDto.track(Map<String, dynamic>.from(item['track'] as Map)),
    ];
  }

  /// Ротор отдаёт по пять треков за запрос. Чтобы очередь не выглядела как
  /// «пять песен и всё», сразу забираем несколько пачек параллельно и
  /// склеиваем без дублей. Дальше плеер докачивает буфер заранее.
  Future<List<SourceTrack>> waveMany({
    String station = defaultStation,
    int batches = 4,
    int target = 20,
  }) async {
    final parts = await Future.wait([
      for (var i = 0; i < batches; i++) wave(station: station),
    ]);
    final seen = <String>{};
    final tracks = <SourceTrack>[];
    for (final batch in parts) {
      for (final track in batch) {
        if (!seen.add(track.ref.remoteId)) continue;
        tracks.add(track);
        if (tracks.length >= target) return tracks;
      }
    }
    return tracks;
  }

  /// Типы и тело совпадают с официальным клиентом: без этих отчётов волна
  /// перестаёт подстраиваться под пользователя.
  Future<YandexResponse> feedback({
    required String trackId,
    required PlaybackEventType type,
    required Duration played,
    String station = defaultStation,
  }) => _api.post(
    '/rotor/station/$station/feedback',
    body: {
      'type': type.wire,
      'entity': 'track',
      'trackId': trackId,
      'totalPlayedSeconds': played.inSeconds,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    },
  );
}


final class WaveStation {
  const WaveStation({required this.id, required this.title, this.iconUrl});

  final String id;
  final String title;
  final String? iconUrl;
}

final class WaveSettings {
  const WaveSettings({this.mood, this.energy, this.diversity, this.language});

  /// 0..4, середина — 2: спокойное ↔ активное.
  final int? mood;
  final int? energy;
  final String? diversity;
  final String? language;

  static const List<String> diversityValues = [
    'default',
    'maximum_diversity',
    'minimum_diversity',
  ];

  static const List<String> languageValues = ['any', 'ru', 'en', 'nonrank'];

  WaveSettings copyWith({
    int? mood,
    int? energy,
    String? diversity,
    String? language,
  }) => WaveSettings(
    mood: mood ?? this.mood,
    energy: energy ?? this.energy,
    diversity: diversity ?? this.diversity,
    language: language ?? this.language,
  );
}
