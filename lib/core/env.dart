/// Конфиг, который можно перебить сборкой: `--dart-define=YM_API_BASE=…`.
///
/// Реквизиты ниже не секрет: они публично используются открытыми клиентами
/// Я.Музыки (см. docs/API_PROBE.md). Секрет — только полученный токен, он
/// живёт в таблице `auth_tokens`.
class AppConfig {
  const AppConfig._();

  static const String yandexClientId = String.fromEnvironment(
    'YM_CLIENT_ID',
    defaultValue: '23cabbbdc6cd418abb4b39c32c41195d',
  );

  static const String yandexClientSecret = String.fromEnvironment(
    'YM_CLIENT_SECRET',
    defaultValue: '53bc75238f0c4d08a118e51fe9203300',
  );

  static const String yandexApiBase = String.fromEnvironment(
    'YM_API_BASE',
    defaultValue: 'https://api.music.yandex.net',
  );

  static const String yandexOAuthHost = String.fromEnvironment(
    'YM_OAUTH_HOST',
    defaultValue: 'https://oauth.yandex.ru',
  );

  /// Соль подписи адреса хранилища. Подтверждена живым запросом 2026-10-21:
  /// md5hex(соль + path без ведущего слэша + s).
  static const String yandexGetMp3Salt = String.fromEnvironment(
    'YM_GETMP3_SALT',
    defaultValue: 'XGRvlVRHweBcSULG',
  );

  static const String userAgent = 'YandexMusic/26.0.0 (Android)';
}
