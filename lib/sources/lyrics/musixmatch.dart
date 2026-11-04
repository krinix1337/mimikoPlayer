import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/logging/app_logger.dart';
import 'lrclib.dart';

/// Musixmatch через API десктоп-клиента: бесплатный токен, самая большая база
/// синхронных текстов. Неофициально — при любой ошибке молча отдаём «нет
/// текста», каскад пойдёт дальше.
class MusixmatchLyrics {
  MusixmatchLyrics({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://apic-desktop.musixmatch.com/ws/1.1',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              responseType: ResponseType.plain,
              headers: const {
                'Cookie': 'AWSELBCORS=0; AWSELB=0',
                'User-Agent': 'Mozilla/5.0',
              },
            ),
          );

  final Dio _dio;

  static final MusixmatchLyrics shared = MusixmatchLyrics();

  static const _appId = 'web-desktop-app-v1.0';
  static const _empty = Lyrics(lines: [], synced: false);

  String? _token;
  DateTime? _blockedUntil;

  Future<Lyrics> fetch({
    required String title,
    required String artist,
    String? album,
    required Duration duration,
  }) async {
    // После отказа (капча, лимит) не долбим сервис — пауза на 10 минут.
    final blocked = _blockedUntil;
    if (blocked != null && DateTime.now().isBefore(blocked)) return _empty;
    try {
      final token = _token ??= await _fetchToken();
      if (token == null) {
        AppLogger.instance.warn('Musixmatch: токен не выдан');
        return _empty;
      }
      final response = await _dio.get<String>(
        '/macro.subtitles.get',
        queryParameters: {
          'format': 'json',
          'namespace': 'lyrics_richsynched',
          'subtitle_format': 'mxm',
          'app_id': _appId,
          'usertoken': token,
          'q_artist': artist,
          'q_track': title,
          if (album != null && album.isNotEmpty) 'q_album': album,
          'q_duration': duration.inSeconds,
          'f_subtitle_length': duration.inSeconds,
        },
      );
      final data = jsonDecode(response.data ?? '');
      final status = _status(data);
      if (status != 200) AppLogger.instance.warn('Musixmatch: статус $status');
      if (status == 401) {
        _token = null;
        _blockedUntil = DateTime.now().add(const Duration(minutes: 10));
        return _empty;
      }
      final parsed = parseMacro(data);
      if (!parsed.synced) {
        AppLogger.instance.info('Musixmatch: нет синхронного текста');
      }
      return parsed;
    } on Object catch (error) {
      AppLogger.instance.warn('Musixmatch: $error');
      return _empty;
    }
  }

  Future<String?> _fetchToken() async {
    final response = await _dio.get<String>(
      '/token.get',
      queryParameters: {'app_id': _appId, 'user_language': 'en'},
    );
    final data = jsonDecode(response.data ?? '');
    final token =
        (((data as Map?)?['message'] as Map?)?['body'] as Map?)?['user_token'];
    if (token is! String || token.isEmpty || token.contains('UpgradeOnly')) {
      _blockedUntil = DateTime.now().add(const Duration(minutes: 10));
      return null;
    }
    return token;
  }

  static int? _status(Object? data) {
    final header = ((data as Map?)?['message'] as Map?)?['header'];
    final code = (header as Map?)?['status_code'];
    return code is int ? code : null;
  }

  /// Разбор ответа macro.subtitles.get: subtitle_body — JSON-строка со
  /// списком `{text, time: {total}}`.
  static Lyrics parseMacro(Object? data) {
    final calls =
        (((data as Map?)?['message'] as Map?)?['body'] as Map?)?['macro_calls'];
    if (calls is! Map) return _empty;
    final subtitles =
        ((calls['track.subtitles.get'] as Map?)?['message'] as Map?)?['body'];
    final list = (subtitles is Map) ? subtitles['subtitle_list'] : null;
    if (list is! List || list.isEmpty) return _empty;
    final body = ((list.first as Map?)?['subtitle'] as Map?)?['subtitle_body'];
    if (body is! String || body.isEmpty) return _empty;
    final items = jsonDecode(body);
    if (items is! List) return _empty;

    final raw = <({Duration start, String text})>[];
    for (final item in items) {
      if (item is! Map) continue;
      final total = (item['time'] as Map?)?['total'];
      final text = '${item['text'] ?? ''}'.trim();
      if (total is! num || text.isEmpty) continue;
      raw.add((
        start: Duration(milliseconds: (total * 1000).round()),
        text: text,
      ));
    }
    if (raw.isEmpty) return _empty;
    final lines = <LyricLine>[
      for (var i = 0; i < raw.length; i++)
        LyricLine(
          start: raw[i].start,
          end: i + 1 < raw.length
              ? raw[i + 1].start
              : raw[i].start + const Duration(seconds: 6),
          text: raw[i].text,
        ),
    ];
    return Lyrics(
      lines: lines,
      synced: true,
      plain: raw.map((line) => line.text).join('\n'),
    );
  }
}
