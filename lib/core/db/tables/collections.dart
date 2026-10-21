import 'package:drift/drift.dart';

import 'library.dart';

@TableIndex(name: 'playlists_by_source', columns: {#source, #remotePlaylistId}, unique: true)
@TableIndex(name: 'playlists_by_kind', columns: {#kind})
class Playlists extends Table {
  /// Свой id `pl_...` для локальных, `source:remoteId` для импортированных.
  TextColumn get id => text()();

  /// local для плейлистов, созданных в приложении.
  TextColumn get source => text().withDefault(const Constant('local'))();
  TextColumn get remotePlaylistId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get ownerUid => text().nullable()();

  /// user | imported | radio | liked
  TextColumn get kind => text().withDefault(const Constant('user'))();
  IntColumn get totalTracks => integer().nullable()();
  BoolColumn get canEdit => boolean().withDefault(const Constant(true))();

  /// manual | addedDesc — порядок, который реально видит пользователь.
  TextColumn get sortMode => text().withDefault(const Constant('manual'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'playlist_tracks_order', columns: {#playlistId, #position})
class PlaylistTracks extends Table {
  TextColumn get playlistId =>
      text().references(Playlists, #id, onDelete: KeyAction.cascade)();
  TextColumn get localTrackId =>
      text().references(Tracks, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer().withDefault(const Constant(0))();

  /// Откуда именно добавили: тот же локальный трек мог прийти из двух каталогов.
  TextColumn get sourceId => text()();
  TextColumn get remoteId => text()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {playlistId, localTrackId};
}

@TableIndex(name: 'likes_by_state', columns: {#state, #likedAt})
class Likes extends Table {
  TextColumn get localTrackId =>
      text().references(Tracks, #id, onDelete: KeyAction.cascade)();

  /// -1 дизлайк, 0 снято, 1 лайк.
  IntColumn get state => integer().withDefault(const Constant(1))();
  DateTimeColumn get likedAt => dateTime().withDefault(currentDateAndTime)();

  /// Лайк живёт локально до тех пор, пока не синхронизирован в каталог.
  BoolColumn get syncedToRemote => boolean().withDefault(const Constant(false))();
  TextColumn get remoteSource => text().nullable()();

  /// 1 = поставить, -1 = снять; null = ничего не ждём.
  IntColumn get pendingOp => integer().nullable()();

  @override
  Set<Column> get primaryKey => {localTrackId};
}
