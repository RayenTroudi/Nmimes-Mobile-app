# Localization (EN/FR/AR) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add English/French/Arabic localization to the Nmimes Flutter app with device-locale detection, persistent user preference, and a language-switcher bottom sheet reachable from the home screen and parent settings.

**Architecture:** A `LocaleNotifier` (`ValueNotifier<Locale>`) lives at the app root and is exposed via a `LocaleProvider` inherited widget; `MaterialApp.locale` binds to it. Strings are stored in ARB files under `lib/l10n/` and accessed via generated `AppLocalizations`; a `context.l10n` extension provides a terse call-site alias. Arabic uses `GoogleFonts.cairo` via locale-aware `AppTextStyles` factory methods; English and French use Poppins.

**Tech Stack:** Flutter `flutter_localizations` (SDK), `intl ^0.19.0`, `shared_preferences ^2.3.0`, `google_fonts ^6.2.1` (already present), `flutter gen-l10n` code generation.

## Global Constraints

- English is the default/fallback locale.
- Supported locales: `en`, `fr`, `ar` only.
- ARB key naming: `screenOrWidget_elementType_descriptor` (e.g. `childSignIn_button_continue`).
- Brand name "Nmimes", asset paths, and route strings are NOT extracted — stay hardcoded.
- Dynamic values (username, points) use ARB `{placeholder}` syntax.
- `EdgeInsets.only(left/right)` → `EdgeInsetsDirectional.only(start/end)` wherever encountered during string extraction.
- `TextAlign.left` → `TextAlign.start` wherever encountered.
- Arabic font: `GoogleFonts.cairo`. EN/FR font: `GoogleFonts.poppins`.
- Generated files in `lib/l10n/generated/` are git-ignored.
- `SharedPreferences` key for saved locale: `app_locale`.

---

### Task 1: Dependencies, l10n.yaml, and code-generation scaffold

**Files:**
- Modify: `pubspec.yaml`
- Create: `l10n.yaml`
- Create: `lib/l10n/app_en.arb` (minimal — one key to verify codegen works)
- Create: `lib/l10n/app_fr.arb`
- Create: `lib/l10n/app_ar.arb`
- Create: `.gitignore` entry for generated files (append to existing)

**Interfaces:**
- Produces: `AppLocalizations` class accessible as `AppLocalizations.of(context)` — consumed by every later task.

- [ ] **Step 1: Add dependencies to pubspec.yaml**

Open `pubspec.yaml`. The current `dependencies` block is:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.1
```

Replace with:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.1
  intl: ^0.19.0
  shared_preferences: ^2.3.0
```

Also add `generate: true` under the `flutter:` section (keep all existing keys, just append):
```yaml
flutter:
  generate: true
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

- [ ] **Step 2: Create l10n.yaml at project root**

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n/generated
nullable-getter: false
```

- [ ] **Step 3: Create lib/l10n/app_en.arb with one bootstrap key**

```json
{
  "@@locale": "en",
  "appTitle": "Nmimes",
  "@appTitle": { "description": "App title" }
}
```

- [ ] **Step 4: Create lib/l10n/app_fr.arb**

```json
{
  "@@locale": "fr",
  "appTitle": "Nmimes"
}
```

- [ ] **Step 5: Create lib/l10n/app_ar.arb**

```json
{
  "@@locale": "ar",
  "appTitle": "Nmimes"
}
```

- [ ] **Step 6: Add generated folder to .gitignore**

Append to the existing `.gitignore` at project root:
```
# L10n generated files
lib/l10n/generated/
```

- [ ] **Step 7: Run flutter pub get and code generation**

```powershell
flutter pub get
flutter gen-l10n
```

Expected: No errors. `lib/l10n/generated/app_localizations.dart` is created.

- [ ] **Step 8: Commit**

```powershell
git add pubspec.yaml pubspec.lock l10n.yaml lib/l10n/ .gitignore
git commit -m "feat: add l10n deps, arb scaffold, codegen config"
```

---

### Task 2: LocaleProvider + LocaleNotifier

**Files:**
- Create: `lib/providers/locale_provider.dart`

**Interfaces:**
- Produces:
  - `LocaleNotifier` — a `ValueNotifier<Locale>` with `setLocale(Locale)` that persists to SharedPreferences.
  - `LocaleProvider` — an `InheritedWidget` that exposes `LocaleNotifier` to the tree.
  - `LocaleProvider.of(context)` → `LocaleNotifier`
  - `resolveInitialLocale()` → `Future<Locale>` (reads prefs, falls back to device locale, then `en`)

- [ ] **Step 1: Create lib/providers/locale_provider.dart**

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';
const _supported = ['en', 'fr', 'ar'];

Future<Locale> resolveInitialLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_kLocaleKey);
  if (saved != null && _supported.contains(saved)) {
    return Locale(saved);
  }
  final deviceLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  if (_supported.contains(deviceLang)) {
    return Locale(deviceLang);
  }
  return const Locale('en');
}

class LocaleNotifier extends ValueNotifier<Locale> {
  LocaleNotifier(super.value);

