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

  /// Текущие настройки станции. Старый `/settings` отдаёт mood/energy,
  /// которыми новый клиент уже не пользуется — читаем `settings2` из info.
  Future<WaveSettings?> settings(String station) async {
    final result = await _api.get('/rotor/station/$station/info');
    if (!result.isOk) return null;
    final stations = result.asList;
    if (stations.isEmpty) return null;
    return parseSettings2(stations.first['settings2']);
  }

  static WaveSettings? parseSettings2(Object? raw) {
    if (raw is! Map) return null;
    return WaveSettings(
      moodEnergy: '${raw['moodEnergy'] ?? 'all'}',
      diversity: '${raw['diversity'] ?? 'default'}',
      language: '${raw['language'] ?? 'any'}',
    );
  }

  static Map<String, Object?> settingsBody(WaveSettings settings) => {
    'moodEnergy': settings.moodEnergy,
    'diversity': settings.diversity,
    'language': settings.language,
    'type': 'rotor',
  };

  /// Меняет настройки «Моей волны». У жанровых станций эндпоинт отвечает
  /// «ok», но значения не сохраняет, поэтому UI показывает их только для
  /// личной волны.
  Future<bool> saveSettings(String station, WaveSettings settings) async =>
      (await _api.post(
        '/rotor/station/$station/settings3',
        body: settingsBody(settings),
      )).isOk;

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
  const WaveSettings({
    this.moodEnergy = 'all',
    this.diversity = 'default',
    this.language = 'any',
  });

  /// `active`, `fun`, `calm`, `sad`, `all`.
  final String moodEnergy;

  /// `favorite`, `discover`, `popular`, `default`.
  final String diversity;

  /// `russian`, `not-russian`, `without-words`, `any`.
  final String language;

  static const List<String> moodEnergyValues = [
    'active',
    'fun',
    'calm',
    'sad',
    'all',
  ];

  static const List<String> diversityValues = [
    'favorite',
    'discover',
    'popular',
    'default',
  ];

  static const List<String> languageValues = [
    'russian',
    'not-russian',
    'without-words',
    'any',
  ];

  WaveSettings copyWith({
    String? moodEnergy,
    String? diversity,
    String? language,
  }) => WaveSettings(
    moodEnergy: moodEnergy ?? this.moodEnergy,
    diversity: diversity ?? this.diversity,
    language: language ?? this.language,
  );
}
