import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import '../../app_providers.dart';
import '../../app_services.dart';
import '../../core/logging/app_logger.dart';
import '../../core/prefs/prefs_store.dart';
import 'download_scheduler.dart';
import 'download_service.dart';

/// Точка входа WorkManager. Живёт в отдельном Flutter-движке, поэтому
/// поднимает свои зависимости из БД, а не из UI-состояния.
@pragma('vm:entry-point')
void downloadCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != autoDownloadTaskName) return true;
    try {
      WidgetsFlutterBinding.ensureInitialized();
      DartPluginRegistrant.ensureInitialized();

      final services = AppServices.ensure();
      await services.applyPreferences();
      initialPrefs = await loadPrefs(services.db);
      try {
        await services.restoreAccount();
      } on Object {
        // Токен может быть просрочен; очередь останется до следующего запуска.
      }

      final container = ProviderContainer();
      try {
        await container
            .read(downloadControllerProvider.notifier)
            .pumpAutoQueue(
              requireNetworkCheck: false,
              timeBudget: const Duration(minutes: 8),
            );
      } finally {
        container.dispose();
      }
      return true;
    } on Object catch (error) {
      AppLogger.instance.warn('фоновая загрузка упала: $error');
      return false;
    }
  });
}
