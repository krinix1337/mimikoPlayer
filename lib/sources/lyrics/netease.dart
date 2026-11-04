import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/logging/app_logger.dart';
import 'lrclib.dart';

/// NetEase Cloud Music: бесплатный публичный веб-API без ключа. Поиск трека
/// по «исполнитель название», затем LRC по id. Таймкоды построчные.
class NetEaseLyrics {
  NetEaseLyrics({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://music.163.com/api',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              responseType: ResponseType.plain,
              headers: const {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
                    'AppleWebKit/537.36 (KHTML, like Gecko) '
                    'Chrome/124.0 Safari/537.36',
                'Referer': 'https://music.163.com/',
              },
            ),
          );

  final Dio _dio;

  static final NetEaseLyrics shared = NetEaseLyrics();

  static const _empty = Lyrics(lines: [], synced: false);

  Future<Lyrics> fetch({
    required String title,
    required String artist,
    required Duration duration,
  }) async {
    try {
      final search = await _dio.get<String>(
        '/search/get',
        queryParameters: {'s': '$artist $title', 'type': 1, 'limit': 10},
      );
      final id = pickSong(_asMap(search.data), title, duration);
      if (id == null) {
        AppLogger.instance.info('NetEase: трек не найден');
        return _empty;
      }
      final lyric = await _dio.get<String>(
        '/song/lyric',
        queryParameters: {'id': id, 'lv': 1, 'kv': 1, 'tv': -1},
      );
      final lrc = _asMap(lyric.data)?['lrc'];
      final text = lrc is Map ? lrc['lyric'] : null;
      if (text is! String || text.trim().isEmpty) return _empty;
      final parsed = LrcLib.parse({'syncedLyrics': text});
      // У инструменталов NetEase отдаёт заглушку «纯音乐，请欣赏».
      if (parsed.lines.length <= 1) return _empty;
      return parsed;
    } on Object catch (error) {
      AppLogger.instance.warn('NetEase: $error');
      return _empty;
    }
  }

  /// Ответ приходит как text/plain с JSON внутри — разбираем сами.
  static Map? _asMap(Object? data) {
    if (data is Map) return data;
    if (data is! String || data.isEmpty) return null;
    final decoded = jsonDecode(data);
    return decoded is Map ? decoded : null;
  }

  /// Песня с ближайшей длительностью (допуск 5 с) — чужие тайминги хуже,
  /// чем их отсутствие. Название сверяем мягко: без регистра и скобок.
  static int? pickSong(Map? data, String title, Duration duration) {
    final songs = (data?['result'] as Map?)?['songs'];
    if (songs is! List) return null;
    final wanted = _norm(title);
    int? best;
    var bestDelta = 1 << 30;
    for (final song in songs) {
      if (song is! Map) continue;
      final id = song['id'];
      final ms = song['duration'] ?? song['dt'];
      if (id is! int || ms is! num) continue;
      final name = _norm('${song['name'] ?? ''}');
      if (wanted.isNotEmpty &&
          !name.contains(wanted) &&
          !wanted.contains(name)) {
        continue;
      }
      final delta = (ms / 1000 - duration.inSeconds).abs().round();
      if (delta > 5 || delta >= bestDelta) continue;
      bestDelta = delta;
      best = id;
    }
    return best;
  }

  static String _norm(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'\(.*?\)|\[.*?\]'), '')
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '');
}
