import 'package:flutter/material.dart';
import 'package:camera_android/camera_android.dart';
import 'theme/app_theme.dart';
import 'providers/locale_provider.dart';
import 'l10n/generated/app_localizations.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/choose_role_screen.dart';
import 'screens/auth/child_sign_in_screen.dart';
import 'screens/auth/child_access_code_screen.dart';
import 'screens/auth/child_sign_in_success_screen.dart';
import 'screens/auth/child_grades_screen.dart';
import 'screens/auth/parent_sign_in_screen.dart';
import 'screens/auth/parent_access_code_screen.dart';
import 'screens/auth/parent_forgot_access_code_screen.dart';
import 'screens/auth/parent_reset_access_code_screen.dart';
import 'screens/auth/parent_sign_up_screen.dart';
import 'screens/auth/account_created_screen.dart';
import 'screens/auth/parent_otp_screen.dart';
import 'screens/auth/parent_profile_setup_screen.dart';
import 'screens/auth/parent_grades_screen.dart';
import 'screens/shell/main_shell.dart';
import 'screens/snap/snap_homework_screen.dart';
import 'screens/snap/snap_homework_camera_screen.dart';
import 'screens/snap/snap_lesson_screen.dart';
import 'screens/snap/snap_captured_screen.dart';
import 'screens/snap/snap_send_screen.dart';
import 'screens/snap/snap_explain_screen.dart';
import 'screens/snap/does_this_make_sense_screen.dart';
import 'screens/snap/snap_success_screen.dart';
import 'screens/snap/snap_hw_captured_screen.dart';
import 'screens/snap/snap_hw_send_screen.dart';
import 'screens/snap/snap_hw_success_screen.dart';
import 'screens/snap/snap_hw_explain_screen.dart';
import 'screens/study_room/peer_learning_screen.dart';
import 'screens/study_room/my_room_screen.dart';
import 'screens/study_room/joined_room_screen.dart';
import 'screens/study_room/invite_code_screen.dart';
import 'screens/study_room/end_room_screen.dart';
import 'screens/study_room/leave_room_screen.dart';
import 'screens/teach_it_back/teach_it_back_screen.dart';
import 'screens/teach_it_back/explaining_back_screen.dart';
import 'screens/ai_chat/ai_chat_screen.dart';
import 'screens/ai_chat/ai_chat_voice_screen.dart';
import 'screens/ai_chat/ai_chat_side_menu_screen.dart';
import 'screens/rewards/rewards_screen.dart';
import 'screens/rewards/notifications_screen.dart';
import 'screens/rewards/claim_reward_screen.dart';
import 'screens/rewards/saved_formulas_screen.dart';
import 'screens/rewards/formula_detail_screen.dart';
import 'screens/challenges/challenges_screen.dart';
import 'screens/challenges/start_challenge_screen.dart';
import 'screens/challenges/challenge_screen.dart';
import 'screens/challenges/challenge_completed_screen.dart';
import 'screens/challenges/pvp_challenge_screen.dart';
import 'screens/challenges/leave_challenge_screen.dart';
import 'screens/challenges/join_challenge_screen.dart';
import 'screens/challenges/maze_start_screen.dart';
import 'screens/challenges/maze_challenge_screen.dart';
import 'screens/challenges/maze_completed_screen.dart';
import 'screens/challenges/algebra_start_screen.dart';
import 'screens/challenges/algebra_challenge_screen.dart';
import 'screens/challenges/algebra_completed_screen.dart';
import 'screens/parents/parents_view_screen.dart';
import 'screens/parents/subscription_screen.dart';
import 'screens/parents/payment_screen.dart';
import 'screens/parents/payment_success_screen.dart';
import 'screens/parents/edit_child_profile_screen.dart';
import 'screens/parents/children_screen.dart';
import 'screens/parents/settings_screen.dart';
import 'screens/parents/terms_screen.dart';
import 'screens/parents/privacy_screen.dart';
import 'screens/parents/log_out_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/help_screen.dart';
import 'screens/profile/avatar_screen.dart';
import 'screens/profile/log_out_screen.dart' as profile_logout;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AndroidCamera.registerWith();
  final initialLocale = await resolveInitialLocale();
  runApp(NmimesApp(initialLocale: initialLocale));
}

class NmimesApp extends StatefulWidget {
  final Locale initialLocale;
  const NmimesApp({super.key, required this.initialLocale});

  @override
  State<NmimesApp> createState() => _NmimesAppState();
}

class _NmimesAppState extends State<NmimesApp> {
  late final LocaleNotifier _localeNotifier;

