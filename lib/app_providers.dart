import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_services.dart';
import 'core/content/ai_filter.dart';
import 'core/content/artist_blocklist.dart';
import 'core/content/censor_base.dart';
import 'core/db/daos/downloads_dao.dart';
import 'core/db/daos/library_dao.dart';
import 'core/db/database.dart';
import 'core/logging/app_logger.dart';
import 'core/prefs/prefs.dart';
import 'core/prefs/prefs_store.dart';
import 'core/sources/source_dto.dart';
import 'core/sources/source_id.dart';
import 'sources/lyrics/lrclib.dart';
import 'sources/lyrics/lyrics_service.dart';
import 'features/library/library_actions.dart';
import 'features/player/playback_controller.dart';
import 'features/player/player_snapshot.dart';
import 'sources/yandex/yandex_source.dart';
import 'sources/local/local_source.dart';

/// Сборка зависимостей и провайдеры состояния для UI. Плеер сюда попадает
/// только как интерфейс [PlaybackController] — типы audio_service UI не видит.
final playbackControllerProvider = Provider<PlaybackController>(
  (ref) =>
      throw StateError('playbackControllerProvider не переопределён в main'),
);

final appServicesProvider = Provider<AppServices>(
  (ref) => AppServices.ensure(),
);

final playerSnapshotProvider = StreamProvider<PlayerSnapshot>(
  (ref) => ref.watch(playbackControllerProvider).snapshots,
);

final playerSnapshotProviderValue = Provider<PlayerSnapshot>(
  (ref) => ref.watch(playerSnapshotProvider).value ?? const PlayerSnapshot(),
);

/// Файлы из `Music/` в наружном хранилище приложения. Каждый ingest приводит к
/// локальной строке трека, поэтому дальше по ним идёт общая цепочка источников.
final localTracksProvider = FutureProvider<List<Track>>((ref) async {
  final services = ref.watch(appServicesProvider);
  final result = await LocalSource().search('', pageSize: 500);

  final ids = await services.db.tracksDao.ingestAll(result.tracks);
  AppLogger.instance.info('найдено локальных файлов: ${result.tracks.length}');
  if (ids.isEmpty) return const [];
  return services.db.tracksDao.byIdList(ids);
});

/// Пикер «Недавних»: любая новая запись истории пересобирает раздел, даже
/// если экран всё это время лежал под плеером и не пересоздавался.
final historyTickProvider = StreamProvider.autoDispose<int>((ref) {
  final db = ref.watch(appServicesProvider).db;
  return db.select(db.history).watch().map((rows) => rows.length);
});

final databaseInfoProvider = FutureProvider<DatabaseInfo>((ref) async {
  final db = ref.watch(appServicesProvider).db;
  return DatabaseInfo(
    schemaVersion: await db.schemaVersionInDb(),
    rows: await db.rowCountSnapshot(),
  );
});

final downloadQueueStatsProvider =
    StreamProvider.autoDispose<DownloadQueueStats>(
      (ref) => ref.watch(appServicesProvider).db.downloadsDao.watchStats(),
    );

final downloadedFilesSummaryProvider =
    StreamProvider.autoDispose<DownloadedFilesSummary>(
      (ref) => ref
          .watch(appServicesProvider)
          .db
          .downloadsDao
          .watchCompletedFilesSummary(),
    );

final sourcePriorityProvider = FutureProvider<List<SourceId>>((ref) async {
  final services = ref.watch(appServicesProvider);
  final order = await services.db.settingsDao.playbackPriority();
  // В сохранённом порядке могли остаться источники, которых больше нет в
  // сборке (например, YouTube): в настройках им нечего показывать.
  return [
    for (final id in order)
      if (services.registry.byId(id) != null) id,
  ];
});

/// Стартовое значение читает main() до runApp: провайдер берёт его при первом
/// build, дальше только перезапись одним blob'ом в `app_settings`.
Prefs initialPrefs = const Prefs();

class PrefsController extends Notifier<Prefs> {
  @override
  Prefs build() => initialPrefs;

