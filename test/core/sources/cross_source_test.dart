import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/sources/cross_source.dart';
import 'package:phoneyandex/core/sources/source_dto.dart';
import 'package:phoneyandex/core/sources/source_errors.dart';
import 'package:phoneyandex/core/sources/source_id.dart';

SourceTrack track(String title, List<String> artists, int seconds) =>
    SourceTrack(
      ref: RemoteTrackRef(SourceId.yandex, '1'),
      title: title,
      artists: artists,
      duration: Duration(seconds: seconds),
    );

void main() {
  test('YouTube-обвес снимается, песня находится', () {
    final match = pickCrossSourceMatch(
      [
        track('Gimme Love', ['Joji'], 203),
        track('Slow Dancing', ['Joji'], 180),
      ],
      title: 'Joji - Gimme Love (Official Video)',
      artists: ['88rising'],
      duration: const Duration(seconds: 202),
    );
    expect(match?.title, 'Gimme Love');
  });

  test('чужой исполнитель не подставляется вместо трека', () {
    final match = pickCrossSourceMatch(
      [
        track('Hotel California', ['Eagles'], 391),
      ],
      title: 'Joji - Hotel California',
      artists: ['Joji'],
      duration: const Duration(seconds: 300),
    );
    expect(match, isNull);
  });

  test(
    'одинаковое название и длительность, но другой исполнитель — промах',
    () {
      final match = pickCrossSourceMatch(
        [
          track('Hotel California', ['Eagles'], 391),
        ],
        title: 'Joji - Hotel California',
        artists: ['Joji'],
        duration: const Duration(seconds: 391),
      );
      expect(match, isNull);
    },
  );

  test('большая разница в длительности — промах', () {
    final match = pickCrossSourceMatch(
      [
        track('Gimme Love', ['Joji'], 203),
      ],
      title: 'Gimme Love',
      artists: ['Joji'],
      duration: const Duration(seconds: 60),
    );
    expect(match, isNull);
  });

  test('название очищается от служебных слов', () {
    expect(
      normalizeMatchText('Joji — Gimme Love [Official Audio] (prod. X)'),
      'joji gimme love',
    );
  });

  test('запрос для Яндекса не содержит YouTube-обвеса', () {
    expect(
      crossSourceQuery('Joji - Gimme Love (Official Video)', ['88rising']),
      'joji gimme love',
    );
    expect(
      crossSourceQuery('(Official Video)', ['Joji']),
      '(Official Video) Joji',
    );
  });

  test('подстановка лечит снятые и удалённые, но не сеть и не авторизацию', () {
    SourceFailure failure(SourceFailReason reason) =>
        SourceFailure(source: SourceId.yandex, reason: reason);

    for (final reason in [
      SourceFailReason.unavailable,
      SourceFailReason.notInCatalog,
      SourceFailReason.geoBlocked,
      SourceFailReason.remoteError,
    ]) {
      expect(worthCrossSource(failure(reason)), isTrue, reason: reason.name);
    }
    for (final reason in [
      SourceFailReason.network,
      SourceFailReason.authRequired,
      SourceFailReason.authExpired,
      SourceFailReason.needsPlus,
      SourceFailReason.remoteThrottled,
      SourceFailReason.codecUnsupported,
      SourceFailReason.localFileMissing,
      SourceFailReason.allSourcesExhausted,
    ]) {
      expect(worthCrossSource(failure(reason)), isFalse, reason: reason.name);
    }
  });
}
