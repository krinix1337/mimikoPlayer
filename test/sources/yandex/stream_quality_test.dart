import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/sources/stream_target.dart';
import 'package:phoneyandex/sources/yandex/yandex_stream.dart';

void main() {
  final variants = <Map<String, dynamic>>[
    {'downloadInfoUrl': 'low', 'bitrateInKbps': 64, 'codec': 'mp3'},
    {'downloadInfoUrl': 'normal', 'bitrateInKbps': 192, 'codec': 'mp3'},
    {'downloadInfoUrl': 'high', 'bitrateInKbps': 320, 'codec': 'mp3'},
  ];

  test('выбранное качество реально влияет на вариант', () {
    expect(
      YandexStream.pickVariant(variants, Quality.low)!['bitrateInKbps'],
      64,
    );
    expect(
      YandexStream.pickVariant(variants, Quality.normal)!['bitrateInKbps'],
      192,
    );
    expect(
      YandexStream.pickVariant(variants, Quality.high)!['bitrateInKbps'],
      320,
    );
    expect(
      YandexStream.pickVariant(variants, Quality.auto)!['bitrateInKbps'],
      320,
    );
  });

  test('lossless предпочитает flac, а при его отсутствии — максимум', () {
    final withFlac = [
      ...variants,
      {'downloadInfoUrl': 'flac', 'bitrateInKbps': 900, 'codec': 'flac'},
    ];
    expect(
      YandexStream.pickVariant(withFlac, Quality.lossless)!['codec'],
      'flac',
    );
    expect(
      YandexStream.pickVariant(variants, Quality.lossless)!['bitrateInKbps'],
      320,
    );
  });

  test('пустой download-info не роняет выбор', () {
    expect(YandexStream.pickVariant(const [], Quality.high), isNull);
    expect(
      YandexStream.pickVariant([
        {'codec': 'mp3'},
      ], Quality.high),
      isNull,
    );
  });
}
