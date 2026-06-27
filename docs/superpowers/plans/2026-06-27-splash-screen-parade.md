# Splash Screen Parade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the existing splash screen with a funny chaotic character parade — 5 Nmimes foxes slide in one by one, hold for a group photo beat, scatter off-screen, then the logo drops in with a bounce.

**Architecture:** Single file full rewrite of `lib/screens/splash/splash_screen.dart`. Uses a `Stack` + `Positioned` layout with one `AnimationController` per character slide-in and slide-out, plus a logo bounce controller and a text fade controller. A `_runSequence()` async method drives the phase timing with `Future.delayed`.

**Tech Stack:** Flutter, `dart:async` (Future.delayed), `google_fonts`, `package:flutter/material.dart` animation controllers, `TickerProviderStateMixin`.

## Global Constraints

- Background is always `AppColors.background` (cream `0xFFFAF3E8`) — no orange phase at all.
- Total splash duration: ~3500ms before navigating to `/onboarding`.
- All image assets already exist in `assets/images/` — do not add or rename any files.
- Use `GoogleFonts.poppins` for all text, matching existing font usage in the app.
- No new dependencies — this is pure Flutter animation.
- Replace `lib/screens/splash/splash_screen.dart` entirely. No backwards-compatibility shims.

---

### Task 1: Rewrite SplashScreen with character entry animations

**Files:**
- Modify: `lib/screens/splash/splash_screen.dart` (full rewrite)

**Interfaces:**
- Produces: `SplashScreen` widget (stateful, `const SplashScreen({super.key})`) — same public API as before, drop-in replacement.

- [ ] **Step 1: Replace the file contents**

Replace all of `lib/screens/splash/splash_screen.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

// Character entry config
class _CharConfig {
  const _CharConfig({
    required this.asset,
    required this.width,
    required this.height,
    required this.entryOffset,   // where it slides IN from (e.g. Offset(-2, 0) = from left)
    required this.exitOffset,    // where it slides OUT to
    required this.left,          // Positioned.left (null if using right)
    required this.right,         // Positioned.right (null if using left)
    required this.bottom,        // Positioned.bottom
    required this.entryDelay,    // ms before entry starts
  });
  final String asset;
  final double width;
  final double height;
  final Offset entryOffset;
  final Offset exitOffset;
  final double? left;
  final double? right;
  final double bottom;
  final int entryDelay;
}

const _chars = [
  _CharConfig(
    asset: 'assets/images/onboarding_understand.png',
    width: 130, height: 130,
    entryOffset: Offset(-2, 0), exitOffset: Offset(-2, 0),
    left: 10, right: null, bottom: 160,
    entryDelay: 0,
  ),
  _CharConfig(
    asset: 'assets/images/fox_soccer.png',
    width: 120, height: 120,
    entryOffset: Offset(2, 0), exitOffset: Offset(2, 0),
    left: null, right: 10, bottom: 170,
    entryDelay: 400,
  ),
  _CharConfig(
    asset: 'assets/images/fox_gift.png',
    width: 120, height: 120,
    entryOffset: Offset(-2, 0), exitOffset: Offset(-2, 0),
    left: 60, right: null, bottom: 155,
    entryDelay: 800,
  ),
  _CharConfig(
    asset: 'assets/images/avatar_default.png',
    width: 120, height: 120,
    entryOffset: Offset(2, 0), exitOffset: Offset(2, 0),
    left: null, right: 60, bottom: 155,
    entryDelay: 1200,
  ),
  _CharConfig(
    asset: 'assets/images/yippyee.png',
    width: 150, height: 150,
    entryOffset: Offset(0, -2), exitOffset: Offset(0, 2),
    left: null, right: null, bottom: 120,
    entryDelay: 1600,
  ),
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // One entry + one exit controller per character
  late final List<AnimationController> _entryCtrl;
  late final List<AnimationController> _exitCtrl;

  // Logo + text
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;

  bool _showLogo = false;

  @override
  void initState() {
    super.initState();

    _entryCtrl = List.generate(
      _chars.length,
      (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 300)),
    );
    _exitCtrl = List.generate(
      _chars.length,
      (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 250)),
    );
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Phase 1: characters slide in, staggered 400ms apart
    for (int i = 0; i < _chars.length; i++) {
      await Future.delayed(Duration(milliseconds: i == 0 ? 0 : 400));
      if (!mounted) return;
      _entryCtrl[i].forward();
    }

    // Phase 2: group photo hold (wait for last entry to finish + 300ms hold)
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Phase 3: all scatter simultaneously
    for (final ctrl in _exitCtrl) {
      ctrl.forward();
    }

    // Phase 4: logo drops in after scatter completes
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _showLogo = true);
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _textCtrl.forward();

    // Phase 5: navigate
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  void dispose() {
    for (final c in _entryCtrl) c.dispose();
    for (final c in _exitCtrl) c.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Widget _buildCharacter(int index, BoxConstraints constraints) {
    final cfg = _chars[index];

    final entryAnim = SlideTransition(
      position: Tween<Offset>(begin: cfg.entryOffset, end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl[index], curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: cfg.exitOffset).animate(
          CurvedAnimation(parent: _exitCtrl[index], curve: Curves.easeIn),
        ),
        child: Image.asset(cfg.asset, width: cfg.width, height: cfg.height, fit: BoxFit.contain),
      ),
    );

    // yippyee (index 4) is centered horizontally
    if (index == 4) {
      return Positioned(
        bottom: cfg.bottom,
        left: (constraints.maxWidth - cfg.width) / 2,
        child: entryAnim,
      );
    }

    return Positioned(
      bottom: cfg.bottom,
      left: cfg.left,
      right: cfg.right,
      child: entryAnim,
    );
  }

  Widget _buildLogo() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.bounceOut),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/nmimes_logo.png', width: 100, height: 100, fit: BoxFit.contain),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _textCtrl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nmimes',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Math, made Simple...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Characters layer
              for (int i = 0; i < _chars.length; i++)
                _buildCharacter(i, constraints),

              // Logo — centered in upper half, only shown after scatter
              if (_showLogo)
                Positioned(
                  top: constraints.maxHeight * 0.28,
                  left: 0,
                  right: 0,
                  child: Center(child: _buildLogo()),
                ),
            ],
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Hot restart the app and watch the splash**

Run the app with `flutter run`. The splash should show:
1. Math fox slides in from left (~0ms)
2. Sunglasses fox slides in from right (~400ms)
3. Gift fox slides in from left (~800ms)
4. Matcha fox slides in from right (~1200ms)
5. Yippyee drops from top (~1600ms)
6. All 5 hold briefly (~300ms)
7. All 5 scatter simultaneously
8. Logo drops with bounce from top, "Nmimes" + tagline fade in
9. Navigates to `/onboarding` (~3.5s total)

If the app shows a blank cream screen with character chaos followed by the logo — it's working.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/splash/splash_screen.dart
git commit -m "feat: replace splash with chaotic Nmimes character parade"
```

