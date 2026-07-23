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
import 'package:nmimes/screens/auth/child_sign_in_screen.dart';
import 'package:nmimes/screens/auth/parent_access_code_screen.dart';
import 'package:nmimes/screens/auth/parent_forgot_access_code_screen.dart';
import 'package:nmimes/screens/auth/parent_otp_screen.dart';
import 'package:nmimes/screens/auth/parent_sign_in_screen.dart';
import 'package:nmimes/screens/auth/account_created_screen.dart';
import 'package:nmimes/screens/challenges/algebra_completed_screen.dart';
import 'package:nmimes/screens/challenges/algebra_start_screen.dart';
import 'package:nmimes/screens/challenges/challenge_completed_screen.dart';
import 'package:nmimes/screens/challenges/challenge_screen.dart';
import 'package:nmimes/screens/challenges/maze_completed_screen.dart';
import 'package:nmimes/screens/challenges/maze_start_screen.dart';
import 'package:nmimes/screens/challenges/start_challenge_screen.dart';
import 'package:nmimes/screens/onboarding/choose_role_screen.dart';
import 'package:nmimes/screens/onboarding/onboarding_screen.dart';
import 'package:nmimes/screens/parents/payment_success_screen.dart';
import 'package:nmimes/screens/auth/parent_reset_access_code_screen.dart';
import 'package:nmimes/screens/ai_chat/ai_chat_screen.dart';
import 'package:nmimes/screens/challenges/challenges_screen.dart';
import 'package:nmimes/screens/profile/profile_screen.dart';
import 'package:nmimes/screens/rewards/saved_formulas_screen.dart';
import 'package:nmimes/screens/study_room/peer_learning_screen.dart';

/// Screens that use Spacer() without a scroll view — the pattern behind the
/// reported RenderFlex overflow. Rendered at squeezed sizes to find breaks.
final Map<String, Widget Function()> _screens = {
  'onboarding': () => const OnboardingScreen(),
  'choose_role': () => const ChooseRoleScreen(),
  'child_access_code': () => const ChildAccessCodeScreen(),
  'parent_access_code': () => const ParentAccessCodeScreen(),
  'parent_forgot_access_code': () => const ParentForgotAccessCodeScreen(),
  'parent_otp': () => const ParentOtpScreen(),
  'account_created': () => const AccountCreatedScreen(),
  'algebra_completed': () => const AlgebraCompletedScreen(),
  'algebra_start': () => const AlgebraStartScreen(),
  'challenge_completed': () => const ChallengeCompletedScreen(),
  'challenge': () => const ChallengeScreen(),
  'maze_completed': () => const MazeCompletedScreen(),
  'maze_start': () => const MazeStartScreen(),
  'start_challenge': () => const StartChallengeScreen(),
  'payment_success': () => const PaymentSuccessScreen(),
  'parent_reset_access_code': () => const ParentResetAccessCodeScreen(),
  // Not Spacer-based, but both gained animated wrappers and the formula grid
  // gained a Stack/Positioned card. A large text scale is where a fixed-ratio
  // grid cell breaks first, so they belong in the sweep.
  'peer_learning': () => const PeerLearningScreen(),
  'saved_formulas': () => const SavedFormulasScreen(),
  // The map body now sits inside a clipped rounded sheet, which tightens the
  // height available to the path rows and the champion's taller slot.
  'challenges': () => const ChallengesScreen(),
  'child_sign_in': () => const ChildSignInScreen(),
  'parent_sign_in': () => const ParentSignInScreen(),
  'profile': () => const ProfileScreen(),
  'ai_chat': () => const AIChatScreen(),
};

// A small phone, a normal phone at a large accessibility font scale, a
// 7" tablet, and a 10" tablet. Covers the range the app must fit.
const _cases = <String, (Size, double)>{
  'small@1.0': (Size(320, 568), 1.0),
  'normal@1.3': (Size(390, 844), 1.3),
  'tablet7@1.0': (Size(600, 960), 1.0),
  'tablet10@1.2': (Size(800, 1280), 1.2),
};

Widget _wrap(Widget child, double textScale) => MediaQuery(
  data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
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
      home: child,
    ),
  ),
);

void main() {
  setUpAll(() async {
    // Several screens touch Supabase.instance during build. Initialize it
    // against a dummy local URL so they render; no network call is made by
    // a pure layout pump.
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost:54321',
      anonKey: 'test-anon-key',
    );
  });

  for (final screen in _screens.entries) {
    for (final c in _cases.entries) {
      testWidgets('${screen.key} does not overflow @ ${c.key}', (tester) async {
        tester.view.physicalSize = c.value.$1;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // Capture every individual FlutterError raised during the pumps
        // below, not just the one flutter_test keeps in its single pending
        // slot. When 2+ errors fire before anyone calls takeException()
        // (e.g. two overflowing _RoleCards laid out in the same frame),
        // flutter_test collapses them into a single "Multiple exceptions
        // (N) were detected..." summary whose text does NOT contain
        // "overflowed" — takeException() (called once, or even drained in a
        // loop after the fact) can only ever return that summary, because
        // the individual messages are never queued anywhere; they are only
        // ever printed via dumpErrorToConsole. So the only reliable way to
        // see every real message is to intercept FlutterError.onError
        // ourselves for the duration of the pumps, record the full text of
        // each one, and still forward to the previous handler so
        // flutter_test's own bookkeeping (and its tolerance for unrelated
        // errors) keeps working.
        final capturedErrors = <String>[];
        final previousOnError = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          capturedErrors.add(details.toString());
          previousOnError?.call(details);
        };
        try {
          await tester.pumpWidget(_wrap(screen.value(), c.value.$2));
          // Long enough for entry animations (BounceIn etc.) and their
          // timers to finish, so they don't leak into the next test.
          await tester.pump(const Duration(seconds: 1));
          await tester.pump(const Duration(seconds: 1));
        } finally {
          FlutterError.onError = previousOnError;
        }

        // These screens can also throw unrelated "Supabase not initialized"
        // errors in a bare test environment; only layout overflow is what
        // this test guards, so anything else is tolerated/ignored.
        final overflowed =
            capturedErrors.where((e) => e.contains('overflowed')).toList();
        expect(
          overflowed,
          isEmpty,
          reason: '${screen.key} @ ${c.key}: ${overflowed.join(' | ')}',
        );

        // Drain whatever flutter_test itself is still holding (its own
        // single-slot exception or "Multiple exceptions" summary) so it
        // doesn't fail the test a second, redundant way or leak into the
        // next test. We've already made the real assertion above using the
        // fully-detailed capturedErrors, so this is just cleanup/tolerance
        // for the non-overflow errors these screens are allowed to throw.
        tester.takeException();
      });
    }
  }
}
