import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../core/constants.dart';
import '../../core/env.dart';
import '../../core/logging/app_logger.dart';
import '../../core/sources/source_errors.dart';
import '../../core/sources/source_id.dart';
import '../../core/sources/stream_target.dart';
import 'yandex_api.dart';

/// Получение адреса потока классическим путём: `download-info` → XML с
/// `host/path/ts/s` → `md5(соль + path + s)`. Проверено живым запросом
/// 2026-10-21: итоговый URL отдаёт 206 без заголовка авторизации.
class YandexStream {
  YandexStream(this._api);

  final YandexApi _api;

  Future<StreamResult> resolve(
    String trackId, {
    required SourceId source,
    Quality preferred = Quality.auto,
  }) async {
    // Классический download-info отдаёт только mp3/aac: FLAC есть лишь у
    // нового get-file-info. Без него «Без потерь» ничего не меняло.
    if (preferred == Quality.lossless) {
      final lossless = await _resolveFileInfo(trackId, source: source);
      if (lossless != null) return lossless;
    }

    final info = await _api.get('/tracks/$trackId/download-info');
    if (!info.isOk) {
      return StreamFailed(info.failure!);
    }

    final variant = pickVariant(info.asList, preferred);
    if (variant == null) {
      return StreamFailed(
        SourceFailure(
          source: source,
          reason: SourceFailReason.unavailable,
          message: 'download-info пуст',
        ),
      );
    }
    final infoUrl = variant['downloadInfoUrl']?.toString();
    if (infoUrl == null) {
      return StreamFailed(
        SourceFailure(
          source: source,
          reason: SourceFailReason.remoteError,
          message: 'в download-info нет downloadInfoUrl',
        ),
      );
    }

    final xml = await _api.getAbsolute(infoUrl);
    if (!xml.isOk) {
      return StreamFailed(xml.failure!);
    }

    final fields = _parseFields('${xml.data}');
    final host = fields['host'];
    final path = fields['path'];
    final ts = fields['ts'];
    final s = fields['s'];
    if (host == null || path == null || ts == null || s == null) {
      return StreamFailed(
        SourceFailure(
          source: source,
          reason: SourceFailReason.remoteError,
          message: 'в ответе хранилища нет нужных полей',
        ),
      );
    }

    return StreamReady(
      target: StreamUrl(
        url: Uri.parse('https://$host/get-mp3/${_sign(path, s)}/$ts$path'),
        // Адрес подписан под конкретный ts; реальный TTL ещё не замерен
        // (docs/API_PROBE.md, пункт 1), поэтому берём консервативную оценку.
        expiresAt: DateTime.now().add(defaultStreamTtl),
      ),
      source: source,
      quality: _qualityOf(variant),
      codec: variant['codec']?.toString(),
      bitrateKbps: (variant['bitrateInKbps'] as num?)?.toInt(),
    );
  }

