# Nmimes Flutter App — Design Spec

**Date:** 2026-06-18  
**Figma File:** `nTCRDprxcTlycEFofCgzRk` (English Version page, node 0:1)  
**Scope:** English-only pixel-fidelity implementation of all screens  
**Approach:** Option A — flat Navigator routing, one file per screen, no external state management

---

## 1. Project Context

An existing Flutter project (`nmimes`) scaffolded at `d:\nmimes mobile app\nmimes` — currently the default counter app skeleton. The goal is to replace it entirely with a full implementation of every screen in the Figma file.

The Figma file has three pages: **English Version** (in scope), Arabic Version (out of scope), Extras (out of scope).

---

## 2. Folder Structure

```
lib/
  main.dart
  theme/
    colors.dart
    text_styles.dart
    spacing.dart
    app_theme.dart
  screens/
    splash/
      splash_screen.dart
    onboarding/
      onboarding_screen.dart
      choose_role_screen.dart
    auth/
      child_sign_in_screen.dart
      child_sign_in_success_screen.dart
      child_grades_screen.dart
      parent_sign_in_screen.dart
      parent_sign_up_screen.dart
      account_created_screen.dart
      parent_profile_setup_screen.dart
      parent_grades_screen.dart
      parent_sign_in_success_screen.dart
    home/
      home_screen.dart
    snap/
      snap_homework_screen.dart
      snap_lesson_screen.dart
      snap_captured_screen.dart
      snap_send_screen.dart
      does_this_make_sense_screen.dart
      snap_success_screen.dart
    study_room/
      peer_learning_screen.dart
      my_room_screen.dart
      joined_room_screen.dart
      invite_code_screen.dart
      end_room_screen.dart
      leave_room_screen.dart
    teach_it_back/
      teach_it_back_screen.dart
      explaining_back_screen.dart
    ai_chat/
      ai_chat_screen.dart
      ai_chat_voice_screen.dart
      ai_chat_side_menu_screen.dart
    rewards/
      notifications_screen.dart
      claim_reward_screen.dart
      rewards_screen.dart
      saved_formulas_screen.dart
      formula_detail_screen.dart
    challenges/
      challenges_screen.dart
      start_challenge_screen.dart
      challenge_screen.dart
      challenge_completed_screen.dart
      pvp_challenge_screen.dart
      leave_challenge_screen.dart
    parents/
      parents_view_screen.dart
      subscription_screen.dart
      payment_screen.dart
      edit_child_profile_screen.dart
      children_screen.dart
      settings_screen.dart
      log_out_screen.dart
    profile/
      profile_screen.dart
      help_screen.dart
      avatar_screen.dart
  widgets/
    primary_button.dart
    secondary_button.dart
    app_text_field.dart
    bottom_nav_bar.dart
    onboarding_dots.dart
    chat_bubble.dart
    reward_card.dart
    challenge_card.dart
    avatar_widget.dart
    role_card.dart
    home_action_button.dart
    study_room_card.dart
assets/
  images/
  icons/
```

---

## 3. Design Tokens

### 3.1 Colors — `lib/theme/colors.dart`

```dart
class AppColors {
  static const primary        = Color(0xFFFF6B35);
  static const primaryDark    = Color(0xFFE55A2B);
  static const background     = Color(0xFFFFFFFF);
  static const surface        = Color(0xFFF5F5F5);
  static const textPrimary    = Color(0xFF1A1A2E);
  static const textSecondary  = Color(0xFF666666);
  static const textHint       = Color(0xFF999999);
  static const success        = Color(0xFF4CAF50);
  static const navBarBg       = Color(0xFFFFFFFF);
  static const navActive      = Color(0xFFFF6B35);
  static const navInactive    = Color(0xFFBBBBBB);
  static const cardBorder     = Color(0xFFE0E0E0);
  static const dotActive      = Color(0xFFFF6B35);
  static const dotInactive    = Color(0xFFD9D9D9);
  static const inputBorder    = Color(0xFFE0E0E0);
  static const white          = Color(0xFFFFFFFF);
  static const black          = Color(0xFF000000);
}
```

