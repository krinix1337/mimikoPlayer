import 'package:dio/dio.dart';

import '../../core/logging/app_logger.dart';

/// Аудио-URL из InnerTube player API.
///
/// `youtube_explode_dart` 3.1.0 на части сетей отвечает `UNPLAYABLE`: его
/// запросы к player API не совпадают с тем, что сейчас принимает YouTube.
/// Здесь используются те же публичные клиенты, что и у yt-dlp (IOS и ANDROID)
/// с актуальными версиями и заголовками — им PO-токен не требуется.
final class YoutubeInnertube {
  YoutubeInnertube({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              validateStatus: (status) => status != null && status < 500,
            ),
          );

  static const _playerUrl = 'https://www.youtube.com/youtubei/v1/player';
  static const _searchUrl = 'https://www.youtube.com/youtubei/v1/search';
  static const _apiKey = 'AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8';

  static const _clients = [
    _InnertubeClient(
      name: 'IOS',
      version: '20.10.4',
      headerValue: '5',
      userAgent:
          'com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU '
          'iOS 18_3_2 like Mac OS X;)',
      deviceModel: 'iPhone16,2',
      osName: 'iPhone',
      osVersion: '18.3.2.22D82',
    ),
    _InnertubeClient(
      name: 'ANDROID',
      version: '20.10.38',
      headerValue: '3',
      userAgent:
          'com.google.android.youtube/20.10.38 (Linux; U; Android 14) gzip',
      osName: 'Android',
      osVersion: '14',
      androidSdk: 34,
    ),
  ];

  final Dio _dio;

