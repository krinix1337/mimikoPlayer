import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/auth_dao.dart';
import 'daos/history_dao.dart';
import 'daos/library_dao.dart';
import 'daos/queue_dao.dart';
import 'daos/settings_dao.dart';
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
    AuthTokens,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'phoneyandex'));

  /// Для unit-тестов поверх NativeDatabase.memory().
  AppDatabase.forTesting(super.executor);

  TracksDao get tracksDao => TracksDao(this);
  StreamsDao get streamsDao => StreamsDao(this);
  HistoryDao get historyDao => HistoryDao(this);
  QueueDao get queueDao => QueueDao(this);
  SettingsDao get settingsDao => SettingsDao(this);
  AuthDao get authDao => AuthDao(this);
  LibraryDao get libraryDao => LibraryDao(this);

  @override
  int get schemaVersion => latestSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => migrationSteps[latestSchemaVersion]!.up(m),
    onUpgrade: (m, from, to) async {
      for (var version = from + 1; version <= to; version++) {
        final step = migrationSteps[version];
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
    'queue_snapshots': await _count(queueSnapshots, 'queue_snapshots'),
    'app_settings': await _count(appSettings, 'app_settings'),
  };

  Future<int> _count(ResultSetImplementation<dynamic, dynamic> table, String tableName) async {
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