### 3.2 Typography — `lib/theme/text_styles.dart`

Font: **Poppins** via `google_fonts` package.

| Style name     | Weight    | Size | Use |
|----------------|-----------|------|-----|
| `h1`           | SemiBold  | 28   | Screen titles (onboarding) |
| `h2`           | SemiBold  | 22   | Section headings |
| `h3`           | SemiBold  | 18   | Card titles, role labels |
| `buttonLabel`  | SemiBold  | 16   | Primary/secondary buttons |
| `body`         | Regular   | 14   | General body text |
| `bodySmall`    | Regular   | 12   | Subtitles, captions |
| `caption`      | Regular   | 11   | Hint text, timestamps |

### 3.3 Spacing — `lib/theme/spacing.dart`

```dart
class AppSpacing {
  static const xs   = 4.0;
  static const sm   = 8.0;
  static const md   = 16.0;
  static const lg   = 20.0;
  static const xl   = 24.0;
  static const xxl  = 32.0;
  static const xxxl = 48.0;
}
```

### 3.4 Key Dimensions

| Element | Width | Height | Corner Radius |
|---|---|---|---|
| Design canvas reference | 375px | — | — |
| PrimaryButton | 335 | 70 | 14 |
| Status bar placeholder | 375 | 59 | — |
| Bottom nav bar | 375 | 83 | — |
| Role card (ChooseRole) | 161 | 161 | 16 |
| HomeActionButton | 335 | 100 | 16 |
| StudyRoomCard | 335 | 81 | 16 |
| AppTextField | 335 | 56 | 12 |
| Onboarding dot (active) | 40 | 16 | 8 |
| Onboarding dot (inactive) | 16 | 16 | 8 |

---

## 4. Shared Widgets

### `PrimaryButton`
- Size: 335×70, corner radius 14
- Background: `AppColors.primary`
- Label: `AppTextStyles.buttonLabel`, color white
- Constructor: `PrimaryButton({required String label, required VoidCallback onTap})`

### `SecondaryButton`
- Same size as PrimaryButton but outlined style (border: primary, text: primary, background: transparent)

### `AppTextField`
- Width: 335, height: 56, border radius 12
- Border color: `AppColors.inputBorder`, focused: `AppColors.primary`
- Font: `AppTextStyles.body`
- Constructor: `AppTextField({required String hint, TextEditingController? controller, bool obscure = false})`

### `BottomNavBar`
- 5 tabs: Home, Study Room, AI Chat, Rewards, Challenges
- Each tab: icon (Material or custom) + label
- Active: `AppColors.navActive`, inactive: `AppColors.navInactive`
- Height: 83, background: white, top border `AppColors.cardBorder`
- Constructor: `BottomNavBar({required int currentIndex, required ValueChanged<int> onTap})`

### `OnboardingDots`
- Row of 4 dots; active dot 40×16 rounded pill, inactive 16×16 circle
- Colors: `AppColors.dotActive` / `AppColors.dotInactive`

### `ChatBubble`
- Two variants: `isUser` (right-aligned, primary bg, white text) and AI (left-aligned, surface bg, textPrimary)
- Rounded corners 16, padding 12×16

### `RewardCard`
- Surface card, border radius 16, padding 16
- Shows reward icon, title, points badge

### `ChallengeCard`
- Surface card, border radius 16
- Shows subject, difficulty badge, timer indicator

### `AvatarWidget`
- Circular image (radius 20 default), orange border 2px
- Fallback to initial letter if no image

### `RoleCard`
- 161×161, border radius 16, border 2px (inactive: cardBorder, active: primary)
- Contains illustration image 70×70 + label below

### `HomeActionButton`
- 335×100, border radius 16, surface background
- Icon 48×48 right side, title + subtitle left side

