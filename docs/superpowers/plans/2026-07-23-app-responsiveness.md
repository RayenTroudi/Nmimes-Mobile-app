# App Responsiveness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Nmimes app render correctly across phone and tablet sizes and clamped OS text scales, eliminating the current layout-overflow exceptions, by adding a breakpoint-based responsive foundation and converting the highest-traffic screens.

**Architecture:** A `BuildContext` extension (`context.rs()`, `context.isTablet`, `context.wp()`) provides breakpoint-based sizing as a pure function of `MediaQuery`. `MaterialApp.builder` clamps the OS text scaler to a safe range. High-traffic screens and their shared widgets adopt the helpers; the rest keep working with fixed sizes and adopt incrementally.

**Tech Stack:** Flutter/Dart, `flutter_test` (widget tests), `flutter analyze`.

## Global Constraints

- Package name is `nmimes` (imports use `package:nmimes/...`).
- Breakpoints from `MediaQuery.size.shortestSide`: `>= 600` = tablet, `< 600` = phone, `< 360` = small phone.
- OS text scale is clamped to `minScaleFactor: 0.9, maxScaleFactor: 1.3`.
- `rs()` treats its argument as a tablet-reference size; the scale ratio is clamped so phones scale down (~0.85×) and large tablets do not over-scale (cap ~1.15×).
- Follow existing patterns: theme tokens live in `lib/theme/`, the localization idiom is `context.l10n`. Match the existing overflow-test harness in `test/overflow_test.dart` / `test/overflow_audit_test.dart`.
- Verify each screen task with `flutter analyze` (must report no issues) and the overflow widget test.
- End commit messages with `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

---

### Task 1: Responsive `BuildContext` extension

**Files:**
- Create: `lib/theme/responsive.dart`
- Test: `test/responsive_test.dart`

**Interfaces:**
- Consumes: nothing (pure `MediaQuery`).
- Produces:
  - `extension Responsive on BuildContext`
  - `bool get isTablet` — `MediaQuery.of(this).size.shortestSide >= 600`
  - `bool get isSmallPhone` — `shortestSide < 360`
  - `double rs(double size)` — scaled size; ratio clamped to `[0.82, 1.15]`, reference shortest side `600`
  - `double wp(double fraction)` — `MediaQuery.of(this).size.width * fraction`
  - `double hp(double fraction)` — `MediaQuery.of(this).size.height * fraction`
  - `double get gutter` — `rs(24)` (standard edge padding)

- [ ] **Step 1: Write the failing test**

```dart
// test/responsive_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmimes/theme/responsive.dart';

/// Pumps a widget under a MediaQuery of the given size and hands the
/// captured BuildContext to [body] for assertions.
Future<void> _withSize(
  WidgetTester tester,
  Size size,
  void Function(BuildContext context) body,
) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: Builder(
        builder: (context) {
          body(context);
          return const SizedBox();
        },
      ),
    ),
  );
}

