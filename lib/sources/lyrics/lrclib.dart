import 'dart:convert';

import 'package:dio/dio.dart';

/// Строка синхронных слов: момент появления и момент, когда она перестаёт
/// быть активной.
final class LyricLine {
  const LyricLine({required this.start, required this.end, required this.text});

  final Duration start;
  final Duration end;
  final String text;

  double progressAt(Duration at) {
    final span = end - start;
    if (span <= Duration.zero) return at >= end ? 1 : 0;
    return ((at - start).inMilliseconds / span.inMilliseconds).clamp(0.0, 1.0);
  }
}

final class Lyrics {
  const Lyrics({required this.lines, required this.synced, this.plain = ''});

  /// Пусто, когда у трека нет текста вообще.
  final List<LyricLine> lines;

  /// true — есть таймкоды LRC; false — только обычный текст.
  final bool synced;
  final String plain;

  bool get isEmpty => lines.isEmpty && plain.isEmpty;

  /// Текст без таймкодов: строки для показа, но активной строки нет.
  static Lyrics fromPlain(String text) => Lyrics(
    lines: [
      for (final line in const LineSplitter().convert(text))
        if (line.trim().isNotEmpty)
          LyricLine(
            start: Duration.zero,
            end: Duration.zero,
            text: line.trim(),
          ),
    ],
    synced: false,
    plain: text.trim(),
  );

  /// Индекс строки, звучащей в момент [at]. Без таймкодов активной строки
  /// нет — возвращаем -1, чтобы вызывающий код не красил случайную строку.
  int lineAt(Duration at) {
    if (!synced || lines.isEmpty) return -1;
    for (var i = 0; i < lines.length; i++) {
      if (at < lines[i].end) return i;
    }
    return lines.length - 1;
  }
}

/// LRCLIB — публичный текст-без-ключа источник: `GET /api/get` по метаданным
/// трека, 404 означает «нет текста», а не ошибку.
class LrcLib {
  LrcLib({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://lrclib.net/api',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              responseType: ResponseType.json,
            ),
          );

  final Dio _dio;

  /// Один экземпляр на приложение: Dio держит пул соединений.
  static final LrcLib shared = LrcLib();

  static const Duration _fallbackLine = Duration(seconds: 6);

  Future<Lyrics> fetch({
    required String title,
    required String artist,
    required String? album,
    required Duration duration,
  }) async {
    Lyrics direct = const Lyrics(lines: [], synced: false);
    try {
      final response = await _dio.get<dynamic>(
        '/get',
        queryParameters: {
          'track_name': title,
          'artist_name': artist,
          if (album != null && album.isNotEmpty) 'album_name': album,
          'duration': duration.inSeconds,
        },
      );
      direct = parse(response.data);
      if (direct.synced) return direct;
    } on DioException {
      // 404 у `/get` — обычное дело при расхождении длительности; пробуем
      // поиск ниже.
    } on Object {
      // Текст не обязателен: каскад продолжит поиск.
    }

    // `/get` строг к длительности: расхождение в 1 секунду даёт 404, хотя та
    // же запись в `/search` находится. Таймкоды важнее обычного текста.
    final found = await _search(
      title: title,
      artist: artist,
      duration: duration,
    );
    if (found.synced) return found;
    return direct.isEmpty ? found : direct;
  }

  Future<Lyrics> _search({
    required String title,
    required String artist,
    required Duration duration,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/search',
        queryParameters: {'track_name': title, 'artist_name': artist},
      );
      return pickSearchResult(response.data, duration);
    } on Object {
      return const Lyrics(lines: [], synced: false);
    }
  }

  /// Выбирает ближайший по длительности вариант с таймкодами (допуск 5 с).
  /// Без близкой длительности лучше не красить строки по чужим таймингам.
  static Lyrics pickSearchResult(Object? data, Duration duration) {
    if (data is! List) return const Lyrics(lines: [], synced: false);
    Map? best;
    var bestDelta = 1 << 30;
    for (final item in data) {
      if (item is! Map) continue;
      final synced = item['syncedLyrics'];
      if (synced is! String || synced.trim().isEmpty) continue;
      final raw = item['duration'];
      final seconds = raw is num ? raw.round() : int.tryParse('$raw');
      if (seconds == null) continue;
      final delta = (seconds - duration.inSeconds).abs();
      if (delta > 5 || delta >= bestDelta) continue;
      bestDelta = delta;
      best = item;
    }
    return best == null ? const Lyrics(lines: [], synced: false) : parse(best);
  }

  /// Разбор вынесен отдельно: живого ответа может ещё не быть, а формат LRC
  /// проверяется тестом.
  static Lyrics parse(Object? data) {
    if (data is! Map) return const Lyrics(lines: [], synced: false);
    final syncedText = data['syncedLyrics'];
    final plainText = (data['plainLyrics'] as String?)?.trim() ?? '';

    if (syncedText is String && syncedText.trim().isNotEmpty) {
      final raw = _stampedLines(syncedText);
      final lines = <LyricLine>[];
      for (var i = 0; i < raw.length; i++) {
        final start = raw[i].start;
        final next = i + 1 < raw.length ? raw[i + 1].start : null;
        if (raw[i].text.isEmpty) continue;
        lines.add(
          LyricLine(
            start: start,
            end: next ?? start + _fallbackLine,
            text: raw[i].text,
          ),
        );
      }
      if (lines.isNotEmpty) {
        return Lyrics(lines: lines, synced: true, plain: plainText);
      }
    }

    if (plainText.isEmpty) return const Lyrics(lines: [], synced: false);
    return Lyrics(
      lines: [
        for (final line in const LineSplitter().convert(plainText))
          if (line.trim().isNotEmpty)
            LyricLine(
              start: Duration.zero,
              end: Duration.zero,
              text: line.trim(),
            ),
      ],
      synced: false,
      plain: plainText,
    );
  }

  static final RegExp _stamp = RegExp(
    r'\[(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?\]',
  );

  static List<({Duration start, String text})> _stampedLines(String source) {
    final result = <({Duration start, String text})>[];
    for (final raw in const LineSplitter().convert(source)) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      final stamps = _stamp.allMatches(line).toList();
      if (stamps.isEmpty) continue;
      // Одна строка может нести несколько меток подряд: [00:10.00][00:40.00]текст.
      final text = line.substring(stamps.last.end).trim();
      for (final stamp in stamps) {
        result.add((start: _durationOf(stamp), text: text));
      }
    }
    result.sort((a, b) => a.start.compareTo(b.start));
    return result;
  }

  static Duration _durationOf(RegExpMatch stamp) {
    final minutes = int.parse(stamp.group(1)!);
    final seconds = int.parse(stamp.group(2)!);
    final fraction = stamp.group(3);
    final millis = fraction == null
        ? 0
        : int.parse(fraction.padRight(3, '0').substring(0, 3));
    return Duration(minutes: minutes, seconds: seconds, milliseconds: millis);
  }
}