### `StudyRoomCard`
- 335×81, border radius 16, surface background
- Icon 28×28 left, title + subtitle center, chevron right

---

## 5. Screen Inventory

### Figma sections → Screen files

#### Splash & Onboarding
| Screen file | Figma frame | Node ID |
|---|---|---|
| `splash_screen.dart` | Splash 3 → Splash 4 (animated) | 375:3809, 375:3811 |
| `onboarding_screen.dart` | Onboarding 7, 8, 9, 11 (PageView) | 375:3813, 375:3843, 375:3873, 375:3937 |
| `choose_role_screen.dart` | Choose Role | 1124:3152 |

**SplashScreen:** Centered mascot logo (`nmimes_front 1` image), dark background, animates to Splash 4 (mascot + chat bubble "Hey! I'm Nmimes!") after 1.5s, then navigates to OnboardingScreen.

**OnboardingScreen:** PageView with 4 pages. Each page: illustration top half, card bottom half with heading + subtitle + body text. OnboardingDots indicator. "Next" PrimaryButton → advances page or navigates to ChooseRoleScreen on last page.

**ChooseRoleScreen:** Two RoleCards ("Child", "Parent") side by side. PrimaryButton "Continue" → routes based on selection.

#### Auth — Child
| Screen file | Figma frame | Node ID |
|---|---|---|
| `child_sign_in_screen.dart` | Child SIGN IN | 1126:9641 |
| `child_sign_in_success_screen.dart` | Child SIGN IN Success | 1126:9677 |
| `grades_screen.dart` (child) | Geades (child) | — |

**ChildSignInScreen:** Heading "SIGN IN", PIN-entry keypad (3×4 grid of digit buttons, 3 slot display), PrimaryButton "Continue".

**ChildSignInSuccessScreen:** Success illustration, "You're in!" message, auto-navigate to HomeScreen after 2s.

#### Auth — Parent
| Screen file | Figma frame | Node ID |
|---|---|---|
| `parent_sign_in_screen.dart` | SIGN IN (parent) | 375:3970 |
| `parent_sign_up_screen.dart` | SIGN UP | 375:4014 |
| `account_created_screen.dart` | Account Created! | 375:4970 |
| `parent_profile_setup_screen.dart` | Profile Set up! | 375:4985 |
| `grades_screen.dart` (parent) | Geades | 375:4488 |
| `parent_sign_in_success_screen.dart` | SIGN IN Success | 375:5036 |

**ParentSignInScreen / ParentSignUpScreen:** Standard email + password AppTextFields, PrimaryButton. Sign up also has name field.

**AccountCreatedScreen:** Celebration illustration, "Account Created!" heading, auto-navigate to profile setup.

**ParentProfileSetupScreen:** Form for child name + avatar selection, PrimaryButton "Continue".

**GradesScreen:** Grade selector grid (e.g. grades 1–12), PrimaryButton "Done".

#### Home & Snap
| Screen file | Figma frame | Node ID |
|---|---|---|
| `home_screen.dart` | Home | 375:4195 |
| `snap_homework_screen.dart` | Snap a Homework | 375:4502 |
| `snap_lesson_screen.dart` | Snap a Lesson | 510:2483 |
| `snap_captured_screen.dart` | Snap captured | 510:2520 |
| `snap_send_screen.dart` | Snap & Send Captured | 375:4617 |
| `does_this_make_sense_screen.dart` | Does this make sense? | 1081:11964 |
| `snap_success_screen.dart` | Success | 445:6766 |

**HomeScreen:** AppBar with avatar + greeting. Body: HomeActionButton "Snap a Homework", HomeActionButton "Snap a Lesson", "Study Rooms" section header + StudyRoomCard "Peer Learning", HomeActionButton "Teach It Back!". BottomNavBar index 0.

**SnapHomeworkScreen / SnapLessonScreen:** Full-screen camera viewfinder placeholder (dark bg), shutter FAB center-bottom, close X top-left, instruction text overlay.

