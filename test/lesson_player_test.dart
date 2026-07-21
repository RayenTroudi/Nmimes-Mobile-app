import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmimes/l10n/generated/app_localizations.dart';
import 'package:nmimes/screens/snap/lesson_player/lesson_player_screen.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      );

  testWidgets('lesson player renders intro step and advances on continue',
      (tester) async {
    await tester.pumpWidget(wrap(const LessonPlayerScreen()));
    await tester.pump(const Duration(seconds: 3));

    // Step 1: intro equation with the mystery x
    expect(find.text('Meet the mystery number!'), findsOneWidget);

    // Tap Continue → balance intro step
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('An equation is like a balance'), findsOneWidget);
  });
}