  Future<void> _write(Prefs next) async {
    state = next;
    await savePrefs(AppServices.ensure().db, next);
    AppServices.ensure().applyPreferences();
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _write(state.copyWith(themeMode: mode));

  Future<void> setPalette(AppPalette palette) =>
      _write(state.copyWith(palette: palette));

  Future<void> setAccent(AccentColor accent) =>
      _write(state.copyWith(accent: accent));

  Future<void> setContrast(Contrast contrast) =>
      _write(state.copyWith(contrast: contrast));

  Future<void> setCorner(CornerRadius corner) =>
      _write(state.copyWith(corner: corner));

  Future<void> setMotion(AnimationsSpeed speed) =>
      _write(state.copyWith(animations: speed));

  Future<void> setLocaleCode(String? code) => _write(
    code == null
        ? state.copyWith(clearLocale: true)
        : state.copyWith(localeCode: code),
  );

  Future<void> setCollectionSort(CollectionSort sort) =>
      _write(state.copyWith(collectionSort: sort));

  Future<void> setLauncherIcon(LauncherIcon icon) =>
      _write(state.copyWith(launcherIcon: icon));

  Future<void> setQuality(String quality) =>
      _write(state.copyWith(quality: quality));

  Future<void> setFade(bool value) => _write(state.copyWith(fade: value));

  Future<void> setCrossfadeSeconds(int value) =>
      _write(state.copyWith(crossfadeSeconds: value));

  Future<void> setEqEnabled(bool value) =>
      _write(state.copyWith(eqEnabled: value));

  Future<void> setEqPreset(String value) =>
      _write(state.copyWith(eqPreset: value));

  /// Своя кривая: слайдеры уже прислали итоговые дБ, пресет — custom.
  Future<void> setEqCustom(List<double> gains, double level) => _write(
    state.copyWith(
      eqPreset: 'custom',
      eqCustomGains: List<double>.unmodifiable(gains),
      eqCustomLevel: level,
    ),
  );

  Future<void> setLyricsSize(LyricsSize size) =>
      _write(state.copyWith(lyricsSize: size));

  Future<void> setLyricsDim(bool value) =>
      _write(state.copyWith(lyricsDimOthers: value));

  Future<void> setCompactUi(bool value) =>
      _write(state.copyWith(compactUi: value));

  Future<void> setShowMiniPlayer(bool value) =>
      _write(state.copyWith(showMiniPlayer: value));

  Future<void> setShowNavLabels(bool value) =>
      _write(state.copyWith(showNavLabels: value));

  Future<void> setSpinCookies(bool value) =>
      _write(state.copyWith(spinCookies: value));

  Future<void> setCollectStats(bool value) =>
      _write(state.copyWith(collectStats: value));

  Future<void> setArtworkShape(ArtworkShape value) =>
      _write(state.copyWith(artworkShape: value));

  Future<void> setHideAiTracks(bool value) async {
    if (value) await AiFilter.instance.ensureLoaded(force: true);
    await _write(state.copyWith(hideAiTracks: value));
  }

  Future<void> setHomeCoverTone(HomeCoverTone tone) =>
      _write(state.copyWith(homeCoverTone: tone));

  Future<void> setBlurBottom(double value) =>
      _write(state.copyWith(blurBottom: value));

  Future<void> setBlurTop(double value) =>
      _write(state.copyWith(blurTop: value));

  Future<void> setBlurCover(double value) =>
      _write(state.copyWith(blurCover: value));

  Future<void> setOpenPlayerOnPlay(bool value) =>
      _write(state.copyWith(openPlayerOnPlay: value));

  Future<void> setAutoDownloadLikes(bool value) =>
      _write(state.copyWith(autoDownloadLikes: value));

  Future<void> setAutoDownloadWifiOnly(bool value) =>
      _write(state.copyWith(autoDownloadWifiOnly: value));

  Future<void> setAutoDownloadAllApproved(bool value) =>
      _write(state.copyWith(autoDownloadAllApproved: value));

  Future<void> setDownloadLimitBytes(int? bytes) => _write(
    bytes == null
        ? state.copyWith(clearDownloadLimit: true)
        : state.copyWith(downloadLimitBytes: bytes),
  );

  Future<void> setAutoDownloadQuality(String quality) {
    final normalized = const {'low', 'normal', 'high'}.contains(quality)
        ? quality
        : 'normal';
    return _write(state.copyWith(autoDownloadQuality: normalized));
  }

  Future<void> setCensorBypass(bool value) async {
    CensorBase.instance.enabled = value;
    final services = ref.read(appServicesProvider);
    services.resolver.clearMemoryCache();
    unawaited(services.db.streamsDao.clearResolutions());
    if (value) {
      unawaited(CensorBase.instance.ensureLoaded(force: true));
    }
    await _write(state.copyWith(censorBypass: value));
  }

  static const _searchHistoryLimit = 12;

  /// Запрос попадает в историю только когда его реально отправили или
  /// открыли результат: иначе туда текут все промежуточные нажатия.
  Future<void> rememberSearch(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return;
    if (state.searchHistory.isNotEmpty &&
        state.searchHistory.first.toLowerCase() == normalized.toLowerCase()) {
      return;
    }
    final next = [
      normalized,
      ...state.searchHistory.where(
        (item) => item.toLowerCase() != normalized.toLowerCase(),
      ),
    ].take(_searchHistoryLimit).toList();
    await _write(state.copyWith(searchHistory: next));
  }

  Future<void> clearSearchHistory() =>
      _write(state.copyWith(searchHistory: const []));

  Future<void> setHomeBackground(HomeBackground value) =>
      _write(state.copyWith(homeBackground: value));

  /// Значок лаунчера при сбросе не трогаем: он переключается в системе, и
  /// сброс одной строки в настройках разводил их — в лаунчере оставался
  /// выбранный значок, а настройки и заставка показывали стандартный.
  Future<void> reset() =>
      _write(const Prefs().copyWith(launcherIcon: state.launcherIcon));

  Future<void> setWaveOnWifiOnly(bool value) =>
      _write(state.copyWith(waveOnWifiOnly: value));

  Future<void> setWaveSoundCloud(bool value) =>
      _write(state.copyWith(waveSoundCloud: value));
}

final prefsProvider = NotifierProvider<PrefsController, Prefs>(
  PrefsController.new,
);

/// Обложка трека по локальному id — нужна для превью соседнего трека при
/// свайпе в плеере, где под рукой только очередь из id.
final trackCoverProvider = FutureProvider.autoDispose.family<String?, String>((
  ref,
  id,
) async {
  final track = await ref.watch(appServicesProvider).db.tracksDao.byId(id);
  return track?.coverUrl;
});

/// Полные строки очереди для шторки: номер, обложка, автор и длительность.
final queueRowsProvider = FutureProvider.autoDispose
    .family<List<CollectionRow>, List<String>>((ref, ids) async {
      final db = ref.watch(appServicesProvider).db;
      return db.libraryDao.rowsForIds(ids);
    });

/// Поиск по всем подключённым источникам сразу. Источник без входа
/// молча пропускается: просить логиниться — дело экрана входа.
///
/// Отдаём результаты по мере готовности, а не ждём самый медленный источник:
/// иначе медленный SoundCloud держал пустой экран, хотя Яндекс уже ответил.
/// Загружает список ИИ-исполнителей для бейджей «ИИ» в списках.
/// Один общий future: строки только смотрят на его готовность.
final aiBadgeReadyProvider = FutureProvider<void>((ref) async {
  await AiFilter.instance.ensureLoaded();
});

final combinedSearchProvider = StreamProvider.autoDispose
    .family<List<SourceSearchHit>, String>((ref, query) {
      final registry = ref.watch(appServicesProvider).registry;
      final needle = query.trim();
      if (needle.isEmpty) return Stream.value(const <SourceSearchHit>[]);
      final hideAi = ref.watch(prefsProvider.select((p) => p.hideAiTracks));

      final sources = [
        for (final source in registry.all)
          if (source.capabilities.canSearch &&
              (!source.capabilities.requiresAuth || source.auth.isReady))
            source,
      ];
      if (sources.isEmpty) return Stream.value(const <SourceSearchHit>[]);

      late final StreamController<List<SourceSearchHit>> controller;
      final bySource = <SourceId, List<SourceSearchHit>>{};
      var pending = sources.length;

      List<SourceSearchHit> snapshot() => [
        for (final source in sources) ...?bySource[source.id],
      ];

      void finish() {
        pending--;
        if (pending == 0 && !controller.isClosed) controller.close();
      }

      controller = StreamController<List<SourceSearchHit>>(
        onListen: () {
          for (final source in sources) {
            () async {
              try {
                if (hideAi) await AiFilter.instance.ensureLoaded();
                final result = await source
                    .search(needle, pageSize: 20)
                    .timeout(const Duration(seconds: 10));
                bySource[source.id] = [
                  for (final track in result.tracks)
                    if ((!hideAi || !AiFilter.instance.isAiTrack(track)) &&
                        !ArtistBlocklist.instance.isBlocked(track.artists))
                      SourceSearchHit(track.ref.source, track),
                ];
                if (!controller.isClosed) controller.add(snapshot());
              } on Object {
                // Один упавший источник не должен гасить весь поиск.
              } finally {
                finish();
              }
            }();
          }
        },
      );
      ref.onDispose(controller.close);
      return controller.stream;
    });

/// Артисты и альбомы для экрана поиска. Треки идут общим каскадом, поэтому
/// здесь отдельный запрос `type=all` и только две секции.
final yandexSearchSectionsProvider = FutureProvider.autoDispose
    .family<SearchSections, String>((ref, query) async {
      final source = ref.watch(yandexSourceProvider);
      if (source == null || !ref.watch(yandexReadyProvider)) {
        return const SearchSections();
      }
      return source.searchSections(query);
    });

final yandexSourceProvider = Provider<YandexSource?>((ref) {
  final source = ref.watch(appServicesProvider).registry.byId(SourceId.yandex);
  return source is YandexSource ? source : null;
});

final yandexAuthStateProvider = StreamProvider<AuthState>((ref) async* {
  final source = ref.watch(yandexSourceProvider);
  if (source == null) {
    yield const AuthUnknown();
    return;
  }
  yield source.auth;
  yield* source.authChanges;
});

/// Готовность аккаунта одним флагом. Запросы каталога без неё уходят до
/// восстановления токена и кэшируют пустой ответ — из-за этого волна
/// оставалась пустой до перезапуска приложения.
final yandexReadyProvider = Provider<bool>((ref) {
  final auth = ref.watch(yandexAuthStateProvider).value;
  return auth is AuthReady;
});

final class SourceSearchHit {
  const SourceSearchHit(this.source, this.track);

