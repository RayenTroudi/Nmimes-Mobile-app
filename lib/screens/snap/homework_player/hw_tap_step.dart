import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/chunky_button.dart';
import 'homework_steps.dart';
import 'homework_widgets.dart';

/// Steps 1 & 2 — pick the answer. Wrong picks shake and buzz; after two
/// misses the correct choice glows gold, the same affordance the lesson
/// player's [TapQuizStep] uses.
///
/// [HwStepKind.tapGrid] lays choices out 2x2 for short tokens (x, 5, 2, 15);
/// [HwStepKind.tapList] stacks them full-width for sentence-length options.
class HwTapStep extends StatefulWidget {
  final HwStep step;
  final void Function(bool correct, {String? message}) onAnswer;

  const HwTapStep({super.key, required this.step, required this.onAnswer});

  @override
  State<HwTapStep> createState() => HwTapStepState();
}

/// Public so the player can call [reset] through a [GlobalKey] when the
/// child dismisses the wrong-answer sheet.
class HwTapStepState extends State<HwTapStep>
    with SingleTickerProviderStateMixin {
  int _misses = 0;
  int? _shakingIndex;
  int? _lockedIndex;
  bool _answered = false;

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _pick(int i) async {
    if (_answered) return;
    final l = context.l10n;

    if (i == widget.step.correctIndex) {
      HapticFeedback.mediumImpact();
      setState(() {
        _answered = true;
        _lockedIndex = i;
      });
      widget.onAnswer(true, message: widget.step.correct?.call(l));
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _misses++;
      _shakingIndex = i;
      _lockedIndex = i;
    });
    await _shake.forward(from: 0);
    if (!mounted) return;
    setState(() => _shakingIndex = null);
    widget.onAnswer(false, message: widget.step.hint?.call(l));
  }

  /// Re-arm after the child dismisses the wrong-answer sheet.
  void reset() {
    if (!mounted) return;
    setState(() => _lockedIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final step = widget.step;
    final choices = step.choices!(l);
    final showGlow = _misses >= 2 && !_answered;
    final isGrid = step.kind == HwStepKind.tapGrid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HwStagger(index: 0, child: HwStepLabel(label: step.label!(l))),
        const SizedBox(height: 12),
        HwStagger(
          index: 1,
          child: Text(
            step.question!(l),
            style: AppTextStyles.font(
              context,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (isGrid)
          _grid(choices, showGlow)
        else
          ...List.generate(
            choices.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HwStagger(
                index: 2 + i,
                child: _choice(i, choices[i], showGlow, grid: false),
              ),
            ),
          ),
        if (showGlow) ...[
          const SizedBox(height: 4),
          Text(
            l.lesson_quiz_glowHint,
            style: AppTextStyles.font(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.goldDark,
            ),
          ),
        ],
      ],
    );
  }

  Widget _grid(List<String> choices, bool showGlow) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              for (var i = 0; i < choices.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HwStagger(
                    index: 2 + i,
                    child: _choice(i, choices[i], showGlow, grid: true),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              for (var i = 1; i < choices.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HwStagger(
                    index: 2 + i,
                    child: _choice(i, choices[i], showGlow, grid: true),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _choice(int i, String label, bool showGlow, {required bool grid}) {
    final isCorrect = i == widget.step.correctIndex;
    final glow = showGlow && isCorrect;
    final settled = _lockedIndex == i && _shakingIndex != i;

    // Colour only after the shake finishes, so the tile reads as "wrong"
    // rather than flashing red mid-wobble.
    final Color border;
    if (settled) {
      border = isCorrect ? AppColors.green : AppColors.red;
    } else if (glow) {
      border = AppColors.gold;
    } else {
      border = AppColors.border;
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _shake,
        builder: (context, child) {
          final dx = _shakingIndex == i
              ? 10 *
                  (1 - _shake.value) *
                  ((_shake.value * 6).floor().isEven ? 1 : -1)
              : 0.0;
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: glow
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.7),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: ChunkyButton(
            onTap: _answered ? null : () => _pick(i),
            color: settled
                ? (isCorrect ? AppColors.successBg : AppColors.errorBg)
                : AppColors.white,
            borderColor: border,
            width: double.infinity,
            height: grid ? AppSizes.buttonHeight : 60,
            // The step drives its own haptics, distinguishing right from wrong.
            haptics: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: grid ? 4 : 14),
              child: Text(
                label,
                textAlign: grid ? TextAlign.center : TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.font(
                  context,
                  fontSize: grid ? 22 : 15,
                  fontWeight: grid ? FontWeight.w800 : FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
