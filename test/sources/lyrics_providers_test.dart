import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/sources/lyrics/musixmatch.dart';
import 'package:phoneyandex/sources/lyrics/netease.dart';

void main() {
  group('NetEaseLyrics.pickSong', () {
    test('берёт песню с близкой длительностью и тем же названием', () {
      final data = {
        'result': {
          'songs': [
            {'id': 1, 'name': 'Believer (Live)', 'duration': 300000},
            {'id': 2, 'name': 'Believer', 'duration': 204000},
            {'id': 3, 'name': 'Thunder', 'duration': 204000},
          ],
        },
      };
      expect(
        NetEaseLyrics.pickSong(data, 'Believer', const Duration(seconds: 204)),
        2,
      );
    });

    test('без близкой длительности — ничего', () {
      final data = {
        'result': {
          'songs': [
            {'id': 1, 'name': 'Believer', 'duration': 100000},
          ],
        },
      };
      expect(
        NetEaseLyrics.pickSong(data, 'Believer', const Duration(seconds: 204)),
        isNull,
      );
    });
  });

  test('MusixmatchLyrics.parseMacro разбирает subtitle_body', () {
    final body = jsonEncode([
      {
        'text': 'First line',
        'time': {'total': 1.5},
      },
      {
        'text': 'Second line',
        'time': {'total': 4.25},
      },
    ]);
    final data = {
      'message': {
        'body': {
          'macro_calls': {
            'track.subtitles.get': {
              'message': {
                'body': {
                  'subtitle_list': [
                    {
                      'subtitle': {'subtitle_body': body},
                    },
                  ],
                },
              },
            },
          },
        },
      },
    };
    final lyrics = MusixmatchLyrics.parseMacro(data);
    expect(lyrics.synced, isTrue);
    expect(lyrics.lines.length, 2);
    expect(lyrics.lines.first.start, const Duration(milliseconds: 1500));
    expect(lyrics.lines.first.end, const Duration(milliseconds: 4250));
    expect(lyrics.lines.last.text, 'Second line');
  });
}
