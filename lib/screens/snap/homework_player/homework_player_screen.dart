import 'package:flutter/material.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/app_progress_bar.dart';
import 'homework_steps.dart';
import 'homework_widgets.dart';
import 'hw_balance_step.dart';
import 'hw_solution_step.dart';
import 'hw_tap_step.dart';

/// Duolingo-style homework player: one screen, a pill progress bar, and a
/// sequence of interactive steps that advance in place.
///
/// Replaces the old chain of four pushed screens (`_Step1Screen` →
/// `_Step2Screen` → `_Step3Screen` → `_CompleteSolutionScreen`), which kept
/// every previous step alive on the navigator and rebuilt the problem card
/// on each answer. Mirrors [LessonPlayerScreen] so both snap flows behave
/// the same way.
class HomeworkPlayerScreen extends StatefulWidget {
  const HomeworkPlayerScreen({super.key});

  @override
  State<HomeworkPlayerScreen> createState() => _HomeworkPlayerScreenState();
}

enum _Feedback { none, correct, wrong }

class _HomeworkPlayerScreenState extends State<HomeworkPlayerScreen> {
  static const _equation = '2x + 5 = 15';

  final _steps = buildDemoHomework();

  /// One key per step index. A single shared key would be present twice
  /// during the AnimatedSwitcher crossfade — the outgoing and incoming tap
  /// steps are both mounted — which is a duplicate-GlobalKey crash.
  final _tapStepKeys = <int, GlobalKey<HwTapStepState>>{};

  GlobalKey<HwTapStepState> _keyFor(int index) =>
      _tapStepKeys.putIfAbsent(index, () => GlobalKey<HwTapStepState>());

  int _index = 0;
  int _misses = 0;
  _Feedback _feedback = _Feedback.none;
  String _feedbackText = '';

  void _next() {
    setState(() {
      _feedback = _Feedback.none;
      _misses = 0;
    });
    if (_index < _steps.length - 1) {
      setState(() => _index++);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/snap-hw-success', (r) => false);
    }
  }

  void _onAnswer(bool correct, {String? message}) {
    setState(() {
      _feedback = correct ? _Feedback.correct : _Feedback.wrong;
      _feedbackText = message ?? '';
      if (!correct) _misses++;
    });
  }

  /// Dismiss the wrong-answer sheet and re-arm the step's choices.
  void _tryAgain() {
    setState(() => _feedback = _Feedback.none);
    _tapStepKeys[_index]?.currentState?.reset();
  }

  Widget _buildStep(HwStep step, int index) {
    switch (step.kind) {
      case HwStepKind.tapGrid:
      case HwStepKind.tapList:
        return HwTapStep(
          key: _keyFor(index),
          step: step,
          onAnswer: _onAnswer,
        );
      case HwStepKind.balance:
        return HwBalanceStep(step: step, onAnswer: _onAnswer);
      case HwStepKind.solution:
        return HwSolutionStep(
          step: step,
          onComplete: () => _onAnswer(true),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final step = _steps[_index];
    final isLast = _index == _steps.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Top bar: close + progress
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (r) => false),
                        child: const Icon(Icons.close_rounded,
                            color: AppColors.textHint, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppProgressBar(
                          value: (_index + 1) / _steps.length,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_index + 1}/${_steps.length}',
                        style: AppTextStyles.font(
                          context,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 220),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hoisted out of the switcher: the equation is the one
                        // constant across every step, so it neither rebuilds
                        // nor re-animates as steps change.
                        const HwProblemCard(equation: _equation),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.15, 0),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          // Top-aligned so the outgoing and incoming steps
                          // share a top edge instead of jumping when they
                          // differ in height.
                          layoutBuilder: (current, previous) => Stack(
                            alignment: Alignment.topCenter,
                            children: [...previous, ?current],
                          ),
                          child: KeyedSubtree(
                            key: ValueKey(_index),
                            child: _buildStep(step, _index),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Duolingo-style feedback sheet.
            //
            // Slid by a fractional translation rather than a negative
            // `bottom`: the sheet's height varies with the hint text and the
            // stuck-actions button, and any fixed offset that is too small
            // leaves it on screen while one that is too large pushes the
            // button out of reach of taps.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                offset:
                    _feedback == _Feedback.none ? const Offset(0, 1) : Offset.zero,
                child: IgnorePointer(
                  ignoring: _feedback == _Feedback.none,
                  child: HwFeedbackSheet(
                    correct: _feedback == _Feedback.correct,
                    title: _feedback == _Feedback.correct
                        ? l.lesson_feedback_correct
                        : l.snap_hw_letsLearnTogether,
                    detail: _feedbackText,
                    buttonLabel: _feedback == _Feedback.correct
                        ? (isLast
                            ? l.snap_button_done
                            : l.snap_button_nextStep)
                        : l.snap_hw_button_tryAgain,
                    onPressed:
                        _feedback == _Feedback.correct ? _next : _tryAgain,
                    // After two misses, offer a way forward, not a loop.
                    showStuckActions: _misses >= 2,
                    onSkip: _next,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
