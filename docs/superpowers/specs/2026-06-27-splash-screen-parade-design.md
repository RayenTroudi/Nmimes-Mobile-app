# Splash Screen Redesign: "The Nmimes Parade"

**Date:** 2026-06-27  
**Status:** Approved  

---

## Overview

Replace the current professional splash sequence with a funny, chaotic character parade. Five Nmimes characters slide in from alternating sides one by one, briefly form a group photo, then all scatter off-screen so the logo can dramatically drop in. Total duration ~3.5 seconds.

---

## Assets Used

| Asset | Character Role |
|-------|---------------|
| `assets/images/onboarding_understand.png` | Math nerd fox (points at phone with formula) |
| `assets/images/fox_soccer.png` | Sunglasses swag fox |
| `assets/images/fox_gift.png` | Gift fox with glowing box |
| `assets/images/avatar_default.png` | Matcha latte fox |
| `assets/images/yippyee.png` | Dancing fox — parade star, center-front |
| `assets/images/nmimes_logo.png` | Logo (final reveal) |

---

## Animation Sequence

### Background
Cream (`AppColors.background`) throughout the entire splash. No orange phase.

### Phase 1 — The Parade (0ms – 1600ms)
Characters slide in staggered 400ms apart:

| Delay | Character | Entry Direction | Size |
|-------|-----------|-----------------|------|
| 0ms | `onboarding_understand.png` | From LEFT | 130×130 |
| 400ms | `fox_soccer.png` | From RIGHT | 120×120 |
| 800ms | `fox_gift.png` | From LEFT | 120×120 |
| 1200ms | `avatar_default.png` | From RIGHT | 120×120 |
| 1600ms | `yippyee.png` | From TOP (drops down) | 150×150 |

Each character slides in with `Curves.easeOut` over 300ms.

Characters are positioned in a loose, slightly overlapping arc across the bottom 55% of the screen. Not perfectly aligned — intentionally messy. `yippyee` lands center-bottom, slightly larger, slightly in front (higher z-order).

### Phase 2 — Group Photo (1900ms – 2200ms)
All 5 on screen simultaneously for ~300ms. No animation, just held — like a chaotic group photo moment.

### Phase 3 — The Scatter (2200ms)
All 5 characters simultaneously animate off-screen in 250ms with `Curves.easeIn`:

| Character | Exit Direction |
|-----------|---------------|
| `onboarding_understand.png` | To LEFT |
| `fox_soccer.png` | To RIGHT |
| `fox_gift.png` | To LEFT |
| `avatar_default.png` | To RIGHT |
| `yippyee.png` | Downward |

### Phase 4 — Logo Drop (2450ms)
`nmimes_logo.png` slides in from the top with a bounce overshoot (`Curves.bounceOut`) over 400ms. Settles center-screen.

"Nmimes" text fades in below the logo over 300ms.

"Math, made Simple..." tagline fades in below text over 200ms with a slight delay (100ms after text starts).

### Phase 5 — Navigate (3500ms)
`Navigator.pushReplacementNamed(context, '/onboarding')`.

---

## Layout

```
┌─────────────────────────────┐
│                             │
│                             │
│                             │
│         [LOGO]              │  ← Phase 4 only
│         Nmimes              │
│     Math, made Simple...    │
│                             │
│  [fox1] [fox2] [fox3] [fox4]│  ← Phase 1–3
│         [yippyee]           │  ← Phase 1–3, center-front
└─────────────────────────────┘
```

Character row sits roughly at 55–75% height of screen. Logo appears center 30–50% height.

---

## Implementation Notes

- Use `AnimationController` per character (5 controllers for entry, 5 for exit, 1 for logo bounce, 1 for text/tagline fade).
- Character positions: use `Positioned` inside a `Stack` sized to full screen.
- Entry: `SlideTransition` with `Tween<Offset>` from off-screen to final position.
- Exit: reverse direction `SlideTransition`.
- Logo bounce: `SlideTransition` from `Offset(0, -1)` to `Offset.zero` with `Curves.bounceOut`.
- Replace current `SplashScreen` entirely — no need to keep any existing phases.
- File: `lib/screens/splash/splash_screen.dart`

---

## What Changes

- `lib/screens/splash/splash_screen.dart` — full rewrite
- Figma screenshots (`figma_screenshots/splash3.png`, `figma_screenshots/splash4.png`) are superseded by this design
