import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/sources/yandex/yandex_station.dart';

void main() {
  test('settings2 читается из ответа info', () {
    final settings = YandexStation.parseSettings2({
      'language': 'russian',
      'moodEnergy': 'fun',
      'diversity': 'favorite',
    });

    expect(settings, isNotNull);
    expect(settings!.moodEnergy, 'fun');
    expect(settings.diversity, 'favorite');
    expect(settings.language, 'russian');
  });

  test('битый settings2 не роняет лист настроек', () {
    expect(YandexStation.parseSettings2(null), isNull);
    expect(YandexStation.parseSettings2('ok'), isNull);
    expect(YandexStation.parseSettings2({})?.moodEnergy, 'all');
  });

  test('тело settings3 совпадает с официальным клиентом', () {
    expect(
      YandexStation.settingsBody(
        const WaveSettings(
          moodEnergy: 'calm',
          diversity: 'discover',
          language: 'not-russian',
        ),
      ),
      {
        'moodEnergy': 'calm',
        'diversity': 'discover',
        'language': 'not-russian',
        'type': 'rotor',
      },
    );
  });
}
