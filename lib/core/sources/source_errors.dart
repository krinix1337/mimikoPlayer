import 'source_id.dart';

/// Причина, по которой источник не отдал поток. Определяет поведение цепочки
/// резервных источников: см. [SourceFailure.fallbackToNextSource].
enum SourceFailReason {
  /// В этом каталоге такого трека нет.
  notInCatalog,

  /// Трек есть, но он помечен недоступным (снят с публикации).
  unavailable,

  /// Доступ заблокирован по региону.
  geoBlocked,

  /// Нужна платная подписка у источника.
  needsPlus,

  /// Пользователь не вошёл в источник.
  authRequired,

  /// Токен протух, нужно перелогиниться.
  authExpired,

  /// Мы подписали URL, а сервер ответил 403 — ключ подписи устарел.
  signatureRejected,

  /// Источник ограничил частоту запросов.
  remoteThrottled,

  network,
  remoteError,
  codecUnsupported,
  localFileMissing,

  /// Все playable-источники перебраны и отказали.
  allSourcesExhausted,
}

/// Отказ источника. Это значение, а не исключение: цепочка резервных
/// источников ветвится по [reason] без try/catch.
final class SourceFailure implements Exception {
  const SourceFailure({
    required this.source,
    required this.reason,
    this.httpStatus,
    this.message,
    this.retryAfter,
  });

  final SourceId source;
  final SourceFailReason reason;
  final int? httpStatus;
  final String? message;
  final Duration? retryAfter;

  /// Переходим к следующему источнику в цепочке.
  bool get fallbackToNextSource => switch (reason) {
    SourceFailReason.authRequired ||
    SourceFailReason.authExpired ||
    SourceFailReason.remoteThrottled ||
    SourceFailReason.allSourcesExhausted => false,
    _ => true,
  };

  /// Останавливаем цепочку и просим пользователя действовать.
  bool get needsUserAction => switch (reason) {
    SourceFailReason.authRequired ||
    SourceFailReason.authExpired ||
    SourceFailReason.needsPlus => true,
    _ => false,
  };

  /// Тот же источник, но позже.
  bool get retrySameSource => switch (reason) {
    SourceFailReason.remoteThrottled || SourceFailReason.network => true,
    _ => false,
  };

  /// Сколько держать запрет на этот источник для этого трека.
  Duration get negativeCacheTtl => switch (reason) {
    SourceFailReason.notInCatalog ||
    SourceFailReason.unavailable ||
    SourceFailReason.geoBlocked => const Duration(days: 7),
    SourceFailReason.remoteThrottled ||
    SourceFailReason.network => const Duration(minutes: 5),
    _ => Duration.zero,
  };

  @override
  String toString() =>
      '${source.wire}/${reason.name}'
      '${httpStatus == null ? '' : ' http=$httpStatus'}'
      '${message == null ? '' : ' $message'}';
}
