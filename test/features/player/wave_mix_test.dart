import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/sources/source_dto.dart';
import 'package:phoneyandex/core/sources/source_id.dart';
import 'package:phoneyandex/features/player/wave_mix.dart';

SourceTrack _track(String id, String artist) => SourceTrack(
  ref: RemoteTrackRef(SourceId.yandex, id),
  title: 'Песня $id',
  artists: [artist],
  duration: const Duration(minutes: 3),
);

void main() {
  group('pickWaveIndexes', () {
    test('один исполнитель занимает не больше двух мест', () {
      final tracks = [
        for (var i = 0; i < 5; i++) _track('$i', 'shadowraze'),
        _track('9', 'Eve'),
      ];
      final ids = [for (final t in tracks) 't_${t.ref.remoteId}'];
      final picked = pickWaveIndexes(
        tracks: tracks,
        ids: ids,
        recent: const {},
        minFresh: 1,
      );
      expect(picked, [0, 1, 5]);
    });

    test('дубли и дизлайки уходят', () {
      final tracks = [_track('1', 'a'), _track('2', 'b'), _track('3', 'c')];
      final picked = pickWaveIndexes(
        tracks: tracks,
        ids: const ['x', 'x', 'y'],
        recent: const {},
        disliked: const {'y'},
        minFresh: 1,
      );
      expect(picked, [0]);
    });

    test('недавно слушанное уходит в хвост, если свежего хватает', () {
      final tracks = [
        _track('1', 'a'),
        _track('2', 'b'),
        _track('3', 'c'),
        _track('4', 'd'),
      ];
      final ids = ['t1', 't2', 't3', 't4'];
      final picked = pickWaveIndexes(
        tracks: tracks,
        ids: ids,
        recent: const {'t1', 't2'},
        minFresh: 2,
      );
      expect(picked, [2, 3]);
    });

    test('свежего мало — недавнее добирается, волна не пустеет', () {
      final tracks = [_track('1', 'a'), _track('2', 'b'), _track('3', 'c')];
      final picked = pickWaveIndexes(
        tracks: tracks,
        ids: const ['t1', 't2', 't3'],
        recent: const {'t1', 't2'},
        minFresh: 3,
      );
      expect(picked, [2, 0, 1]);
    });
  });
}
