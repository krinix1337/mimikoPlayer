import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/auth_dao.dart';
import 'daos/downloads_dao.dart';
import 'daos/history_dao.dart';
import 'daos/library_dao.dart';
import 'daos/queue_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/stats_dao.dart';
import 'daos/streams_dao.dart';
import 'daos/tracks_dao.dart';
import 'migrations/schema_versions.dart';
import 'tables/collections.dart';
import 'tables/library.dart';
import 'tables/playback.dart';
import 'tables/settings.dart';

part 'database.g.dart';

/// База приложения. Всё чтение/запись идёт через DAO ниже — миграции поэтому
/// не задевают UI.
@DriftDatabase(
  tables: [
    Artists,
    Albums,
    Tracks,
    TrackArtists,
    RemoteIdMappings,
    Playlists,
    PlaylistTracks,
    Likes,
    History,
    QueueSnapshots,
    StreamResolutions,
    TrackFailures,
    DownloadedFiles,
    DownloadTasks,
    AuthTokens,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(
        driftDatabase(
          name: 'phoneyandex',
          native: const DriftNativeOptions(setup: _configureConnection),
        ),
      );

  /// Фоновая автозагрузка живёт в отдельном Flutter-движке и держит своё
  /// соединение с тем же файлом. Без ожидания блокировки запись из окна
  /// сразу падала с «database is locked» ещё до первого кадра — оставался
  /// чёрный экран. Ждём до 10 с, пока соседнее соединение допишет.
  static void _configureConnection(dynamic db) {
    db.execute('PRAGMA busy_timeout = 10000');
  }

  /// Для unit-тестов поверх NativeDatabase.memory().
  AppDatabase.forTesting(super.executor);

  TracksDao get tracksDao => TracksDao(this);
  DownloadsDao get downloadsDao => DownloadsDao(this);
  StreamsDao get streamsDao => StreamsDao(this);
  HistoryDao get historyDao => HistoryDao(this);
  StatsDao get statsDao => StatsDao(this);
  QueueDao get queueDao => QueueDao(this);
  SettingsDao get settingsDao => SettingsDao(this);
  AuthDao get authDao => AuthDao(this);
  LibraryDao get libraryDao => LibraryDao(this);

  @override
  int get schemaVersion => latestSchemaVersion;

  /// Шаги живут здесь, а не в `schema_versions.dart`: им нужны геттеры
  /// таблиц, и импорт этого файла туда создал бы цикл.
  late final Map<int, MigrationStep> _migrationSteps = {
    1: MigrationStep(
      description:
          'базовая схема: треки, плейлисты, лайки, история, кэш потоков',
      up: (m) => m.createAll(),
    ),
    2: MigrationStep(
      description: 'очередь загрузок, источник и локальная обложка',
      up: (m) async {
        await m.createTable(downloadTasks);
        await m.addColumn(downloadedFiles, downloadedFiles.origin);
        await m.addColumn(downloadedFiles, downloadedFiles.coverPath);
      },
    ),
    3: MigrationStep(
      description: 'дубли треков в плейлисте: ключ по позиции',
      up: (m) => m.alterTable(TableMigration(playlistTracks)),
    ),
    4: MigrationStep(
      description: 'пометка «скачан без цензуры»',
      up: (m) => m.addColumn(downloadedFiles, downloadedFiles.uncensored),
    ),
    5: MigrationStep(
      description: 'флаг «в статистике» у истории',
      up: (m) => m.addColumn(history, history.inStats),
    ),
  };

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Не запускаем последний шаг на чистой установке: шаг 2 добавляет
    // колонки к уже существующей таблице и без createAll не создаст базу.
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      for (var version = from + 1; version <= to; version++) {
        final step = _migrationSteps[version];
        if (step == null) {
          throw StateError('нет миграции для версии $version');
        }
        await step.up(m);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );

  /// Счётчики таблиц для debug-экрана: проверка, что схема реально создана и
  /// переживает kill процесса.
  Future<Map<String, int>> rowCountSnapshot() async => {
    'tracks': await _count(tracks, 'tracks'),
    'artists': await _count(artists, 'artists'),
    'albums': await _count(albums, 'albums'),
    'remote_id_mappings': await _count(remoteIdMappings, 'remote_id_mappings'),
    'playlists': await _count(playlists, 'playlists'),
    'playlist_tracks': await _count(playlistTracks, 'playlist_tracks'),
    'likes': await _count(likes, 'likes'),
    'history': await _count(history, 'history'),
    'stream_resolutions': await _count(streamResolutions, 'stream_resolutions'),
    'track_failures': await _count(trackFailures, 'track_failures'),
    'downloaded_files': await _count(downloadedFiles, 'downloaded_files'),
    'download_tasks': await _count(downloadTasks, 'download_tasks'),
    'queue_snapshots': await _count(queueSnapshots, 'queue_snapshots'),
    'app_settings': await _count(appSettings, 'app_settings'),
  };

  Future<int> _count(
    ResultSetImplementation<dynamic, dynamic> table,
    String tableName,
  ) async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM "$tableName"',
      readsFrom: {table},
    ).getSingle();
    return row.read<int>('c');
  }

  Future<int> schemaVersionInDb() async {
    final row = await customSelect('PRAGMA user_version').getSingle();
    return row.read<int>('user_version');
  }
}
