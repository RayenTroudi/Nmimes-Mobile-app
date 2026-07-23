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

/// The access-code screens hide a real, focusable TextField behind the six/four
/// code circles and focus it (on mount / on tap) to raise the keyboard. If the
/// hidden field is laid out at zero size, focusing it trips a layout assertion:
///   additionalConstraints: BoxConstraints(w=0.0, h=0.0)
/// These tests focus the hidden field and assert no such exception is thrown.

Widget _wrap(Widget child, {Object? args}) => MediaQuery(
  data: const MediaQueryData(size: Size(320, 640)),
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
      // Route through onGenerateRoute so the screen receives its arguments,
      // matching how it is reached in the app (username / email string).
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

  testWidgets('child access code: focusing hidden field does not throw a '
      'zero-size layout assertion', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const ChildAccessCodeScreen(), args: 'kid'));
    // The screen auto-focuses the hidden field in a post-frame callback.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final ex = tester.takeException();
    expect(
      ex?.toString() ?? '',
      isNot(contains('BoxConstraints(w=0.0, h=0.0)')),
      reason: 'child access code hidden field laid out at zero size on focus',
    );
  });

  testWidgets('parent access code: focusing hidden field does not throw a '
      'zero-size layout assertion', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(const ParentAccessCodeScreen(), args: 'p@e.com'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final ex = tester.takeException();
    expect(
      ex?.toString() ?? '',
      isNot(contains('BoxConstraints(w=0.0, h=0.0)')),
      reason: 'parent access code hidden field laid out at zero size on focus',
    );
  });
}