  Future<void> setLocale(Locale locale) async {
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }
}

class LocaleProvider extends InheritedWidget {
  final LocaleNotifier notifier;

  const LocaleProvider({
    super.key,
    required this.notifier,
    required super.child,
  });

  static LocaleNotifier of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocaleProvider>()!
        .notifier;
  }

  @override
  bool updateShouldNotify(LocaleProvider oldWidget) =>
      notifier != oldWidget.notifier;
}
```

- [ ] **Step 2: Commit**

```powershell
git add lib/providers/locale_provider.dart
git commit -m "feat: add LocaleNotifier and LocaleProvider"
```

---

### Task 3: Wire MaterialApp to LocaleProvider

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/l10n/l10n_extension.dart`

**Interfaces:**
- Consumes: `LocaleNotifier`, `LocaleProvider`, `resolveInitialLocale()` from Task 2; `AppLocalizations` from Task 1.
- Produces: `context.l10n` extension — consumed by all screen tasks.

- [ ] **Step 1: Create lib/l10n/l10n_extension.dart**

```dart
import 'package:flutter/material.dart';
import 'generated/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
```

- [ ] **Step 2: Rewrite lib/main.dart**

Replace the `main()` function and `NmimesApp` class. Keep all imports and route map exactly as they are — only change `main()` and the `build` method of `NmimesApp`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'providers/locale_provider.dart';
import 'l10n/generated/app_localizations.dart';

// ... (keep all existing screen imports unchanged) ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        theme: AppTheme.light,
        locale: _localeNotifier.value,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: '/',
        routes: {
          // ... keep all existing routes unchanged ...
        },
      ),
    );
  }
}
```

- [ ] **Step 3: Run the app to verify it launches without errors**

```powershell
flutter run
```

Expected: App launches on splash screen, no red screen or missing-delegate errors.

- [ ] **Step 4: Commit**

```powershell
git add lib/main.dart lib/l10n/l10n_extension.dart
git commit -m "feat: wire MaterialApp to LocaleProvider and AppLocalizations"
```

---

### Task 4: Locale-aware AppTextStyles

**Files:**
- Modify: `lib/theme/text_styles.dart`

**Interfaces:**
- Produces: `AppTextStyles.font(context, {fontSize, fontWeight, color, height})` — a single locale-aware factory used by all screen tasks to replace `GoogleFonts.poppins(...)` inline calls.
- The existing static getters (`h1`, `h2`, `body`, etc.) remain for backward compatibility but are not used in new localized code.

- [ ] **Step 1: Add locale-aware factory method to AppTextStyles**

Append to `lib/theme/text_styles.dart` (after the existing getters, inside the class):

```dart
  /// Returns Poppins for EN/FR, Cairo for AR.
  static TextStyle font(
    BuildContext context, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (isAr) {
      return GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );
    }
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }
```

- [ ] **Step 2: Commit**

```powershell
git add lib/theme/text_styles.dart
git commit -m "feat: add locale-aware AppTextStyles.font() factory"
```

---

### Task 5: LanguagePickerSheet widget

**Files:**
- Create: `lib/widgets/language_picker_sheet.dart`

**Interfaces:**
- Consumes: `LocaleProvider.of(context)` from Task 2.
- Produces: `showLanguagePicker(BuildContext context)` — a top-level function that opens the modal bottom sheet. Consumed by Task 6 (home pill) and Task 7 (settings).

- [ ] **Step 1: Create lib/widgets/language_picker_sheet.dart**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/locale_provider.dart';
import '../theme/colors.dart';

const _languages = [
  (code: 'en', flag: '🇬🇧', label: 'English'),
  (code: 'fr', flag: '🇫🇷', label: 'Français'),
  (code: 'ar', flag: '🇸🇦', label: 'العربية'),
];

void showLanguagePicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _LanguagePickerSheet(
      notifier: LocaleProvider.of(context),
    ),
  );
}

class _LanguagePickerSheet extends StatelessWidget {
  final LocaleNotifier notifier;
  const _LanguagePickerSheet({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final current = notifier.value.languageCode;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDEDEDE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            for (final lang in _languages) ...[
              ListTile(
                leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
                title: Text(
                  lang.label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: current == lang.code
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  notifier.setLocale(Locale(lang.code));
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```powershell
git add lib/widgets/language_picker_sheet.dart
git commit -m "feat: add LanguagePickerSheet reusable widget"
```

---

### Task 6: Wire language pill in HomeScreen

**Files:**
- Modify: `lib/screens/home/home_screen.dart`

**Interfaces:**
- Consumes: `showLanguagePicker()` from Task 5; `LocaleProvider.of(context)` from Task 2.

- [ ] **Step 1: Make the language pill reactive and tappable**

In `lib/screens/home/home_screen.dart`, update `_HomeHeader.build`. Add the import at the top:

```dart
import '../../widgets/language_picker_sheet.dart';
import '../../providers/locale_provider.dart';
```

Replace the static pill widget block (the `Container` with `🇬🇧` and `'ENG'`) with:

```dart
ValueListenableBuilder<Locale>(
  valueListenable: LocaleProvider.of(context),
  builder: (context, locale, _) {
    final (flag, label) = switch (locale.languageCode) {
      'fr' => ('🇫🇷', 'FR'),
      'ar' => ('🇸🇦', 'عر'),
      _ =>  ('🇬🇧', 'ENG'),
    };
    return GestureDetector(
      onTap: () => showLanguagePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down,
                color: AppColors.white, size: 14),
          ],
        ),
      ),
    );
  },
),
```

- [ ] **Step 2: Verify in app**

Run the app, navigate to home, tap the language pill. Confirm the bottom sheet appears with three options. Select Arabic — confirm the pill changes to `🇸🇦 عر`. Select English — confirm it returns to `🇬🇧 ENG`.

- [ ] **Step 3: Commit**

```powershell
git add lib/screens/home/home_screen.dart
git commit -m "feat: wire home language pill to LocaleProvider and picker sheet"
```

---

### Task 7: Language row in SettingsScreen

**Files:**
- Modify: `lib/screens/parents/settings_screen.dart`

**Interfaces:**
- Consumes: `showLanguagePicker()` from Task 5.

- [ ] **Step 1: Add Language row to SettingsScreen**

Add the import at the top of `lib/screens/parents/settings_screen.dart`:
```dart
import '../../widgets/language_picker_sheet.dart';
```

In the `ListView` children, insert a new row **between** the Notifications row and the Terms & Conditions row:

```dart
const SizedBox(height: 16),

