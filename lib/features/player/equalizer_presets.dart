import 'dart:math' as math;

/// Кривая пресета задана на десяти опорных частотах (как в десктопной
/// версии); на устройстве её пересчитываем в реальные полосы эквалайзера.
const List<double> equalizerBandHz = [
  32,
  64,
  125,
  250,
  500,
  1000,
  2000,
  4000,
  8000,
  16000,
];

/// Значение пресета «своя настройка»: кривая и уровень берутся из Prefs.
const String equalizerCustomId = 'custom';

final class EqualizerPreset {
  const EqualizerPreset(this.id, this.gainsDb, {this.preampDb = 0});

  final String id;
  final List<double> gainsDb;
  final double preampDb;
}

const List<EqualizerPreset> equalizerPresets = [
  EqualizerPreset('flat', [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
  EqualizerPreset('bass', [7, 6, 4, 2, 0, 0, 0, 1, 2, 2], preampDb: -2),
  EqualizerPreset('treble', [0, 0, 0, 0, 1, 2, 4, 6, 7, 8], preampDb: -1),
  EqualizerPreset('rock', [5, 4, 2, -1, -2, 1, 3, 5, 5, 4]),
  EqualizerPreset('electronic', [6, 5, 3, 0, -2, 2, 1, 4, 6, 5], preampDb: -1),
  EqualizerPreset('pop', [-1, 2, 4, 5, 4, 0, -1, 1, 3, 3]),
  EqualizerPreset('vocal', [-3, -2, 0, 2, 4, 5, 4, 2, 0, -1]),
  EqualizerPreset('acoustic', [3, 2, 1, 1, 2, 3, 3, 4, 4, 3]),
];

EqualizerPreset equalizerPresetById(String id) {
  for (final preset in equalizerPresets) {
    if (preset.id == id) return preset;
  }
  return equalizerPresets.first;
}

/// Уровни в децибелах для конкретных полос устройства.
List<double> equalizerGains(
  EqualizerPreset preset, {
  required List<double> centersHz,
  required double minDb,
  required double maxDb,
}) => equalizerGainsFromCurve(
  preset.gainsDb,
  level: preset.preampDb,
  centersHz: centersHz,
  minDb: minDb,
  maxDb: maxDb,
);

/// Своя кривая: 10 опорных точек плюс уровень, всё в дБ.
List<double> equalizerGainsFromCurve(
  List<double> curve, {
  required List<double> centersHz,
  required double minDb,
  required double maxDb,
  double level = 0,
}) {
  final gains = curve.length == equalizerBandHz.length
      ? curve
      : const <double>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return [
    for (final center in centersHz)
      (_interpolate(center, gains) + level).clamp(minDb, maxDb).toDouble(),
  ];
}

/// Частоты полос логарифмические: интерполяция по log2 даёт предсказуемую
/// кривую между октавами, а не «ступеньки» в низах.
double _interpolate(double hz, List<double> gains) {
  if (hz <= equalizerBandHz.first) return gains.first;
  if (hz >= equalizerBandHz.last) return gains.last;
  for (var i = 0; i < equalizerBandHz.length - 1; i++) {
    final low = equalizerBandHz[i];
    final high = equalizerBandHz[i + 1];
    if (hz > high) continue;
    final t = (math.log(hz) - math.log(low)) / (math.log(high) - math.log(low));
    return gains[i] + (gains[i + 1] - gains[i]) * t;
  }
  return gains.last;
}
