import 'dart:async';

import 'package:dio/dio.dart';

import '../../core/logging/app_logger.dart';
import '../../core/sources/source_errors.dart';
import '../../core/sources/source_id.dart';

/// HTTP-слой SoundCloud.
///
/// Официальный API требует регистрацию приложения, поэтому используется тот же
/// публичный `client_id` веб-плеера, что и у yt-dlp/VLC: он лежит в JS-ассетах
/// главной страницы и периодически меняется. При 401/403 ключ пересобирается
/// один раз и запрос повторяется.
class SoundCloudApi {
  SoundCloudApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              headers: const {
                // Мобильный UA SoundCloud редиректит на m.soundcloud.com, где
                // нет JS-ассетов с client_id. Нужен десктопный.
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
                    'AppleWebKit/537.36 (KHTML, like Gecko) '
                    'Chrome/126.0.0.0 Safari/537.36',
                'Accept-Language': 'en-US,en;q=0.9',
              },
              validateStatus: (status) => status != null && status < 600,
            ),
          );

  static const _apiBase = 'https://api-v2.soundcloud.com';
  static const _webHome = 'https://soundcloud.com/';
  static const _assetPattern =
      'https://a-v2\\.sndcdn\\.com/assets/[^"\']+\\.js';
  static const _clientIdPattern =
      r'''client_id\s*[:=]\s*["']([0-9a-zA-Z]{20,40})["']''';

  /// Публичный ключ веб-плеера на случай, если сайт SoundCloud не открывается
  /// (DPI сбрасывает TLS, а api-v2 при этом доступен). Ключ может устареть:
  /// тогда динамическая добыча с сайта найдёт новый. Проверяется запросом.
  static const _fallbackClientId = '3GKD969NJWD1eB6gvQJN0GnueYbcWszv';

  final Dio _dio;
  String? _clientId;
  Future<String?>? _resolving;

  SourceId get sourceId => SourceId.soundcloud;

  Future<String?> ensureClientId({bool force = false}) {
    if (!force && _clientId != null) return Future.value(_clientId);
    if (!force && _resolving != null) return _resolving!;
    final future = _resolveClientId().whenComplete(() => _resolving = null);
    _resolving = future;
    return future;
  }

  Future<String?> _resolveClientId() async {
    // Запасной ключ пробуем первым: на сетях с DPI сайт SoundCloud не
    // открывается, а api-v2 доступен. Проверка занимает один лёгкий запрос.
    final fallback = await _verifyClientId(_fallbackClientId);
    if (fallback == true || fallback == null) {
      _clientId = _fallbackClientId;
      return _clientId;
    }

    final extracted = await _extractClientId();
    if (extracted != null && await _verifyClientId(extracted) != false) {
      _clientId = extracted;
      AppLogger.instance.info('soundcloud: client_id получен с сайта');
      return extracted;
    }
    AppLogger.instance.warn('soundcloud: client_id не найден');
    return null;
  }

  /// true — ключ рабочий, false — отклонён, null — сеть недоступна.
  Future<bool?> _verifyClientId(String id) async {
    try {
      final response = await _dio
          .get<dynamic>(
            '$_apiBase/search/tracks',
            queryParameters: {'q': 'test', 'limit': 1, 'client_id': id},
          )
          .timeout(const Duration(seconds: 6));
      final status = response.statusCode ?? 0;
      if (status == 200) return true;
      if (status == 401 || status == 403) return false;
      return null;
    } on Object catch (error) {
      AppLogger.instance.warn('soundcloud client_id check: $error');
      return null;
    }
  }

  Future<String?> _extractClientId() async {
    try {
      final home = await _dio
          .get<String>(
            _webHome,
            options: Options(responseType: ResponseType.plain),
          )
          .timeout(const Duration(seconds: 6));
      final html = home.data ?? '';
      final direct = extractClientId(html);
      if (direct != null) return direct;
      final assets = RegExp(_assetPattern)
          .allMatches(html)
          .map((match) => match.group(0)!)
          .toSet()
          .take(12)
          .toList();
      for (final asset in assets) {
        try {
          final js = await _dio
              .get<String>(
                asset,
                options: Options(responseType: ResponseType.plain),
              )
              .timeout(const Duration(seconds: 4));
          final found = extractClientId(js.data ?? '');
          if (found != null) return found;
        } on Object {
          // Один недоступный ассет не должен ломать поиск ключа.
        }
      }
    } on Object catch (error) {
      AppLogger.instance.warn('soundcloud client_id: $error');
    }
    return null;
  }

  /// Публичный ключ из HTML/JS. Вынесен для теста.
  static String? extractClientId(String text) {
    final match = RegExp(_clientIdPattern).firstMatch(text);
    return match?.group(1);
  }

  Future<SoundCloudReply> search(
    String query, {
    int limit = 50,
    int offset = 0,
    bool retry = true,
  }) => _get(
    '/search/tracks',
    query: {'q': query, 'limit': '$limit', 'offset': '$offset'},
    retry: retry,
  );

  Future<SoundCloudReply> tracks(List<String> ids, {bool retry = true}) {
    if (ids.isEmpty) return Future.value(const SoundCloudReply.ok([]));
    return _get('/tracks', query: {'ids': ids.join(',')}, retry: retry);
  }

  Future<SoundCloudReply> track(String id, {bool retry = true}) =>
      _get('/tracks/$id', retry: retry);

  /// Разворачивает выбранный транскодинг в подписанный медиа-URL.
  Future<SoundCloudReply> resolveMedia(
    String transcodingUrl, {
    String? trackAuthorization,
    bool retry = true,
  }) async {
    final id = await ensureClientId();
    if (id == null) return _noClientId();
    final parsed = Uri.parse(transcodingUrl);
    final absolute = parsed.hasScheme
        ? parsed
        : Uri.parse('$_apiBase$transcodingUrl');
    final uri = _withParams(absolute, {
      'client_id': id,
      if (trackAuthorization != null && trackAuthorization.isNotEmpty)
        'track_authorization': trackAuthorization,
    });
    final reply = await _send(uri.toString());
    if (reply.isOk) return reply;
    if (retry && _shouldRefresh(reply.failure!)) {
      _clientId = null;
      if (await ensureClientId(force: true) != null) {
        return resolveMedia(
          transcodingUrl,
          trackAuthorization: trackAuthorization,
          retry: false,
        );
      }
    }
    return reply;
  }

  Future<SoundCloudReply> _get(
    String path, {
    Map<String, String>? query,
    bool retry = true,
  }) async {
    final id = await ensureClientId();
    if (id == null) return _noClientId();
    final reply = await _send(
      _withParams(Uri.parse('$_apiBase$path'), {
        ...?query,
        'client_id': id,
      }).toString(),
    );
    if (reply.isOk) return reply;
    final failure = reply.failure!;
    if (retry && _shouldRefresh(failure)) {
      _clientId = null;
      final fresh = await ensureClientId(force: true);
      if (fresh != null) return _get(path, query: query, retry: false);
    }
    return reply;
  }

  bool _shouldRefresh(SourceFailure failure) =>
      failure.httpStatus == 401 || failure.httpStatus == 403;

  Future<SoundCloudReply> _send(String url) async {
    try {
      final response = await _dio.get<dynamic>(url);
      final status = response.statusCode ?? 0;
      if (status == 200 && response.data != null) {
        return SoundCloudReply.ok(response.data);
      }
      return SoundCloudReply.failure(
        SourceFailure(
          source: sourceId,
          reason: _reasonFor(status),
          httpStatus: status,
          message: status == 404 ? 'трек не найден' : null,
        ),
      );
    } on DioException catch (error) {
      return SoundCloudReply.failure(
        SourceFailure(
          source: sourceId,
          reason: SourceFailReason.network,
          message: error.message,
        ),
      );
    }
  }

  SoundCloudReply _noClientId() => SoundCloudReply.failure(
    SourceFailure(
      source: sourceId,
      reason: SourceFailReason.network,
      message: 'SoundCloud: не удалось получить client_id',
    ),
  );

  static SourceFailReason _reasonFor(int status) => switch (status) {
    // Анонимный источник: «протух ключ» не должен останавливать цепочку
    // источников — просто пробуем следующий.
    401 || 403 => SourceFailReason.remoteError,
    404 => SourceFailReason.notInCatalog,
    429 => SourceFailReason.remoteThrottled,
    _ => SourceFailReason.remoteError,
  };

  static Uri _withParams(Uri uri, Map<String, String> extra) {
    final params = {...uri.queryParameters, ...extra};
    return uri.replace(queryParameters: params);
  }

  Future<void> dispose() async {
    _dio.close(force: true);
    _clientId = null;
    _resolving = null;
  }
}

final class SoundCloudReply {
  const SoundCloudReply.ok(this.data) : failure = null;

  const SoundCloudReply.failure(this.failure) : data = null;

  final Object? data;
  final SourceFailure? failure;

  bool get isOk => failure == null;

  Map<String, dynamic>? get asMap =>
      data is Map ? Map<String, dynamic>.from(data! as Map) : null;
}