  final SourceId source;
  final SourceTrack track;
}

/// Раздел коллекции: порядок стабильный, исполнитель и обложка достаются
/// из тех же двух запросов — списки не дёргают базу на каждую строку.
final collectionProvider = FutureProvider.autoDispose
    .family<List<CollectionRow>, CollectionKind>((ref, kind) async {
      final db = ref.watch(appServicesProvider).db;
      final sort = ref.watch(prefsProvider.select((p) => p.collectionSort));
      final hideAi = ref.watch(prefsProvider.select((p) => p.hideAiTracks));
      // «Недавние» остаются смонтированными под открытым плеером, поэтому
      // без тика истории список показывал бы старый порядок до перезахода.
      if (kind == CollectionKind.recent) ref.watch(historyTickProvider);
      final rows = await db.libraryDao.collectionRows(kind, sort: sort);
      if (!hideAi) return rows;
      await AiFilter.instance.ensureLoaded();
      return [
        for (final row in rows)
          if (!AiFilter.instance.isAiRow(
            row.title,
            row.artist,
            row.artistRemoteIds,
          ))
            row,
      ];
    });

/// Исполнители, которых чаще всего слушают: считается по истории.
///
/// Сначала отдаём то, что уже есть в базе, а аватары без обложек добираем
/// из карточек Яндекса фоном: `topArtists` не должен ждать десяток запросов.
final topArtistsProvider = FutureProvider<List<ArtistPlaycount>>((ref) async {
  final db = ref.watch(appServicesProvider).db;
  final artists = await db.libraryDao.topArtists(limit: 12);
  final source = ref.watch(yandexSourceProvider);
  final missing = [
    for (final artist in artists)
      if (artist.coverUrl == null && artist.remoteId.isNotEmpty) artist,
  ].take(10).toList();
  if (source != null && missing.isNotEmpty) {
    unawaited(_backfillArtistCovers(ref, source, db, missing));
  }
  return artists;
});

Future<void> _backfillArtistCovers(
  Ref ref,
  YandexSource source,
  AppDatabase db,
  List<ArtistPlaycount> artists,
) async {
  var changed = false;
  for (final artist in artists) {
    try {
      final brief = await source.artist(artist.remoteId);
      if (brief?.coverUrl == null) continue;
      await db.libraryDao.setArtistCover(artist.artistId, brief!.coverUrl);
      changed = true;
    } on Object {
      // Сеть/токен недоступны — обложка догрузится при следующем открытии.
      continue;
    }
  }
  if (changed) ref.invalidateSelf();
}

/// Текст трека из LRCLIB. Пустой `Lyrics` — это «текста нет», а не ошибка:
/// экран караоке показывает именно это, без виджета загрузки на полчаса.
final trackLyricsProvider = FutureProvider.autoDispose.family<Lyrics, String>((
  ref,
  trackId,
) async {
  final db = ref.watch(appServicesProvider).db;
  final track = await db.tracksDao.byId(trackId);
  if (track == null) return const Lyrics(lines: [], synced: false);
  final artists = await db.tracksDao.artistNamesOf(trackId);
  final variants = await db.tracksDao.variantsOf(trackId);
  SourceTrack? yandexVariant;
  for (final variant in variants) {
    if (variant.ref.source == SourceId.yandex) {
      yandexVariant = variant;
      break;
    }
  }
  final yandex = ref.watch(appServicesProvider).yandex;
  Future<Lyrics?> Function()? official;
  if (yandexVariant != null && yandex != null) {
    final remoteId = yandexVariant.ref.remoteId;
    official = () => yandex.lyrics(remoteId);
  }
  return LyricsService.shared.fetch(
    title: track.title,
    artist: artists.isEmpty ? '' : artists.first,
    album: await db.tracksDao.albumTitleOf(trackId),
    duration: Duration(seconds: track.durationSec),
    official: official,
  );
});

/// Карточка исполнителя из Яндекса: фото, счётчики, популярные треки, альбомы.
final artistBriefProvider = FutureProvider.autoDispose
    .family<ArtistBrief?, String>((ref, artistId) async {
      final source = ref.watch(yandexSourceProvider);
      if (source == null) return null;
      final artist = await source.artist(artistId);
      if (artist == null) return null;
      final hideAi = ref.watch(prefsProvider.select((p) => p.hideAiTracks));
      if (!hideAi) return artist;
      await AiFilter.instance.ensureLoaded();
      return ArtistBrief(
        remoteId: artist.remoteId,
        name: artist.name,
        coverUrl: artist.coverUrl,
        trackCount: artist.trackCount,
        albumCount: artist.albumCount,
        listeners: artist.listeners,
        popular: [
          for (final track in artist.popular)
            if (!AiFilter.instance.isAiTrack(track)) track,
        ],
        albums: artist.albums,
      );
    });

/// Все треки артиста, а не только популярная пятёрка.
final artistTracksProvider = FutureProvider.autoDispose
    .family<List<SourceTrack>, String>((ref, artistId) async {
      final source = ref.watch(yandexSourceProvider);
      if (source == null) return const [];
      final tracks = await source.artistTracks(artistId);
      final hideAi = ref.watch(prefsProvider.select((p) => p.hideAiTracks));
      if (!hideAi) return tracks;
      await AiFilter.instance.ensureLoaded();
      return [
        for (final track in tracks)
          if (!AiFilter.instance.isAiTrack(track)) track,
      ];
    });

/// Полная дискография артиста.
final artistAlbumsProvider = FutureProvider.autoDispose
    .family<List<AlbumBrief>, String>((ref, artistId) async {
      final source = ref.watch(yandexSourceProvider);
      if (source == null) return const [];
      final albums = await source.artistAlbums(artistId);
      final hideAi = ref.watch(prefsProvider.select((p) => p.hideAiTracks));
      if (!hideAi) return albums;
      await AiFilter.instance.ensureLoaded();
      return [
        for (final album in albums)
          if (!album.artistIds.any(AiFilter.instance.isAiArtistId)) album,
      ];
    });

/// Альбом целиком — треки приходят в порядке диска.
final albumProvider = FutureProvider.autoDispose.family<AlbumSnapshot?, String>(
  (ref, albumId) async {
    final source = ref.watch(yandexSourceProvider);
    if (source == null) return null;
    final album = await source.album(albumId);
    if (album == null) return null;
    final hideAi = ref.watch(prefsProvider.select((p) => p.hideAiTracks));
    if (!hideAi) return album;
    await AiFilter.instance.ensureLoaded();
    return AlbumSnapshot(
      remoteId: album.remoteId,
      title: album.title,
      coverUrl: album.coverUrl,
      year: album.year,
      artists: album.artists,
      tracks: [
        for (final track in album.tracks)
          if (!AiFilter.instance.isAiTrack(track)) track,
      ],
    );
  },
);

/// Новинки лендинга для раздела «Что послушать».
final newReleasesProvider = FutureProvider<List<AlbumBrief>>((ref) async {
  final source = ref.watch(yandexSourceProvider);
  if (source == null || !ref.watch(yandexReadyProvider)) return const [];
  final albums = await source.newReleases(limit: 12);
  final hideAi = ref.watch(prefsProvider.select((p) => p.hideAiTracks));
  if (!hideAi) return albums;
  await AiFilter.instance.ensureLoaded();
  return [
    for (final album in albums)
      if (!album.artistIds.any(AiFilter.instance.isAiArtistId)) album,
  ];
});

/// Полная лента новинок для страницы «Новые релизы».
final newReleasesPageProvider = FutureProvider.autoDispose<List<AlbumBrief>>((
  ref,
) async {
  final source = ref.watch(yandexSourceProvider);
  if (source == null || !ref.watch(yandexReadyProvider)) return const [];
  final albums = await source.newReleases(limit: 30);
  final hideAi = ref.watch(prefsProvider.select((p) => p.hideAiTracks));
  if (!hideAi) return albums;
  await AiFilter.instance.ensureLoaded();
  return [
    for (final album in albums)
      if (!album.artistIds.any(AiFilter.instance.isAiArtistId)) album,
  ];
});

/// Чарт Яндекса: позиция и трек.
final chartProvider = FutureProvider<List<ChartEntry>>((ref) async {
  final source = ref.watch(yandexSourceProvider);
  if (source == null) return const [];
  final entries = await source.chart();
  AppLogger.instance.info('чарт: ${entries.length} треков');
  final hideAi = ref.watch(prefsProvider.select((p) => p.hideAiTracks));
  if (!hideAi) return entries;
  await AiFilter.instance.ensureLoaded();
  return [
    for (final entry in entries)
      if (!AiFilter.instance.isAiTrack(entry.track)) entry,
  ];
});

/// Фоновая синхронизация коллекции: раз в сутки, уже после первого кадра.
/// Без неё лайки остаются в том объёме, каким их застал прошлый импорт, —
/// именно из-за этого в коллекции висело 500 из 1028.
const String _likesSyncedKey = 'likes_synced_at_v2';
const String _dislikesSyncedKey = 'dislikes_synced_at_v2';

/// Прогрев «Обзора»: чарт и новинки качаются сразу после входа, а не в
/// момент открытия вкладки. Без этого секция новинок появлялась позже всех
/// и сдвигала уже показанный экран.
final discoverWarmupProvider = FutureProvider<void>((ref) async {
  if (!ref.watch(yandexReadyProvider)) return;
  await Future.wait([
    ref
        .watch(chartProvider.future)
        .catchError((Object _) => const <ChartEntry>[]),
    ref
        .watch(newReleasesProvider.future)
        .catchError((Object _) => const <AlbumBrief>[]),
  ]);
});

/// Прогрев обложек коллекции в дисковом кэше: карточки «Любимого» и
/// недавних треков открываются без серых квадратов. Сами строки из базы
/// не держим — они перечитываются быстро, дорогие здесь только картинки.
final collectionWarmupProvider = FutureProvider<void>((ref) async {
  Future<List<CollectionRow>> rows(Future<List<CollectionRow>> future) async {
    try {
      return await future;
    } on Object {
      return const [];
    }
  }

  final liked = await rows(
    ref.read(collectionProvider(CollectionKind.liked).future),
  );
  final recent = await rows(
    ref.read(collectionProvider(CollectionKind.recent).future),
  );
  final artists = await _safeArtists(ref);
  final urls = <String>[
    for (final row in [...liked.take(4), ...recent.take(8)])
      if (row.coverUrl != null && row.coverUrl!.isNotEmpty) row.coverUrl!,
    for (final artist in artists.take(6))
      if (artist.coverUrl != null && artist.coverUrl!.isNotEmpty)
        artist.coverUrl!,
  ];
  if (urls.isEmpty) return;
  final manager = DefaultCacheManager();
  for (final url in urls) {
    try {
      await manager.getSingleFile(url);
    } on Object {
      // Одна неудачная обложка не должна останавливать прогрев.
    }
  }
});

Future<List<ArtistPlaycount>> _safeArtists(Ref ref) async {
  try {
    return await ref.read(topArtistsProvider.future);
  } on Object {
    return const [];
  }
}

final librarySyncProvider = FutureProvider<void>((ref) async {
  final services = ref.watch(appServicesProvider);
  final source = ref.watch(yandexSourceProvider);
  if (source == null) return;

  // Ждём восстановления аккаунта: до него auth не ready, и импорт вернёт
  // пустой список, а отметка о синхронизации соврёт.
  if (!source.auth.isReady) {
    try {
      await services.restoreAccount();
    } on Object {
      return;
    }
  }
  if (!source.auth.isReady) return;

  // Снятые здесь лайки, которые не дошли до Яндекса, повторяем при каждой
  // синхронизации, а не раз в сутки.
  try {
    await PendingUnlikes.retry(services.db, source);
  } on Object catch (error) {
    AppLogger.instance.warn('снятие лайков не повторилось: $error');
  }
  try {
    await PendingFeedback.retry(services.db, source);
  } on Object catch (error) {
    AppLogger.instance.warn('офлайн-лайки не дошли: $error');
  }

  final lastRaw = await services.db.settingsDao.value(_likesSyncedKey);
  final last = lastRaw == null
      ? null
      : DateTime.tryParse(lastRaw.replaceAll('"', ''));
  final likesFresh =
      last != null &&
      DateTime.now().difference(last) < const Duration(hours: 24);

  var likes = 0;
  if (!likesFresh) {
    try {
      likes = await importYandexLikes(source: source, db: services.db);
    } on Object catch (error) {
      AppLogger.instance.warn('лайки не синхронизировались: $error');
    }
    // Если часть пачек не разрешилась, отметку не ставим: иначе недостающие
    // лайки не доберутся ещё сутки.
    final complete =
        source.lastLikesExpected == 0 || likes >= source.lastLikesExpected;
    if (likes > 0 && complete) {
      await services.db.settingsDao.setValue(
        _likesSyncedKey,
        DateTime.now().toIso8601String(),
      );
      ref.invalidate(collectionProvider);
    } else if (likes > 0) {
      AppLogger.instance.warn(
        'лайки: импортировано $likes из ${source.lastLikesExpected}, повторю позже',
      );
      ref.invalidate(collectionProvider);
    }
  }

  // «Нелюбимое» — отдельный список в API. Импортируем после лайков, чтобы
  // трек, который на сервере уже не рекомендован, не остался любимым.
  final lastDislikesRaw = await services.db.settingsDao.value(
    _dislikesSyncedKey,
  );
  final lastDislikes = lastDislikesRaw == null
      ? null
      : DateTime.tryParse(lastDislikesRaw.replaceAll('"', ''));
  final dislikesFresh =
      lastDislikes != null &&
      DateTime.now().difference(lastDislikes) < const Duration(hours: 6);
  if (!dislikesFresh) {
    try {
      final dislikes = await importYandexDislikes(
        source: source,
        db: services.db,
      );
      await services.db.settingsDao.setValue(
        _dislikesSyncedKey,
        DateTime.now().toIso8601String(),
      );
      if (dislikes > 0) ref.invalidate(collectionProvider);
    } on Object catch (error) {
      AppLogger.instance.warn('«Нелюбимое» не синхронизировалось: $error');
    }
  }

  // Плейлисты — отдельно: падение одного не должно отменять лайки.
  try {
    final lists = await importYandexPlaylists(source: source, db: services.db);
    AppLogger.instance.info('коллекция: $likes лайков, $lists плейлистов');
    ref.invalidate(playlistsProvider);
  } on Object catch (error) {
    AppLogger.instance.warn('плейлисты не синхронизировались: $error');
  }
});

final playlistsProvider = FutureProvider<List<PlaylistOverview>>(
  (ref) => ref.watch(appServicesProvider).db.libraryDao.playlistsOverview(),
);

/// Плейлист по локальному id (`yandex:<kind>`): шапка и треки в порядке источника.
final playlistProvider = FutureProvider.autoDispose
    .family<PlaylistDetail?, String>((ref, id) async {
      final services = ref.watch(appServicesProvider);
      final db = services.db;
      // Открываем плейлист — тянем его содержимое с Яндекса: треки, добавленные
      // в «настоящем» приложении, иначе дождались бы только суточной
      // синхронизации. Без сети или при отказе молча читаем то, что в базе.
      final yandex = services.yandex;
      if (id.startsWith('yandex:') &&
          yandex != null &&
          yandex.auth is AuthReady) {
        try {
          final snapshot = await yandex.getPlaylist(id.substring(7));
          if (snapshot != null) {
            await db.libraryDao.importPlaylist(
              source: SourceId.yandex,
              snapshot: snapshot,
            );
          }
        } on Object {
          // Офлайн — показываем кэш.
        }
      }
      final overview = await db.libraryDao.playlistById(id);
      if (overview == null) return null;
      final hideAi = ref.watch(prefsProvider.select((p) => p.hideAiTracks));
      final rows = await db.libraryDao.playlistRows(id);
      if (hideAi) await AiFilter.instance.ensureLoaded();
      return PlaylistDetail(
        overview: overview,
        rows: hideAi
            ? [
                for (final row in rows)
                  if (!AiFilter.instance.isAiRow(
                    row.title,
                    row.artist,
                    row.artistRemoteIds,
                  ))
                    row,
              ]
            : rows,
      );
    });

/// Разовый переимпорт плейлистов. Первый маркер (v3) чинил повторы после
/// миграции; второй (v4) — короткие ссылки `/playlists`; третий (v5) —
/// отравленные этими ссылками mapping'и: импорт теперь перезаписывает их
/// полноценными треками. Маркер не даёт гонять это на каждом запуске; без
/// сети просто повторим в следующий раз.
Future<void> reimportPlaylistsOnce(WidgetRef ref) async {
  final services = ref.read(appServicesProvider);
  final marker = await services.db.settingsDao.value('playlists_v5_done');
  if (marker != null) return;
  final source = services.yandex;
  if (source == null) return;
  try {
    await importYandexPlaylists(source: source, db: services.db);
    await services.db.settingsDao.setValue('playlists_v5_done', '1');
    ref.invalidate(playlistsProvider);
  } on Object {
    // Офлайн или отказ — попробуем при следующем запуске.
  }
}

/// Импортирует лайки Яндекса в локальную базу. Аргументы явные, чтобы
/// функцию могли вызвать и провайдер, и виджет.
///
/// `refreshTimestamp: false` — повторный импорт не должен переставлять
/// коллекцию: дата лайка ставится один раз, при первом попадании в базу.
Future<int> importYandexLikes({
  required YandexSource? source,
  required AppDatabase db,
}) async {
  if (source == null) return 0;

  // Лайки, снятые здесь, но не снятые в Яндексе: сначала пробуем снять ещё
  // раз, а оставшиеся не даём импорту вернуть обратно.
  final pending = await PendingUnlikes.retry(db, source);
  final all = await source.likedTracks();
  final entries = [
    for (final entry in all)
      if (!pending.contains(entry.track.ref.remoteId)) entry,
  ];
  // Одна транзакция на весь импорт, а дата лайка — из Яндекса, а не «сейчас»:
  // повторный импорт не должен переставлять коллекцию.
  await db.transaction(() async {
    for (final entry in entries) {
      final ingested = await db.tracksDao.ingest(entry.track);
      await db.libraryDao.setLike(
        ingested.localTrackId,
        1,
        remoteSource: SourceId.yandex,
        refreshTimestamp: false,
        likedAt: entry.likedAt,
      );
    }
  });
  return all.length;
}

/// Импортирует «Нелюбимое» Яндекса. Отметка -1 перезаписывает локальный
/// лайк: на сервере эти состояния взаимоисключающие.
Future<int> importYandexDislikes({
  required YandexSource? source,
  required AppDatabase db,
}) async {
  if (source == null) return 0;
  final entries = await source.dislikedTracks();
  await db.transaction(() async {
    for (final entry in entries) {
      final ingested = await db.tracksDao.ingest(entry.track);
      await db.libraryDao.setLike(
        ingested.localTrackId,
        -1,
        remoteSource: SourceId.yandex,
        refreshTimestamp: false,
        likedAt: entry.likedAt,
      );
    }
  });
  return entries.length;
}

/// Быстрая синхронизация списка плейлистов: полные треки тянутся только у
/// новых и изменившихся по количеству. Именно поэтому добавленный в другом
/// клиенте плейлист появляется без перезапуска и без импорта всей коллекции.
Future<int> syncYandexPlaylists({
  required YandexSource? source,
  required AppDatabase db,
  int limit = 50,
}) async {
  if (source == null) return 0;
  final own = await source.playlists();
  final liked = await source.likedPlaylists();
  // Один из списков не пришёл — удалять «пропавшие» плейлисты нельзя.
  final complete = own != null && liked != null;
  final summaries = <PlaylistSummary>[...?own, ...?liked];
  final local = {
    for (final playlist in await db.libraryDao.playlistsOverview())
      playlist.id: playlist,
  };
  var fetched = 0;
  for (final summary in summaries.take(limit)) {
    final id = 'yandex:${summary.remotePlaylistId}';
    final existing = local[id];
    final count = summary.trackCount;
    final changed =
        existing == null || (count != null && existing.trackCount != count);
    if (!changed) continue;
    final snapshot = await source.getPlaylist(summary.remotePlaylistId);
    if (snapshot == null) continue;
    await db.libraryDao.importPlaylist(
      source: SourceId.yandex,
      snapshot: snapshot,
    );
    fetched++;
  }
  if (complete && summaries.length <= limit) {
    await db.libraryDao.removePlaylistsExcept({
      for (final summary in summaries) 'yandex:${summary.remotePlaylistId}',
    });
  }
  return fetched;
}

/// Быстрый синк по запросу экрана или возврата приложения. Полный обход
/// сервера не чаще раза в 30 секунд, если не просили force.
class PlaylistSyncController extends Notifier<DateTime?> {
  bool _running = false;