  @override
  void initState() {
    super.initState();
    _localeNotifier = LocaleNotifier(widget.initialLocale);
    _localeNotifier.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _localeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleProvider(
      notifier: _localeNotifier,
      child: MaterialApp(
        title: 'Nmimes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightForLocale(_localeNotifier.value),
        locale: _localeNotifier.value,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: '/',
        routes: {
          '/':                (_) => const SplashScreen(),
          '/onboarding':      (_) => const OnboardingScreen(),
          '/choose-role':     (_) => const ChooseRoleScreen(),
          '/child-sign-in':   (_) => const ChildSignInScreen(),
          '/child-access-code': (_) => const ChildAccessCodeScreen(),
          '/child-success':   (_) => const ChildSignInSuccessScreen(),
          '/child-grades':    (_) => const ChildGradesScreen(),
          '/parent-sign-in':  (_) => const ParentSignInScreen(),
          '/parent-access-code': (_) => const ParentAccessCodeScreen(),
          '/parent-forgot-access-code': (_) => const ParentForgotAccessCodeScreen(),
          '/parent-reset-access-code': (_) => const ParentResetAccessCodeScreen(),
          '/parent-sign-up':  (_) => const ParentSignUpScreen(),
          '/parent-otp':      (_) => const ParentOtpScreen(),
          '/account-created':    (_) => const AccountCreatedScreen(),
          '/profile-setup-done': (_) => const AccountCreatedScreen(),
          '/parent-setup':    (_) => const ParentProfileSetupScreen(),
          '/parent-grades':   (_) => const ParentGradesScreen(),
          '/parent-success':  (_) => const ParentSignInSuccessScreen(), // defined in account_created_screen.dart
          '/home':            (_) => const MainShell(),
          '/snap-homework':   (_) => const SnapHomeworkScreen(),
          '/snap-hw-camera':  (_) => const SnapHomeworkCameraScreen(),
          '/snap-lesson':     (_) => const SnapLessonScreen(),
          '/snap-captured':   (_) => const SnapCapturedScreen(),
          '/snap-send':       (_) => const SnapSendScreen(),
          '/snap-explain':    (_) => const SnapExplainScreen(),
          '/snap-sense':      (_) => const DoesThisMakeSenseScreen(),
          '/snap-hw-captured':(_) => const SnapHwCapturedScreen(),
          '/snap-hw-send':    (_) => const SnapHwSendScreen(),
          '/snap-hw-success': (_) => const SnapHwSuccessScreen(),
          '/snap-hw-explain': (_) => const SnapHwExplainScreen(),
          '/snap-success':    (_) => const SnapSuccessScreen(),
          '/peer-learning':   (_) => const PeerLearningScreen(),
          '/my-room':         (_) => const MyRoomScreen(),
          '/joined-room':     (_) => const JoinedRoomScreen(),
          '/invite-code':     (_) => const InviteCodeScreen(),
          '/end-room':        (_) => const EndRoomScreen(),
          '/leave-room':      (_) => const LeaveRoomScreen(),
          '/teach-it-back':   (_) => const TeachItBackScreen(),
          '/explaining-back': (_) => const ExplainingBackScreen(),
          '/ai-chat':         (_) => const AIChatScreen(),
          '/ai-chat-voice':   (_) => const AIChatVoiceScreen(),
          '/ai-chat-menu':    (_) => const AIChatSideMenuScreen(),
          '/rewards':         (_) => const RewardsScreen(),
          '/notifications':   (_) => const NotificationsScreen(),
          '/claim-reward':    (_) => const ClaimRewardScreen(),
          '/saved-formulas':  (_) => const SavedFormulasScreen(),
          '/formula-detail':  (_) => const FormulaDetailScreen(),
          '/challenges':      (_) => const ChallengesScreen(),
          '/start-challenge': (_) => const StartChallengeScreen(),
          '/challenge':       (_) => const ChallengeScreen(),
          '/challenge-done':  (_) => const ChallengeCompletedScreen(),
          '/pvp-challenge':   (_) => const PVPChallengeScreen(),
          '/leave-challenge': (_) => const LeaveChallengeScreen(),
          '/join-challenge':  (_) => const JoinChallengeScreen(),
          '/maze-start':      (_) => const MazeStartScreen(),
          '/maze-challenge':  (_) => const MazeChallengeScreen(),
          '/maze-done':       (_) => const MazeCompletedScreen(),
          '/algebra-start':   (_) => const AlgebraStartScreen(),
          '/algebra-challenge':(_) => const AlgebraChallengeScreen(),
          '/algebra-done':    (_) => const AlgebraCompletedScreen(),
          '/parents-view':    (_) => const ParentsViewScreen(),
          '/subscription':    (_) => const SubscriptionScreen(),
          '/payment':         (_) => const PaymentScreen(),
          '/payment-success': (_) => const PaymentSuccessScreen(),
          '/edit-child':      (_) => const EditChildProfileScreen(),
          '/children':        (_) => const ChildrenScreen(),
          '/settings':        (_) => const SettingsScreen(),
          '/terms':           (_) => const TermsScreen(),
          '/privacy':         (_) => const PrivacyScreen(),
          '/parent-logout':   (_) => const LogOutScreen(),
          '/profile':         (_) => const ProfileScreen(),
          '/help':            (_) => const HelpScreen(),
          '/avatar':          (_) => const AvatarScreen(),
          '/logout':          (_) => const profile_logout.LogOutScreen(),
        },
      ),
    );
  }
}
