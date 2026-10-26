import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../logging/app_logger.dart';
import '../sources/source_dto.dart';

/// Фильтр ИИ-треков.
///
/// Основной источник — открытый список исполнителей проекта Slopless
/// (github.com/alexeyfv/slopless, GPL-3.0). Список не входит в APK: он
/// скачивается по сети, кладётся в кэш приложения и обновляется раз в неделю.
/// Если сети нет, остаются явные пометки в метаданных (AI, Suno, Udio,
/// нейросеть) и прошлый кэш.
class AiFilter {
  AiFilter._();

  static final AiFilter instance = AiFilter._();

  static const _sources = [
    'https://raw.githubusercontent.com/alexeyfv/slopless/main/data/yandex_music.json',
    'https://cdn.jsdelivr.net/gh/alexeyfv/slopless@main/data/yandex_music.json',
  ];
  static const _cacheName = 'slopless_artists.json';
  static const _cacheTtl = Duration(days: 7);

  Set<int> _artistIds = const {};
  DateTime? _loadedAt;
  bool _attempted = false;
  DateTime? _retryAt;
  Future<void>? _loading;

  int get artistsCount => _artistIds.length;

  bool get hasRemoteList => _artistIds.isNotEmpty;

  Future<void> ensureLoaded({bool force = false}) {
    if (force) {
      _attempted = false;
      _retryAt = null;
    }
    if (_attempted) return Future.value();
    final now = DateTime.now();
    final retryAt = _retryAt;
    if (retryAt != null && now.isBefore(retryAt)) {
      return Future.value();
    }
    if (_loading case final loading?) return loading;
    final future = _load().whenComplete(() {
      // Пустой список — признак сетевой ошибки. Через две минуты попробуем
      // снова, вместо того чтобы ждать перезапуска.
      _attempted = _artistIds.isNotEmpty;
      _retryAt = _artistIds.isEmpty
          ? DateTime.now().add(const Duration(minutes: 2))
          : null;
      _loading = null;
    });
    _loading = future;
    return future;
  }

  Future<void> _load() async {
    final cache = await _cacheFile();
    if (cache != null) {
      var fresh = false;
      if (await cache.exists()) {
        try {
          final stat = await cache.stat();
          fresh = DateTime.now().difference(stat.modified) < _cacheTtl;
          await _readCache(cache);
          if (fresh && _artistIds.isNotEmpty) {
            _markLoaded();
            return;
          }
        } on Object catch (error) {
          AppLogger.instance.warn('AI-список из кэша не прочитан: $error');
        }
      }
      // Нет кэша, он устарел или пуст — пробуем сеть. Если сеть недоступна,
      // ниже останется то, что успели прочитать из старого кэша.
      if (!fresh || _artistIds.isEmpty) {
        await _refresh(cache);
        if (await cache.exists()) {
          try {
            await _readCache(cache);
          } on Object catch (error) {
            AppLogger.instance.warn(
              'AI-список после обновления не прочитан: $error',
            );
          }
        }
      }
    }
    _markLoaded();
  }

  void _markLoaded() {
    _loadedAt = DateTime.now();
    AppLogger.instance.info(
      'AI-фильтр: ${_artistIds.length} исполнителей в списке',
    );
  }

  Future<void> _refresh(File cache) async {
    for (final url in _sources) {
      try {
        final response = await Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
            responseType: ResponseType.plain,
            headers: const {
              'User-Agent': 'mimikoPlayer/1.2.2 (+github.com/krinix1337)',
            },
          ),
        ).get<String>(url);
        final raw = response.data;
        if (raw == null || raw.isEmpty) continue;
        // Проверяем формат до записи: битый или пустой ответ не должен
        // затереть рабочий кэш.
        if (parse(raw).isEmpty) continue;
        await cache.writeAsString(raw, flush: true);
        return;
      } on Object catch (error) {
        AppLogger.instance.warn('AI-список $url: $error');
      }
    }
  }

  Future<void> _readCache(File cache) async {
    final raw = await cache.readAsString();
    _artistIds = parse(raw);
  }

  /// Разбор ответа Slopless: `{timestamp, artists: [int, ...]}`.
  Set<int> parse(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return const {};
    final artists = decoded['artists'];
    if (artists is! List) return const {};
    final ids = <int>{};
    for (final value in artists) {
      final parsed = value is num ? value.toInt() : int.tryParse('$value');
      if (parsed != null) ids.add(parsed);
    }
    return ids;
  }

  Future<File?> _cacheFile() async {
    try {
      final dir = await getApplicationSupportDirectory();
      return File(p.join(dir.path, _cacheName));
    } on Object {
      return null;
    }
  }

  /// Трек из каталога: сначала точный список по id артистов, затем явные
  /// пометки в названии/исполнителе.
  bool isAiTrack(SourceTrack track) {
    if (_hasBlockedArtistId(track.artistIds)) return true;
    return matches(track.title, track.artists);
  }

  bool isAiArtistId(String? remoteId) =>
      remoteId != null && _artistIds.contains(int.tryParse(remoteId));

  bool isAiRow(String title, String artist, List<String> remoteIds) {
    if (_hasBlockedArtistId(remoteIds)) return true;
    return matches(title, [artist]);
  }

  /// Для плеера: название и все исполнители, id — из локальной базы.
  bool isAiLocal(String title, List<String> artists, List<String> remoteIds) {
    if (_hasBlockedArtistId(remoteIds)) return true;
    return matches(title, artists);
  }

  bool _hasBlockedArtistId(Iterable<String> ids) {
    if (_artistIds.isEmpty) return false;
    for (final id in ids) {
      final parsed = int.tryParse(id);
      if (parsed != null && _artistIds.contains(parsed)) return true;
    }
    return false;
  }

  static final RegExp _latin = RegExp(
    r'(^|[^a-z0-9])(ai[ _-]?(music|cover|song|track|voice|generated|artist|remix)|suno|udio)([^a-z0-9]|$)',
    caseSensitive: false,
  );

  static const List<String> _cyrillic = [
    'нейрослоп',
    'нейросет',
    'нейро-трек',
    'нейротрек',
    'сгенерировано ии',
    'сгенерирован ии',
    'ии-трек',
    'ии трек',
    'ии-кавер',
    'ии кавер',
    'искусственный интеллект',
  ];

  /// Эвристика по явным пометкам — работает даже без списка.
  static bool matches(String title, Iterable<String> artists) {
    final text = '$title ${artists.join(' ')}'.toLowerCase();
    if (_latin.hasMatch(text)) return true;
    return _cyrillic.any(text.contains);
  }

  DateTime? get loadedAt => _loadedAt;
}
