import 'package:drift/drift.dart';

/// Версия схемы и тип шага миграции. Сами шаги лежат в `AppDatabase`:
/// им нужны геттеры таблиц, а импорт БД сюда создал бы цикл.
///
/// Правило проекта: только аддитивные шаги — новая колонка с null или
/// дефолтом, никаких переименований и смены типа PK. Удаление таблицы = две
/// миграции: сначала перестать писать, потом дропать.
typedef MigrationUp = Future<void> Function(Migrator m);

final class MigrationStep {
  const MigrationStep({required this.description, required this.up});

  final String description;
  final MigrationUp up;
}

const int latestSchemaVersion = 5;
