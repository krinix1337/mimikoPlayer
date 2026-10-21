import 'dart:convert';

import 'package:drift/drift.dart';

import '../../sources/registry.dart';
import '../../sources/source_id.dart';
import '../database.dart';

/// Настройки приложения: приоритет источников, качество, тема.
class SettingsDao {
  SettingsDao(this._db);

  final AppDatabase _db;

  static const String keyPlaybackPriority = 'playback_priority';
  static const String keyDefaultQuality = 'default_quality';
  static const String keyThemeMode = 'theme_mode';

  Future<List<SourceId>> playbackPriority() async {
    final raw = await _value(keyPlaybackPriority);
    if (raw == null) return SourceRegistry.defaultPlaybackPriority;
    final decoded = jsonDecode(raw);
    if (decoded is! List) return SourceRegistry.defaultPlaybackPriority;

    final result = <SourceId>[];
    for (final entry in decoded) {
      final id = SourceId.values.where((e) => e.wire == '$entry').firstOrNull;
      if (id != null) result.add(id);
    }
    return result.isEmpty ? SourceRegistry.defaultPlaybackPriority : result;
  }

  Future<void> setPlaybackPriority(List<SourceId> order) =>
      _put(keyPlaybackPriority, jsonEncode([for (final id in order) id.wire]));

  Future<String?> value(String key) => _value(key);

  Future<void> setValue(String key, Object? value) =>
      _put(key, jsonEncode(value));

  Future<String?> _value(String key) async {
    final row = await (_db.select(_db.appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.valueJson;
  }

  Future<void> _put(String key, String valueJson) =>
      _db.into(_db.appSettings).insertOnConflictUpdate(
        AppSettingsCompanion.insert(
          key: key,
          valueJson: valueJson,
          updatedAt: Value(DateTime.now()),
        ),
      );
}
