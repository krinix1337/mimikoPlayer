import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/sources/source_errors.dart';
import 'package:phoneyandex/core/sources/source_id.dart';
import 'package:phoneyandex/core/sources/stream_target.dart';
import 'package:phoneyandex/sources/soundcloud/soundcloud_api.dart';
import 'package:phoneyandex/sources/soundcloud/soundcloud_dto.dart';
import 'package:phoneyandex/sources/soundcloud/soundcloud_source.dart';

const _search = {
  'collection': [
    {
      'kind': 'track',
      'id': 927823084,
      'title': 'MORGENSHTERN, Lil Pump - WATAFUK?!',
      'duration': 149011,
      'streamable': true,
      'policy': 'ALLOW',
      'artwork_url': 'https://i1.sndcdn.com/artworks-abc-large.jpg',
      'user': {'username': 'Zhara Music'},
      'permalink_url': 'https://soundcloud.com/zhara/watafuk',
    },
    {
      'kind': 'track',
      'id': 2,
      'title': 'Снят с публикации',
      'duration': 1000,
      'streamable': false,
      'policy': 'BLOCK',
      'user': {'username': 'uploader'},
    },
    {'kind': 'playlist', 'id': 3, 'title': 'не трек'},
  ],
};

Map<String, dynamic> _trackJson({bool encryptedOnly = false}) => {
  'id': 1322623234,
  'title': 'NIGHT DANCER',
  'duration': 222000,
  'streamable': true,
  'policy': 'ALLOW',
  'publisher_metadata': {'artist': 'imase'},
  'user': {'username': 'imase'},
  'track_authorization': 'auth-token',
  'media': {
    'transcodings': [
      if (!encryptedOnly)
        {
          'url': 'https://api-v2.soundcloud.com/media/aac',
          'preset': 'aac_160k',
          'format': {'protocol': 'hls', 'mime_type': 'audio/mp4'},
        },
      if (!encryptedOnly)
        {
          'url': 'https://api-v2.soundcloud.com/media/mp3',
          'preset': 'mp3_1_0',
          'format': {'protocol': 'progressive', 'mime_type': 'audio/mpeg'},
        },
      if (!encryptedOnly)
        {
          'url': 'https://api-v2.soundcloud.com/media/96',
          'preset': 'aac_96k',
          'format': {'protocol': 'hls', 'mime_type': 'audio/mp4'},
        },
      {
        'url': 'https://api-v2.soundcloud.com/media/enc',
        'preset': 'aac_160k',
        'format': {'protocol': 'cbc-encrypted-hls', 'mime_type': 'audio/mp4'},
      },
    ],
  },
};

class _FakeApi extends SoundCloudApi {
  _FakeApi({this.trackJson, this.mediaUrl});

  final Map<String, dynamic>? trackJson;
  final String? mediaUrl;
  int mediaCalls = 0;

  @override
  Future<String?> ensureClientId({bool force = false}) async => 'test_client';

  @override
  Future<SoundCloudReply> track(String id, {bool retry = true}) async =>
      SoundCloudReply.ok(trackJson);

  @override
  Future<SoundCloudReply> resolveMedia(
    String transcodingUrl, {
    String? trackAuthorization,
    bool retry = true,
  }) async {
    mediaCalls++;
    return SoundCloudReply.ok({'url': mediaUrl});
  }
}

void main() {
  group('SoundCloudDto', () {
    test('ключ client_id достаётся из JS-ассета', () {
      const js =
          'client_id:"3GKD969NJWD1eB6gvQJN0GnueYbcWszv",env:"production"';
      expect(
        SoundCloudApi.extractClientId(js),
        '3GKD969NJWD1eB6gvQJN0GnueYbcWszv',
      );
      expect(SoundCloudApi.extractClientId('nothing here'), isNull);
    });

    test('поиск разбирает название, артистов, обложку и блокировки', () {
      final tracks = SoundCloudDto.searchTracks(_search);

      expect(tracks, hasLength(2));
      final first = tracks.first;
      expect(first.ref.source, SourceId.soundcloud);
      expect(first.ref.remoteId, '927823084');
      // Без publisher-метаданных «Artist - Title» разбирается на части.
      expect(first.title, 'WATAFUK?!');
      expect(first.artists, ['MORGENSHTERN', 'Lil Pump']);
      expect(first.duration, const Duration(milliseconds: 149011));
      expect(first.coverUrl, 'https://i1.sndcdn.com/artworks-abc-t500x500.jpg');
      expect(first.available, isTrue);
      expect(tracks[1].available, isFalse);
    });

    test('publisher-артист важнее разбора заголовка', () {
      final track = SoundCloudDto.track({
        'id': 1,
        'title': 'NIGHT DANCER',
        'duration': 222000,
        'streamable': true,
        'policy': 'ALLOW',
        'publisher_metadata': {'artist': 'imase'},
        'user': {'username': 'imase'},
      });

      expect(track?.title, 'NIGHT DANCER');
      expect(track?.artists, ['imase']);
    });

    test(
      'progressive MP3 предпочтительнее HLS, шифрованный HLS пропускается',
      () {
        final progressive = SoundCloudDto.pickTranscoding(_trackJson());
        expect(progressive?['preset'], 'mp3_1_0');

        final hls = SoundCloudDto.pickTranscoding(
          _trackJson(encryptedOnly: true),
        );
        expect(hls, isNull);

        final noProgressive = _trackJson();
        ((noProgressive['media'] as Map)['transcodings'] as List).removeWhere(
          (item) => (item as Map)['preset'] == 'mp3_1_0',
        );
        expect(
          SoundCloudDto.pickTranscoding(noProgressive)?['preset'],
          'aac_160k',
        );
      },
    );

    test('срок жизни медиа-URL читается из expires', () {
      final value =
          'https://cf-media.sndcdn.com/file.mp3?expires=1893456000&Policy=x';
      expect(
        SoundCloudDto.expiresAt(value)?.millisecondsSinceEpoch,
        1893456000000,
      );
      expect(SoundCloudDto.expiresAt('https://cdn/file.mp3'), isNull);
    });
  });

  group('SoundCloudSource', () {
    test('поток отдаёт прогрессивный MP3 и срок из ссылки', () async {
      final fake = _FakeApi(
        trackJson: _trackJson(),
        mediaUrl:
            'https://cf-media.sndcdn.com/file.mp3?expires=1893456000&Policy=x',
      );
      final source = SoundCloudSource(api: fake);

      final track = SoundCloudDto.track(_trackJson())!;
      final result = await source.resolveStream(track, preferred: Quality.high);

      expect(result, isA<StreamReady>());
      final ready = result as StreamReady;
      expect(ready.target, isA<StreamUrl>());
      expect((ready.target as StreamUrl).url.path, contains('file.mp3'));
      expect(ready.codec, 'mp3');
      expect(ready.source, SourceId.soundcloud);
      expect(
        (ready.target as StreamUrl).expiresAt.millisecondsSinceEpoch,
        1893456000000,
      );
      expect(fake.mediaCalls, 1);
    });

    test('заблокированный трек не отдаёт поток', () async {
      final blocked = _trackJson()..['policy'] = 'BLOCK';
      final source = SoundCloudSource(api: _FakeApi(trackJson: blocked));
      final track = SoundCloudDto.track(_trackJson())!;

      final result = await source.resolveStream(track);

      expect(result, isA<StreamFailed>());
      expect(
        (result as StreamFailed).failure.reason,
        SourceFailReason.unavailable,
      );
    });
  });
}