// Language
_SettingsRow(
  label: 'Language',
  onTap: () => showLanguagePicker(context),
),
```

- [ ] **Step 2: Verify in app**

Navigate to parent settings, confirm a "Language" row appears. Tap it — confirm the picker sheet opens.

- [ ] **Step 3: Commit**

```powershell
git add lib/screens/parents/settings_screen.dart
git commit -m "feat: add Language row to parent SettingsScreen"
```

---

### Task 8: Full ARB strings — splash, onboarding, choose role

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_ar.arb`
- Modify: `lib/screens/splash/splash_screen.dart`
- Modify: `lib/screens/onboarding/onboarding_screen.dart`
- Modify: `lib/screens/onboarding/choose_role_screen.dart`

**Interfaces:**
- Consumes: `context.l10n` from Task 3; `AppTextStyles.font(context, ...)` from Task 4.

- [ ] **Step 1: Add strings to ARB files**

Append to `app_en.arb`:
```json
  "splash_tagline": "Math, made Simple...",

  "onboarding_title_snapIt": "Snap it.\nGet it.",
  "onboarding_badge_snapIt": "No typing. No stress.",
  "onboarding_body_snapIt": "Photograph your homework or lesson and\nNmimes reads it in seconds.",
  "onboarding_title_understand": "Understand,\nDon't just copy",
  "onboarding_badge_understand": "Built to make it click",
  "onboarding_body_understand": "Clear visual explanations that teach you\nthe why, not just the answer.",
  "onboarding_title_play": "Play your way\nto Mastery",
  "onboarding_badge_play": "Math, but actually fun",
  "onboarding_body_play": "Duel friends, join study rooms, and\nteach it back to lock it in.",
  "onboarding_title_rewards": "Win Real\nRewards",
  "onboarding_badge_rewards": "Effort that pays off",
  "onboarding_body_rewards": "Hit your goals and unlock real\nrewards.",
  "onboarding_button_next": "Next",
  "onboarding_button_start": "Let's Start",
  "onboarding_button_back": "Back",

  "chooseRole_title": "Who are you?",
  "chooseRole_subtitle": "Choose your role to get started",
  "chooseRole_role_student": "Student",
  "chooseRole_role_parent": "Parent"
```

Append to `app_fr.arb`:
```json
  "splash_tagline": "Les maths, simplifiées...",

  "onboarding_title_snapIt": "Prends en photo.\nComprends.",
  "onboarding_badge_snapIt": "Sans taper. Sans stress.",
  "onboarding_body_snapIt": "Photographiez vos devoirs ou votre cours et\nNmimes les déchiffre en secondes.",
  "onboarding_title_understand": "Comprendre,\npas juste copier",
  "onboarding_badge_understand": "Conçu pour que ça clique",
  "onboarding_body_understand": "Des explications visuelles claires qui enseignent\nle pourquoi, pas juste la réponse.",
  "onboarding_title_play": "Joue à ta façon\njusqu'à la maîtrise",
  "onboarding_badge_play": "Les maths, vraiment fun",
  "onboarding_body_play": "Défie des amis, rejoins des salles d'étude et\nenseigne-le pour le retenir.",
  "onboarding_title_rewards": "Gagne de vraies\nrécompenses",
  "onboarding_badge_rewards": "Des efforts qui paient",
  "onboarding_body_rewards": "Atteins tes objectifs et débloque de vraies\nrécompenses.",
  "onboarding_button_next": "Suivant",
  "onboarding_button_start": "C'est parti",
  "onboarding_button_back": "Retour",

  "chooseRole_title": "Qui êtes-vous ?",
  "chooseRole_subtitle": "Choisissez votre rôle pour commencer",
  "chooseRole_role_student": "Élève",
  "chooseRole_role_parent": "Parent"
```

