import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';
import 'core/content/ai_filter.dart';
import 'core/logging/app_logger.dart';
import 'core/sources/source_dto.dart';
import 'core/sources/source_id.dart';
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
  final fetched =
      withSoundCloud && station != WaveStationIds.coolMusic
      ? await _withSoundCloud(ref, base)
      : base;
  final tracks = hideAi
      ? [
          for (final track in fetched)
            if (!AiFilter.instance.isAiTrack(track)) track,
        ]
      : fetched;
  final ids = await services.db.tracksDao.ingestAll(tracks);
  final disliked = await services.db.libraryDao.dislikedAmong(ids);
  return [
    for (var i = 0; i < tracks.length; i++)
      if (!disliked.contains(ids[i]))
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

/// Подмешивает несколько треков SoundCloud к выдаче Яндекса: ищем по
/// исполнителям, которые уже есть в волне. Параллельно и без ошибок наружу —
/// недоступный SoundCloud оставляет обычную волну.
Future<List<SourceTrack>> _withSoundCloud(
  Ref ref,
  List<SourceTrack> base,
) async {
  final sc = ref.read(appServicesProvider).registry.byId(SourceId.soundcloud);
  if (sc == null) return base;
  final artists = <String>[];
  for (final track in base) {
    final artist = track.artists.isEmpty ? '' : track.artists.first.trim();
    if (artist.isNotEmpty && !artists.contains(artist)) artists.add(artist);
    if (artists.length == 3) break;
  }
  if (artists.isEmpty) return base;

  Future<List<SourceTrack>> searchOne(String artist) async {
    try {
      return (await sc.search(artist, pageSize: 10)).tracks;
    } on Object {
      return const [];
    }
  }

  final batches = await Future.wait([
    for (final artist in artists) searchOne(artist),
  ]);
  final extras = <SourceTrack>[];
  final seen = <String>{};
  for (final batch in batches) {
    var added = 0;
    for (final track in batch) {
      if (!track.available || track.duration.inSeconds < 60) continue;
      if (!seen.add(track.ref.remoteId)) continue;
      extras.add(track);
      added++;
      if (added == 2) break;
    }
  }
  if (extras.isEmpty) return base;
  AppLogger.instance.info('волна: SoundCloud +${extras.length} треков');

  final mixed = <SourceTrack>[];
  var pick = 0;
  for (var i = 0; i < base.length; i++) {
    mixed.add(base[i]);
    if (i % 4 == 3 && pick < extras.length) mixed.add(extras[pick++]);
  }
  mixed.addAll(extras.skip(pick));
  return mixed;
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
