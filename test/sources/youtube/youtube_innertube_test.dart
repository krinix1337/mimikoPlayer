import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/sources/youtube/youtube_innertube.dart';

Map<String, dynamic> _player({String status = 'OK', bool withUrl = true}) => {
  'playabilityStatus': {'status': status},
  'streamingData': {
    'expiresInSeconds': '21600',
    'adaptiveFormats': [
      {
        'mimeType': 'audio/webm; codecs="opus"',
        'bitrate': 160000,
        if (withUrl) 'url': 'https://rr1.googlevideo.com/opus.webm',
      },
      {
        'mimeType': 'audio/mp4; codecs="mp4a.40.2"',
        'bitrate': 129000,
        if (withUrl) 'url': 'https://rr1.googlevideo.com/aac.m4a',
        if (!withUrl) 'signatureCipher': 's=abc&url=https%3A%2F%2Fexample',
      },
    ],
  },
};

void main() {
  test('AAC/mp4 выбирается даже при меньшем битрейте', () {
    final now = DateTime.utc(2026, 10, 24, 12);
    final audio = YoutubeInnertube.parsePlayerResponse(
      _player(),
      now: now,
      userAgent: 'com.google.ios.youtube/20.10.4',
    );

    expect(audio, isNotNull);
    expect(audio!.url.path, '/aac.m4a');
    expect(audio.codec, 'aac');
    expect(audio.bitrateKbps, 129);
    expect(audio.userAgent, 'com.google.ios.youtube/20.10.4');
    expect(
      audio.expiresAt,
      now.add(const Duration(hours: 6)).subtract(const Duration(seconds: 60)),
    );
  });

  test('UNPLAYABLE и ответы без прямых URL не дают аудио', () {
    expect(
      YoutubeInnertube.parsePlayerResponse(_player(status: 'UNPLAYABLE')),
      isNull,
    );
    expect(
      YoutubeInnertube.parsePlayerResponse(_player(withUrl: false)),
      isNull,
    );
    expect(YoutubeInnertube.parsePlayerResponse({}), isNull);
    expect(YoutubeInnertube.parsePlayerResponse(null), isNull);
  });

  test('если URL есть только у webm — берётся он', () {
    final json = _player();
    final formats = ((json['streamingData'] as Map)['adaptiveFormats'] as List);
    formats.removeAt(1);

    final audio = YoutubeInnertube.parsePlayerResponse(json);

    expect(audio?.codec, 'opus');
    expect(audio?.bitrateKbps, 160);
  });

  test('поиск: videoRenderer с длительностью, Shorts и эфиры отброшены', () {
    final json = {
      'contents': {
        'twoColumnSearchResultsRenderer': {
          'primaryContents': {
            'sectionListRenderer': {
              'contents': [
                {
                  'itemSectionRenderer': {
                    'contents': [
                      {
                        'videoRenderer': {
                          'videoId': 'mEZGDjA9Dtk',
                          'title': {
                            'runs': [
                              {'text': 'NIGHT DANCER'},
                            ],
                          },
                          'ownerText': {
                            'runs': [
                              {'text': 'imase'},
                            ],
                          },
                          'lengthText': {'simpleText': '3:31'},
                          'thumbnail': {
                            'thumbnails': [
                              {'url': 'https://i.ytimg.com/vi/a/hq.jpg'},
                            ],
                          },
                        },
                      },
                      {
                        'videoRenderer': {
                          'videoId': 'live',
                          'title': {'simpleText': 'Эфир'},
                          'lengthText': {'simpleText': 'LIVE'},
                        },
                      },
                      {
                        'videoRenderer': {
                          'videoId': 'short',
                          'title': {'simpleText': 'Короткий'},
                          'lengthText': {'simpleText': '0:15'},
                        },
                      },
                    ],
                  },
                },
              ],
            },
          },
        },
      },
    };

    final items = YoutubeInnertube.parseSearchResponse(json, limit: 10);

    expect(items, hasLength(1));
    expect(items.first.id, 'mEZGDjA9Dtk');
    expect(items.first.title, 'NIGHT DANCER');
    expect(items.first.author, 'imase');
    expect(items.first.duration, const Duration(minutes: 3, seconds: 31));
    expect(items.first.thumbnailUrl, 'https://i.ytimg.com/vi/a/hq.jpg');
  });
}