---

### Task 2: Tune layout positions if needed

This task is conditional — run it only if the character positions look off on a real device (overlapping too much, cut off at edges, etc.).

**Files:**
- Modify: `lib/screens/splash/splash_screen.dart` — the `_chars` const list only

**Interfaces:**
- Consumes: `_CharConfig` from Task 1 (`left`, `right`, `bottom` fields)
- Produces: adjusted positions, same widget structure

- [ ] **Step 1: Identify which characters need repositioning**

On device, note which characters are clipped or overlap awkwardly. The `bottom` values to adjust are in `_chars` (the const list at the top of the file):

| Index | Character | Current bottom |
|-------|-----------|---------------|
| 0 | onboarding_understand | 160 |
| 1 | fox_soccer | 170 |
| 2 | fox_gift | 155 |
| 3 | avatar_default | 155 |
| 4 | yippyee (center) | 120 |

- [ ] **Step 2: Adjust `bottom` / `left` / `right` values in `_chars`**

Edit the relevant `_CharConfig` entries in `_chars`. Example — if `fox_gift` is too low:

```dart
  _CharConfig(
    asset: 'assets/images/fox_gift.png',
    width: 120, height: 120,
    entryOffset: Offset(-2, 0), exitOffset: Offset(-2, 0),
    left: 60, right: null, bottom: 175,  // changed from 155 → 175
    entryDelay: 800,
  ),
```

- [ ] **Step 3: Hot reload and verify**

`r` in the Flutter run terminal to hot reload. Confirm all 5 characters are visible and form a loose chaotic arc.

- [ ] **Step 4: Commit if changes were made**

```bash
git add lib/screens/splash/splash_screen.dart
git commit -m "fix: adjust splash character positions for device layout"
```
