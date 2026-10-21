import 'package:drift/drift.dart';

@TableIndex(name: 'artists_by_source', columns: {#source, #remoteArtistId}, unique: true)
@TableIndex(name: 'artists_by_name_norm', columns: {#nameNorm})
class Artists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Нормализованное имя — ключ матчинга между источниками.
  TextColumn get nameNorm => text()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get source => text()();
  TextColumn get remoteArtistId => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@TableIndex(name: 'albums_by_source', columns: {#source, #remoteAlbumId}, unique: true)
class Albums extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get coverUrl => text().nullable()();
  IntColumn get year => integer().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get source => text()();
  TextColumn get remoteAlbumId => text()();

  /// Порядок артистов альбома как в исходном каталоге.
  TextColumn get artistIdsCsv => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@TableIndex(name: 'tracks_by_fingerprint', columns: {#fingerprint}, unique: true)
@TableIndex(name: 'tracks_by_title_norm', columns: {#titleNorm})
@TableIndex(name: 'tracks_by_isrc', columns: {#isrc})
@TableIndex(name: 'tracks_by_last_seen', columns: {#lastSeenAt})
class Tracks extends Table {
  /// Наш идентификатор: `t_<sha1[..24]>`. Удалённый id сюда не пишем — одна
  /// песня живёт в нескольких каталогах и в файлах пользователя.
  TextColumn get id => text()();

  TextColumn get title => text()();
  TextColumn get titleNorm => text()();
  IntColumn get durationSec => integer()();
  IntColumn get mainArtistId =>
      integer().nullable().references(Artists, #id, onDelete: KeyAction.setNull)();
  IntColumn get albumId =>
      integer().nullable().references(Albums, #id, onDelete: KeyAction.setNull)();
  TextColumn get coverUrl => text().nullable()();

  /// Мост между каталогами. Пустая строка = источника без ISRC, а не «нет ISRC».
  TextColumn get isrc => text().nullable()();
  BoolColumn get explicitFlag => boolean().withDefault(const Constant(false))();
  BoolColumn get lyricsAvailable => boolean().withDefault(const Constant(false))();

  TextColumn get fingerprint => text()();
  IntColumn get popularity => integer().nullable()();

  /// Пометка для будущего фильтра AI-артистов и цензуры.
  TextColumn get contentRating => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// Для очистки «давно не слушанного» на этапе офлайна.
  DateTimeColumn get lastSeenAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get metadataSource => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'track_artists_by_artist', columns: {#artistId})
class TrackArtists extends Table {
  TextColumn get trackId =>
      text().references(Tracks, #id, onDelete: KeyAction.cascade)();
  IntColumn get artistId =>
      integer().references(Artists, #id, onDelete: KeyAction.cascade)();

  /// artist | albumArtist | composer — как в каталоге.
  TextColumn get role => text().withDefault(const Constant('artist'))();
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {trackId, artistId, role};
}

@TableIndex(name: 'mappings_by_track', columns: {#localTrackId})
class RemoteIdMappings extends Table {
  TextColumn get source => text()();

  /// Идентификатор ровно в терминах источника: у Яндекса голое число трека.
  TextColumn get remoteId => text()();
  TextColumn get albumRemoteId => text().nullable()();
  TextColumn get localTrackId =>
      text().references(Tracks, #id, onDelete: KeyAction.cascade)();

  /// exact | isrc | fuzzy | manual — по нечёткому совпадению строки не сливаются.
  TextColumn get mappingConfidence => text().withDefault(const Constant('exact'))();

  /// Сырой JSON: новый метаданный поле можно добавить без сетевого рефетча.
  TextColumn get remoteJson => text().nullable()();

  DateTimeColumn get firstSeenAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSeenAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {source, remoteId};
}
