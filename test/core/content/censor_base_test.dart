import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/content/censor_base.dart';

void main() {
  test('список цензуры разбирается в id → ссылку', () {
    final map = CensorBase.parseList(
      '{"tracks":{"88057589":"https://example/88057589","123":"https://example/123"}}',
    );
    expect(map, hasLength(2));
    expect(map['88057589'], 'https://example/88057589');
  });

  test('битые записи не попадают в карту', () {
    final map = CensorBase.parseList(
      '{"tracks":{"1":null,"2":42,"3":"","4":"https://example/4"}}',
    );
    expect(map, {'4': 'https://example/4'});
    expect(CensorBase.parseList('[]'), isEmpty);
    expect(CensorBase.parseList('{}'), isEmpty);
  });

  test('небезопасные ссылки из списка отбрасываются', () {
    final map = CensorBase.parseList(
      '{"tracks":{'
      '"1":"javascript:alert(1)",'
      '"2":"file:///etc/passwd",'
      '"3":"http://example/3",'
      '"4":"https://example/4"'
      '}}',
    );
    expect(map, {'4': 'https://example/4'});
  });
}
