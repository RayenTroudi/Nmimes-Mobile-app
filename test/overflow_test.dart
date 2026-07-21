import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmimes/l10n/generated/app_localizations.dart';
import 'package:nmimes/screens/onboarding/onboarding_screen.dart';

/// Sizes that squeeze layouts: a small phone, a very short phone, and a
/// normal phone with a large accessibility text scale.
const _sizes = <String, Size>{
  'small (320x568)': Size(320, 568),
  'short (360x640)': Size(360, 640),
  'tall (412x915)': Size(412, 915),
};

Widget _wrap(Widget child, {double textScale = 1.0}) => MediaQuery(
  data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
  child: MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: child,
  ),
);

void main() {
  for (final entry in _sizes.entries) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('onboarding fits: ${entry.key} @${scale}x', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _wrap(const OnboardingScreen(), textScale: scale),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  }
}