**SnapCapturedScreen:** Captured image preview, "Retake" secondary button + "Send" PrimaryButton.

**SnapSendScreen:** Multi-step (Figma shows ~12 flow states). Renders the captured image with AI overlay showing math solution steps. Each step: image top, explanation card bottom, "Next" button. Implemented as a single screen with local `step` state.

**DoesThisMakeSenseScreen:** AI asks confirmation question, "Yes" / "No" buttons.

**SnapSuccessScreen:** Success animation/illustration, "Great job!" message, PrimaryButton "Back to Home".

#### Study Room
| Screen file | Figma frame | Node ID |
|---|---|---|
| `peer_learning_screen.dart` | Peer Learning | 375:4539 |
| `my_room_screen.dart` | My Room | 375:5076 |
| `joined_room_screen.dart` | Joined Room | 375:5485 |
| `invite_code_screen.dart` | Invite Code | 398:3998 |
| `end_room_screen.dart` | End Room | 375:5855 |
| `leave_room_screen.dart` | Leave Room | 375:5862 |

**PeerLearningScreen:** "Create Room" + "Join Room" options as large cards. No bottom nav.

**MyRoomScreen / JoinedRoomScreen:** Room view with participant avatars, subject/topic display, problem area, action buttons.

**InviteCodeScreen:** Modal-style sheet showing 6-digit code, copy button.

**EndRoomScreen / LeaveRoomScreen:** Confirmation dialog overlay on blurred room background.

#### Teach It Back
| Screen file | Figma frame | Node ID |
|---|---|---|
| `teach_it_back_screen.dart` | Teach It Back! | 375:7667 |
| `explaining_back_screen.dart` | Explaining back | 1277:6685 |

**TeachItBackScreen:** Intro screen with mascot, explanation of the feature, PrimaryButton "Start".

**ExplainingBackScreen:** Multi-step flow (11 Figma states → single screen with step counter). User records/types their explanation, AI responds. Scrollable chat-like layout.

#### AI Chat
| Screen file | Figma frame | Node ID |
|---|---|---|
| `ai_chat_screen.dart` | AI chat | 375:5876 |
| `ai_chat_voice_screen.dart` | AI chat - voice interaction | 702:1486 |
| `ai_chat_side_menu_screen.dart` | Side Menu AI Chat | 375:8232 |

**AIChatScreen:** Mascot avatar + name top center, welcome message, PrimaryButton "Let's Chat!" → opens chat input. BottomNavBar index 2. Hamburger icon top-left → AIChatSideMenuScreen.

**AIChatVoiceScreen:** Full-screen voice UI. Animated mic button center (blob background). "Listening…" label bottom. "Let's Talk" header + close X. Waveform animation placeholder.

**AIChatSideMenuScreen:** Left drawer with chat history list.

#### Rewards
| Screen file | Figma frame | Node ID |
|---|---|---|
| `notifications_screen.dart` | Notifications | 376:12415 |
| `claim_reward_screen.dart` | Claim Reward | 1189:5413 |
| `rewards_screen.dart` | Rewards | 375:7795 |
| `saved_formulas_screen.dart` | Saved Formulas | 1085:12182 |
| `formula_detail_screen.dart` | Details | 1085:12254 |

**RewardsScreen:** BottomNavBar index 3. Tabs: "Rewards" / "Notifications" / "Saved Formulas". Rewards tab: grid of RewardCards with points. Notifications tab: list of NotificationItems. Saved Formulas tab: list of formula cards → FormulaDetailScreen.

**ClaimRewardScreen:** Modal sheet showing reward details, animated confetti placeholder, "Claim" PrimaryButton.

#### Challenges
| Screen file | Figma frame | Node ID |
|---|---|---|
| `challenges_screen.dart` | Challenges | 375:7898 |
| `start_challenge_screen.dart` | Start Challenge | 375:5919 |
| `challenge_screen.dart` | Challenge | 375:6123 |
| `challenge_completed_screen.dart` | Challenge Completed | 375:6059 |
| `pvp_challenge_screen.dart` | PVP Challenge | 1330:6920 |
| `leave_challenge_screen.dart` | Leave Challenge | 1333:7420 |