  /// Поиск идёт через WEB-клиент: у него в ответе классический
  /// `videoRenderer` с длительностью. IOS отдаёт новый `elementRenderer`
  /// без длины, а `youtube_explode` на части сетей возвращает 0 видео.
  Future<List<YoutubeSearchItem>> search(String query, {int limit = 50}) async {
    final client = _searchClient;
    try {
      final response = await _dio.post<dynamic>(
        _searchUrl,
        queryParameters: {'key': _apiKey},
        data: {
          'context': {'client': client.toJson()},
          'query': query,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': client.userAgent,
            'X-YouTube-Client-Name': client.headerValue,
            'X-YouTube-Client-Version': client.version,
            'Accept-Language': 'en-US,en;q=0.9',
          },
        ),
      );
      return parseSearchResponse(response.data, limit: limit);
    } on Object catch (error) {
      AppLogger.instance.warn('youtube innertube search: $error');
      return const [];
    }
  }

  static const _searchClient = _InnertubeClient(
    name: 'WEB',
    version: '2.20250310.01.00',
    headerValue: '1',
    userAgent:
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
    osName: 'Windows',
    osVersion: '10.0',
  );

  /// Достаёт `videoRenderer` из ответа поиска, отбрасывая Shorts, эфиры и
  /// ролики без длительности.
  static List<YoutubeSearchItem> parseSearchResponse(
    Object? json, {
    int limit = 50,
  }) {
    if (json is! Map) return const [];
    final found = <Map<String, dynamic>>[];

    void collect(Object? node) {
      if (found.length >= limit) return;
      if (node is Map) {
        final renderer = node['videoRenderer'];
        if (renderer is Map) {
          found.add(Map<String, dynamic>.from(renderer));
        }
        for (final value in node.values) {
          collect(value);
        }
      } else if (node is List) {
        for (final value in node) {
          collect(value);
        }
      }
    }

    collect(json);
    final items = <YoutubeSearchItem>[];
    for (final renderer in found) {
      final id = renderer['videoId'];
      if (id is! String || id.isEmpty) continue;
      final duration = _parseDuration(
        (renderer['lengthText'] as Map?)?['simpleText'],
      );
      if (duration == null ||
          duration < const Duration(seconds: 20) ||
          duration > const Duration(hours: 3)) {
        continue;
      }
      final title = _runsText(renderer['title']);
      if (title.isEmpty) continue;
      final author = _runsText(renderer['ownerText']) == ''
          ? _runsText(renderer['longBylineText'])
          : _runsText(renderer['ownerText']);
      final thumbnails = (renderer['thumbnail'] as Map?)?['thumbnails'];
      String? thumb;
      if (thumbnails is List && thumbnails.isNotEmpty) {
        final last = thumbnails.last;
        if (last is Map && last['url'] is String) {
          thumb = last['url'] as String;
        }
      }
      items.add(
        YoutubeSearchItem(
          id: id,
          title: title,
          author: author.isEmpty ? 'YouTube' : author,
          duration: duration,
          thumbnailUrl: thumb is String ? thumb : null,
        ),
      );
    }
    return items;
  }

  static String _runsText(Object? node) {
    if (node is! Map) return '';
    if (node['simpleText'] case final String text) return text.trim();
    final runs = node['runs'];
    if (runs is List) {
      return runs
          .map((run) => run is Map ? '${run['text'] ?? ''}' : '')
          .join()
          .trim();
    }
    return '';
  }

  static Duration? _parseDuration(Object? value) {
    if (value is! String) return null;
    final parts = value.split(':');
    if (parts.length < 2 || parts.length > 3) return null;
    final numbers = [for (final part in parts) int.tryParse(part.trim())];
    if (numbers.any((number) => number == null)) return null;
    var seconds = 0;
    for (final number in numbers) {
      seconds = seconds * 60 + number!;
    }
    return Duration(seconds: seconds);
  }

  /// Перебирает клиентов; null — аудио нет ни у одного.
  Future<YoutubeAudio?> resolve(String videoId) async {
    for (final client in _clients) {
      try {
        final response = await _dio.post<dynamic>(
          _playerUrl,
          queryParameters: {'key': _apiKey},
          data: {
            'context': {'client': client.toJson()},
            'videoId': videoId,
            'contentCheckOk': true,
            'racyCheckOk': true,
          },
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': client.userAgent,
              'X-YouTube-Client-Name': client.headerValue,
              'X-YouTube-Client-Version': client.version,
              'Accept-Language': 'en-US,en;q=0.9',
            },
          ),
        );
        final audio = parsePlayerResponse(
          response.data,
          userAgent: client.userAgent,
        );
        if (audio != null) {
          AppLogger.instance.info(
            'youtube innertube ${client.name}: аудио ${audio.bitrateKbps} kbps',
          );
          return audio;
        }
        final status = response.data is Map
            ? (response.data as Map)['playabilityStatus']
            : null;
        AppLogger.instance.warn(
          'youtube innertube ${client.name}: '
          '${status is Map ? status['status'] : 'нет ответа'}',
        );
      } on Object catch (error) {
        AppLogger.instance.warn('youtube innertube ${client.name}: $error');
      }
    }
    return null;
  }

  /// Разбор ответа player API. Вынесен, чтобы тестировать без сети.
  static YoutubeAudio? parsePlayerResponse(
    Object? json, {
    DateTime? now,
    String? userAgent,
  }) {
    if (json is! Map) return null;
    final status = json['playabilityStatus'];
    if (status is! Map || status['status'] != 'OK') return null;

    final streaming = json['streamingData'];
    if (streaming is! Map) return null;
    final formats =
        <Map<String, dynamic>>[
          for (final source in [
            streaming['adaptiveFormats'],
            streaming['formats'],
          ])
            if (source is List)
              for (final item in source)
                if (item is Map) Map<String, dynamic>.from(item),
        ].where((item) {
          final mime = '${item['mimeType']}';
          return mime.startsWith('audio/') && item['url'] is String;
        }).toList();
    if (formats.isEmpty) return null;

    // AAC/mp4 понятнее Android-декодеру; битрейт — следующий критерий.
    int rank(Map<String, dynamic> item) {
      final mime = '${item['mimeType']}';
      final bitrate = item['bitrate'] is int ? item['bitrate'] as int : 0;
      return (mime.contains('mp4') ? 100000000 : 0) + bitrate;
    }

    formats.sort((a, b) => rank(b).compareTo(rank(a)));
    final chosen = formats.first;
    final mime = '${chosen['mimeType']}';
    final rawBitrate = chosen['bitrate'] is int ? chosen['bitrate'] as int : 0;
    final expiresIn = int.tryParse('${streaming['expiresInSeconds']}') ?? 21600;
    final current = now ?? DateTime.now();
    final expiresAt = current
        .add(Duration(seconds: expiresIn))
        .subtract(const Duration(seconds: 60));
    return YoutubeAudio(
      url: Uri.parse(chosen['url'] as String),
      codec: mime.contains('mp4') ? 'aac' : 'opus',
      bitrateKbps: (rawBitrate / 1000).round(),
      expiresAt: expiresAt,
      userAgent: userAgent,
    );
  }

  Future<void> dispose() async {
    _dio.close(force: true);
  }
}

final class YoutubeAudio {
  const YoutubeAudio({
    required this.url,
    required this.codec,
    required this.bitrateKbps,
    required this.expiresAt,
    this.userAgent,
  });

  final Uri url;
  final String codec;
  final int bitrateKbps;
  final DateTime expiresAt;

  /// UA клиента, которым получен URL; некоторые CDN-узлы его проверяют.
  final String? userAgent;
}

final class YoutubeSearchItem {
  const YoutubeSearchItem({
    required this.id,
    required this.title,
    required this.author,
    required this.duration,
    this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String author;
  final Duration duration;
  final String? thumbnailUrl;
}

final class _InnertubeClient {
  const _InnertubeClient({
    required this.name,
    required this.version,
    required this.headerValue,
    required this.userAgent,
    required this.osName,
    required this.osVersion,
    this.deviceModel,
    this.androidSdk,
  });

  final String name;
  final String version;
  final String headerValue;
  final String userAgent;
  final String osName;
  final String osVersion;
  final String? deviceModel;
  final int? androidSdk;

  Map<String, Object?> toJson() => {
    'clientName': name,
    'clientVersion': version,
    'osName': osName,
    'osVersion': osVersion,
    if (deviceModel != null) 'deviceModel': deviceModel,
    if (androidSdk != null) 'androidSdkVersion': androidSdk,
    'hl': 'en',
    'gl': 'US',
  };
}
