import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/db/daos/auth_dao.dart';
import '../../core/logging/app_logger.dart';
import '../../core/env.dart';
import '../../core/sources/source_dto.dart';
import '../../core/sources/source_errors.dart';
import 'yandex_api.dart';

/// Ошибка авторизации в человеческом виде: UI показывает [message], а не
/// дамп DioException.
class YandexAuthException implements Exception {
  const YandexAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum _PollKind { token, pending, retryLater, failed }

final class _PollResult {
  const _PollResult(this.kind, {this.token, this.refreshToken, this.expiresInSeconds, this.message});

  final _PollKind kind;
  final String? token;
  final String? refreshToken;
  final int? expiresInSeconds;
  final String? message;
}

final class DeviceLogin {
  const DeviceLogin({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUrl,
    required this.interval,
    required this.expiresIn,
  });

  final String deviceCode;
  final String userCode;
  final String verificationUrl;
  final Duration interval;
  final Duration expiresIn;

  /// Яндекс принимает код параметром `code` и уносит его в retpath после
  /// входа — проверено на https://ya.ru/device. Открываем сразу эту ссылку,
  /// чтобы код не пришлось вводить руками.
  Uri get verificationUri {
    final base = Uri.parse(verificationUrl);
    final query = Map<String, String>.from(base.queryParameters)
      ..['code'] = userCode;
    return base.replace(queryParameters: query);
  }
}

/// OAuth device flow Яндекса. Пароль приложения не видит: пользователь
/// подтверждает код на странице Яндекса (проверено живым запросом,
/// docs/API_PROBE.md).
class YandexAuth {
  YandexAuth(this._dao, this._api)
    : _oauth = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
          headers: const {'User-Agent': AppConfig.userAgent},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

  static const provider = 'yandex';

  final AuthDao _dao;
  final YandexApi _api;
  final Dio _oauth;
  final StreamController<AuthState> _changes =
      StreamController<AuthState>.broadcast();

  AuthState _state = const AuthUnknown();
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiresAt;

  Stream<AuthState> get changes => _changes.stream;

  AuthState get state => _state;

  String? get accessToken => _accessToken;

  bool get isSignedIn => _state is AuthReady;

  /// Что-то годное для заголовка? Пустой токен — это «не входился».
  bool get hasUsableToken => _accessToken != null && _accessToken!.isNotEmpty;

  Future<void> restore() async {
    final row = await _dao.load(provider);
    if (row == null || row.accessToken.isEmpty) {
      _emit(const AuthNeedsDeviceLogin());
      return;
    }

    _accessToken = row.accessToken;
    _refreshToken = row.refreshToken;
    _api.token = row.accessToken;

    if (row.expiresAt != null &&
        DateTime.fromMillisecondsSinceEpoch(row.expiresAt!)
            .isBefore(DateTime.now())) {
      final refreshed = await _refresh();
      if (!refreshed) {
        _emit(const AuthExpired());
        return;
      }
    }

    await _loadAccount(row.uid, row.login, row.hasPlus);
  }

  /// Вызывается перед первым сетевым хопом источника.
  Future<void> ensureValid() async {
    if (!hasUsableToken) {
      await restore();
    }
    if (!hasUsableToken) return;

    if (_state is AuthExpired) {
      await _refresh();
    }
  }

