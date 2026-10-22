import 'package:dio/dio.dart';

import 'lrclib.dart';

/// Каскад источников текста. Сначала LRCLIB — если есть таймкоды, караоке
/// работает; затем официальный текст Яндекса из supplement-эндпоинта; затем
/// LRCLIB без таймкодов и lyrics.ovh.
///
/// `lyrics` Яндекса с подписью отдаёт 404 даже для треков с lyricsAvailable,
/// а supplement работает по обычному OAuth и содержит полный текст.
class LyricsService {
  LyricsService({Dio? dio, LrcLib? lrcLib})
    : _dio =
          dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 6))),
      _lrcLib = lrcLib ?? LrcLib.shared;

  final Dio _dio;
  final LrcLib _lrcLib;

  static final LyricsService shared = LyricsService();

  Future<Lyrics> fetch({
    required String title,
    required String artist,
    String? album,
    required Duration duration,
    Future<Lyrics?> Function()? official,
  }) async {
    final fromLrclib = await _lrcLib.fetch(
      title: title,
      artist: artist,
      album: album,
      duration: duration,
    );
    if (fromLrclib.synced) return fromLrclib;

    // Официальный текст Яндекса (без таймкодов) точнее свободного овх.
    if (official != null) {
      try {
        final fromYandex = await official();
        if (fromYandex != null && !fromYandex.isEmpty) return fromYandex;
      } on Object {
        // Текст не обязателен: падать из-за него нельзя.
      }
    }
    if (!fromLrclib.isEmpty) return fromLrclib;
    if (artist.trim().isEmpty || title.trim().isEmpty) return fromLrclib;
    return _plainFromOvh(title: title, artist: artist);
  }

  Future<Lyrics> _plainFromOvh({
    required String title,
    required String artist,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        'https://api.lyrics.ovh/v1/${Uri.encodeComponent(artist)}/'
        '${Uri.encodeComponent(title)}',
      );
      final text = (response.data as Map?)?['lyrics'];
      if (text is! String || text.trim().isEmpty) {
        return const Lyrics(lines: [], synced: false);
      }
      return Lyrics.fromPlain(text);
    } on Object {
      return const Lyrics(lines: [], synced: false);
    }
  }
}
