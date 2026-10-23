import 'package:workmanager/workmanager.dart';

import '../../core/logging/app_logger.dart';

const String autoDownloadTaskName = 'mimiko_auto_download';
const String autoDownloadNow = 'mimiko_auto_download_now';
const String autoDownloadPeriodic = 'mimiko_auto_download_periodic';

/// Один воркер обрабатывает очередь не дольше нескольких минут; периодическая
/// задача продолжает её после возврата приложения в фон.
Future<void> scheduleAutoDownload({required bool wifiOnly}) async {
  try {
    final constraints = Constraints(
      networkType: wifiOnly ? NetworkType.unmetered : NetworkType.connected,
      requiresBatteryNotLow: true,
      requiresStorageNotLow: true,
    );
    await Workmanager().registerOneOffTask(
      autoDownloadNow,
      autoDownloadTaskName,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: constraints,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 1),
    );
    await Workmanager().registerPeriodicTask(
      autoDownloadPeriodic,
      autoDownloadTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: constraints,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 1),
    );
  } on Object catch (error) {
    AppLogger.instance.warn('WorkManager не запланирован: $error');
  }
}

Future<void> cancelAutoDownload() async {
  try {
    await Workmanager().cancelByUniqueName(autoDownloadNow);
    await Workmanager().cancelByUniqueName(autoDownloadPeriodic);
  } on Object catch (error) {
    AppLogger.instance.warn('WorkManager не отменён: $error');
  }
}
