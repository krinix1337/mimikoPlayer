import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_services.dart';
import 'core/content/ai_filter.dart';
import 'core/content/censor_base.dart';
import 'core/db/daos/library_dao.dart';
import 'core/db/database.dart';
import 'core/logging/app_logger.dart';
import 'core/prefs/prefs.dart';
import 'core/prefs/prefs_store.dart';
import 'core/sources/source_dto.dart';
import 'core/sources/source_id.dart';
import 'sources/lyrics/lrclib.dart';
import 'sources/lyrics/lyrics_service.dart';
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

final historyProvider = FutureProvider<List<RecentPlay>>((ref) async {
  final services = ref.watch(appServicesProvider);
  final rows = await services.db.historyDao.recent(limit: 30);
  if (rows.isEmpty) return const [];

  final tracks = await services.db.tracksDao.byIdList(
    rows.map((e) => e.localTrackId).toSet().toList(),
  );
  final byId = {for (final t in tracks) t.id: t};

  return [
    for (final row in rows)
      if (byId[row.localTrackId] case final track?)
        RecentPlay(
          localTrackId: row.localTrackId,
          title: track.title,
          playedAt: row.playedAt,
          source: SourceId.fromWire(row.source),
        ),
  ];
});

final databaseInfoProvider = FutureProvider<DatabaseInfo>((ref) async {
  final db = ref.watch(appServicesProvider).db;
  return DatabaseInfo(
    schemaVersion: await db.schemaVersionInDb(),
    rows: await db.rowCountSnapshot(),
  );
});

final sourcePriorityProvider = FutureProvider<List<SourceId>>(
  (ref) => ref.watch(appServicesProvider).db.settingsDao.playbackPriority(),
);

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

  Future<void> setFrameHz(double hz) => _write(state.copyWith(frameHz: hz));

  Future<void> setFade(bool value) => _write(state.copyWith(fade: value));

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

  Future<void> setArtworkShape(ArtworkShape value) =>
      _write(state.copyWith(artworkShape: value));

  Future<void> setHideAiTracks(bool value) async {
    if (value) await AiFilter.instance.ensureLoaded(force: true);
    await _write(state.copyWith(hideAiTracks: value));
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

  Future<void> setHomeBackground(HomeBackground value) =>
      _write(state.copyWith(homeBackground: value));

  Future<void> reset() => _write(const Prefs());

  Future<void> setWaveOnWifiOnly(bool value) =>
      _write(state.copyWith(waveOnWifiOnly: value));
}

final prefsProvider = NotifierProvider<PrefsController, Prefs>(
  PrefsController.new,
);

/// Заголовок трека по локальному id — для очередей и списков истории.
final trackTitleProvider = FutureProvider.family<String, String>((
  ref,
  id,
) async {
  final track = await ref.watch(appServicesProvider).db.tracksDao.byId(id);
  return track?.title ?? id;
});

/// Поиск по всем подключённым источникам сразу. Источник без входа
/// молча пропускается: просить логиниться — дело экрана входа.
///
/// Отдаём результаты по мере готовности, а не ждём самый медленный источник:
/// иначе медленный YouTube держал пустой экран, хотя Яндекс уже ответил.
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
                    if (!hideAi || !AiFilter.instance.isAiTrack(track))
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

  final lastRaw = await services.db.settingsDao.value(_likesSyncedKey);
  final last = lastRaw == null
      ? null
      : DateTime.tryParse(lastRaw.replaceAll('"', ''));
  if (last != null &&
      DateTime.now().difference(last) < const Duration(hours: 24)) {
    return;
  }

  var likes = 0;
  try {
    likes = await importYandexLikes(source: source, db: services.db);
  } on Object catch (error) {
    AppLogger.instance.warn('лайки не синхронизировались: $error');
  }
  if (likes > 0) {
    await services.db.settingsDao.setValue(
      _likesSyncedKey,
      DateTime.now().toIso8601String(),
    );
    ref.invalidate(collectionProvider);
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
      final db = ref.watch(appServicesProvider).db;
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

  final entries = await source.likedTracks();
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
  return entries.length;
}

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
  for (final summary in (await source.playlists()).take(limit)) {
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
  return snapshots.length;
}

final class RecentPlay {
  const RecentPlay({
    required this.localTrackId,
    required this.title,
    required this.playedAt,
    required this.source,
  });

  final String localTrackId;
  final String title;
  final DateTime playedAt;
  final SourceId source;
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
