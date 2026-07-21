import 'package:flutter/widgets.dart';
import '../../../l10n/generated/app_localizations.dart';

/// The kinds of interactive steps the lesson player can render.
enum LessonStepKind {
  introEquation, // equation appears piece by piece, x pulses
  balanceIntro, // seesaw rocks then settles level
  tapQuiz, // pick the right move from chunky choices
  balanceRemove, // -5 blocks lift off both pans, stays level
  dragSplit, // drag 10 blocks into two x groups
  reveal, // verification count-up + big green stamp
}

/// One step of a scripted lesson. Quiz fields are only set for
/// [LessonStepKind.tapQuiz]. When AI generates lessons later, it just
/// emits a list of these.
class LessonStep {
  final LessonStepKind kind;
  final String Function(AppLocalizations l)? question;
  final List<String>? choices;
  final int correctIndex;
  final String Function(AppLocalizations l)? hint;
  final String? equation; // reminder shown under the quiz question

  const LessonStep(
    this.kind, {
    this.question,
    this.choices,
    this.correctIndex = 0,
    this.hint,
    this.equation,
  });
}

/// The scripted lesson for the demo problem 2x + 5 = 15.
List<LessonStep> buildDemoLesson(BuildContext context) {
  return [
    const LessonStep(LessonStepKind.introEquation),
    const LessonStep(LessonStepKind.balanceIntro),
    LessonStep(
      LessonStepKind.tapQuiz,
      question: (l) => l.lesson_quiz1_question,
      choices: const ['− 5', '÷ 2', '+ 15'],
      correctIndex: 0,
      hint: (l) => l.lesson_quiz1_hint,
      equation: '2x + 5 = 15',
    ),
    const LessonStep(LessonStepKind.balanceRemove),
    const LessonStep(LessonStepKind.dragSplit),
    LessonStep(
      LessonStepKind.tapQuiz,
      question: (l) => l.lesson_quiz2_question,
      choices: const ['3', '5', '7'],
      correctIndex: 1,
      hint: (l) => l.lesson_quiz2_hint,
      equation: '2x = 10',
    ),
    const LessonStep(LessonStepKind.reveal),
  ];
}
