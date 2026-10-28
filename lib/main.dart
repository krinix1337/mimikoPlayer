import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'app_providers.dart';
import 'app_services.dart';
import 'core/logging/app_logger.dart';
import 'core/logging/frame_stats.dart';
import 'core/prefs/prefs_store.dart';
import 'features/downloads/download_worker.dart';
import 'features/player/audio_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FrameStats.install();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  try {
    await Workmanager().initialize(downloadCallbackDispatcher);
  } on Object catch (error) {
    AppLogger.instance.warn('WorkManager не инициализирован: $error');
  }

  final services = AppServices.ensure();
  await services.applyPreferences();
  initialPrefs = await loadPrefs(services.db);

  // Инициализация сервиса до runApp: после смерти процесса этот же вызов
  // поднимает плеер в headless-движке, и очередь восстанавливается из БД.
  final handler = await AudioService.init<MusicBackgroundAudioHandler>(
    builder: () => MusicBackgroundAudioHandler(services),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'net.nekto.phoneyandex.media',
      androidNotificationChannelName: _channelName(initialPrefs.localeCode),
      androidNotificationChannelDescription: _channelDescription(
        initialPrefs.localeCode,
      ),
      androidNotificationIcon: 'drawable/ic_stat_mimiko',
      // Пауза короче 10 минут не должна ронять foreground-сервис: иначе
      // на Android 17 теряется while-in-use и resume играет в тишину.
      // Ongoing-флаг с этим сочетанием запрещён ассертом плагина.
      androidStopForegroundOnPause: false,
      androidNotificationOngoing: false,
      androidResumeOnClick: true,
      androidNotificationClickStartsActivity: true,
      artDownscaleWidth: 512,
      artDownscaleHeight: 512,
      fastForwardInterval: Duration(seconds: 15),
      rewindInterval: Duration(seconds: 15),
    ),
  );

  // Плагин при service-запуске исполняет стандартный entrypoint, то есть этот
  // же main() без окна. runApp тут безопасен: движок без поверхности просто не
  // рисует, а плеер и восстановление очереди идут от того же экземпляра.
  await _requestNotificationPermission();
  runApp(AppRoot(controller: handler));
  // Аккаунт подтягиваем после первого кадра: логин нужен не для старта,
  // а для запросов к Яндексу, и не должен задерживать окно.
  unawaited(services.restoreAccount());
}

/// Название канала создаётся один раз на уровне системы и перевести его
/// позже нельзя, поэтому язык читаем из сохранённых настроек заранее.
String _channelName(String? localeCode) =>
    localeCode == 'en' ? 'Playback' : 'Воспроизведение';

String _channelDescription(String? localeCode) => localeCode == 'en'
    ? 'Background music playback'
    : 'Фоновое воспроизведение музыки';

Future<void> _requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (status.isGranted) return;
  final result = await Permission.notification.request();
  AppLogger.instance.info('разрешение уведомлений: ${result.name}');
}
