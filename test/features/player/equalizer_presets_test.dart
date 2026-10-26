import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/features/player/equalizer_presets.dart';

List<double> _levels(String id, {double minDb = -15, double maxDb = 15}) =>
    equalizerGains(
      equalizerPresetById(id),
      centersHz: const [60, 230, 910, 4000, 14000],
      minDb: minDb,
      maxDb: maxDb,
    );

void main() {
  test('ровный пресет не двигает ни одну полосу', () {
    expect(_levels('flat'), [0, 0, 0, 0, 0]);
  });

  test('бас поднимает низ и не задирает верх', () {
    final levels = _levels('bass');
    expect(levels.first, greaterThan(0));
    expect(levels[1], greaterThan(0));
    expect(levels.last, lessThanOrEqualTo(0));
  });

  test('верх поднимает высокие частоты', () {
    final levels = _levels('treble');
    expect(levels.last, greaterThan(5));
    expect(levels.first, lessThanOrEqualTo(0));
  });

  test('уровни ограничены диапазоном устройства', () {
    final levels = _levels('treble', minDb: -3, maxDb: 3);
    expect(levels.every((level) => level >= -3 && level <= 3), isTrue);
  });

  test('неизвестный пресет откатывается на ровный', () {
    expect(equalizerPresetById('nope').id, 'flat');
  });

  test('своя кривая и уровень сдвигают все полосы', () {
    final flat = equalizerGainsFromCurve(
      const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      centersHz: const [60, 230, 910, 4000, 14000],
      minDb: -15,
      maxDb: 15,
      level: 3,
    );
    expect(flat, [3, 3, 3, 3, 3]);
  });

  test('своя кривая клипуется диапазоном устройства', () {
    final hot = equalizerGainsFromCurve(
      const [12, 12, 12, 12, 12, 12, 12, 12, 12, 12],
      centersHz: const [60, 230, 910, 4000, 14000],
      minDb: -15,
      maxDb: 6,
      level: 10,
    );
    expect(hot.every((gain) => gain == 6), isTrue);
  });
}