Append to `app_ar.arb`:
```json
  "splash_tagline": "الرياضيات، بكل بساطة...",

  "onboarding_title_snapIt": "التقط.\nافهم.",
  "onboarding_badge_snapIt": "بدون كتابة. بدون ضغط.",
  "onboarding_body_snapIt": "صوّر واجبك أو درسك و\nسيقرأه Nmimes في ثوانٍ.",
  "onboarding_title_understand": "افهم،\nلا تنسخ فقط",
  "onboarding_badge_understand": "مصمم ليُرسّخ الفهم",
  "onboarding_body_understand": "شروحات بصرية واضحة تعلّمك\nالسبب، لا مجرد الإجابة.",
  "onboarding_title_play": "العب بطريقتك\nحتى الإتقان",
  "onboarding_badge_play": "الرياضيات، بشكل ممتع فعلاً",
  "onboarding_body_play": "تحدَّ أصدقاءك، انضم لغرف الدراسة،\nوعلّم ما تعلمته لترسّخه.",
  "onboarding_title_rewards": "اكسب جوائز\nحقيقية",
  "onboarding_badge_rewards": "مجهودك له ثمن",
  "onboarding_body_rewards": "حقق أهدافك وافتح مكافآت\nحقيقية.",
  "onboarding_button_next": "التالي",
  "onboarding_button_start": "هيا نبدأ",
  "onboarding_button_back": "رجوع",

  "chooseRole_title": "من أنت؟",
  "chooseRole_subtitle": "اختر دورك للبدء",
  "chooseRole_role_student": "طالب",
  "chooseRole_role_parent": "ولي أمر"
```

- [ ] **Step 2: Run flutter gen-l10n**

```powershell
flutter gen-l10n
```

Expected: No errors.

- [ ] **Step 3: Update splash_screen.dart**

Add import:
```dart
import '../../l10n/l10n_extension.dart';
import '../../theme/text_styles.dart';
```

In `_buildLogo()`, replace the tagline `Text` widget's hardcoded string and style:
```dart
// Before:
Text(
  'Math, made Simple...',
  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textHint),
),
// After:
Builder(
  builder: (ctx) => Text(
    ctx.l10n.splash_tagline,
    style: AppTextStyles.font(ctx, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textHint),
  ),
),
```

- [ ] **Step 4: Update onboarding_screen.dart**

Add imports:
```dart
import '../../l10n/l10n_extension.dart';
import '../../theme/text_styles.dart';
```

Replace the static `_pages` const list with a function that takes `BuildContext`:

```dart
List<_OnboardingData> _buildPages(BuildContext context) => [
  _OnboardingData(
    image: 'assets/images/onboarding_snap.png',
    title: context.l10n.onboarding_title_snapIt,
    badge: context.l10n.onboarding_badge_snapIt,
    body: context.l10n.onboarding_body_snapIt,
  ),
  _OnboardingData(
    image: 'assets/images/onboarding_understand.png',
    title: context.l10n.onboarding_title_understand,
    badge: context.l10n.onboarding_badge_understand,
    body: context.l10n.onboarding_body_understand,
  ),
  _OnboardingData(
    image: 'assets/images/onboarding_play.png',
    title: context.l10n.onboarding_title_play,
    badge: context.l10n.onboarding_badge_play,
    body: context.l10n.onboarding_body_play,
  ),
  _OnboardingData(
    image: 'assets/images/onboarding_rewards.png',
    title: context.l10n.onboarding_title_rewards,
    badge: context.l10n.onboarding_badge_rewards,
    body: context.l10n.onboarding_body_rewards,
  ),
];
```

In `_OnboardingScreenState.build`, replace `_pages` with `_buildPages(context)`.

In `_OnboardingPage.build`, replace all `GoogleFonts.poppins(...)` with `AppTextStyles.font(context, ...)` with matching params, and replace the button label strings:
- `'Next'` → `context.l10n.onboarding_button_next`  
- `"Let's Start"` → `context.l10n.onboarding_button_start`  
- `'Back'` → `context.l10n.onboarding_button_back`

- [ ] **Step 5: Update choose_role_screen.dart**

Read the file first, then add imports and replace all string literals using the keys above. Replace `GoogleFonts.poppins(...)` with `AppTextStyles.font(context, ...)`.

- [ ] **Step 6: Hot-reload and verify all three locales**

