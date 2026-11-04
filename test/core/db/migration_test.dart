import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:phoneyandex/core/db/database.dart';
import 'package:sqlite3/sqlite3.dart';

/// Минимальная v1-схема, достаточная для проверки апгрейда: лайки и
/// скачанные файлы должны пережить добавление очереди и новых колонок.
void _createV1(File file) {
  final raw = sqlite3.open(file.path);
  try {
    raw.execute('CREATE TABLE tracks (id TEXT NOT NULL PRIMARY KEY)');
    raw.execute(
      'CREATE TABLE history (id INTEGER PRIMARY KEY, local_track_id TEXT, '
      'played_at INTEGER, played_ms INTEGER, completed INTEGER, source TEXT)',
    );
    raw.execute('''
      CREATE TABLE likes (
        local_track_id TEXT NOT NULL PRIMARY KEY
          REFERENCES tracks (id) ON DELETE CASCADE,
        state INTEGER NOT NULL DEFAULT 1,
        liked_at INTEGER NOT NULL,
        synced_to_remote INTEGER NOT NULL DEFAULT 0,
        remote_source TEXT,
        pending_op INTEGER
      )
    ''');
    raw.execute('''
      CREATE TABLE downloaded_files (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_track_id TEXT NOT NULL UNIQUE
          REFERENCES tracks (id) ON DELETE CASCADE,
        file_path TEXT NOT NULL,
        size_bytes INTEGER NOT NULL DEFAULT 0,
        quality TEXT NOT NULL DEFAULT 'auto',
        codec TEXT,
        state TEXT NOT NULL DEFAULT 'pending',
        source TEXT NOT NULL,
        error_text TEXT,
        sha1 TEXT,
        downloaded_at INTEGER NOT NULL
      )
    ''');
    // Реальная v1 уже содержала связи плейлистов: без неё шаг 3 (смена
    // ключа на позицию) нечего переносить.
    raw.execute('''
      CREATE TABLE playlist_tracks (
        playlist_id TEXT NOT NULL,
        local_track_id TEXT NOT NULL,
        position INTEGER NOT NULL DEFAULT 0,
        source_id TEXT NOT NULL,
        remote_id TEXT NOT NULL,
        added_at INTEGER NOT NULL
      )
    ''');
    raw.execute("INSERT INTO tracks (id) VALUES ('t_1')");
    raw.execute('''
      INSERT INTO playlist_tracks (
        playlist_id, local_track_id, position, source_id, remote_id, added_at
      ) VALUES ('yandex:1', 't_1', 0, 'yandex', 'r_1', 1760000000)
    ''');
    raw.execute('''
      INSERT INTO likes (local_track_id, state, liked_at)
      VALUES ('t_1', 1, 1760000000)
    ''');
    raw.execute('''
      INSERT INTO downloaded_files (
        local_track_id, file_path, size_bytes, quality, state, source,
        downloaded_at
      ) VALUES (
        't_1', '/data/downloads/t_1.mp3', 2048, 'high', 'complete',
        'yandex', 1760000000
      )
    ''');
    raw.execute('PRAGMA user_version = 1');
  } finally {
    raw.close();
  }
}

void main() {
  test('апгрейд v1 → v5 сохраняет лайки и старые загрузки', () async {
    final dir = await Directory.systemTemp.createTemp('mimiko_migration_');
    final file = File(p.join(dir.path, 'app.sqlite'));
    _createV1(file);

    final db = AppDatabase.forTesting(NativeDatabase(file));
    try {
      expect(await db.schemaVersionInDb(), 5);
      expect(await db.libraryDao.likedTrackIds(), ['t_1']);

      final downloads = await db.select(db.downloadedFiles).get();
      expect(downloads, hasLength(1));
      expect(downloads.single.filePath, '/data/downloads/t_1.mp3');
      expect(downloads.single.uncensored, isFalse);
      expect(downloads.single.origin, 'manual');
      expect(downloads.single.coverPath, isNull);
      expect(await db.select(db.downloadTasks).get(), isEmpty);
    } finally {
      await db.close();
      await dir.delete(recursive: true);
    }
  });

  test('чистая установка создаёт всю схему v4', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    try {
      expect(await db.schemaVersionInDb(), 5);
      final counts = await db.rowCountSnapshot();
      expect(
        counts.keys,
        containsAll(['likes', 'downloaded_files', 'download_tasks']),
      );
      expect(counts['download_tasks'], 0);
    } finally {
      await db.close();
    }
  });
}