  /// `get-file-info` с quality=lossless: подпись — HMAC-SHA256 от склейки
  /// параметров (кодеки без запятых), base64 без последнего символа.
  /// Транспорт raw — файл без шифрования, его играет обычный плеер.
  /// null — FLAC нет или запрос не прошёл: тогда берём обычный путь.
  Future<StreamResult?> _resolveFileInfo(
    String trackId, {
    required SourceId source,
  }) async {
    const codecs = ['flac', 'flac-mp4', 'aac-mp4', 'aac', 'mp3'];
    const transport = 'raw';
    const quality = 'lossless';
    // remoteId бывает «трек:альбом», подписывается только id трека.
    final id = trackId.split(':').first;
    for (final key in _fileInfoKeys) {
      final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final payload = '$ts$id$quality${codecs.join()}$transport';
      final digest = Hmac(
        sha256,
        utf8.encode(key),
      ).convert(utf8.encode(payload));
      final sign = base64.encode(digest.bytes);
      final response = await _api.get('/get-file-info', {
        'ts': '$ts',
        'trackId': id,
        'quality': quality,
        'codecs': codecs.join(','),
        'transports': transport,
        'sign': sign.substring(0, sign.length - 1),
      });
      if (!response.isOk) {
        AppLogger.instance.warn(
          'get-file-info $id: http=${response.failure?.httpStatus} '
          '${response.failure?.message}',
        );
        continue;
      }
      final info = response.asMap?['downloadInfo'];
      if (info is! Map) {
        AppLogger.instance.warn('get-file-info $id: нет downloadInfo');
        return null;
      }
      final codec = info['codec']?.toString().toLowerCase() ?? '';
      final url =
          info['url']?.toString() ??
          (info['urls'] is List && (info['urls'] as List).isNotEmpty
              ? (info['urls'] as List).first.toString()
              : null);
      AppLogger.instance.info('get-file-info $id: $codec ${info['bitrate']}');
      if (url == null || !codec.startsWith('flac')) return null;
      return StreamReady(
        target: StreamUrl(
          url: Uri.parse(url),
          expiresAt: DateTime.now().add(defaultStreamTtl),
        ),
        source: source,
        quality: Quality.lossless,
        codec: codec,
        bitrateKbps: (info['bitrate'] as num?)?.toInt(),
      );
    }
    return null;
  }

  /// Ключи подписи из открытых клиентов; первый, что принят сервером, и
  /// работает.
  static const _fileInfoKeys = [
    'p93jhgh689SBReK6ghtw62',
    'kzqU4XhfCaY6B6JTHODeq5',
  ];

  String _sign(String path, String s) => md5
      .convert(
        utf8.encode('${AppConfig.yandexGetMp3Salt}${path.substring(1)}$s'),
      )
      .toString();

  static Map<String, dynamic>? pickVariant(
    List<Map<String, dynamic>> variants,
    Quality preferred,
  ) {
    final usable = [
      for (final variant in variants)
        if (variant['downloadInfoUrl'] != null) variant,
    ];
    if (usable.isEmpty) return null;

    int bitrate(Map<String, dynamic> variant) =>
        (variant['bitrateInKbps'] as num?)?.toInt() ?? 0;

    if (preferred == Quality.lossless) {
      final flac = [
        for (final variant in usable)
          if ('${variant['codec']}'.toLowerCase() == 'flac') variant,
      ];
      if (flac.isNotEmpty) {
        flac.sort((a, b) => bitrate(b).compareTo(bitrate(a)));
        return flac.first;
      }
    }

    if (preferred == Quality.auto) {
      usable.sort((a, b) => bitrate(b).compareTo(bitrate(a)));
      return usable.first;
    }

    final target = switch (preferred) {
      Quality.low => 96,
      Quality.normal => 192,
      Quality.high => 320,
      _ => 320,
    };
    final below = [
      for (final variant in usable)
        if (bitrate(variant) <= target) variant,
    ]..sort((a, b) => bitrate(b).compareTo(bitrate(a)));
    if (below.isNotEmpty) return below.first;

    final above = [
      for (final variant in usable)
        if (bitrate(variant) > target) variant,
    ]..sort((a, b) => bitrate(a).compareTo(bitrate(b)));
    return above.isEmpty ? usable.first : above.first;
  }

  static Quality _qualityOf(Map<String, dynamic> variant) {
    final bitrate = (variant['bitrateInKbps'] as num?)?.toInt() ?? 0;
    if ((variant['codec']?.toString()) == 'flac' || bitrate >= 900) {
      return Quality.lossless;
    }
    if (bitrate >= 320) return Quality.high;
    if (bitrate >= 192) return Quality.normal;
    if (bitrate > 0) return Quality.low;
    return Quality.auto;
  }

  static Map<String, String> _parseFields(String body) {
    final result = <String, String>{};
    for (final match in RegExp(r'<(\w+)>([^<]*)</\1>').allMatches(body)) {
      result[match.group(1)!] = match.group(2)!;
    }
    return result;
  }
}