Switch language to FR and AR from the home pill (you'll need to navigate past onboarding once in EN, change locale, then re-launch or navigate back). Confirm text changes language and Arabic renders with Cairo font.

- [ ] **Step 7: Commit**

```powershell
git add lib/l10n/ lib/screens/splash/ lib/screens/onboarding/
git commit -m "feat: localize splash, onboarding, choose-role screens"
```

---

### Task 9: Auth screens — child flow

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_ar.arb`
- Modify: `lib/screens/auth/child_sign_in_screen.dart`
- Modify: `lib/screens/auth/child_access_code_screen.dart`
- Modify: `lib/screens/auth/child_sign_in_success_screen.dart`
- Modify: `lib/screens/auth/child_grades_screen.dart`

**Interfaces:**
- Consumes: `context.l10n`, `AppTextStyles.font(context, ...)`.

- [ ] **Step 1: Add strings to ARB files**

Append to each ARB file:

`app_en.arb`:
```json
  "childSignIn_title": "SIGN IN",
  "childSignIn_subtitle": "Please enter your username",
  "childSignIn_hint_username": "Enter your username",
  "childSignIn_button_continue": "Continue",

  "childAccessCode_title": "SIGN IN",
  "childAccessCode_subtitle": "Please enter your 4-digit access code",

  "childSuccess_title": "Welcome back!",
  "childSuccess_subtitle": "You're all set",
  "childSuccess_button_continue": "Continue",

  "childGrades_title": "What grade are you in?",
  "childGrades_subtitle": "Select your grade",
  "childGrades_button_continue": "Continue"
```

`app_fr.arb`:
```json
  "childSignIn_title": "CONNEXION",
  "childSignIn_subtitle": "Veuillez entrer votre nom d'utilisateur",
  "childSignIn_hint_username": "Entrez votre nom d'utilisateur",
  "childSignIn_button_continue": "Continuer",

  "childAccessCode_title": "CONNEXION",
  "childAccessCode_subtitle": "Veuillez entrer votre code d'accès à 4 chiffres",

  "childSuccess_title": "Bon retour !",
  "childSuccess_subtitle": "Tout est prêt",
  "childSuccess_button_continue": "Continuer",

  "childGrades_title": "En quelle classe êtes-vous ?",
  "childGrades_subtitle": "Sélectionnez votre classe",
  "childGrades_button_continue": "Continuer"
```

`app_ar.arb`:
```json
  "childSignIn_title": "تسجيل الدخول",
  "childSignIn_subtitle": "أدخل اسم المستخدم الخاص بك",
  "childSignIn_hint_username": "اسم المستخدم",
  "childSignIn_button_continue": "متابعة",

  "childAccessCode_title": "تسجيل الدخول",
  "childAccessCode_subtitle": "أدخل رمز الدخول المكوّن من 4 أرقام",

  "childSuccess_title": "مرحباً بعودتك!",
  "childSuccess_subtitle": "كل شيء جاهز",
  "childSuccess_button_continue": "متابعة",

  "childGrades_title": "في أي صف أنت؟",
  "childGrades_subtitle": "اختر صفك الدراسي",
  "childGrades_button_continue": "متابعة"
```

- [ ] **Step 2: Run flutter gen-l10n**

```powershell
flutter gen-l10n
```

- [ ] **Step 3: Update child_sign_in_screen.dart**

Add imports:
```dart
import '../../l10n/l10n_extension.dart';
import '../../theme/text_styles.dart';
```

Replace:
- `'SIGN IN'` → `context.l10n.childSignIn_title`
- `'Please enter your username'` → `context.l10n.childSignIn_subtitle`
- `hintText: 'Enter your username'` → `hintText: context.l10n.childSignIn_hint_username`
- `'Continue'` → `context.l10n.childSignIn_button_continue`
- All `GoogleFonts.poppins(...)` → `AppTextStyles.font(context, ...)`

- [ ] **Step 4: Update child_access_code_screen.dart**

Same pattern — replace strings and font calls per keys above.

- [ ] **Step 5: Read and update child_sign_in_success_screen.dart and child_grades_screen.dart**

Read each file, then replace strings and font calls using their respective ARB keys.

- [ ] **Step 6: Commit**

```powershell
git add lib/l10n/ lib/screens/auth/child_sign_in_screen.dart lib/screens/auth/child_access_code_screen.dart lib/screens/auth/child_sign_in_success_screen.dart lib/screens/auth/child_grades_screen.dart
git commit -m "feat: localize child auth screens"
```

---

### Task 10: Auth screens — parent flow

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_ar.arb`
- Modify: `lib/screens/auth/parent_sign_in_screen.dart`
- Modify: `lib/screens/auth/parent_sign_up_screen.dart`
- Modify: `lib/screens/auth/parent_access_code_screen.dart`
- Modify: `lib/screens/auth/parent_forgot_access_code_screen.dart`
- Modify: `lib/screens/auth/parent_reset_access_code_screen.dart`
- Modify: `lib/screens/auth/parent_otp_screen.dart`
- Modify: `lib/screens/auth/parent_profile_setup_screen.dart`
- Modify: `lib/screens/auth/parent_grades_screen.dart`
- Modify: `lib/screens/auth/account_created_screen.dart`

**Interfaces:**
- Consumes: `context.l10n`, `AppTextStyles.font(context, ...)`.

- [ ] **Step 1: Read all parent auth screen files**

Read each file to extract all string literals before writing ARB entries.

- [ ] **Step 2: Add strings to all three ARB files**

Use the naming prefix `parentSignIn_`, `parentSignUp_`, `parentAccessCode_`, `parentForgotCode_`, `parentResetCode_`, `parentOtp_`, `parentSetup_`, `parentGrades_`, `accountCreated_`.

For each screen, add the extracted English string as the EN value, provide French and Arabic translations.

Example pattern for `app_en.arb`:
```json
  "parentSignIn_title": "SIGN IN",
  "parentSignIn_subtitle": "Welcome back, Parent",
  "parentSignIn_hint_phone": "Phone number",
  "parentSignIn_button_continue": "Continue",
  "parentSignIn_link_signUp": "Don't have an account? Sign up"
```
(Adjust keys and values to match what's actually in each file after reading.)

- [ ] **Step 3: Run flutter gen-l10n**

```powershell
flutter gen-l10n
```

- [ ] **Step 4: Update each parent auth screen**

For each file: add imports, replace string literals with `context.l10n.<key>`, replace `GoogleFonts.poppins(...)` with `AppTextStyles.font(context, ...)`, replace any `EdgeInsets.only(left/right)` with `EdgeInsetsDirectional.only(start/end)`.

- [ ] **Step 5: Commit**

```powershell
git add lib/l10n/ lib/screens/auth/
git commit -m "feat: localize parent auth screens"
```

---

### Task 11: Home screen strings

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_ar.arb`
- Modify: `lib/screens/home/home_screen.dart`

**Interfaces:**
- Consumes: `context.l10n`, `AppTextStyles.font(context, ...)`.
- Note: `home_greeting` uses a `{name}` placeholder.

- [ ] **Step 1: Add strings to ARB files**

`app_en.arb`:
```json
  "home_greeting": "Hi, {name}",
  "@home_greeting": {
    "placeholders": { "name": { "type": "String" } }
  },
  "home_label_yourPoints": "Your Points",
  "home_button_rewards": "Rewards",
  "home_card_snapHomework_title": "Snap a Homework",
  "home_card_snapHomework_subtitle": "Practice & solve!",
  "home_card_snapLesson_title": "Snap a Lesson",
  "home_card_snapLesson_subtitle": "Understand first!",
  "home_label_studyRooms": "Study Rooms",
  "home_row_peerLearning_title": "Peer Learning",
  "home_row_peerLearning_subtitle": "Team up and solve together",
  "home_row_savedFormulas_title": "Saved Formulas"
```

`app_fr.arb`:
```json
  "home_greeting": "Salut, {name}",
  "@home_greeting": {
    "placeholders": { "name": { "type": "String" } }
  },
  "home_label_yourPoints": "Vos points",
  "home_button_rewards": "Récompenses",
  "home_card_snapHomework_title": "Photographier un devoir",
  "home_card_snapHomework_subtitle": "Pratiquez et résolvez !",
  "home_card_snapLesson_title": "Photographier une leçon",
  "home_card_snapLesson_subtitle": "Comprenez d'abord !",
  "home_label_studyRooms": "Salles d'étude",
  "home_row_peerLearning_title": "Apprentissage entre pairs",
  "home_row_peerLearning_subtitle": "Faites équipe et résolvez ensemble",
  "home_row_savedFormulas_title": "Formules sauvegardées"
```

`app_ar.arb`:
```json
  "home_greeting": "مرحباً، {name}",
  "@home_greeting": {
    "placeholders": { "name": { "type": "String" } }
  },
  "home_label_yourPoints": "نقاطك",
  "home_button_rewards": "المكافآت",
  "home_card_snapHomework_title": "التقط واجباً",
  "home_card_snapHomework_subtitle": "تدرَّب وحلَّ!",
  "home_card_snapLesson_title": "التقط درساً",
  "home_card_snapLesson_subtitle": "افهم أولاً!",
  "home_label_studyRooms": "غرف الدراسة",
  "home_row_peerLearning_title": "التعلم المشترك",
  "home_row_peerLearning_subtitle": "تعاون وحل معاً",
  "home_row_savedFormulas_title": "الصيغ المحفوظة"
```

- [ ] **Step 2: Run flutter gen-l10n**

```powershell
flutter gen-l10n
```

- [ ] **Step 3: Update home_screen.dart**

Replace `'Hi, '` / `'John Deo'` RichText with:
```dart
Text(
  context.l10n.home_greeting('John Deo'),
  style: AppTextStyles.font(context, fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white),
),
```

Replace all other hardcoded strings with `context.l10n.<key>`. Replace `GoogleFonts.poppins(...)` with `AppTextStyles.font(context, ...)`.

- [ ] **Step 4: Commit**

```powershell
git add lib/l10n/ lib/screens/home/home_screen.dart
git commit -m "feat: localize home screen"
```

---

### Task 12: Profile, bottom nav, and shell screens

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_ar.arb`
- Modify: `lib/screens/profile/profile_screen.dart`
- Modify: `lib/screens/profile/help_screen.dart`
- Modify: `lib/screens/profile/avatar_screen.dart`
- Modify: `lib/screens/profile/log_out_screen.dart`
- Modify: `lib/screens/profile/points_card.dart`
- Modify: `lib/widgets/bottom_nav_bar.dart`

**Interfaces:**
- Consumes: `context.l10n`, `AppTextStyles.font(context, ...)`.

- [ ] **Step 1: Read all files in this task**

Read each file to know the exact strings before writing ARB entries.

- [ ] **Step 2: Add strings to ARB files**

Use prefixes: `profile_`, `help_`, `avatar_`, `logOut_`, `pointsCard_`, `nav_`.

Example `app_en.arb` entries:
```json
  "profile_title": "Profile",
  "profile_button_help": "Help",
  "profile_button_logOut": "Log Out",
  "nav_home": "Home",
  "nav_aiChat": "AI Chat",
  "nav_challenges": "Challenges",
  "nav_profile": "Profile",
  "logOut_title": "Log Out",
  "logOut_body": "Are you sure you want to log out?",
  "logOut_button_confirm": "Log Out",
  "logOut_button_cancel": "Cancel"
```
(Add all strings found in each file.)

Add French and Arabic equivalents for each key.

- [ ] **Step 3: Run flutter gen-l10n**

```powershell
flutter gen-l10n
```

- [ ] **Step 4: Update each file**

Replace all string literals and `GoogleFonts.poppins(...)` calls in each file.

- [ ] **Step 5: Commit**

```powershell
git add lib/l10n/ lib/screens/profile/ lib/widgets/bottom_nav_bar.dart
git commit -m "feat: localize profile screens and bottom nav"
```

---

### Task 13: Parent portal screens

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_ar.arb`
- Modify: `lib/screens/parents/parents_view_screen.dart`
- Modify: `lib/screens/parents/children_screen.dart`
- Modify: `lib/screens/parents/edit_child_profile_screen.dart`
- Modify: `lib/screens/parents/settings_screen.dart`
- Modify: `lib/screens/parents/subscription_screen.dart`
- Modify: `lib/screens/parents/payment_screen.dart`
- Modify: `lib/screens/parents/payment_success_screen.dart`
- Modify: `lib/screens/parents/terms_screen.dart`
- Modify: `lib/screens/parents/privacy_screen.dart`
- Modify: `lib/screens/parents/log_out_screen.dart`

**Interfaces:**
- Consumes: `context.l10n`, `AppTextStyles.font(context, ...)`.

- [ ] **Step 1: Read all files**

Read each parent screen file to extract strings.

- [ ] **Step 2: Add strings to ARB files**

Prefixes: `parentsView_`, `children_`, `editChild_`, `settings_`, `subscription_`, `payment_`, `paymentSuccess_`, `terms_`, `privacy_`, `parentLogOut_`.

`app_en.arb` example entries:
```json
  "settings_title": "Settings",
  "settings_label_subscription": "Subscription",
  "settings_label_notifications": "Notifications",
  "settings_label_language": "Language",
  "settings_label_terms": "Terms & Conditions",
  "settings_label_privacy": "Privacy Policy",
  "settings_label_logOut": "Log Out"
```
(Adjust based on actual file content after reading.)

- [ ] **Step 3: Run flutter gen-l10n**

```powershell
flutter gen-l10n
```

- [ ] **Step 4: Update each file**

Replace strings and font calls in each file.

- [ ] **Step 5: Commit**

```powershell
git add lib/l10n/ lib/screens/parents/
git commit -m "feat: localize parent portal screens"
```

---

### Task 14: Snap screens

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_ar.arb`
- Modify: `lib/screens/snap/snap_homework_screen.dart`
- Modify: `lib/screens/snap/snap_homework_camera_screen.dart`
- Modify: `lib/screens/snap/snap_lesson_screen.dart`
- Modify: `lib/screens/snap/snap_captured_screen.dart`
- Modify: `lib/screens/snap/snap_send_screen.dart`
- Modify: `lib/screens/snap/snap_explain_screen.dart`
- Modify: `lib/screens/snap/snap_success_screen.dart`
- Modify: `lib/screens/snap/snap_hw_captured_screen.dart`
- Modify: `lib/screens/snap/snap_hw_send_screen.dart`
- Modify: `lib/screens/snap/snap_hw_success_screen.dart`
- Modify: `lib/screens/snap/snap_hw_explain_screen.dart`
- Modify: `lib/screens/snap/does_this_make_sense_screen.dart`
- Modify: `lib/screens/snap/snap_widgets.dart`

**Interfaces:**
- Consumes: `context.l10n`, `AppTextStyles.font(context, ...)`.

- [ ] **Step 1: Read all snap screen files**

- [ ] **Step 2: Add strings with prefix `snap_` to all three ARB files**

- [ ] **Step 3: Run flutter gen-l10n**

```powershell
flutter gen-l10n
```

- [ ] **Step 4: Update all snap screen files**

- [ ] **Step 5: Commit**

```powershell
git add lib/l10n/ lib/screens/snap/
git commit -m "feat: localize snap screens"
```

---

### Task 15: Challenges screens

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_ar.arb`
- Modify: all files in `lib/screens/challenges/`

**Interfaces:**
- Consumes: `context.l10n`, `AppTextStyles.font(context, ...)`.

- [ ] **Step 1: Read all challenge screen files**

- [ ] **Step 2: Add strings with prefix `challenge_`, `maze_`, `algebra_`, `pvp_` to ARB files**

- [ ] **Step 3: Run flutter gen-l10n**

```powershell
flutter gen-l10n
```

- [ ] **Step 4: Update all challenge screen files**

- [ ] **Step 5: Commit**

```powershell
git add lib/l10n/ lib/screens/challenges/
git commit -m "feat: localize challenge screens"
```

---

### Task 16: Study room screens

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_ar.arb`
- Modify: all files in `lib/screens/study_room/`

- [ ] **Step 1: Read all study room screen files**

- [ ] **Step 2: Add strings with prefix `studyRoom_` to ARB files**

- [ ] **Step 3: Run flutter gen-l10n**

```powershell
flutter gen-l10n
```

- [ ] **Step 4: Update all study room screen files**

- [ ] **Step 5: Commit**

```powershell
git add lib/l10n/ lib/screens/study_room/
git commit -m "feat: localize study room screens"
```

---

### Task 17: Remaining screens and widgets

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_ar.arb`
- Modify: `lib/screens/rewards/` (all files)
- Modify: `lib/screens/ai_chat/` (all files)
- Modify: `lib/screens/teach_it_back/` (all files)
- Modify: `lib/widgets/` (any widgets with user-visible strings: `app_text_field.dart`, `chat_bubble.dart`, `reward_card.dart`, `challenge_card.dart`, `role_card.dart`, `home_action_button.dart`, `study_room_card.dart`, `primary_button.dart`, `secondary_button.dart`)

- [ ] **Step 1: Read all remaining files with user-visible strings**

- [ ] **Step 2: Add strings with prefixes `rewards_`, `aiChat_`, `teachItBack_` and widget-level prefixes to ARB files**

- [ ] **Step 3: Run flutter gen-l10n**

```powershell
flutter gen-l10n
```

- [ ] **Step 4: Update all remaining files**

- [ ] **Step 5: Commit**

```powershell
git add lib/l10n/ lib/screens/rewards/ lib/screens/ai_chat/ lib/screens/teach_it_back/ lib/widgets/
git commit -m "feat: localize rewards, AI chat, teach-it-back screens and widgets"
```

---

### Task 18: Final RTL audit and EdgeInsetsDirectional sweep

**Files:**
- Modify: Any file using `EdgeInsets.only(left/right)` or `TextAlign.left/right`

**Interfaces:**
- Consumes: All previously modified files.

- [ ] **Step 1: Find all remaining hardcoded directional insets**

```powershell
grep -rn "EdgeInsets.only" lib/screens/ lib/widgets/
grep -rn "TextAlign.left\|TextAlign.right" lib/screens/ lib/widgets/
```

- [ ] **Step 2: Replace each occurrence**

- `EdgeInsets.only(left: x)` → `EdgeInsetsDirectional.only(start: x)`
- `EdgeInsets.only(right: x)` → `EdgeInsetsDirectional.only(end: x)`
- `EdgeInsets.only(left: x, right: y)` → `EdgeInsetsDirectional.only(start: x, end: y)`
- `TextAlign.left` → `TextAlign.start`
- `TextAlign.right` → `TextAlign.end`

- [ ] **Step 3: Switch app to Arabic, do a full screen-by-screen walkthrough**

Navigate every main screen. Confirm layouts mirror correctly (back arrows point right, text aligns right, lists flow RTL). Note any visual issues.

- [ ] **Step 4: Fix any visual issues found**

- [ ] **Step 5: Commit**

```powershell
git add -p
git commit -m "fix: replace directional EdgeInsets and TextAlign for RTL correctness"
```

---

### Task 19: Save memory and final smoke test

**Files:**
- No code changes.

- [ ] **Step 1: Full locale smoke test — English**

Launch app fresh (clear app data or reinstall). Confirm:
- Splash shows "Math, made Simple..."
- Onboarding text is English, Poppins font.
- Language pill shows 🇬🇧 ENG.
- All main screens readable.

- [ ] **Step 2: Full locale smoke test — French**

Switch to FR via home pill. Confirm:
- All text updates to French.
- Font stays Poppins.
- Restart app — FR is remembered.

- [ ] **Step 3: Full locale smoke test — Arabic**

Switch to AR. Confirm:
- All text updates to Arabic.
- Font is Cairo (visually distinct from Poppins).
- Layout is RTL (back arrow points right, text aligns right).
- Restart app — AR is remembered.

- [ ] **Step 4: Device locale fallback test**

Change device language to French, clear app data, launch. Confirm app starts in French without user selection.

- [ ] **Step 5: Final commit**

```powershell
git add .
git commit -m "feat: complete EN/FR/AR localization"
```
