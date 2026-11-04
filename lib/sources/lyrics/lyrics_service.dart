import 'package:dio/dio.dart';

import '../../core/logging/app_logger.dart';
import 'lrclib.dart';
import 'musixmatch.dart';
import 'netease.dart';

/// Каскад источников текста. Сначала таймкоды: LRCLIB, Musixmatch, NetEase;
/// затем официальный текст Яндекса из supplement-эндпоинта; затем LRCLIB без
/// таймкодов и lyrics.ovh.
///
/// `lyrics` Яндекса с подписью отдаёт 404 даже для треков с lyricsAvailable,
/// а supplement работает по обычному OAuth и содержит полный текст.
class LyricsService {
  LyricsService({
    Dio? dio,
    LrcLib? lrcLib,
    MusixmatchLyrics? musixmatch,
    NetEaseLyrics? netEase,
  }) : _dio =
           dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 6))),
       _lrcLib = lrcLib ?? LrcLib.shared,
       _musixmatch = musixmatch ?? MusixmatchLyrics.shared,
       _netEase = netEase ?? NetEaseLyrics.shared;

  final Dio _dio;
  final LrcLib _lrcLib;
  final MusixmatchLyrics _musixmatch;
  final NetEaseLyrics _netEase;

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
    if (fromLrclib.synced) {
      AppLogger.instance.info('Текст: LRCLIB');
      return fromLrclib;
    }

    // Нет таймкодов в LRCLIB — ищем их у Musixmatch, затем у NetEase.
    if (artist.trim().isNotEmpty && title.trim().isNotEmpty) {
      final fromMusixmatch = await _musixmatch.fetch(
        title: title,
        artist: artist,
        album: album,
        duration: duration,
      );
      if (fromMusixmatch.synced) {
        AppLogger.instance.info('Текст: Musixmatch');
        return fromMusixmatch;
      }
      final fromNetEase = await _netEase.fetch(
        title: title,
        artist: artist,
        duration: duration,
      );
      if (fromNetEase.synced) {
        AppLogger.instance.info('Текст: NetEase');
        return fromNetEase;
      }
    }

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
