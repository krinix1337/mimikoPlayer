/// Общесистемные константы. Всё, что зависит от измерения на живом запросе,
/// помечено и меряется в `tool/probe/`.
library;

const String userAgent = 'YandexMusic/26.0.0 (Android)';
const String acceptLanguage = 'ru';

const Duration httpConnectTimeout = Duration(seconds: 10);
const Duration httpReceiveTimeout = Duration(seconds: 20);

/// Подписанные ссылки Яндекса живут по `ts`; реальный TTL в ответе не приходит,
/// поэтому до замера живым запросом держим консервативную оценку.
const Duration defaultStreamTtl = Duration(minutes: 20);

/// Резерв: переиспользуем ссылку, только если до истечения остаётся запас.
const Duration streamTtlSafetyMargin = Duration(minutes: 2);

/// Абсолютный потолок жизни ссылки в кэше.
const Duration streamTtlMax = Duration(hours: 1);

const int streamLruSize = 32;

/// Сколько треков подряд может отказать до остановки очереди.
const int maxConsecutivePlaybackFailures = 2;

/// Порог watchdog'а буфера: недостаточно закачанного за это время — перевалид.
const Duration bufferStallWindow = Duration(seconds: 15);
const Duration bufferStallThreshold = Duration(seconds: 5);

/// FGS с типом mediaPlayback обязан быть остановлен, если пауза дольше этой
/// границы (требование Android к media-уведомлениям).
const Duration maxPausedServiceDuration = Duration(minutes: 10);

/// Позиция, после которой «previous» перемотает в начало вместо предыдущего трека.
const Duration previousRestartThreshold = Duration(seconds: 3);
