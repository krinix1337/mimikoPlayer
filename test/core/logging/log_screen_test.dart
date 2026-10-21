import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/core/logging/app_logger.dart';
import 'package:phoneyandex/core/logging/log_screen.dart';

void main() {
  setUp(() => AppLogger.instance.clear());

  testWidgets('экран логов показывает буфер и очищается', (tester) async {
    AppLogger.instance.info('первая строка');
    AppLogger.instance.warn('цепочка отказала (t_1): yandex/unavailable');

    await tester.pumpWidget(const MaterialApp(home: LogScreen()));

    expect(find.textContaining('первая строка'), findsOneWidget);
    expect(find.textContaining('yandex/unavailable'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(find.textContaining('первая строка'), findsNothing);
    expect(find.text('Пока пусто'), findsOneWidget);
  });
}
