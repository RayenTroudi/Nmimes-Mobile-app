# Interactive Snap-a-Lesson Player — Design

**Date:** 2026-07-21
**Status:** Approved by user

## Problem

After a child snaps a lesson, the app teaches through walls of text: an
"Understanding the question" screen with two dense cards, followed by four
pushed solution-step screens of more text. Kids don't read walls of text.

## Goal

Replace the text-heavy teaching flow (snap-send intro → understanding →
4 solution step screens) with a single Duolingo-style **Lesson Player**:
animated, interactive, game-like. Content stays scripted around the demo
problem `2x + 5 = 15` (no AI/OCR yet), but the architecture must make
AI-generated steps a drop-in later.

Scope: **Snap a Lesson flow only.** Snap Homework (`snap_hw_*`) is untouched.

## Flow

snap captured → confirm → **Lesson Player** (one screen, steps animate in
place) → existing `/snap-success` celebration.

## Lesson steps (scripted for 2x + 5 = 15)

1. **Meet the mystery number** (animation) — equation appears piece by piece
   with bouncy entrances; `x` pulses with a "?"; fox: "x is hiding! Let's
   find it." Tap to continue.
2. **Balance scale intro** (animation) — animated seesaw: left pan `2x + 5`,
   right pan `15`; rocks, settles level. "An equation is a balance."
3. **Quiz: what do we remove first?** (tap-the-answer) — choices `−5`, `÷2`,
   `+15`. Wrong → shake + red feedback + fox hint. Right → green feedback.
4. **Watch it balance** (animation) — `−5` blocks lift off BOTH pans
   simultaneously, scale stays level; equation morphs to `2x = 10`.
5. **Drag-and-drop: split it** (game) — `10` shown as ten blocks; drag into
   two groups of 5 onto two `x` targets; each `x` lights up as `5`.
6. **Quiz: so x = ?** (tap-the-answer) — `3 / 5 / 7`. Correct → fox
   celebrates.
7. **Check it!** (animation) — `2(5) + 5` counts up to `15`; big green
   `15 = 15 ✓` stamp + star burst → auto-advance to `/snap-success`.

## Feedback system

- Bottom sheet slides up, Duolingo style: green (`AppColors.successBg`) on
  correct, red (`AppColors.errorBg`) on wrong, with haptics.
- Wrong answers never block: after 2 misses the correct answer glows as a
  hint.
- No lives/hearts — kids app, always forward.
- Orange pill progress bar at top advances per completed step.

## Architecture

`lib/screens/snap/lesson_player/`

| File | Responsibility |
|---|---|
| `lesson_player_screen.dart` | Scaffold, progress bar, step switcher (AnimatedSwitcher), feedback sheet, completion → `/snap-success` |
| `lesson_steps.dart` | `LessonStep` model + the scripted step list. This is the future AI plug-in point: AI later just emits this list. |
| `intro_equation_step.dart` | Step 1 |
| `balance_scale_step.dart` | Steps 2 & 4 (parameterized: intro rock vs remove-5 animation) |
| `tap_quiz_step.dart` | Steps 3 & 6 (parameterized: question, choices, hint) |
| `drag_split_step.dart` | Step 5 |
| `reveal_step.dart` | Step 7 |

Reuses: `ChunkyButton`, `AppProgressBar`, `AppColors`, `AppTextStyles`,
existing fox assets. All strings via l10n (EN/FR/AR); layouts symmetric or
`AlignmentDirectional`-based so RTL works.

## Removed / kept

- Replaced: `_UnderstandingScreen`, `_SolutionScreen`, `_MakeSenseDialog`
  in `snap_send_screen.dart` (the intro "Let's find out" screen routes
  straight into the Lesson Player).
- Kept: capture screens, `/snap-success`, all `snap_hw_*` screens.

## Error handling

- No network involved (scripted). Drag gestures cancel cleanly on
  interruption; step state is local to each step widget.

## Testing

- `flutter analyze` clean.
- Widget smoke test: player renders step 1 and advances on tap.
- Manual run-through of all 7 steps in EN + AR (RTL).
