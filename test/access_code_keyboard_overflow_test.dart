import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:nmimes/l10n/generated/app_localizations.dart';
import 'package:nmimes/providers/auth_state.dart';
import 'package:nmimes/theme/app_theme.dart';
import 'package:nmimes/screens/auth/child_access_code_screen.dart';
import 'package:nmimes/screens/auth/parent_access_code_screen.dart';

/// The access-code screens put a fixed content Column inside an Expanded card.
/// When the soft keyboard opens it shrinks the card's height; without a scroll
/// view the Column overflowed ("A RenderFlex overflowed by N pixels on the
/// bottom"). These tests pump the screen with a large bottom viewInset (the
/// keyboard) at a short height and assert no overflow.

Widget _wrap(Widget child, {required double keyboardInset, Object? args}) =>
    MediaQuery(
      data: MediaQueryData(
        size: const Size(360, 640),
        viewInsets: EdgeInsets.only(bottom: keyboardInset),
      ),
      child: ChangeNotifierProvider(
        create: (_) => AuthState(),
        child: MaterialApp(
          theme: AppTheme.lightForLocale(const Locale('en')),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (_) => child,
            settings: RouteSettings(name: '/', arguments: args),
          ),
        ),
      ),
    );

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost:54321',
      anonKey: 'test-anon-key',
    );
  });

  for (final entry in <String, (Widget Function(), Object?)>{
    'child_access_code': (() => const ChildAccessCodeScreen(), 'kid'),
    'parent_access_code': (() => const ParentAccessCodeScreen(), 'p@e.com'),
  }.entries) {
    testWidgets('${entry.key} does not overflow with the keyboard open',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // 300px keyboard inset on a 640px-tall screen — a realistic squeeze.
      await tester.pumpWidget(
        _wrap(entry.value.$1(), keyboardInset: 300, args: entry.value.$2),
      );
      await tester.pump(const Duration(milliseconds: 50));

      final overflowed = <String>[];
      for (Object? ex = tester.takeException();
          ex != null;
          ex = tester.takeException()) {
        final s = ex.toString();
        if (s.contains('overflowed')) overflowed.add(s.split('\n').first);
      }
      expect(
        overflowed,
        isEmpty,
        reason: '${entry.key} @ keyboard-open: ${overflowed.join(' | ')}',
      );
    });
  }
}
