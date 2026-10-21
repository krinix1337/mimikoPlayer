@Tags(['live'])
library;

/// Живой прогон модуля Яндекса: требует токен в файле и доступ в сеть.
/// Запуск: `dart test test/integration/yandex_live_test.dart` (после
/// `dart run tool/probe/yandex_probe.dart login`).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/sources/source_dto.dart';
import 'package:phoneyandex/core/sources/source_id.dart';
import 'package:phoneyandex/core/sources/stream_target.dart';
import 'package:phoneyandex/sources/yandex/yandex_api.dart';
import 'package:phoneyandex/sources/yandex/yandex_source.dart';

final _tokenFile = File('C:/project/musor/yandex_token.txt');

void main() {
  final token = _tokenFile.existsSync() ? _tokenFile.readAsStringSync().trim() : '';
  if (token.isEmpty) {
    markTestSkipped('нет токена: сначала probe login');
    return;
  }

  final api = YandexApi()..token = token;
  final source = YandexSource(api: api);

  test('поиск отдаёт треки с артистами и обложкой', () async {
    final result = await source.search('queen', pageSize: 10);

    expect(result.tracks, isNotEmpty);
    final first = result.tracks.first;
    expect(first.ref.source, SourceId.yandex);
    expect(first.artists, isNotEmpty);
    expect(first.duration.inMilliseconds, greaterThan(0));
    expect(first.coverUrl, startsWith('https://'));
    expect(result.total, greaterThan(result.tracks.length));
  });

  test('пакетный getTracksByIds принимает числовые id', () async {
    final found = await source.search('queen', pageSize: 3);
    final refs = [for (final track in found.tracks) track.ref];

    final tracks = await source.getTracksByIds(refs);

    expect(tracks.length, refs.length);
    expect(tracks.map((t) => t.ref.remoteId), refs.map((r) => r.remoteId));
  });

  test('поток отдаётся и это играбельные байты', () async {
    final found = await source.search('queen', pageSize: 3);
    final track = found.tracks.first;

    final result = await source.resolveStream(track);

    expect(result, isA<StreamReady>(), reason: '$result');
    final ready = result as StreamReady;
    expect(ready.source, SourceId.yandex);
    final url = (ready.target as StreamUrl).url;
    stderr.writeln('поток: ${url.host} битрейт=${ready.bitrateKbps} codec=${ready.codec}');

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    final request = await client.openUrl('GET', url)
      ..headers.set(HttpHeaders.rangeHeader, 'bytes=0-8191');
    final response = await request.close();
    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
    }
    client.close(force: true);

    expect(response.statusCode, anyOf(200, 206));
    expect(bytes.length, greaterThan(1024));
    // sync-байт MPEG-кадра: 11111111 111x_xxx
    expect(bytes[0], 0xFF);
    expect(bytes[1] & 0xE0, 0xE0);
  });

  test('волна отдаёт треки текущего аккаунта', () async {
    final tracks = await source.station.wave();
    expect(tracks, isNotEmpty);
    expect(tracks.first.title, isNotEmpty);
  });

  test('список плейлистов аккаунта и один плейлист с треками', () async {
    final uid = '1874380055';
    final list = await api.get('/users/$uid/playlists/list');
    expect(list.isOk, isTrue);
    expect(list.asList, isNotEmpty);

    final kind = '${list.asList.first['kind']}';
    final fetched = await api.get('/users/$uid/playlists', {'kinds': kind});
    final playlist = fetched.asList.first;
    expect((playlist['tracks'] as List?) ?? const [], isNotEmpty);
  });

  test('лайки резолвятся в полные треки', () async {
    final result = await api.get('/users/1874380055/likes/tracks');
    final library = result.asMap?['library'] as Map?;
    final pairs = (library?['tracks'] as List? ?? const []).take(20).toList();
    expect(pairs, isNotEmpty);

    final refs = [
      for (final pair in pairs)
        RemoteTrackRef(
          SourceId.yandex,
          '${(pair as Map)['id']}',
          albumId: '${pair['albumId']}',
        ),
    ];
    final tracks = await source.getTracksByIds(refs);

    expect(tracks, hasLength(refs.length));
    expect(jsonEncode(tracks.first.raw!.keys.toList()), isNotEmpty);
  });
}
