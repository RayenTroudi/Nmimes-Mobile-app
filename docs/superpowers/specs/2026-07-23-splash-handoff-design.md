# Splash handoff: seamless native → Flutter transition

Date: 2026-07-23

## Problem

Two user-reported issues with the launch experience:

1. **"The image is not clear in the Flutter one."** On entry, the Flutter splash
   scales the eyes in from scale `0` using `Curves.elasticOut`. During that
   elastic overshoot the eyes are distorted/blurry and start from nothing.

2. **"No transition between the default launch screen and the custom one."** The
   native launch screen (Android `launch_background.xml` / `splash_eyes_icon.xml`,
   iOS `LaunchImage`) shows the eyes **static, full size, centered**. Flutter's
   first frame then draws the same eyes at **scale 0** and bounces them back up.
   The result is a hard cut: full-size eyes → collapse → elastic bounce.

Both issues share one root cause: the Flutter splash animates the eyes *in* (from
zero, with overshoot) instead of *continuing* from the state the native screen
left them in (full size, centered, static).

## Constraint

**Do not change the current image** — the eyes' geometry, colors, gap, and pupil
ratio stay exactly as they are on both native and Flutter. The native assets
(`splash_eyes.xml`, `splash_eyes_icon.xml`, iOS `LaunchImage`) are **not**
touched. This is purely a change to how the Flutter splash animates the eyes on
entry.

## Design (Approach A — eyes static on entry)

Make the Flutter splash start exactly where the native one ended.

1. **Remove the eyes' scale-in bounce.** Delete the `elasticOut`
   `_badgeScaleIn` scale that wraps the eyes in `_blinkingBadge()`. The eyes
   render at full size and centered from frame 1 — pixel-identical to the native
   screen — so there is no pop and no blur.

2. **Retire the now-unused intro controller.** `_introCtrl` existed only to drive
   `_badgeScaleIn`. With the scale-in gone it no longer animates anything, so it
   is removed (controller field, `_badgeScaleIn`, its `forward()`/`await`, and its
   `dispose()`), and the blink loop / text sequence now start immediately in
   `_runSequence()` rather than after the intro completes.

3. **Keep the text and dots animating in.** The "Nmimes" wordmark, tagline, and
   bouncing loading dots keep their existing fade/scale entrance — that is the
   custom screen coming alive. Only the eyes (the element shared with the native
   screen) stay put.

4. **Blink loop starts after handoff.** The continuous blink loop (`_blinkCtrl`)
   still begins once the splash is up, so the handoff reads as "the same eyes,
   now blinking."

### Component touched

- `lib/screens/splash/splash_screen.dart` only.

### Data flow / sequence after change

```
native launch (static eyes, full size, centered)
        │  Flutter first frame
        ▼
Flutter splash: eyes already full size + centered (no scale-in)
        │  immediately
        ├─ blink loop starts
        ├─ wordmark fades/scales in
        ├─ tagline fades in (+250ms)
        └─ dots bounce loop
        │  ~1700ms later
        ▼
route to /onboarding | /home | /parents-view
```

## Out of scope / YAGNI

- No changes to native Android or iOS launch assets.
- No changes to eye geometry, colors, or the blink animation itself.
- No sub-option B (subtle no-overshoot settle) — user chose static (A).

## Testing

Manual verification on device/emulator: cold-launch the app and confirm the eyes
do not pop, shrink, or blur at the native → Flutter handoff — they should appear
continuous. `flutter analyze` must pass with no new warnings (e.g. no unused
field / dead code left behind by the removed controller).
