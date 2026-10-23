import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:phoneyandex/features/downloads/download_service.dart';

/// Механика докачки проверяется на локальном сервере: без живого Яндекса
/// видно, что Range, 206, игнорирование Range и обрыв посередине работают.
void main() {
  late HttpServer server;
  late Directory dir;
  late Uint8List payload;

  /// Ответ сервера на один запрос.
  int requests = 0;
  String? lastRange;
  bool ignoreRange = false;
  bool chunked = false;
  int? statusOverride;

  setUpAll(() async {
    payload = Uint8List.fromList(
      List.generate(200 * 1024, (i) => (i * 31 + 7) % 251),
    );
  });

  setUp(() async {
    requests = 0;
    lastRange = null;
    ignoreRange = false;
    chunked = false;
    statusOverride = null;
    dir = await Directory.systemTemp.createTemp('mimiko_fetch_');
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      requests++;
      lastRange = request.headers.value('range');
      final response = request.response;
      if (statusOverride != null) {
        response.statusCode = statusOverride!;
        await response.close();
        return;
      }

      var from = 0;
      final match = RegExp(r'bytes=(\d+)-').firstMatch(lastRange ?? '');
      if (match != null && !ignoreRange) {
        from = int.parse(match.group(1)!);
        if (from >= payload.length) {
          response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
          await response.close();
          return;
        }
        response.statusCode = HttpStatus.partialContent;
        response.headers.set(
          'content-range',
          'bytes $from-${payload.length - 1}/${payload.length}',
        );
      } else {
        response.statusCode = HttpStatus.ok;
      }
      response.headers.contentType = ContentType('audio', 'mpeg');
      final body = Uint8List.sublistView(payload, from);
      response.contentLength = body.length;

      if (!chunked) {
        response.add(body);
        await response.close();
        return;
      }
      // Медленная отдача: можно оборвать посередине.
      for (var i = 0; i < body.length; i += 4096) {
        response.add(
          Uint8List.sublistView(
            body,
            i,
            i + 4096 > body.length ? body.length : i + 4096,
          ),
        );
        await response.flush();
        await Future<void>.delayed(const Duration(milliseconds: 15));
      }
      await response.close();
    });
  });

  tearDown(() async {
    await server.close(force: true);
    await dir.delete(recursive: true);
  });

  Future<DownloadedAudio> fetch({
    CancelToken? cancelToken,
    Future<bool> Function(int extraBytes)? fitsInLimit,
  }) => DownloadService.fetchResumable(
    url: Uri.parse('http://127.0.0.1:${server.port}/track'),
    dir: dir,
    localTrackId: 't_1',
    cancelToken: cancelToken,
    fitsInLimit: fitsInLimit,
  );

  File part() => File(p.join(dir.path, 't_1.part'));

  test('файл без частичной закачки ложится целиком', () async {
    final audio = await fetch();
    expect(audio.codec, 'mp3');
    expect(audio.bytes, payload.length);
    expect(await File(audio.path).readAsBytes(), payload);
    expect(await part().exists(), isFalse);
  });

  test('Range продолжает с того же байта', () async {
    await part().writeAsBytes(Uint8List.sublistView(payload, 0, 40 * 1024));

    final audio = await fetch();

    expect(lastRange, 'bytes=${40 * 1024}-');
    expect(audio.bytes, payload.length);
    expect(await File(audio.path).readAsBytes(), payload);
  });

  test('игнорирование Range перезаписывает файл с нуля', () async {
    ignoreRange = true;
    await part().writeAsBytes(Uint8List.sublistView(payload, 0, 40 * 1024));

    final audio = await fetch();

    expect(audio.bytes, payload.length);
    expect(await File(audio.path).readAsBytes(), payload);
  });

  test('416 чистит побитый .part', () async {
    statusOverride = HttpStatus.requestedRangeNotSatisfiable;
    await part().writeAsBytes(Uint8List.sublistView(payload, 0, 10 * 1024));

    await expectLater(
      fetch(),
      throwsA(
        isA<DownloadException>().having(
          (e) => e.message,
          'message',
          contains('повреждён'),
        ),
      ),
    );
    expect(await part().exists(), isFalse);
  });

  test('обрыв посередине оставляет .part, повтор докачивает остаток', () async {
    chunked = true;
    final token = CancelToken();
    Timer(const Duration(milliseconds: 120), () => token.cancel('cut'));

    await expectLater(
      fetch(cancelToken: token),
      throwsA(isA<DownloadPausedException>()),
    );
    final partial = await part().length();
    expect(partial, greaterThan(0));
    expect(partial, lessThan(payload.length));

    chunked = false;
    final audio = await fetch();

    expect(requests, greaterThan(1));
    expect(lastRange, 'bytes=$partial-');
    expect(await File(audio.path).readAsBytes(), payload);
  });

  test('лимит резервируется по фактическому размеру файла', () async {
    var asked = -1;
    await expectLater(
      fetch(
        fitsInLimit: (extra) async {
          asked = extra;
          return false;
        },
      ),
      throwsA(isA<DownloadLimitException>()),
    );
    expect(asked, payload.length);
  });
}
