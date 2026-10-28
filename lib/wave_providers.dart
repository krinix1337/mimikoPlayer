import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';
import 'core/content/ai_filter.dart';
import 'core/logging/app_logger.dart';
import 'core/sources/source_dto.dart';
import 'core/sources/source_id.dart';
import 'sources/soundcloud/soundcloud_source.dart';
import 'sources/yandex/yandex_station.dart';

/// Понятный список жанров вместо серверной выдачи: `/rotor/stations/list`
/// отдаёт 700+ станций вперемешку с колыбельными и детскими подборками.
const _genreOrder = [
  'genre:pop',
  'genre:ruspop',
  'genre:rap',
  'genre:rusrap',
  'genre:rock',
  'genre:rusrock',
  'genre:alternative',
  'genre:indie',
  'genre:electronics',
  'genre:dance',
  'genre:edmgenre',
  'genre:metal',
  'genre:jazz',
  'genre:classical',
  'genre:rnb',
  'genre:soul',
  'genre:funk',
  'genre:disco',
  'genre:reggae',
  'genre:shanson',
  'genre:estrada',
  'genre:folk',
  'genre:soundtrack',
  'genre:animemusic',
  'genre:kpop',
  'genre:phonkgenre',
];

/// Станции волн из Яндекса: `user:onyourwave`, `genre:pop`, …
final waveStationsProvider = FutureProvider<List<WaveStation>>((ref) async {
  final source = ref.watch(yandexSourceProvider);
  if (source == null) return const [];
  // Без готового токена станции не отдаются: ждём вход, а не кэшируем пусто.
  if (!ref.watch(yandexReadyProvider)) return const [];
  await source.warmUp();
  final cover = source.playlistCover(WaveStationIds.coolMusicPlaylist);
  final all = await source.station.stations(limit: 200);
  final byId = {for (final station in all) station.id: station};
  return [
    for (final id in _genreOrder) ?byId[id],
    WaveStation(
      id: WaveStationIds.coolMusic,
      title: 'Крутая музыка',
      iconUrl: await cover,
    ),
  ];
});

/// Выбранная станция — общая для главной и настроек.
class StationController extends Notifier<String> {
  @override
  String build() => WaveStationIds.myVibe;

  void select(String station) => state = station;
}

final stationProvider = NotifierProvider<StationController, String>(
  StationController.new,
);

/// Название выбранной станции. Пустая строка — это «моя волна»: подпись
/// берётся из локализации, потому что у станции нет собственного имени.
final waveStationTitleProvider = Provider<String>((ref) {
  final id = ref.watch(stationProvider);
  if (id == WaveStationIds.myVibe) return '';
  final stations =
      ref.watch(waveStationsProvider).value ?? const <WaveStation>[];
  return stations.where((s) => s.id == id).firstOrNull?.title ?? id;
});

/// Треки текущей волны, уже сведённые в локальные строки.
final waveTracksProvider = FutureProvider<List<WaveTrack>>((ref) async {
  final source = ref.watch(yandexSourceProvider);
  if (source == null) return const [];
  if (!ref.watch(yandexReadyProvider)) return const [];
  final station = ref.watch(stationProvider);
  final services = ref.watch(appServicesProvider);
  final withSoundCloud = ref.watch(
    prefsProvider.select((p) => p.waveSoundCloud),
  );

  await source.warmUp();
  final hideAi = ref.watch(prefsProvider.select((p) => p.hideAiTracks));
  if (hideAi) await AiFilter.instance.ensureLoaded();
  final base = station == WaveStationIds.coolMusic
      ? (List<SourceTrack>.of(
          await source.playlistTracks(WaveStationIds.coolMusicPlaylist),
        )..shuffle())
      : await source.station.waveMany(station: station);
  final fetched = withSoundCloud && station != WaveStationIds.coolMusic
      ? await _soundCloudWave(ref, base)
      : base;
  final tracks = hideAi
      ? [
          for (final track in fetched)
            if (!AiFilter.instance.isAiTrack(track)) track,
        ]
      : fetched;
  final ids = await services.db.tracksDao.ingestAll(tracks);
  final disliked = await services.db.libraryDao.dislikedAmong(ids);
  // Разные remote id (сингл/альбом, копия из SoundCloud) сводятся в один
  // локальный трек: без отсева он стоял в волне дважды.
  final seen = <String>{};
  return [
    for (var i = 0; i < tracks.length; i++)
      if (!disliked.contains(ids[i]) && seen.add(ids[i]))
        WaveTrack(localTrackId: ids[i], source: tracks[i]),
  ];
});

