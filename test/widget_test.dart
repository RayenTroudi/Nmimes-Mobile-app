import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmimes/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NmimesApp(initialLocale: Locale('en')));
    expect(find.byType(NmimesApp), findsOneWidget);
  });
}
