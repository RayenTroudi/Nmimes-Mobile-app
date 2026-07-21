import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/app_progress_bar.dart';
import '../../../widgets/chunky_button.dart';
import 'balance_scale_step.dart';
import 'drag_split_step.dart';
import 'intro_equation_step.dart';
import 'lesson_steps.dart';
import 'reveal_step.dart';
import 'tap_quiz_step.dart';

/// Duolingo-style lesson player: one screen, a pill progress bar, and a
/// sequence of animated/interactive steps that advance in place. Replaces
/// the old wall-of-text understanding + solution screens.
class LessonPlayerScreen extends StatefulWidget {
  const LessonPlayerScreen({super.key});

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

enum _Feedback { none, correct, wrong }

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  int _index = 0;
  _Feedback _feedback = _Feedback.none;
  String _feedbackText = '';

  void _next() {
    setState(() => _feedback = _Feedback.none);
    if (_index < 6) {
      setState(() => _index++);
    } else {
      Navigator.pushReplacementNamed(context, '/snap-success');
    }
  }

  /// Called by quiz/game steps when the child answers.
  void _onAnswer(bool correct, {String? message}) {
    HapticFeedback.mediumImpact();
    setState(() {
      _feedback = correct ? _Feedback.correct : _Feedback.wrong;
      _feedbackText = message ?? '';
    });
  }

  void _dismissWrong() => setState(() => _feedback = _Feedback.none);

  Widget _buildStep(LessonStep step) {
    final l = context.l10n;
    switch (step.kind) {
      case LessonStepKind.introEquation:
        return IntroEquationStep(onComplete: _next);
      case LessonStepKind.balanceIntro:
        return BalanceScaleStep(
          mode: BalanceMode.intro,
          onComplete: _next,
        );
      case LessonStepKind.tapQuiz:
        return TapQuizStep(
          key: ValueKey('quiz$_index'),
          question: step.question!(l),
          choices: step.choices!,
          correctIndex: step.correctIndex,
          hint: step.hint!(l),
          equation: step.equation!,
          onAnswer: _onAnswer,
        );
      case LessonStepKind.balanceRemove:
        return BalanceScaleStep(
          mode: BalanceMode.removeFive,
          onComplete: _next,
        );
      case LessonStepKind.dragSplit:
        return DragSplitStep(onAnswer: _onAnswer);
      case LessonStepKind.reveal:
        return RevealStep(onComplete: _next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final steps = buildDemoLesson(context);
    final step = steps[_index];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top bar: close + progress
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                          value: (_index + 1) / steps.length,
                        ),
                      ),
                    ],
                  ),
                ),
                // The active step
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutBack,
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
                    child: KeyedSubtree(
                      key: ValueKey(_index),
                      child: _buildStep(step),
                    ),
                  ),
                ),
              ],
            ),

            // Duolingo-style feedback sheet
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              left: 0,
              right: 0,
              bottom: _feedback == _Feedback.none ? -180 : 0,
              child: _FeedbackSheet(
                correct: _feedback == _Feedback.correct,
                title: _feedback == _Feedback.correct
                    ? l.lesson_feedback_correct
                    : l.lesson_feedback_wrong,
                detail: _feedbackText,
                buttonLabel: _feedback == _Feedback.correct
                    ? l.snap_button_continue
                    : l.lesson_feedback_gotIt,
                onPressed:
                    _feedback == _Feedback.correct ? _next : _dismissWrong,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackSheet extends StatelessWidget {
  final bool correct;
  final String title;
  final String detail;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _FeedbackSheet({
    required this.correct,
    required this.title,
    required this.detail,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final accent = correct ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: BoxDecoration(
        color: correct ? AppColors.successBg : AppColors.errorBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  correct ? Icons.check_rounded : Icons.close_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.font(context,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          if (detail.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              detail,
              style: AppTextStyles.font(context,
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 14),
          ChunkyButton(
            onTap: onPressed,
            color: accent,
            width: double.infinity,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Text(
              buttonLabel,
              style: AppTextStyles.font(context,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
