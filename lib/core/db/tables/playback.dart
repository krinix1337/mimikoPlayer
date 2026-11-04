import 'package:drift/drift.dart';

import 'library.dart';

@TableIndex(name: 'history_by_played_at', columns: {#playedAt})
@TableIndex(name: 'history_by_track', columns: {#localTrackId, #playedAt})
class History extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get localTrackId =>
      text().references(Tracks, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get playedAt => dateTime().withDefault(currentDateAndTime)();

  /// Сколько реально прослушано — нужно для rotor feedback и вытеснения офлайна.
  IntColumn get playedMs => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get source => text()();
  TextColumn get quality => text().withDefault(const Constant('auto'))();

  /// Причина пропуска, если трек закончился не сам.
  TextColumn get skipReason => text().nullable()();
  TextColumn get device => text().nullable()();

  /// Сырое событие источника, чтобы досылать feedback без повторных запросов.
  TextColumn get eventJson => text().nullable()();

  /// Попадает ли прослушивание в статистику. «Очистить» снимает флаг, не
  /// трогая саму историю: волна по ней помнит недавно слышанное.
  BoolColumn get inStats => boolean().withDefault(const Constant(true))();
}

@TableIndex(name: 'queue_snapshots_unique', columns: {#kind}, unique: true)
class QueueSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// player | radio
  TextColumn get kind => text()();

  /// Список localTrackId в порядке очереди.
  TextColumn get itemsJson => text()();
  IntColumn get queueIndex => integer().withDefault(const Constant(0))();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();

  /// off | all | one — значения совпадают с AudioService.repeatMode.
  TextColumn get repeatMode => text().withDefault(const Constant('off'))();
  BoolColumn get shuffleEnabled =>
      boolean().withDefault(const Constant(false))();

  /// Откуда очередь пришла (плейлист, волна, поиск) — нужно для дозаполнения
  /// «Моей волны» после смерти процесса.
  TextColumn get sourceHintJson => text().nullable()();
  DateTimeColumn get savedAt => dateTime().withDefault(currentDateAndTime)();
}

@TableIndex(name: 'stream_resolutions_expiry', columns: {#expiresAt})
class StreamResolutions extends Table {
  TextColumn get localTrackId =>
      text().references(Tracks, #id, onDelete: KeyAction.cascade)();
  TextColumn get source => text()();
  TextColumn get quality => text()();

  /// Заголовки храним отдельно: их нельзя вшивать в URL.
  TextColumn get url => text()();
  TextColumn get headersJson => text().withDefault(const Constant('{}'))();
  TextColumn get codec => text().nullable()();
  IntColumn get bitrateKbps => integer().nullable()();

  /// url | file
  TextColumn get targetKind => text().withDefault(const Constant('url'))();
  TextColumn get filePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column> get primaryKey => {localTrackId, source, quality};
}

@TableIndex(name: 'track_failures_expiry', columns: {#expiresAt})
class TrackFailures extends Table {
  TextColumn get localTrackId =>
      text().references(Tracks, #id, onDelete: KeyAction.cascade)();
  TextColumn get source => text()();

  /// Причина по SourceFailReason.name — без неё цепочка молча долбит каталог.
  TextColumn get reason => text()();
  IntColumn get httpStatus => integer().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get firstFailedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastFailedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column> get primaryKey => {localTrackId, source};
}

@TableIndex(name: 'downloaded_files_state', columns: {#state})
class DownloadedFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get localTrackId =>
      text().references(Tracks, #id, onDelete: KeyAction.cascade)();
  TextColumn get filePath => text()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get quality => text().withDefault(const Constant('auto'))();
  TextColumn get codec => text().nullable()();

  /// manual | auto — ручная загрузка или автозагрузка лайков.
  TextColumn get origin => text().withDefault(const Constant('manual'))();

  /// Локальная копия обложки; без неё «Скачанное» пустеет офлайн.
  TextColumn get coverPath => text().nullable()();

  /// Скачан незацензуренный файл из базы FckCensorData. У старых загрузок
  /// false: они могли скачаться до того, как трек попал в базу.
  BoolColumn get uncensored => boolean().withDefault(const Constant(false))();

  /// pending | downloading | complete | failed
  TextColumn get state => text().withDefault(const Constant('pending'))();
  TextColumn get source => text()();
  TextColumn get errorText => text().nullable()();

  /// Контрольная сумма файла: перекачка после обрыва не должна портить трек.
  TextColumn get sha1 => text().nullable()();
  DateTimeColumn get downloadedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {localTrackId},
  ];
}

/// Очередь загрузок: живёт дольше процесса и переживает kill.
class DownloadTasks extends Table {
  TextColumn get localTrackId =>
      text().references(Tracks, #id, onDelete: KeyAction.cascade)();

  /// queued | downloading | paused | failed | skipped | excluded
  TextColumn get state => text().withDefault(const Constant('queued'))();
  TextColumn get origin => text().withDefault(const Constant('manual'))();

  /// Меньше — раньше; ручные задачи идут впереди автозагрузки.
  IntColumn get priority => integer().withDefault(const Constant(10))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get receivedBytes => integer().withDefault(const Constant(0))();
  IntColumn get totalBytes => integer().nullable()();
  TextColumn get quality => text().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {localTrackId};
}
