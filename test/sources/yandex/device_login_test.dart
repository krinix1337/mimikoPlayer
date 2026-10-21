import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/sources/yandex/yandex_auth.dart';

void main() {
  DeviceLogin login(String url) => DeviceLogin(
    deviceCode: 'dc',
    userCode: 'ps3t26qv',
    verificationUrl: url,
    interval: const Duration(seconds: 5),
    expiresIn: const Duration(seconds: 300),
  );

  test('код подставляется в ссылку подтверждения', () {
    expect(
      login('https://ya.ru/device').verificationUri.toString(),
      'https://ya.ru/device?code=ps3t26qv',
    );
  });

  test('существующие параметры ссылки не теряются', () {
    expect(
      login('https://ya.ru/device?lang=ru').verificationUri.toString(),
      contains('lang=ru'),
    );
  });
}
