import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/sources/source_dto.dart';
import 'package:phoneyandex/core/sources/source_id.dart';
import 'package:phoneyandex/sources/yandex/yandex_source.dart';

SourceTrack _full(String id, String title) => SourceTrack(
  ref: RemoteTrackRef(SourceId.yandex, id),
  title: title,
  artists: const ['Артист'],
  duration: const Duration(minutes: 3),
);

void main() {
  test('короткие ссылки плейлиста разбираются в refs', () {
    final refs = YandexSource.playlistTrackRefs([
      {'timestamp': '2026-10-01T00:00:00', 'id': 10, 'albumId': 500},
      {'timestamp': '2026-10-01T00:00:00', 'id': 11, 'albumId': null},
      'мусор',
      {'timestamp': '2026-10-01T00:00:00'},
    ]);

    expect(refs.map((r) => r.remoteId), ['10', '11']);
    expect(refs.first.albumId, '500');
    expect(refs.last.albumId, isNull);
  });

  test('порядок и повторы плейлиста сохраняются после батча', () {
    final refs = YandexSource.playlistTrackRefs([
      {'id': 10, 'albumId': 500},
      {'id': 11, 'albumId': 501},
      {'id': 10, 'albumId': 500},
      {'id': 12, 'albumId': 502},
    ]);
    // Батч вернул треки в другом порядке и без повтора.
    final ordered = YandexSource.orderPlaylistTracks(refs, [
      _full('12', 'Третий'),
      _full('10', 'Первый'),
      _full('11', 'Второй'),
    ]);

    expect(ordered.map((t) => t.title), [
      'Первый',
      'Второй',
      'Первый',
      'Третий',
    ]);
  });
}
