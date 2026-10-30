import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../db/database.dart';
import '../identity/normalizer.dart';

/// Исполнители, которых пользователь попросил больше не показывать.
///
/// Ключ — нормализованное имя: один и тот же артист из Яндекса и SoundCloud
/// записывается по-разному, а совпадает после нормализации. Хранится в
/// настройках одной JSON-строкой, поэтому схему базы менять не нужно.
class ArtistBlocklist extends ChangeNotifier {
  ArtistBlocklist._();

  static final ArtistBlocklist instance = ArtistBlocklist._();

  static const _key = 'blocked_artists';

  /// нормализованное имя → как показывать пользователю.
  Map<String, String> _names = const {};

  List<String> get names => _names.values.toList()..sort();

  int get length => _names.length;

  Future<void> load(AppDatabase db) async {
    try {
      final raw = await db.settingsDao.value(_key);
      if (raw == null) return;
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        _names = {
          for (final entry in decoded.entries) '${entry.key}': '${entry.value}',
        };
        notifyListeners();
      }
    } on Object {
      // Повреждённая запись не должна мешать запуску: список просто пуст.
    }
  }

  bool isBlockedName(String artist) =>
      _names.containsKey(normalizeArtist(artist));

  /// Любой из исполнителей трека в списке — трек скрываем.
  bool isBlocked(Iterable<String> artists) => artists.any(isBlockedName);

  Future<void> block(AppDatabase db, String artist) async {
    final name = artist.trim();
    if (name.isEmpty) return;
    _names = {..._names, normalizeArtist(name): name};
    await _save(db);
  }

  Future<void> unblock(AppDatabase db, String artist) async {
    final next = {..._names}..remove(normalizeArtist(artist));
    _names = next;
    await _save(db);
  }

  Future<void> _save(AppDatabase db) async {
    await db.settingsDao.setValue(_key, jsonEncode(_names));
    notifyListeners();
  }
}
