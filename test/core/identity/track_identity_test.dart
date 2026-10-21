import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/identity/track_identity.dart';
import 'package:phoneyandex/core/sources/source_dto.dart';
import 'package:phoneyandex/core/sources/source_id.dart';

SourceTrack track({
  required String title,
  required List<String> artists,
  required int seconds,
  String? isrc,
  SourceId source = SourceId.yandex,
  String remoteId = '1',
}) => SourceTrack(
  ref: RemoteTrackRef(source, remoteId),
  title: title,
  artists: artists,
  duration: Duration(seconds: seconds),
  isrc: isrc,
);

void main() {
  group('fingerprint', () {
    test('один и тот же трек из разных каталогов даёт один отпечаток', () {
      final a = track(title: 'Ветер', artists: ['Ария'], seconds: 213, source: SourceId.yandex);
      final b = track(title: 'Ветер', artists: ['Ария'], seconds: 213, source: SourceId.youtube, remoteId: 'x1');
      expect(trackFingerprint(a), trackFingerprint(b));
      expect(localTrackIdFor(a), localTrackIdFor(b));
    });

    test('разная длительность — разный отпечаток', () {
      final live = track(title: 'Ветер', artists: ['Ария'], seconds: 260);
      final studio = track(title: 'Ветер', artists: ['Ария'], seconds: 213);
      expect(trackFingerprint(live), isNot(trackFingerprint(studio)));
    });

    test('remaster в скобках не создаёт дубль', () {
      final clean = track(title: 'Wind', artists: ['Aria'], seconds: 213);
      final remastered = track(title: 'Wind (Remastered 2011)', artists: ['Aria'], seconds: 213);
      expect(localTrackIdFor(clean), localTrackIdFor(remastered));
    });

    test('локальный id стабилен по формату', () {
      final id = localTrackIdFor(track(title: 'Wind', artists: ['Aria'], seconds: 213));
      expect(id, matches(RegExp(r'^t_[0-9a-f]{24}$')));
    });
  });

  group('normalizeIsrc', () {
    test('пробелы и дефисы не мешают', () {
      expect(normalizeIsrc('nl-anm-95-00020'), 'NLANM9500020');
    });

    test('обрезанный или мусорный ISRC игнорируется', () {
      expect(normalizeIsrc('NLANM95'), '');
      expect(normalizeIsrc(null), '');
    });
  });

  group('isFuzzyMatch', () {
    test('один и тот же трек с разными артистами в списке совпадает', () {
      final a = track(title: 'Ветер', artists: ['Ария'], seconds: 213);
      final b = track(title: 'Ветер', artists: ['Ария', 'Флэш'], seconds: 214);
      expect(isFuzzyMatch(a, b), isTrue);
    });

    test('длительность вне допуска — не совпадение', () {
      final a = track(title: 'Ветер', artists: ['Ария'], seconds: 213);
      final b = track(title: 'Ветер', artists: ['Ария'], seconds: 230);
      expect(isFuzzyMatch(a, b), isFalse);
    });

    test('разный артист при том же названии — не совпадение', () {
      final a = track(title: 'Ветер', artists: ['Ария'], seconds: 213);
      final b = track(title: 'Ветер', artists: ['Мельница'], seconds: 213);
      expect(isFuzzyMatch(a, b), isFalse);
    });

    test('опечатка в названии допускается, другая песня — нет', () {
      final a = track(title: 'Wind Of Change', artists: ['Scorpions'], seconds: 213);
      final typo = track(title: 'Wind Of Chnage', artists: ['Scorpions'], seconds: 213);
      final other = track(title: 'Wind Of Hate', artists: ['Scorpions'], seconds: 213);
      expect(isFuzzyMatch(a, typo), isTrue);
      expect(isFuzzyMatch(a, other), isFalse);
    });
  });
}
