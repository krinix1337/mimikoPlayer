import 'package:drift/drift.dart';

/// Упорядоченные миграции. Правило проекта: только аддитивные шаги — новая
/// колонка с null или дефолтом, никаких переименований и смены типа PK.
/// Удаление таблицы = две миграции: сначала перестать писать, потом дропать.
///
/// Ключи соответствуют `AppDatabase.schemaVersion`; новый этап добавляет сюда
/// шаг и поднимает schemaVersion на 1.
typedef MigrationUp = Future<void> Function(Migrator m);

final class MigrationStep {
  const MigrationStep({required this.description, required this.up});

  final String description;
  final MigrationUp up;
}

const int latestSchemaVersion = 1;

final Map<int, MigrationStep> migrationSteps = {
  1: MigrationStep(
    description: 'базовая схема: треки, плейлисты, лайки, история, кэш потоков',
    up: (m) => m.createAll(),
  ),
};