**ChallengesScreen:** BottomNavBar index 4. List of ChallengeCards (subject, difficulty, timer). "PVP" tab for player-vs-player. FAB or button to start new challenge.

**StartChallengeScreen:** Challenge details (subject, question count, timer setting), PrimaryButton "Start".

**ChallengeScreen:** Full-screen quiz UI. Question text top, multiple-choice options (4 cards), progress bar + timer top. Single screen with question index state.

**ChallengeCompletedScreen:** Score display, trophy illustration, breakdown of correct/incorrect, PrimaryButton "Back to Challenges".

**PVPChallengeScreen:** Two-player layout with scores side by side.

**LeaveChallengeScreen:** Confirmation overlay.

#### Parents View
| Screen file | Figma frame | Node ID |
|---|---|---|
| `parents_view_screen.dart` | Parents view | 376:13129 |
| `subscription_screen.dart` | Subscription | 425:2237 |
| `payment_screen.dart` | Payment | 425:2681 |
| `edit_child_profile_screen.dart` | Edit Child Profile | 1128:10029 |
| `children_screen.dart` | Children | 1128:9964 |
| `settings_screen.dart` | Settings | 375:4169 |
| `log_out_screen.dart` (parent) | Log Out | 1128:10247 |

**ParentsViewScreen:** Dashboard. Child progress summary, subscription status, navigation tiles (Children, Grades, Settings, Subscription, Terms, Privacy, Log Out).

**SubscriptionScreen:** 3 plan tiers shown as cards (Figma has 3 states → render all 3 plan cards on one screen). PrimaryButton "Subscribe".

**PaymentScreen:** Payment form (card number, expiry, CVV fields), PrimaryButton "Pay".

**ChildrenScreen:** List of child profiles with edit buttons → EditChildProfileScreen.

**SettingsScreen:** Toggle list (notifications, sound, etc.).

**LogOutScreen:** Confirmation dialog.

#### Profile
| Screen file | Figma frame | Node ID |
|---|---|---|
| `profile_screen.dart` | Profile | 375:4459 |
| `help_screen.dart` | Help | 375:12150 |
| `avatar_screen.dart` | Avatar | 1128:10256 |
| `log_out_screen.dart` (child) | Log Out | 375:5869 |

**ProfileScreen:** Avatar, username, XP/level display, stats row. Menu list: Help, Avatar, Log Out.

**HelpScreen:** FAQ accordion list.

**AvatarScreen:** Grid of avatar options to select.

---

## 6. Navigation Implementation

**`main.dart`** defines named routes:

```dart
routes: {
  '/':                  (_) => const SplashScreen(),
  '/onboarding':        (_) => const OnboardingScreen(),
  '/choose-role':       (_) => const ChooseRoleScreen(),
  '/child-sign-in':     (_) => const ChildSignInScreen(),
  '/child-success':     (_) => const ChildSignInSuccessScreen(),
  '/parent-sign-in':    (_) => const ParentSignInScreen(),
  '/parent-sign-up':    (_) => const ParentSignUpScreen(),
  '/account-created':   (_) => const AccountCreatedScreen(),
  '/parent-setup':      (_) => const ParentProfileSetupScreen(),
  '/grades':            (_) => const GradesScreen(),
  '/home':              (_) => const HomeScreen(),
  '/snap-homework':     (_) => const SnapHomeworkScreen(),
  '/snap-lesson':       (_) => const SnapLessonScreen(),
  '/snap-captured':     (_) => const SnapCapturedScreen(),
  '/snap-send':         (_) => const SnapSendScreen(),
  '/snap-sense':        (_) => const DoesThisMakeSenseScreen(),
  '/snap-success':      (_) => const SnapSuccessScreen(),
  '/peer-learning':     (_) => const PeerLearningScreen(),
  '/my-room':           (_) => const MyRoomScreen(),
  '/joined-room':       (_) => const JoinedRoomScreen(),
  '/invite-code':       (_) => const InviteCodeScreen(),
  '/end-room':          (_) => const EndRoomScreen(),
  '/leave-room':        (_) => const LeaveRoomScreen(),
  '/teach-it-back':     (_) => const TeachItBackScreen(),
  '/explaining-back':   (_) => const ExplainingBackScreen(),
  '/ai-chat':           (_) => const AIChatScreen(),
  '/ai-chat-voice':     (_) => const AIChatVoiceScreen(),
  '/ai-chat-menu':      (_) => const AIChatSideMenuScreen(),
  '/rewards':           (_) => const RewardsScreen(),
  '/notifications':     (_) => const NotificationsScreen(),
  '/claim-reward':      (_) => const ClaimRewardScreen(),
  '/saved-formulas':    (_) => const SavedFormulasScreen(),
  '/formula-detail':    (_) => const FormulaDetailScreen(),
  '/challenges':        (_) => const ChallengesScreen(),
  '/start-challenge':   (_) => const StartChallengeScreen(),
  '/challenge':         (_) => const ChallengeScreen(),
  '/challenge-done':    (_) => const ChallengeCompletedScreen(),
  '/pvp-challenge':     (_) => const PVPChallengeScreen(),
  '/leave-challenge':   (_) => const LeaveChallengeScreen(),
  '/parents-view':      (_) => const ParentsViewScreen(),
  '/subscription':      (_) => const SubscriptionScreen(),
  '/payment':           (_) => const PaymentScreen(),
  '/edit-child':        (_) => const EditChildProfileScreen(),
  '/children':          (_) => const ChildrenScreen(),
  '/settings':          (_) => const SettingsScreen(),
  '/parent-logout':     (_) => const LogOutScreen(),
  '/profile':           (_) => const ProfileScreen(),
  '/help':              (_) => const HelpScreen(),
  '/avatar':            (_) => const AvatarScreen(),
  '/logout':            (_) => const LogOutScreen(),
}
```

The `HomeScreen`, `AIChatScreen`, `RewardsScreen`, and `ChallengesScreen` each render the `BottomNavBar` and use `Navigator.pushReplacementNamed` when switching tabs so the nav bar persists visually.

---

## 7. Dependencies (pubspec.yaml additions)

```yaml
dependencies:
  google_fonts: ^6.2.1      # Poppins font
  cupertino_icons: ^1.0.8   # already present
```

No other packages. No state management library. No camera plugin (camera viewfinder is a placeholder dark container). No real auth.

---

## 8. Assets

- `assets/images/` — Figma image assets (mascot `nmimes_front.png`, onboarding illustrations, avatar options). These will be exported from Figma or approximated with colored placeholder containers where export is not possible due to rate limits.
- `assets/icons/` — Any custom icons not available in `Icons.*`.
- Both registered in `pubspec.yaml` under `flutter: assets:`.

---

## 9. Implementation Constraints

- All screens use `LayoutBuilder` or fixed 375px reference widths scaled via `MediaQuery` to handle different device sizes gracefully.
- No real camera, no real backend, no real auth — all interactions navigate between screens only.
- Multi-step flows (SnapSend: 12 states, ExplainingBack: 11 states, Challenge: multiple questions) are implemented as a single `StatefulWidget` with a local step/index integer.
- `LogOutScreen` has two separate file implementations (`profile/log_out_screen.dart` for child, `parents/log_out_screen.dart` for parent) — both are trivial confirmation dialogs with different back-navigation targets, kept separate to avoid constructor coupling.
- `GradesScreen` has two separate file implementations (`auth/child_grades_screen.dart`, `auth/parent_grades_screen.dart`) — kept separate because navigation targets differ and content may differ slightly.
- Bottom nav switching does NOT use nested navigators — each tab root screen is pushed with `pushReplacementNamed` to keep the navigation stack simple.
