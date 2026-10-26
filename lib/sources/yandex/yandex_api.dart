import 'package:dio/dio.dart';

import '../../core/env.dart';
import '../../core/sources/source_errors.dart';
import '../../core/sources/source_id.dart';

/// HTTP-слой Я.Музыки: заголовки, роспаковка `result`, превращение сетевых
/// отказов в [SourceFailure] — чтобы цепочка резервных источников ветвилась по
/// причине, а не по исключениям.
class YandexApi {
  YandexApi({String? token, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.yandexApiBase,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              headers: const {
                'Accept-Language': 'ru',
                'User-Agent': AppConfig.userAgent,
              },
              validateStatus: (status) => status != null && status < 500,
            ),
          );

  final Dio _dio;

  String? token;

  SourceId get sourceId => SourceId.yandex;

  bool get hasToken => token != null && token!.isNotEmpty;

  Map<String, dynamic> get _headers => {
    if (token != null) 'Authorization': 'OAuth $token',
    // Без клиентского заголовка часть write-эндпоинтов отвечает отказом.
    'X-Yandex-Music-Client': 'YandexMusicAndroid/24023621',
  };

  /// GET с ответом `{result: …}`. Ошибку отдаёт значением, не бросает.
  Future<YandexResponse> get(String path, [Map<String, dynamic>? query]) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: query,
        options: Options(headers: _headers),
      );
      return _unwrap(response);
    } on DioException catch (e) {
      return YandexResponse.failure(_fromDio(e));
    }
  }

  /// Текст песни в открытом supplement-ответе Яндекса. В отличие от
  /// `/tracks/{id}/lyrics`, этому эндпоинту не нужна подпись timeStamp+sign.
  Future<YandexResponse> supplement(String trackId) =>
      get('/tracks/$trackId/supplement');

  Future<YandexResponse> post(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    bool form = false,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        queryParameters: query,
        data: body,
        options: Options(
          headers: {
            ..._headers,
            if (form) ...{'Content-Type': 'application/x-www-form-urlencoded'},
          },
        ),
      );
      return _unwrap(response);
    } on DioException catch (e) {
      return YandexResponse.failure(_fromDio(e));
    }
  }

  /// Запрос произвольного абсолютного URL (downloadInfoUrl живёт не на api-base).
  Future<YandexResponse> getAbsolute(String url) async {
    try {
      final response = await _dio.get<dynamic>(
        url,
        options: Options(headers: _headers, responseType: ResponseType.plain),
      );
      if (response.statusCode == 200) {
        return YandexResponse.ok(
          response.data is String
              ? response.data
              : (response.data?.toString() ?? ''),
        );
      }
      return YandexResponse.failure(
        SourceFailure(
          source: SourceId.yandex,
          reason: _reasonForStatus(response.statusCode),
          httpStatus: response.statusCode,
        ),
      );
    } on DioException catch (e) {
      return YandexResponse.failure(_fromDio(e));
    }
  }

  YandexResponse _unwrap(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    final data = response.data;
    if (status == 200 && data is Map) {
      final result = data['result'];
      if (result != null) return YandexResponse.ok(result);
      // Некоторые эндпоинты отдают массив без обёртки.
      return YandexResponse.ok(data);
    }
    final message = data is Map
        ? (data['error'] as Map?)?.toString() ?? data.toString()
        : data?.toString();
    return YandexResponse.failure(
      SourceFailure(
        source: SourceId.yandex,
        reason: _reasonForStatus(status),
        httpStatus: status,
        message: message,
      ),
    );
  }

  SourceFailReason _reasonForStatus(int? status) => switch (status) {
    401 || 402 => SourceFailReason.authExpired,
    403 => SourceFailReason.geoBlocked,
    404 => SourceFailReason.notInCatalog,
    429 => SourceFailReason.remoteThrottled,
    _ => SourceFailReason.remoteError,
  };

  SourceFailure _fromDio(DioException e) => SourceFailure(
    source: SourceId.yandex,
    reason: switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => SourceFailReason.network,
      DioExceptionType.badCertificate => SourceFailReason.geoBlocked,
      _ => SourceFailReason.network,
    },
    message: e.message,
  );
}

final class YandexResponse {
  const YandexResponse.ok(this.data) : failure = null;

  const YandexResponse.failure(this.failure) : data = null;

  final Object? data;
  final SourceFailure? failure;

  Map<String, dynamic>? get asMap =>
      data is Map ? Map<String, dynamic>.from(data! as Map) : null;

  List<Map<String, dynamic>> get asList => data is List
      ? [
          for (final item in data as List)
            if (item is Map) Map<String, dynamic>.from(item),
        ]
      : const [];

  bool get isOk => failure == null;
}
