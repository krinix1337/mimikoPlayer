import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../logging/app_logger.dart';

/// Незацензуренные версии треков из открытой базы FckCensorData.
///
/// База не входит в APK: список и аудио загружаются с GitHub по требованию.
/// Для каждого трека ссылка проверяется запросом Range и кэшируется на
/// сессию; если GitHub недоступен, играет обычная версия Яндекса.
class CensorBase {
  CensorBase._();

  static final CensorBase instance = CensorBase._();

  static const _listSources = [
    'https://raw.githubusercontent.com/Hazzz895/FckCensorData/main/list.json',
    'https://cdn.jsdelivr.net/gh/Hazzz895/FckCensorData@main/list.json',
  ];
  static const _rawPrefix =
      'https://raw.githubusercontent.com/Hazzz895/FckCensorData/refs/heads/main/';
  static const _cdnPrefix =
      'https://cdn.jsdelivr.net/gh/Hazzz895/FckCensorData@main/';
  static const _cacheName = 'fckcensor_list.json';
  static const _cacheTtl = Duration(hours: 24);

  bool enabled = true;

  Map<String, String> _map = const {};
  final Map<String, String> _verified = {};
  final Set<String> _bad = {};
  bool _attempted = false;
  DateTime? _retryAt;
  Future<void>? _loading;

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.plain,
      followRedirects: true,
      validateStatus: (status) => status == 200 || status == 206,
      headers: const {
        'User-Agent': 'mimikoPlayer/1.2 (+github.com/krinix1337)',
      },
    ),
  );

  int get tracksCount => _map.length;

  Future<void> ensureLoaded({bool force = false}) {
    if (force) {
      _attempted = false;
      _retryAt = null;
      _bad.clear();
    }
    if (_attempted) return Future.value();
    final now = DateTime.now();
    final retryAt = _retryAt;
    if (retryAt != null && now.isBefore(retryAt)) {
      return Future.value();
    }
    if (_loading case final loading?) return loading;
    final future = _load().whenComplete(() {
      // Пустая карта означает сетевую ошибку или битый кэш. Повторим позже,
      // а не будем ждать перезапуска приложения.
      _attempted = _map.isNotEmpty;
      _retryAt = _map.isEmpty
          ? DateTime.now().add(const Duration(minutes: 2))
          : null;
      _loading = null;
    });
    _loading = future;
    return future;
  }

  Future<void> _load() async {
    final file = await _cacheFile();
    if (file != null && await file.exists()) {
      var fresh = false;
      try {
        final stat = await file.stat();
        fresh = DateTime.now().difference(stat.modified) < _cacheTtl;
        await _read(file);
        if (fresh && _map.isNotEmpty) {
          _markLoaded();
          return;
        }
      } on Object catch (error) {
        AppLogger.instance.warn('база цензуры из кэша: $error');
      }
      // Кэш устарел, пуст или битый — пробуем обновить. Если сеть недоступна,
      // останется то, что удалось прочитать из старого файла.
      if (!fresh || _map.isEmpty) {
        await _refresh(file);
        if (await file.exists()) {
          try {
            await _read(file);
          } on Object catch (error) {
            AppLogger.instance.warn('база цензуры после обновления: $error');
          }
        }
      }
    } else if (file != null) {
      await _refresh(file);
      if (await file.exists()) {
        try {
          await _read(file);
        } on Object catch (error) {
          AppLogger.instance.warn('база цензуры: $error');
        }
      }
    }
    _markLoaded();
  }

  void _markLoaded() {
    AppLogger.instance.info('база цензуры: ${_map.length} треков');
  }

  Future<void> _refresh(File cache) async {
    for (final url in _listSources) {
      try {
        final response = await _dio.get<String>(url);
        final raw = response.data;
        if (raw == null || raw.isEmpty) continue;
        final parsed = parseList(raw);
        if (parsed.isEmpty) continue;
        _map = parsed;
        await cache.writeAsString(raw, flush: true);
        return;
      } on Object catch (error) {
        AppLogger.instance.warn('база цензуры $url: $error');
      }
    }
  }

  Future<void> _read(File file) async {
    _map = parseList(await file.readAsString());
  }

  /// Формат FckCensorData: `{"tracks": {"<yandex id>": "<url>", ...}}`.
  static Map<String, String> parseList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return const {};
    final tracks = decoded['tracks'];
    if (tracks is! Map) return const {};
    final result = <String, String>{};
    for (final entry in tracks.entries) {
      final value = entry.value;
      if (value is! String || value.isEmpty) continue;
      final uri = Uri.tryParse(value);
      // В базу не должны попадать file:, javascript: и прочие схемы.
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) continue;
      result['${entry.key}'] = value;
    }
    return result;
  }

  /// Проверенная ссылка на незацензуренную версию или null.
  Future<String?> replacementFor(String yandexTrackId) async {
    if (!enabled) return null;
    if (_verified[yandexTrackId] case final url?) return url;
    if (_bad.contains(yandexTrackId)) return null;

    if (!_attempted) {
      // Не задерживаем первый трек на холодном старте: список догрузится
      // в фоне, а пока играет обычная версия Яндекса.
      try {
        await ensureLoaded().timeout(
          const Duration(seconds: 2),
          onTimeout: () {},
        );
      } on Object {
        return null;
      }
    }
    final stored = _map[yandexTrackId];
    if (stored == null) return null;

    final candidates = <String>[
      stored,
      if (stored.startsWith(_rawPrefix))
        stored.replaceFirst(_rawPrefix, _cdnPrefix),
    ];
    for (final candidate in candidates.toSet()) {
      if (await _probe(candidate)) {
        _verified[yandexTrackId] = candidate;
        AppLogger.instance.info('цензура: версия без цензуры $yandexTrackId');
        return candidate;
      }
    }
    _bad.add(yandexTrackId);
    AppLogger.instance.warn('цензура: файл $yandexTrackId недоступен');
    return null;
  }

  Future<bool> _probe(String url) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {'Range': 'bytes=0-2047'},
          validateStatus: (status) => status == 200 || status == 206,
        ),
      );
      final bytes = response.data;
      if (bytes == null || bytes.length < 128) return false;
      final contentType =
          response.headers.value('content-type')?.toLowerCase() ?? '';
      // GitHub при ошибке может вернуть HTML с кодом 200 — это не аудио.
      if (contentType.startsWith('text/') || contentType.contains('html')) {
        return false;
      }
      return true;
    } on Object catch (error) {
      AppLogger.instance.warn('цензура: probe $url: $error');
      return false;
    }
  }

  Future<File?> _cacheFile() async {
    try {
      final dir = await getApplicationSupportDirectory();
      return File(p.join(dir.path, _cacheName));
    } on Object {
      return null;
    }
  }
}