/// Настройки всегда относятся к «Моей волне»: у жанровых станций Яндекс
/// их не сохраняет, а лист настроек больше не переключает станции.
final waveSettingsProvider = FutureProvider<WaveSettings?>((ref) async {
  final source = ref.watch(yandexSourceProvider);
  if (source == null) return null;
  if (!ref.watch(yandexReadyProvider)) return null;
  await source.warmUp();
  return source.station.settings(WaveStationIds.myVibe);
});

/// Запуск выбранной волны: берёт треки станции и кладёт их в очередь радио.
/// Общая для главной и баннера в коллекции, чтобы логика старта не дублировалась.
Future<bool> startWave(WidgetRef ref) async {
  // Плеер, станция и флаги берутся до await: виджет (а вместе с ним ref)
  // может исчезнуть, пока грузится пачка треков.
  final controller = ref.read(playbackControllerProvider);
  final station = ref.read(stationProvider);
  final title = ref.read(waveStationTitleProvider);
  final soundCloud = ref.read(prefsProvider).waveSoundCloud;
  final tracks = await ref.read(waveTracksProvider.future);
  if (tracks.isEmpty) return false;
  await controller.playQueue(
    [for (final track in tracks) track.localTrackId],
    sourceHint: {
      'kind': 'radio',
      'station': station,
      'title': title,
      'soundcloud': soundCloud && station != WaveStationIds.coolMusic,
    },
  );
  return true;
}

/// Режим «SoundCloud»: волна целиком из SoundCloud. Затравка — исполнители
/// из персональной волны Яндекса, дальше рекомендации SoundCloud («похожие»).
/// Если SoundCloud недоступен, остаётся обычная волна, а не пустой экран.
Future<List<SourceTrack>> _soundCloudWave(
  Ref ref,
  List<SourceTrack> base,
) async {
  final sc = ref.read(appServicesProvider).registry.byId(SourceId.soundcloud);
  if (sc is! SoundCloudSource) return base;
  final artists = <String>[];
  for (final track in base) {
    final artist = track.artists.isEmpty ? '' : track.artists.first.trim();
    if (artist.isNotEmpty && !artists.contains(artist)) artists.add(artist);
    if (artists.length == 4) break;
  }
  if (artists.isEmpty) return base;

  final seeds = [
    for (final id in await Future.wait([
      for (final artist in artists) sc.seedFor(artist),
    ]))
      ?id,
  ];
  final tracks = await sc.radio(seedIds: seeds, target: 24);
  if (tracks.isEmpty) {
    AppLogger.instance.warn('волна SoundCloud пуста — играет обычная');
    return base;
  }
  AppLogger.instance.info(
    'волна SoundCloud: ${tracks.length} треков от ${seeds.length} затравок',
  );
  return tracks;
}

final class WaveTrack {
  const WaveTrack({required this.localTrackId, required this.source});

  final String localTrackId;
  final SourceTrack source;
}

class WaveStationIds {
  const WaveStationIds._();

  static const myVibe = 'user:onyourwave';

  /// Плейлист «Моднявая музыка», который владелец называет «Крутая музыка».
  static const coolMusicPlaylist = '1731735008:1002';
  static const coolMusic = 'playlist:$coolMusicPlaylist';
}
