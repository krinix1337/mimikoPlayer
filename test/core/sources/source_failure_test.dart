import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/sources/source_errors.dart';
import 'package:phoneyandex/core/sources/source_id.dart';

SourceFailure fail(SourceFailReason reason) =>
    SourceFailure(source: SourceId.yandex, reason: reason);

void main() {
  test('цепочка идёт дальше при отказе каталога, региона и подписки', () {
    for (final reason in [
      SourceFailReason.notInCatalog,
      SourceFailReason.unavailable,
      SourceFailReason.geoBlocked,
      SourceFailReason.needsPlus,
      SourceFailReason.codecUnsupported,
      SourceFailReason.signatureRejected,
      SourceFailReason.localFileMissing,
      SourceFailReason.network,
      SourceFailReason.remoteError,
    ]) {
      expect(fail(reason).fallbackToNextSource, isTrue, reason: reason.name);
    }
  });

  test('цепочку останавливают только те отказы, чинит которые пользователь', () {
    for (final reason in [
      SourceFailReason.authRequired,
      SourceFailReason.authExpired,
      SourceFailReason.remoteThrottled,
      SourceFailReason.allSourcesExhausted,
    ]) {
      expect(fail(reason).fallbackToNextSource, isFalse, reason: reason.name);
    }

    expect(fail(SourceFailReason.authRequired).needsUserAction, isTrue);
    expect(fail(SourceFailReason.authExpired).needsUserAction, isTrue);
    expect(fail(SourceFailReason.needsPlus).needsUserAction, isTrue);
    // Подписку тоже чинит человек, но остальные источники стоит попробовать.
    expect(fail(SourceFailReason.needsPlus).fallbackToNextSource, isTrue);
    expect(fail(SourceFailReason.unavailable).needsUserAction, isFalse);
  });

  test('троттлинг ретраится в том же источнике, а не в следующем', () {
    expect(fail(SourceFailReason.remoteThrottled).retrySameSource, isTrue);
    expect(fail(SourceFailReason.network).retrySameSource, isTrue);
    expect(fail(SourceFailReason.unavailable).retrySameSource, isFalse);
  });

  test('негативный кэш: снятый трек помнится долго, сеть — пять минут', () {
    expect(fail(SourceFailReason.notInCatalog).negativeCacheTtl, const Duration(days: 7));
    expect(fail(SourceFailReason.unavailable).negativeCacheTtl, const Duration(days: 7));
    expect(fail(SourceFailReason.geoBlocked).negativeCacheTtl, const Duration(days: 7));
    expect(fail(SourceFailReason.network).negativeCacheTtl, const Duration(minutes: 5));
    expect(fail(SourceFailReason.remoteThrottled).negativeCacheTtl, const Duration(minutes: 5));
  });

  test('отказ, который чинится на месте, в кэше не держится', () {
    for (final reason in [
      SourceFailReason.signatureRejected,
      SourceFailReason.authExpired,
      SourceFailReason.authRequired,
      SourceFailReason.needsPlus,
      SourceFailReason.allSourcesExhausted,
    ]) {
      expect(fail(reason).negativeCacheTtl, Duration.zero, reason: reason.name);
    }
  });

  test('toString содержит источник и причину — это видно в debug-логе', () {
    expect(
      SourceFailure(
        source: SourceId.youtube,
        reason: SourceFailReason.geoBlocked,
        httpStatus: 403,
      ).toString(),
      'youtube/geoBlocked http=403',
    );
  });
}
