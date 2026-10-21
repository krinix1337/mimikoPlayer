import 'package:dio/dio.dart';

import 'lrclib.dart';

/// Каскад источников текста. Порядок честный: сначала тот, что отдаёт
/// таймкоды (LRCLIB), затем бесплатный без ключа (lyrics.ovh) — только текст.
///
/// Эндпоинт текстов Яндекса закрыт подписью (403 Invalid Sign без неё),
/// а Genius требует клиентский токен, поэтому в сборку они не включены:
/// мёртвый запрос в цепочке только увеличивал бы ожидание.
class LyricsService {
  LyricsService({Dio? dio, LrcLib? lrcLib})
    : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 6))),
      _lrcLib = lrcLib ?? LrcLib.shared;

  final Dio _dio;
  final LrcLib _lrcLib;

  static final LyricsService shared = LyricsService();

  Future<Lyrics> fetch({
    required String title,
    required String artist,
    String? album,
    required Duration duration,
  }) async {
    final synced = await _lrcLib.fetch(
      title: title,
      artist: artist,
      album: album,
      duration: duration,
    );
    if (!synced.isEmpty) return synced;
    if (artist.trim().isEmpty || title.trim().isEmpty) return synced;
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
