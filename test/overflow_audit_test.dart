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
import 'package:nmimes/screens/auth/parent_forgot_access_code_screen.dart';
import 'package:nmimes/screens/auth/parent_otp_screen.dart';
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
import 'package:nmimes/screens/challenges/challenges_screen.dart';
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
};

// A small phone and a normal phone at a large accessibility font scale.
const _cases = <String, (Size, double)>{
  'small@1.0': (Size(320, 568), 1.0),
  'normal@1.3': (Size(390, 844), 1.3),
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

        await tester.pumpWidget(_wrap(screen.value(), c.value.$2));
        // Long enough for entry animations (BounceIn etc.) and their timers
        // to finish, so they don't leak into the next test.
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));

        // These screens can also throw unrelated "Supabase not initialized"
        // errors in a bare test environment; only layout overflow is what
        // this test guards, so anything else is drained and ignored.
        final ex = tester.takeException();
        final text = ex?.toString() ?? '';
        expect(
          text.contains('overflowed'),
          isFalse,
          reason: '${screen.key} @ ${c.key}: ${text.split('\n').first}',
        );
      });
    }
  }
}
