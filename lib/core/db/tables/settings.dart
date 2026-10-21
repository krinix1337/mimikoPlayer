import 'package:drift/drift.dart';

/// Токены источников. Значения чувствительные: в SQLite они лежат в
/// app-private каталоге, а логи их не печатают.
@TableIndex(name: 'auth_tokens_expiry', columns: {#expiresAt})
class AuthTokens extends Table {
  /// yandex | spotify | deezer | soundcloud
  TextColumn get provider => text()();
  TextColumn get accessToken => text()();
  TextColumn get refreshToken => text().nullable()();
  TextColumn get tokenType => text().withDefault(const Constant('OAuth'))();
  IntColumn get expiresAt => integer().nullable()();

  TextColumn get uid => text().nullable()();
  TextColumn get login => text().nullable()();
  TextColumn get displayName => text().nullable()();
  BoolColumn get hasPlus => boolean().withDefault(const Constant(false))();
  TextColumn get scopesCsv => text().withDefault(const Constant(''))();

  /// Всё остальное из ответа авторизации (device flow, expiry, region).
  TextColumn get extraJson => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {provider};
}

/// Настройки, которые не относятся к трекам: приоритет источников, качество,
/// лимит офлайна.
class AppSettings extends Table {
  TextColumn get key => text()();

  /// JSON-значение: порядок источников правится без пересборки.
  TextColumn get valueJson => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}
