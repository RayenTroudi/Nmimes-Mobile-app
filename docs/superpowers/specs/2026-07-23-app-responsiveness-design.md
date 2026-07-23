# App-wide Responsiveness — Foundation + Error Fixes

**Date:** 2026-07-23
**Status:** Approved

## Problem

The Nmimes Flutter app was built for a single tablet. Sizes are hardcoded in
pixels throughout (`fontSize: 28`, `height: 58`, `width: 160`,
`screenHeight * 0.28`). On other devices — different phone sizes, other
tablets, and when the OS text-size accessibility setting is raised — layouts
break. The visible symptom is a stream of layout-overflow exceptions such as:

```
constraints: BoxConstraints(w=272.0, h=58.0)
size: Size(272.0, 58.0)
padding: EdgeInsets(0.0, 0.0, 0.0, 4.0)
textDirection: ltr
```

This is a text label vertically overflowing a fixed 58px-high button (the
Continue button on the sign-in screens) once its scaled line height exceeds
the box. The button cannot grow, so it clips by ~4px and throws.

## Decisions

- **Scope:** Build a responsive foundation, fix all current overflow errors,
  and convert the highest-traffic screens now. The remaining ~115 screens keep
  working with fixed sizes and adopt the helpers incrementally later.
- **Scaling model:** Breakpoint-based (phone vs tablet), tablet-first. A
  small-phone guard handles the narrowest devices.
- **Text scaling:** Respect the OS text-size setting but clamp it to a safe
  range so layouts never break.
- **API style:** A `BuildContext` extension (`context.rs(...)`,
  `context.isTablet`, `context.wp(...)`), matching the existing `context.l10n`
  idiom.

## Design

### 1. Core mechanism — `lib/theme/responsive.dart`

An extension on `BuildContext`:

```dart
extension Responsive on BuildContext {
  bool get isTablet;       // shortestSide >= 600
  bool get isSmallPhone;   // shortestSide < 360
  double rs(double size);  // scale a tablet-reference size to this device class
  double wp(double f);     // fraction of screen width
  double hp(double f);     // fraction of screen height
  double get gutter;       // standard screen edge padding per device class
}
```

- Device class comes from `MediaQuery.size.shortestSide` (stable across
  rotation): `< 600` = phone, `>= 600` = tablet; `< 360` = small phone.
- `rs(size)` treats the passed value as a tablet-reference size and maps it to
  the current class via a clamped ratio: phones scale down (~0.85×), tablets
  stay ~1.0×, and the ratio is capped so very large tablets do not over-scale.
- Everything is a pure function of `MediaQuery`, so rotation and split-screen
  work automatically.

### 2. Text scaling — respect but clamp (`lib/main.dart`)

Wrap `MaterialApp.builder` to clamp the OS text scaler:

```dart
builder: (context, child) {
  final mq = MediaQuery.of(context);
  final clamped = mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3);
  return MediaQuery(data: mq.copyWith(textScaler: clamped), child: child!);
}
```

This directly removes the reported overflow whenever an oversized OS text
setting is the cause: the label can no longer grow past what the button
tolerates.

### 3. Overflow-error fixes

Fixed-height boxes that wrap text are the failure mode.

- **Buttons:** replace bare `height: 58` on `ElevatedButton` wrappers with
  `minimumSize` / `minHeight` constraints so the button grows instead of
  clipping; center the label without bottom-biased padding.
- **Sweep:** find `SizedBox(height:)` / `Container(height:)` that directly
  parent a `Text`, and `Row`/`Column` children that overflow, converting
  offenders to `rs()`-scaled or flexible sizing. Verify with `flutter analyze`
  and by checking layouts for the overflow stripes.

### 4. High-traffic screens converted this pass

- `splash/splash_screen.dart`, `onboarding/choose_role_screen.dart`
- `auth/child_sign_in_screen.dart`, `auth/parent_sign_in_screen.dart`
  (source of the reported error)
- `profile/profile_screen.dart`, `ai_chat/ai_chat_screen.dart`
- Shared widgets they depend on: `widgets/primary_button.dart`,
  `widgets/secondary_button.dart`, `widgets/app_text_field.dart`,
  `widgets/bottom_nav_bar.dart`

The remaining screens are untouched and continue to work.

### 5. Text tokens

`AppTextStyles.font(context, fontSize: …)` and `h1/h2/h3` stay as the API.
Because text now flows through the clamped `MediaQuery`, existing call sites
scale correctly without change. Hero text that needs *device-class* scaling
(not just OS scaling) passes `context.rs(28)` explicitly.

## Out of scope

- Converting all 129 screens in one pass.
- Redesigning any screen's visual layout beyond what responsiveness requires.
- Unrelated refactoring.

## Success criteria

- No layout-overflow exceptions on the converted screens across phone and
  tablet sizes and at clamped text scales.
- `flutter analyze` is clean.
- The `context.rs()` / `context.isTablet` API is available app-wide for
  incremental adoption on the remaining screens.
