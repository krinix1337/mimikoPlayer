import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';
import 'core/sources/source_dto.dart';
import 'sources/yandex/yandex_station.dart';

/// Станции волн из Яндекса: `user:onyourwave`, `genre:pop`, …
final waveStationsProvider = FutureProvider<List<WaveStation>>((ref) async {
  final source = ref.watch(yandexSourceProvider);
  if (source == null) return const [];
  // Без готового токена станции не отдаются: ждём вход, а не кэшируем пусто.
  if (!ref.watch(yandexReadyProvider)) return const [];
  await source.warmUp();
  return source.station.stations(limit: 24);
});

/// Выбранная станция — общая для главной и настроек.
class StationController extends Notifier<String> {
  @override
  String build() => WaveStationIds.myVibe;

  void select(String station) => state = station;
}

final stationProvider =
    NotifierProvider<StationController, String>(StationController.new);

/// Название выбранной станции. Пустая строка — это «моя волна»: подпись
/// берётся из локализации, потому что у станции нет собственного имени.
final waveStationTitleProvider = Provider<String>((ref) {
  final id = ref.watch(stationProvider);
  if (id == WaveStationIds.myVibe) return '';
  final stations = ref.watch(waveStationsProvider).value ?? const <WaveStation>[];
  return stations.where((s) => s.id == id).firstOrNull?.title ?? id;
});

/// Треки текущей волны, уже сведённые в локальные строки.
final waveTracksProvider = FutureProvider<List<WaveTrack>>((ref) async {
  final source = ref.watch(yandexSourceProvider);
  if (source == null) return const [];
  if (!ref.watch(yandexReadyProvider)) return const [];
  final station = ref.watch(stationProvider);
  final services = ref.watch(appServicesProvider);

  await source.warmUp();
  final tracks = await source.station.wave(station: station);
  final result = <WaveTrack>[];
  for (final track in tracks) {
    final ingested = await services.db.tracksDao.ingest(track);
    result.add(WaveTrack(localTrackId: ingested.localTrackId, source: track));
  }
  return result;
});

final waveSettingsProvider = FutureProvider<WaveSettings?>((ref) async {
  final source = ref.watch(yandexSourceProvider);
  if (source == null) return null;
  if (!ref.watch(yandexReadyProvider)) return null;
  await source.warmUp();
  return source.station.settings(ref.watch(stationProvider));
});

/// Запуск выбранной волны: берёт треки станции и кладёт их в очередь радио.
/// Общая для главной и баннера в коллекции, чтобы логика старта не дублировалась.
Future<bool> startWave(WidgetRef ref) async {
  final tracks = await ref.read(waveTracksProvider.future);
  if (tracks.isEmpty) return false;
  await ref.read(playbackControllerProvider).playQueue(
    [for (final track in tracks) track.localTrackId],
    sourceHint: {
      'kind': 'radio',
      'station': ref.read(stationProvider),
    },
  );
  return true;
}

final class WaveTrack {
  const WaveTrack({required this.localTrackId, required this.source});

  final String localTrackId;
  final SourceTrack source;
}

class WaveStationIds {
  const WaveStationIds._();

  static const myVibe = 'user:onyourwave';
}
