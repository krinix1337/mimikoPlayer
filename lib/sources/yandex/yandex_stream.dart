import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../core/constants.dart';
import '../../core/env.dart';
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
  }) async {
    final info = await _api.get('/tracks/$trackId/download-info');
    if (!info.isOk) {
      return StreamFailed(info.failure!);
    }

    final variants = _bestFirst(info.asList);
    if (variants.isEmpty) {
      return StreamFailed(
        SourceFailure(
          source: source,
          reason: SourceFailReason.unavailable,
          message: 'download-info пуст',
        ),
      );
    }

    final variant = variants.first;
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

  String _sign(String path, String s) =>
      md5
          .convert(
            utf8.encode('${AppConfig.yandexGetMp3Salt}${path.substring(1)}$s'),
          )
          .toString();

  List<Map<String, dynamic>> _bestFirst(List<Map<String, dynamic>> variants) {
    final usable = [
      for (final variant in variants)
        if (variant['downloadInfoUrl'] != null) variant,
    ];
    usable.sort((a, b) {
      final left = (a['bitrateInKbps'] as num?)?.toInt() ?? 0;
      final right = (b['bitrateInKbps'] as num?)?.toInt() ?? 0;
      return right.compareTo(left);
    });
    return usable;
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
