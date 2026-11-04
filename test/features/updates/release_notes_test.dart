import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/features/updates/release_notes.dart';

void main() {
  testWidgets('Markdown показывает заголовки, списки и жирный текст', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReleaseNotes(
            '## Что нового\n\n'
            '### Источники\n'
            '- **SoundCloud**: поиск и поток.\n'
            '- Второй пункт.\n\n'
            '`flutter analyze` и обычный текст.',
          ),
        ),
      ),
    );

    // «Что нового» уже в шапке страницы — дубль из тела не рисуется.
    expect(find.text('Что нового', findRichText: true), findsNothing);
    expect(find.text('Источники', findRichText: true), findsOneWidget);
    // Пункты списка — по строке на каждый, маркер рисуется точкой, не «•».
    expect(find.text('•'), findsNothing);
    expect(
      find.textContaining('Второй пункт', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('SoundCloud', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('**', findRichText: true), findsNothing);
  });
}
