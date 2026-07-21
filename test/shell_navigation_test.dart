import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:nmimes/l10n/generated/app_localizations.dart';
import 'package:nmimes/providers/auth_state.dart';
import 'package:nmimes/screens/challenges/challenges_screen.dart';
import 'package:nmimes/screens/shell/main_shell.dart';
import 'package:nmimes/screens/study_room/peer_learning_screen.dart';
import 'package:nmimes/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost:54321',
      anonKey: 'test-anon-key',
    );
  });

  Widget app() => ChangeNotifierProvider(
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
          home: const MainShell(),
          routes: {
            '/peer-learning': (_) => const PeerLearningScreen(),
          },
        ),
      );

  /// The shell as reached by `pushNamedAndRemoveUntil('/home', arguments: i)`
  /// — the call the "Continue" hero card makes.
  Widget shellWithArgs(int index) => ChangeNotifierProvider(
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
          // `home:` cannot carry route arguments, so the shell is reached
          // through a generated route the way the hero card reaches it.
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => const MainShell(),
            settings: RouteSettings(name: '/home', arguments: index),
          ),
        ),
      );

  Future<void> beat(WidgetTester tester, [int frames = 10]) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('unvisited tabs are not built behind the home screen',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await beat(tester);
    tester.takeException();

    // A bare IndexedStack builds every child up front, so the challenges
    // screen used to be mounted and running its entry animations while the
    // user was still looking at home — which is what made it flash into view.
    expect(find.byType(ChallengesScreen, skipOffstage: false), findsNothing,
        reason: 'the challenges tab must not build until it is selected');
  });

  testWidgets('selecting the challenges tab builds it and keeps it alive',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await beat(tester);
    tester.takeException();

    await tester.tap(find.byIcon(Icons.emoji_events_rounded));
    await beat(tester);
    tester.takeException();

    expect(find.byType(ChallengesScreen, skipOffstage: false), findsOneWidget,
        reason: 'selecting the tab should build it');

    // Going back home must not tear it down again — that is the whole point
    // of the IndexedStack, and lazy building must not cost it.
    await tester.tap(find.byIcon(Icons.home_rounded));
    await beat(tester);
    tester.takeException();

    expect(find.byType(ChallengesScreen, skipOffstage: false), findsOneWidget,
        reason: 'a visited tab must stay alive to preserve its state');
  });

  // The "Continue" hero card sits directly above the study-room rows and
  // jumps to the challenges tab via `arguments: 2`. A press that misses the
  // peer learning row and lands on it is the likeliest way to end up on
  // challenges unexpectedly, so pin down where that argument routes.
  testWidgets('the continue hero card is what routes to the challenges tab',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // `arguments: 2` selects challenges. If the tab order ever changes, this
    // catches the hero card silently pointing somewhere else.
    await tester.pumpWidget(shellWithArgs(2));
    await beat(tester);
    tester.takeException();

    expect(find.byType(ChallengesScreen, skipOffstage: false), findsOneWidget,
        reason: 'index 2 must be the challenges tab');
  });
}
