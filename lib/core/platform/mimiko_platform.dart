import 'package:flutter/services.dart';

import '../logging/app_logger.dart';

/// Мост к Android-коду: частота кадров окна и смена значка лаунчера.
/// Из Dart ни того, ни другого сделать нельзя.
class MimikoPlatform {
  const MimikoPlatform._();

  static const MethodChannel _channel = MethodChannel(
    'net.nekto.mimiko/platform',
  );

  /// Вернуть реальную частоту, которую система дала окну (0 — канал недоступен).
  static Future<double> actualRefreshRate() async {
    try {
      final value = await _channel.invokeMethod<double>('actualRefreshRate');
      return value ?? 0;
    } on PlatformException catch (error) {
      AppLogger.instance.warn('частоту прочитать не вышло: ${error.message}');
      return 0;
    } on MissingPluginException {
      return 0;
    }
  }

  /// Попросить режим не ниже [hz]; 0 — вернуть управление системе.
  static Future<double> requestFrameRate(double hz) async {
    try {
      final value = await _channel.invokeMethod<double>(
        'setFrameRate',
        hz == 0 ? null : hz,
      );
      return value ?? 0;
    } on PlatformException catch (error) {
      AppLogger.instance.warn('частоту задать не вышло: ${error.message}');
      return 0;
    } on MissingPluginException {
      return 0;
    }
  }

  /// Метаданные аудиофайла из тега: название, исполнитель, альбом,
  /// длительность и встроенная обложка (байты как есть, без base64).
  static Future<LocalMediaInfo> mediaInfo(String path) async {
    try {
      final raw = await _channel.invokeMethod<Map<Object?, Object?>>(
        'getMediaInfo',
        path,
      );
      if (raw == null) return const LocalMediaInfo();
      return LocalMediaInfo(
        title: raw['title'] as String?,
        artist: raw['artist'] as String?,
        album: raw['album'] as String?,
        durationMs: (raw['durationMs'] as num?)?.toInt() ?? 0,
        art: raw['art'] is Uint8List ? raw['art'] as Uint8List : null,
      );
    } on PlatformException catch (error) {
      AppLogger.instance.warn('тег не прочитался: ${error.message}');
      return const LocalMediaInfo();
    } on MissingPluginException {
      return const LocalMediaInfo();
    }
  }

  static Future<bool> setLauncherIcon(String component) async {
    try {
      return await _channel.invokeMethod<bool>('setLauncherIcon', component) ??
          false;
    } on PlatformException catch (error) {
      AppLogger.instance.warn('значок сменить не вышло: ${error.message}');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Свободные байты на разделе данных; 0 — канал недоступен.
  static Future<int> freeBytes() async {
    try {
      return await _channel.invokeMethod<int>('freeBytes') ?? 0;
    } on PlatformException catch (error) {
      AppLogger.instance.warn(
        'свободное место прочитать не вышло: ${error.message}',
      );
      return 0;
    } on MissingPluginException {
      return 0;
    }
  }

  static Future<NetworkStatus> networkStatus() async {
    try {
      final raw = await _channel.invokeMethod<Map<Object?, Object?>>(
        'networkStatus',
      );
      return NetworkStatus(
        connected: raw?['connected'] == true,
        wifi: raw?['wifi'] == true,
        unmetered: raw?['unmetered'] == true,
        vpn: raw?['vpn'] == true,
      );
    } on PlatformException catch (error) {
      AppLogger.instance.warn('сеть прочитать не вышло: ${error.message}');
      return const NetworkStatus();
    } on MissingPluginException {
      return const NetworkStatus();
    }
  }
}

final class NetworkStatus {
  const NetworkStatus({
    this.connected = false,
    this.wifi = false,
    this.unmetered = false,
    this.vpn = false,
  });

  final bool connected;
  final bool wifi;
  final bool unmetered;
  final bool vpn;

  bool get canAutoDownload => connected && (wifi || unmetered);
}

final class LocalMediaInfo {
  const LocalMediaInfo({
    this.title,
    this.artist,
    this.album,
    this.durationMs = 0,
    this.art,
  });

  final String? title;
  final String? artist;
  final String? album;
  final int durationMs;
  final Uint8List? art;

  bool get isEmpty =>
      title == null &&
      artist == null &&
      album == null &&
      durationMs == 0 &&
      art == null;
}