  @override
  DateTime? build() => null;

  Future<bool> refresh({bool force = false}) async {
    if (_running) return false;
    final last = state;
    if (!force &&
        last != null &&
        DateTime.now().difference(last) < const Duration(seconds: 30)) {
      return false;
    }
    _running = true;
    try {
      final services = ref.read(appServicesProvider);
      final source = ref.read(yandexSourceProvider);
      if (source == null) return false;
      final changed = await syncYandexPlaylists(
        source: source,
        db: services.db,
      );
      state = DateTime.now();
      if (changed > 0) {
        ref.invalidate(playlistsProvider);
        ref.invalidate(collectionProvider);
        ref.invalidate(playlistProvider);
      }
      return changed > 0;
    } on Object catch (error) {
      AppLogger.instance.warn('быстрый синк плейлистов: $error');
      return false;
    } finally {
      _running = false;
    }
  }
}

final playlistSyncProvider =
    NotifierProvider<PlaylistSyncController, DateTime?>(
      PlaylistSyncController.new,
    );

/// Сохраняет плейлисты Яндекса целиком: список + треки внутри.
Future<int> importYandexPlaylists({
  required YandexSource? source,
  required AppDatabase db,
  int limit = 50,
}) async {
  if (source == null) return 0;

  // Сеть держим вне транзакции: под замком БД на время запроса остальные
  // чтения встают на секунды.
  final snapshots = <PlaylistSnapshot>[];
  // Свои плейлисты и понравившиеся чужие — это два разных эндпоинта.
  final own = await source.playlists();
  final liked = await source.likedPlaylists();
  // Один из списков не пришёл — удалять «пропавшие» плейлисты нельзя.
  final complete = own != null && liked != null;
  final summaries = <PlaylistSummary>[...?own, ...?liked];
  for (final summary in summaries.take(limit)) {
    final snapshot = await source.getPlaylist(summary.remotePlaylistId);
    if (snapshot != null) snapshots.add(snapshot);
  }
  await db.transaction(() async {
    for (final snapshot in snapshots) {
      await db.libraryDao.importPlaylist(
        source: SourceId.yandex,
        snapshot: snapshot,
      );
    }
  });
  // Плейлисты, удалённые на сервере, больше не висят в коллекции. Чистим
  // только если список пришёл целиком — иначе снесём лишнее при обрезке.
  if (complete && summaries.length <= limit) {
    await db.libraryDao.removePlaylistsExcept({
      for (final summary in summaries) 'yandex:${summary.remotePlaylistId}',
    });
  }
  return snapshots.length;
}

final class DatabaseInfo {
  const DatabaseInfo({required this.schemaVersion, required this.rows});

  final int schemaVersion;
  final Map<String, int> rows;
}

/// Типизированный отказ цепочки источников в человеческом виде.
String describeIssue(PlayerIssue issue) {
  final lines = [
    for (final failure in issue.failures)
      '${failure.source.wire}: ${failure.reason.name}'
          '${failure.httpStatus == null ? '' : ' (${failure.httpStatus})'}'
          '${failure.message == null || failure.message!.isEmpty ? '' : ' · ${_short(failure.message!)}'}',
  ];
  return '${issue.headline}\n${lines.join('\n')}';
}

String _short(String text) {
  final first = text.split('\n').first.trim();
  return first.length <= 140 ? first : '${first.substring(0, 140)}…';
}
