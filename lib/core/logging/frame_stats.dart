import 'dart:ui';

import 'package:flutter/scheduler.dart';

import 'app_logger.dart';

/// Замер плавности на телефоне: раз в пять секунд пишет в лог, сколько кадров
/// не уложилось в бюджет и чем — сборкой (Dart, UI-поток) или отрисовкой
/// (GPU, raster). Включается только сборкой с `--dart-define=FRAME_STATS=true`.
class FrameStats {
  FrameStats._();

  static const bool enabled = bool.fromEnvironment('FRAME_STATS');

  static final List<FrameTiming> _window = [];
  static DateTime _windowStart = DateTime.now();

  static void install() {
    if (!enabled) return;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  static void _onTimings(List<FrameTiming> timings) {
    _window.addAll(timings);
    final now = DateTime.now();
    if (now.difference(_windowStart) < const Duration(seconds: 5)) return;
    _windowStart = now;
    if (_window.isEmpty) return;

    // Бюджет кадра берём по частоте экрана: на 120 Гц это 8,3 мс.
    final display = PlatformDispatcher.instance.displays.firstOrNull;
    final hz = (display?.refreshRate ?? 60).clamp(30, 240);
    final budgetUs = 1000000 ~/ hz;

    var jank = 0;
    var buildJank = 0;
    var rasterJank = 0;
    var worstBuild = 0;
    var worstRaster = 0;
    var totalBuild = 0;
    var totalRaster = 0;
    for (final timing in _window) {
      final build = timing.buildDuration.inMicroseconds;
      final raster = timing.rasterDuration.inMicroseconds;
      totalBuild += build;
      totalRaster += raster;
      if (build > worstBuild) worstBuild = build;
      if (raster > worstRaster) worstRaster = raster;
      if (build > budgetUs || raster > budgetUs) jank++;
      if (build > budgetUs) buildJank++;
      if (raster > budgetUs) rasterJank++;
    }
    final count = _window.length;
    AppLogger.instance.info(
      'frames ${hz.round()}Hz n=$count jank=$jank '
      '(build $buildJank, raster $rasterJank) '
      'build avg ${totalBuild ~/ count ~/ 100 / 10}ms '
      'max ${worstBuild ~/ 100 / 10}ms · '
      'raster avg ${totalRaster ~/ count ~/ 100 / 10}ms '
      'max ${worstRaster ~/ 100 / 10}ms',
    );
    _window.clear();
  }
}
