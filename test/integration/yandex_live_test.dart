@Tags(['live'])
library;

/// Живой прогон модуля Яндекса: требует токен в файле и доступ в сеть.
/// Запуск: `dart test test/integration/yandex_live_test.dart` (после
/// `dart run tool/probe/yandex_probe.dart login`).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/sources/cross_source.dart';
import 'package:phoneyandex/core/sources/source_dto.dart';
import 'package:phoneyandex/core/sources/source_id.dart';
import 'package:phoneyandex/core/sources/stream_target.dart';
import 'package:phoneyandex/sources/yandex/yandex_api.dart';
import 'package:phoneyandex/sources/yandex/yandex_source.dart';
import 'package:phoneyandex/sources/yandex/yandex_station.dart';

final _tokenFile = File('C:/project/musor/yandex_token.txt');

void main() {
  final token = _tokenFile.existsSync()
      ? _tokenFile.readAsStringSync().trim()
      : '';
  if (token.isEmpty) {
    markTestSkipped('нет токена: сначала probe login');
    return;
  }

  final api = YandexApi()..token = token;

  // uid берём из аккаунта токена, а не храним в репозитории.
  Future<String> accountUid() async {
    final status = await api.get('/account/status');
    final account = status.asMap?['account'] as Map?;
    return '${account?['uid']}';
  }
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
    stderr.writeln(
      'поток: ${url.host} битрейт=${ready.bitrateKbps} codec=${ready.codec}',
    );

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
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
    final uid = await accountUid();
    final list = await api.get('/users/$uid/playlists/list');
    expect(list.isOk, isTrue);
    expect(list.asList, isNotEmpty);

    final kind = '${list.asList.first['kind']}';
    final fetched = await api.get('/users/$uid/playlists', {'kinds': kind});
    final playlist = fetched.asList.first;
    expect((playlist['tracks'] as List?) ?? const [], isNotEmpty);

    // /playlists отдаёт короткие ссылки: полные треки добираются батчем,
    // иначе все строки плейлиста сходятся в один пустой отпечаток.
    final refs = YandexSource.playlistTrackRefs(playlist['tracks']);
    final full = await source.getTracksByIds(refs);
    final ordered = YandexSource.orderPlaylistTracks(refs, full);
    expect(refs, isNotEmpty);
    expect(ordered, hasLength(refs.length));
    expect(ordered.every((track) => track.title.isNotEmpty), isTrue);
    // У недоступного трека Яндекс может не отдать длительность — это норма.
    expect(
      ordered
          .where((track) => track.available)
          .every((track) => track.duration.inMilliseconds > 0),
      isTrue,
    );
  });

  test('лайки резолвятся в полные треки', () async {
    final uid = await accountUid();
    final result = await api.get('/users/$uid/likes/tracks');
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

  test('фолбэк с YouTube-названия находит и отдаёт трек Яндекса', () async {
    // Ровно тот запрос, который строит плеер, когда YouTube не отдал поток.
    final query = crossSourceQuery('Joji - Gimme Love (Official Video)', const [
      '88rising',
    ]);
    expect(query, 'joji gimme love');

    final found = await source.search(query, pageSize: 10);
    final match = pickCrossSourceMatch(
      found.tracks,
      title: 'Joji - Gimme Love (Official Video)',
      artists: const ['88rising'],
      duration: const Duration(seconds: 202),
    );
    expect(match, isNotNull, reason: 'в Яндексе не нашлось той же песни');

    final result = await source.resolveStream(match!);
    expect(result, isA<StreamReady>(), reason: '$result');
  });

  test('новые релизы лендинга отдаются с обложками', () async {
    final albums = await source.newReleases(limit: 5);

    expect(albums, isNotEmpty);
    expect(albums.first.title, isNotEmpty);
    expect(albums.first.artistIds, isNotEmpty);
  });

  test('настройки волны читаются из settings2', () async {
    final settings = await source.station.settings('user:onyourwave');

    expect(settings, isNotNull);
    expect(WaveSettings.moodEnergyValues, contains(settings!.moodEnergy));
    expect(WaveSettings.diversityValues, contains(settings.diversity));
    expect(WaveSettings.languageValues, contains(settings.language));
  });
}