void main() {
  testWidgets('isTablet true at >=600 shortest side', (tester) async {
    await _withSize(tester, const Size(800, 1200), (c) {
      expect(c.isTablet, isTrue);
    });
    await _withSize(tester, const Size(1200, 800), (c) {
      expect(c.isTablet, isTrue); // landscape tablet, shortest side 800
    });
  });

  testWidgets('phone is not a tablet; small phone flagged', (tester) async {
    await _withSize(tester, const Size(390, 844), (c) {
      expect(c.isTablet, isFalse);
      expect(c.isSmallPhone, isFalse);
    });
    await _withSize(tester, const Size(320, 568), (c) {
      expect(c.isSmallPhone, isTrue);
    });
  });

  testWidgets('rs scales down on phones, ~1.0 on tablet, capped on huge',
      (tester) async {
    await _withSize(tester, const Size(600, 900), (c) {
      // At the reference shortest side (600) the ratio is 1.0.
      expect(c.rs(100), closeTo(100, 0.001));
    });
    await _withSize(tester, const Size(360, 640), (c) {
      // Phone scales down but never below the 0.82 floor.
      final v = c.rs(100);
      expect(v, lessThan(100));
      expect(v, greaterThanOrEqualTo(82));
    });
    await _withSize(tester, const Size(2000, 2600), (c) {
      // Huge tablet is capped at the 1.15 ceiling.
      expect(c.rs(100), closeTo(115, 0.001));
    });
  });

  testWidgets('wp and hp are fractions of size', (tester) async {
    await _withSize(tester, const Size(400, 800), (c) {
      expect(c.wp(0.5), closeTo(200, 0.001));
      expect(c.hp(0.25), closeTo(200, 0.001));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/responsive_test.dart`
Expected: FAIL — `responsive.dart` does not exist / `isTablet` undefined.

- [ ] **Step 3: Write the extension**

```dart
// lib/theme/responsive.dart
import 'package:flutter/widgets.dart';

/// Breakpoint-based responsive sizing, exposed on [BuildContext] to match the
/// existing `context.l10n` idiom. All values derive from [MediaQuery], so they
/// track rotation and split-screen automatically.
///
/// The app is tablet-first: `rs()` treats its argument as a size measured on
/// the reference tablet (shortest side 600). Phones scale it down; very large
/// tablets are capped so nothing balloons.
extension Responsive on BuildContext {
  Size get _size => MediaQuery.of(this).size;

  /// Shortest side is stable across rotation, so device class doesn't flip
  /// when a tablet is turned landscape.
  double get _shortest => _size.shortestSide;

  bool get isTablet => _shortest >= 600;
  bool get isSmallPhone => _shortest < 360;

  /// The clamped scale ratio applied by [rs].
  double get _scale => (_shortest / 600).clamp(0.82, 1.15);

  /// Scale a tablet-reference size to the current device class.
  double rs(double size) => size * _scale;

  /// Fraction of the screen width (e.g. `wp(0.30)` = 30% of width).
  double wp(double fraction) => _size.width * fraction;

  /// Fraction of the screen height.
  double hp(double fraction) => _size.height * fraction;

  /// Standard screen edge padding for the current device class.
  double get gutter => rs(24);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/responsive_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/theme/responsive.dart test/responsive_test.dart
git commit -m "Add breakpoint-based responsive BuildContext extension"
```

---

### Task 2: Clamp OS text scaling in `MaterialApp`

**Files:**
- Modify: `lib/main.dart` (the `MaterialApp(...)` in `_NmimesAppState.build`, around lines 134-141 where `theme`/`locale` are set — add a `builder`)
- Test: `test/text_scale_clamp_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: within any screen under the app, `MediaQuery.of(context).textScaler` is clamped to `[0.9, 1.3]`.

- [ ] **Step 1: Write the failing test**

```dart
// test/text_scale_clamp_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reproduces the exact builder the app installs, so the clamp behavior is
/// verified independently of the full app bootstrap (which needs Supabase).
Widget clampBuilder(BuildContext context, Widget? child) {
  final mq = MediaQuery.of(context);
  final clamped = mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3);
  return MediaQuery(data: mq.copyWith(textScaler: clamped), child: child!);
}

void main() {
  testWidgets('clamps an oversized OS text scale to 1.3', (tester) async {
    double? seen;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: MaterialApp(
          builder: clampBuilder,
          home: Builder(
            builder: (context) {
              seen = MediaQuery.of(context).textScaler.scale(10) / 10;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(seen, closeTo(1.3, 0.001));
  });

  testWidgets('raises a tiny OS text scale to the 0.9 floor', (tester) async {
    double? seen;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(0.5)),
        child: MaterialApp(
          builder: clampBuilder,
          home: Builder(
            builder: (context) {
              seen = MediaQuery.of(context).textScaler.scale(10) / 10;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(seen, closeTo(0.9, 0.001));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/text_scale_clamp_test.dart`
Expected: PASS actually — this test validates the builder shape in isolation and does not import app code yet. If it passes, that is fine: it locks the contract. Proceed to wire the same builder into the real app in Step 3, then the app-level assertion in Step 4 is the real gate.

Note: this task's "failing" gate is the app-level test in Step 4a below, not this isolated one. Keep both.

- [ ] **Step 3: Wire the builder into `MaterialApp`**

In `lib/main.dart`, inside the `MaterialApp(...)` constructor (alongside `theme:`, `locale:`, `initialRoute:`), add:

```dart
          builder: (context, child) {
            // Respect the user's OS text-size setting but clamp it so no
            // layout can be broken by an extreme accessibility scale — this
            // is the direct cause of the fixed-height button overflow.
            final mq = MediaQuery.of(context);
            final clamped =
                mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3);
            return MediaQuery(
              data: mq.copyWith(textScaler: clamped),
              child: child!,
            );
          },
```

- [ ] **Step 4: Verify analyze is clean and tests pass**

Run: `flutter analyze lib/main.dart`
Expected: `No issues found!`

Run: `flutter test test/text_scale_clamp_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart test/text_scale_clamp_test.dart
git commit -m "Clamp OS text scaling to [0.9, 1.3] app-wide"
```

---

### Task 3: Extend the overflow test harness to tablet sizes

**Files:**
- Modify: `test/overflow_audit_test.dart` (the `_cases` map, lines 60-64; and the sign-in screens are added to `_screens`)

**Interfaces:**
- Consumes: existing `_wrap`, `_screens`, `_cases` harness.
- Produces: the audit now also runs at a tablet size and includes the sign-in screens, so later screen tasks are regression-guarded here.

- [ ] **Step 1: Add tablet cases and sign-in screens (this is the failing gate)**

In `test/overflow_audit_test.dart`, add imports near the other screen imports:

```dart
import 'package:nmimes/screens/auth/child_sign_in_screen.dart';
import 'package:nmimes/screens/auth/parent_sign_in_screen.dart';
```

Add to the `_screens` map:

```dart
  'child_sign_in': () => const ChildSignInScreen(),
  'parent_sign_in': () => const ParentSignInScreen(),
```

Replace the `_cases` map with:

```dart
// A small phone, a normal phone at a large accessibility font scale, a
// 7" tablet, and a 10" tablet. Covers the range the app must fit.
const _cases = <String, (Size, double)>{
  'small@1.0': (Size(320, 568), 1.0),
  'normal@1.3': (Size(390, 844), 1.3),
  'tablet7@1.0': (Size(600, 960), 1.0),
  'tablet10@1.2': (Size(800, 1280), 1.2),
};
```

- [ ] **Step 2: Run the audit to see the current state**

Run: `flutter test test/overflow_audit_test.dart`
Expected: The pre-existing sign-in overflow (`h=58` button) surfaces as a FAIL on `child_sign_in` / `parent_sign_in` at one or more cases. Record which cases fail. (If they happen to pass because Task 2's clamp already fixed the text-scale path, that is acceptable — Task 4 still makes the buttons flexible.)

- [ ] **Step 3: Commit the expanded harness**

```bash
git add test/overflow_audit_test.dart
git commit -m "Expand overflow audit to tablet sizes and sign-in screens"
```

---

### Task 4: Make chunky/primary buttons and text fields overflow-proof

**Files:**
- Read first: `lib/widgets/chunky_button.dart` (parent of `PrimaryButton`; find how height is set)
- Modify: `lib/widgets/chunky_button.dart` and/or `lib/widgets/primary_button.dart`
- Modify: `lib/widgets/app_text_field.dart`
- Test: `test/overflow_audit_test.dart` (already covers via Task 3)

**Interfaces:**
- Consumes: `context.rs()` from Task 1.
- Produces: buttons whose height is a *minimum* (via `minHeight`/`ConstrainedBox`) rather than a fixed value, so a scaled label grows the button instead of clipping.

- [ ] **Step 1: Read the button internals**

Run: open `lib/widgets/chunky_button.dart`. Identify the fixed height (likely `AppSizes.buttonHeight` = 54 or a literal). This is what clips.

- [ ] **Step 2: Convert fixed height to a min-height constraint**

Wherever the button sets a fixed `height:` around its label, replace it with a minimum-height constraint and vertical centering. Concretely, if the label sits in a `SizedBox(height: h)` or `Container(height: h)`, change to:

```dart
ConstrainedBox(
  constraints: BoxConstraints(minHeight: context.rs(AppSizes.buttonHeight)),
  child: Center(child: /* existing label widget */),
)
```

Add `import '../theme/responsive.dart';` to the file. Ensure the label `Text` has `textAlign: TextAlign.center` and no bottom-only padding.

- [ ] **Step 3: Make the sign-in Continue buttons flexible**

In `lib/screens/auth/child_sign_in_screen.dart` and `lib/screens/auth/parent_sign_in_screen.dart`, the Continue buttons use `SizedBox(height: 58, child: ElevatedButton(...))`. Replace the fixed height with a min-height so the label can grow:

```dart
ConstrainedBox(
  constraints: BoxConstraints(minHeight: context.rs(58)),
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      // ...existing style/child unchanged, but ensure the style has no
      // fixed height and the label is centered...
    ),
  ),
)
```

Add `import '../../theme/responsive.dart';` to each screen. (Full conversion of these two screens is Task 5; this step is only the button fix so the audit can go green.)

- [ ] **Step 4: Run the overflow audit**

Run: `flutter test test/overflow_audit_test.dart`
Expected: PASS for all screens including `child_sign_in` and `parent_sign_in` at all four cases.

Run: `flutter analyze lib/widgets/chunky_button.dart lib/widgets/primary_button.dart lib/widgets/app_text_field.dart lib/screens/auth/child_sign_in_screen.dart lib/screens/auth/parent_sign_in_screen.dart`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/ lib/screens/auth/child_sign_in_screen.dart lib/screens/auth/parent_sign_in_screen.dart
git commit -m "Make buttons grow instead of clipping under text scaling"
```

---

### Task 5: Convert the two sign-in screens to responsive sizing

**Files:**
- Modify: `lib/screens/auth/child_sign_in_screen.dart`
- Modify: `lib/screens/auth/parent_sign_in_screen.dart`
- Test: `test/overflow_audit_test.dart`

**Interfaces:**
- Consumes: `context.rs()`, `context.isTablet`, `context.hp()`.
- Produces: sign-in screens whose header, mascot, paddings, radii, field heights, and font sizes scale by device class.

- [ ] **Step 1: Replace fixed pixel values with `rs()` / `hp()`**

In each screen, wrap literal sizes in the helpers. Guidance (apply the same pattern to both files):
- Header height: keep the keyboard-collapse logic, but express the two heights via `hp`: `keyboardInset > 0 ? context.hp(0.12) : context.hp(0.28)`.
- Mascot image: `width: context.rs(160), height: context.rs(160)` and `top: headerHeight - context.rs(110)`.
- Card top radius `32` → `context.rs(32)`.
- Field height (`58` / `52`) → `context.rs(58)` / `context.rs(52)`; field radius (`36` / `30`) → `context.rs(36)` / `context.rs(30)`.
- Title/subtitle/hint font sizes: wrap in `context.rs(...)` (e.g. `fontSize: context.rs(28)`).
- Scroll paddings: wrap the literals in `context.rs(...)`.
- On tablet, widen the card content: constrain the inner column with `ConstrainedBox(constraints: BoxConstraints(maxWidth: context.isTablet ? 520 : double.infinity))` centered, so the form doesn't stretch edge-to-edge on a big tablet.

- [ ] **Step 2: Run the audit and analyze**

Run: `flutter test test/overflow_audit_test.dart`
Expected: PASS at all four cases for both sign-in screens.

Run: `flutter analyze lib/screens/auth/child_sign_in_screen.dart lib/screens/auth/parent_sign_in_screen.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/screens/auth/child_sign_in_screen.dart lib/screens/auth/parent_sign_in_screen.dart
git commit -m "Scale sign-in screens by device class"
```

---

### Task 6: Convert splash and choose-role screens

**Files:**
- Modify: `lib/screens/splash/splash_screen.dart`
- Modify: `lib/screens/onboarding/choose_role_screen.dart`
- Test: `test/overflow_audit_test.dart` (choose_role already listed) + `test/responsive_test.dart` unaffected

**Interfaces:**
- Consumes: `context.rs()`, `context.isTablet`, `context.hp()`.
- Produces: splash eye/wordmark and choose-role header/cards scale by device class.

- [ ] **Step 1: Scale the splash**

In `lib/screens/splash/splash_screen.dart`:
- Eye badge `SizedBox(width: 104, height: 104)` → `context.rs(104)` for both.
- Wordmark `fontSize: 40` → `context.rs(40)`; tagline `fontSize: 15` → `context.rs(15)`.
- Dots `width/height: 12` → `context.rs(12)`; horizontal padding `5` → `context.rs(5)`; bounce offset `-10` → `-context.rs(10)`.
- Bottom `SizedBox(height: 48)` → `context.rs(48)`.
Add `import '../../theme/responsive.dart';`. Note `EyesPainter` reads its own `size` from the `SizedBox`, so scaling the box scales the eyes with no painter change.

- [ ] **Step 2: Scale choose-role**

In `lib/screens/onboarding/choose_role_screen.dart`:
- Header `SizedBox(height: screenHeight * 0.30)` → `context.hp(0.30)`.
- Card top radius `32` → `context.rs(32)`.
- Any role-card fixed sizes / font sizes → wrap in `context.rs(...)`.
- On tablet, center and cap the card column width: `maxWidth: context.isTablet ? 560 : double.infinity`.
Add `import '../../theme/responsive.dart';`.

- [ ] **Step 3: Run audit and analyze**

Run: `flutter test test/overflow_audit_test.dart`
Expected: PASS (choose_role at all four cases).

Run: `flutter analyze lib/screens/splash/splash_screen.dart lib/screens/onboarding/choose_role_screen.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/screens/splash/splash_screen.dart lib/screens/onboarding/choose_role_screen.dart
git commit -m "Scale splash and choose-role screens by device class"
```

---

### Task 7: Convert profile and AI-chat screens

**Files:**
- Read first: `lib/screens/profile/profile_screen.dart`, `lib/screens/ai_chat/ai_chat_screen.dart`
- Modify: both above
- Test: add both to `test/overflow_audit_test.dart` `_screens` (profile has an existing `test/profile_screen_test.dart` — keep it green)

**Interfaces:**
- Consumes: `context.rs()`, `context.isTablet`, `context.hp()`.
- Produces: profile pinned name/avatar and chat header/bubbles scale by device class.

- [ ] **Step 1: Read both screens to find fixed sizes**

Open both files. List every literal `fontSize:`, fixed `height:`/`width:`, `Positioned(top:)`, and radius. These are the conversion targets.

- [ ] **Step 2: Scale profile**

In `lib/screens/profile/profile_screen.dart`:
- Pinned name `fontSize: 28` → `context.rs(28)`; `nameBlockHeight = 48` → `context.rs(48)`.
- Avatar diameter and any fixed card heights → `context.rs(...)`.
- On tablet, cap content width: `maxWidth: context.isTablet ? 640 : double.infinity`, centered.
Add `import '../../theme/responsive.dart';`. Keep the pinned-name opaque `Container(color: AppColors.background)` behavior intact (it must stay non-scrolling).

- [ ] **Step 3: Scale AI-chat**

In `lib/screens/ai_chat/ai_chat_screen.dart`:
- Header icon sizes (`22`, `24`) → `context.rs(...)`.
- Message bubble max-width: if a fixed width, use `context.wp(0.72)` (phone) with a tablet cap, e.g. `min(context.wp(0.72), context.isTablet ? 560.0 : double.infinity)`.
- Input field height and font sizes → `context.rs(...)`.
Add `import '../../theme/responsive.dart';`. Preserve the RTL back-arrow logic added earlier.

- [ ] **Step 4: Add both to the audit and run all tests**

In `test/overflow_audit_test.dart`, import and add:

```dart
import 'package:nmimes/screens/profile/profile_screen.dart';
// ai_chat pulls in networking on build; only add if it renders under the
// bare harness. If it throws a non-layout error, leave it out of _screens
// and rely on flutter analyze for that file.
```

```dart
  'profile': () => const ProfileScreen(),
```

Run: `flutter test test/overflow_audit_test.dart test/profile_screen_test.dart`
Expected: PASS.

Run: `flutter analyze lib/screens/profile/profile_screen.dart lib/screens/ai_chat/ai_chat_screen.dart`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/screens/profile/profile_screen.dart lib/screens/ai_chat/ai_chat_screen.dart test/overflow_audit_test.dart
git commit -m "Scale profile and AI-chat screens by device class"
```

---

### Task 8: Convert shared nav/field widgets and final verification

**Files:**
- Modify: `lib/widgets/bottom_nav_bar.dart`
- Modify: `lib/widgets/secondary_button.dart` (mirror the chunky-button min-height fix if not already covered)
- Test: full suite

**Interfaces:**
- Consumes: `context.rs()`, `context.isTablet`.
- Produces: nav bar and secondary button that scale by device class.

- [ ] **Step 1: Scale the bottom nav bar**

In `lib/widgets/bottom_nav_bar.dart`, wrap fixed icon sizes, label font sizes, and bar height in `context.rs(...)`. On tablet, allow a taller bar and larger icons (they scale automatically via `rs`). Add `import '../theme/responsive.dart';`.

- [ ] **Step 2: Verify secondary button**

Confirm `lib/widgets/secondary_button.dart` routes through the same `chunky_button.dart` fixed by Task 4. If it sets its own fixed height, apply the same `minHeight` + `Center` fix from Task 4 Step 2.

- [ ] **Step 3: Run the FULL test suite**

Run: `flutter test`
Expected: ALL tests PASS (responsive, text-scale clamp, overflow, overflow-audit incl. tablet cases, profile, and the pre-existing suites).

Run: `flutter analyze`
Expected: `No issues found!` across the whole project.

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/bottom_nav_bar.dart lib/widgets/secondary_button.dart
git commit -m "Scale bottom nav and secondary button; final responsive verification"
```

---

## Notes for the implementer

- **Do not** try to convert all 129 screens. Only the files named in these tasks. The rest keep their fixed sizes and still work.
- `rs()` is the workhorse: any raw pixel literal in a converted file becomes `context.rs(<literal>)` unless it's a width/height fraction (use `wp`/`hp`) or a tablet-only cap (use `isTablet`).
- If `flutter test` reports a *non-layout* exception for a screen under the bare harness (commonly "Supabase not initialized" or a network call), that screen should be verified with `flutter analyze` only and left out of `_screens` — follow the precedent already documented in `overflow_audit_test.dart`.
- Keep every previously-shipped behavior (keyboard-collapsing headers, RTL back arrows, pinned non-scrolling profile name, splash blink) intact — this pass changes sizes, not behavior.
