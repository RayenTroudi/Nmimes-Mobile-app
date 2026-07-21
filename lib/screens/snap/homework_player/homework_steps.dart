import '../../../l10n/generated/app_localizations.dart';

/// The kinds of interactive steps the homework player can render.
enum HwStepKind {
  /// Pick what we're solving for, from a 2x2 grid of short tiles.
  tapGrid,

  /// Pick the right move from a list of full-sentence options.
  tapList,

  /// Drag the balance's −5 blocks off both pans, then split 10 into 2x.
  balance,

  /// The worked solution, revealed card by card, ending in a count-up check.
  solution,
}

/// One step of a scripted homework walkthrough. Quiz fields are only set for
/// the tap steps. Mirrors [LessonStep] so an AI-generated homework session can
/// emit the same shape later.
class HwStep {
  final HwStepKind kind;
  final String Function(AppLocalizations l)? label;
  final String Function(AppLocalizations l)? question;
  final List<String> Function(AppLocalizations l)? choices;
  final int correctIndex;
  final String Function(AppLocalizations l)? hint;
  final String Function(AppLocalizations l)? correct;

  const HwStep(
    this.kind, {
    this.label,
    this.question,
    this.choices,
    this.correctIndex = 0,
    this.hint,
    this.correct,
  });
}

/// The scripted walkthrough for the demo problem 2x + 5 = 15.
///
/// Step 3 used to be a text field the child typed "5" into. It is now the
/// balance step: typing a number the fox already told you is not a mechanic,
/// and the keyboard covered the feedback sheet on short screens.
List<HwStep> buildDemoHomework() {
  return [
    HwStep(
      HwStepKind.tapGrid,
      label: (l) => l.snap_hw_step1_label,
      question: (l) => l.snap_hw_step1_question,
      choices: (l) => const ['x', '5', '2', '15'],
      correctIndex: 0,
      hint: (l) => l.snap_hw_step1_wrong,
      correct: (l) => l.snap_hw_step1_correct,
    ),
    HwStep(
      HwStepKind.tapList,
      label: (l) => l.snap_hw_step2_label,
      question: (l) => l.snap_hw_step2_question,
      choices: (l) => [
        l.snap_hw_step2_option1,
        l.snap_hw_step2_option2,
        l.snap_hw_step2_option3,
        l.snap_hw_step2_option4,
      ],
      correctIndex: 0,
      hint: (l) => l.snap_hw_step2_wrong,
      correct: (l) => l.snap_hw_step2_correct_msg,
    ),
    HwStep(
      HwStepKind.balance,
      label: (l) => l.snap_hw_step3_label,
      question: (l) => l.snap_hw_step3_question,
      hint: (l) => l.snap_hw_step3_hint,
      correct: (l) => l.snap_hw_step3_correct,
    ),
    HwStep(
      HwStepKind.solution,
      label: (l) => l.snap_hw_completeSolution_label,
    ),
  ];
}