  Future<DeviceLogin> startDeviceLogin() async {
    final Response<dynamic> response;
    try {
      response = await _oauth.post<dynamic>(
      '${AppConfig.yandexOAuthHost}/device/code',
      options: Options(
        headers: const {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
        data: Uri(
          queryParameters: {
            'client_id': AppConfig.yandexClientId,
            'device_id': await _deviceId(),
            'device_name': 'phoneyandex',
          },
        ).query,
      );
    } on Object {
      throw const YandexAuthException(
        'Нет связи с oauth.yandex.ru — проверь сеть или VPN',
      );
    }

    final json = _asMap(response.data);
    final error = json['error'];
    if (error != null || response.statusCode != 200) {
      throw YandexAuthException('Яндекс не выдал код: ${error ?? response.statusCode}');
    }

    // Код короткоживущий и всё равно показывается на экране — он нужен в логе,
    // чтобы прогон входа можно было закончить с другой машины.
    AppLogger.instance.info(
      'device flow: код ${json['user_code']} на ${json['verification_url']}',
    );

    return DeviceLogin(
      deviceCode: '${json['device_code']}',
      userCode: '${json['user_code']}',
      verificationUrl: '${json['verification_url'] ?? 'https://ya.ru/device'}',
      interval: Duration(seconds: (json['interval'] as num?)?.toInt() ?? 5),
      expiresIn: Duration(seconds: (json['expires_in'] as num?)?.toInt() ?? 300),
    );
  }

  /// Опрашивает выдачу токена, пока пользователь не подтвердит код.
  /// Сетевые сбои (например, DNS описывается после переключения VPN-маршрута)
  /// терпимы: пробуем до истечения кода, а не сдаёмся с первой ошибки.
  Future<bool> completeDeviceLogin(
    DeviceLogin login, {
    Duration? timeout,
  }) async {
    final deadline =
        DateTime.now().add(timeout ?? login.expiresIn + const Duration(seconds: 30));
    var lastError = 'время подтверждения истекло';

    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(login.interval);

      final attempt = await _pollOnce(login.deviceCode);
      switch (attempt.kind) {
        case _PollKind.token:
          await _store(
            accessToken: attempt.token!,
            refreshToken: attempt.refreshToken,
            expiresInSeconds: attempt.expiresInSeconds,
          );
          await _loadAccount(null, null, false);
          return true;

        case _PollKind.pending:
          continue;

        case _PollKind.retryLater:
          lastError = attempt.message ?? lastError;
          continue;

        case _PollKind.failed:
          _emit(AuthFailed(attempt.message ?? 'Яндекс отказал в выдаче токена'));
          return false;
      }
    }

    _emit(AuthFailed(lastError));
    return false;
  }

  Future<_PollResult> _pollOnce(String deviceCode) async {
    try {
      final response = await _oauth.post<dynamic>(
        '${AppConfig.yandexOAuthHost}/token',
        options: Options(
          headers: const {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: Uri(
          queryParameters: {
            'grant_type': 'device_code',
            'code': deviceCode,
            'client_id': AppConfig.yandexClientId,
            'client_secret': AppConfig.yandexClientSecret,
          },
        ).query,
      );

      final json = _asMap(response.data);
      final token = json['access_token'];
      if (token != null) {
        return _PollResult(
          _PollKind.token,
          token: '$token',
          refreshToken: json['refresh_token']?.toString(),
          expiresInSeconds: (json['expires_in'] as num?)?.toInt(),
        );
      }

      final error = json['error']?.toString();
      if (error == null) {
        return _PollResult(_PollKind.retryLater, message: 'Яндекс вернул пустой ответ');
      }
      if (error == 'authorization_pending' || error == 'slow_down') {
        return const _PollResult(_PollKind.pending);
      }
      if (error == 'expired_token' || error == 'access_denied') {
        return _PollResult(_PollKind.failed, message: json['error_description']?.toString() ?? error);
      }
      return _PollResult(_PollKind.retryLater, message: error);
    } on Object catch (e) {
      return _PollResult(_PollKind.retryLater, message: 'сеть недоступна: $e');
    }
  }

  Future<void> logout() async {
    await _dao.clear(provider);
    _accessToken = null;
    _refreshToken = null;
    _api.token = null;
    _emit(const AuthNeedsDeviceLogin());
  }

  Future<bool> _refresh() async {
    final refresh = _refreshToken;
    if (refresh == null) return false;

    // Обновление по refresh_token не проверялась живым запросом: срок жизни
    // выданного токена — год, так что до проверки это мёртвый путь.
    final response = await _oauth.post<dynamic>(
      '${AppConfig.yandexOAuthHost}/token',
      options: Options(
        headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
      ),
      data: Uri(
        queryParameters: {
          'grant_type': 'refresh_token',
          'refresh_token': refresh,
          'client_id': AppConfig.yandexClientId,
          'client_secret': AppConfig.yandexClientSecret,
        },
      ).query,
    );

    final json = _asMap(response.data);
    final token = json['access_token'];
    if (token == null) {
      _emit(const AuthExpired());
      return false;
    }

    await _store(
      accessToken: '$token',
      refreshToken: json['refresh_token']?.toString() ?? refresh,
      expiresInSeconds: (json['expires_in'] as num?)?.toInt(),
    );
    return true;
  }

  Future<void> _store({
    required String accessToken,
    String? refreshToken,
    int? expiresInSeconds,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _api.token = accessToken;
    final expiresAt = expiresInSeconds == null
        ? null
        : DateTime.now().add(Duration(seconds: expiresInSeconds));
    _tokenExpiresAt = expiresAt;

    final row = await _dao.load(provider);
    await _dao.save(
      provider: provider,
      accessToken: accessToken,
      refreshToken: refreshToken ?? row?.refreshToken,
      expiresAtEpochMs: expiresAt?.millisecondsSinceEpoch,
      uid: row?.uid,
      login: row?.login,
      displayName: row?.displayName,
      hasPlus: row?.hasPlus ?? false,
    );
  }

  Future<void> _loadAccount(String? knownUid, String? knownLogin, bool knownPlus) async {
    final result = await _api.get('/account/status');
    if (!result.isOk) {
      _emit(result.failure?.reason == SourceFailReason.authExpired
          ? const AuthExpired()
          : AuthFailed(result.failure?.message ?? 'нет ответа'));
      return;
    }

    final status = result.asMap ?? const <String, dynamic>{};
    final account = _asMap(status['account']);
    final plus = _asMap(status['plus']);
    final uid = '${account['uid'] ?? knownUid ?? ''}';
    final login = '${account['login'] ?? knownLogin ?? ''}';
    final hasPlus = plus['hasPlus'] == true || knownPlus;

    final expiresAt = _tokenExpiresAt ??
        DateTime.now().add(const Duration(days: 365));

    _emit(
      AuthReady(
        uid: uid,
        login: login,
        hasPlus: hasPlus,
        accessTokenExpiresAt: expiresAt,
      ),
    );

    final row = await _dao.load(provider);
    await _dao.save(
      provider: provider,
      accessToken: _accessToken ?? row?.accessToken ?? '',
      refreshToken: _refreshToken ?? row?.refreshToken,
      expiresAtEpochMs: row?.expiresAt,
      uid: uid,
      login: login,
      displayName: account['fullName']?.toString(),
      hasPlus: hasPlus,
    );
  }

  Future<String> _deviceId() async {
    final row = await _dao.load(provider);
    final stored = row?.extraJson == null
        ? null
        : (_asMap(jsonDecode(row!.extraJson!))['device_id'] as String?);
    if (stored != null) return stored;

    final generated = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    await _dao.save(
      provider: provider,
      accessToken: row?.accessToken ?? '',
      refreshToken: row?.refreshToken,
      extra: {'device_id': generated},
    );
    return generated;
  }

  void _emit(AuthState state) {
    _state = state;
    if (!_changes.isClosed) _changes.add(state);
  }

  static Map<String, dynamic> _asMap(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  Future<void> dispose() => _changes.close();
}
