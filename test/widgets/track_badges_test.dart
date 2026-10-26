import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/l10n/app_localizations.dart';
import 'package:phoneyandex/widgets/track_badges.dart';

void main() {
  testWidgets('рисует 18+, ИИ и «без цензуры» по-русски', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TrackBadges(explicit: true, ai: true, uncensored: true),
        ),
      ),
    );

    expect(find.text('18+'), findsOneWidget);
    expect(find.text('ИИ'), findsOneWidget);
    expect(find.text('Без цензуры'), findsOneWidget);
  });

  testWidgets('без флагов не занимает место', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: TrackBadges()),
      ),
    );

    expect(find.byType(Text), findsNothing);
  });
}
