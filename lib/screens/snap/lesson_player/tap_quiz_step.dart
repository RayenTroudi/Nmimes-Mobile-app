import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/chunky_button.dart';

/// Steps 3 & 6 — tap-the-answer quiz. Wrong picks shake red; after two
/// misses the correct choice glows as a hint. Answers report back to the
/// player, which shows the Duolingo feedback sheet.
class TapQuizStep extends StatefulWidget {
  final String question;
  final List<String> choices;
  final int correctIndex;
  final String hint;
  final String equation;
  final void Function(bool correct, {String? message}) onAnswer;

  const TapQuizStep({
    super.key,
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.hint,
    required this.equation,
    required this.onAnswer,
  });

  @override
  State<TapQuizStep> createState() => _TapQuizStepState();
}

class _TapQuizStepState extends State<TapQuizStep>
    with SingleTickerProviderStateMixin {
  int _misses = 0;
  int? _shakingIndex;
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
    if (i == widget.correctIndex) {
      setState(() => _answered = true);
      widget.onAnswer(true);
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() {
      _misses++;
      _shakingIndex = i;
    });
    await _shake.forward(from: 0);
    if (!mounted) return;
    setState(() => _shakingIndex = null);
    widget.onAnswer(false, message: widget.hint);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final showGlow = _misses >= 2 && !_answered;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          // Fox asks the question
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                'assets/images/fox_thumbsup.png',
                width: 90,
                height: 90,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, _) =>
                    const Text('🦊', style: TextStyle(fontSize: 60)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                        color: AppColors.border, width: AppSizes.cardBorder),
                  ),
                  child: Text(
                    widget.question,
                    style: AppTextStyles.font(context,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Equation reminder
          Text(
            widget.equation,
            style: AppTextStyles.font(context,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),

          // Choices
          ...List.generate(widget.choices.length, (i) {
            final isCorrect = i == widget.correctIndex;
            final glow = showGlow && isCorrect;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedBuilder(
                animation: _shake,
                builder: (context, child) {
                  final dx = _shakingIndex == i
                      ? 10 *
                          (1 - _shake.value) *
                          ((_shake.value * 6).floor().isEven ? 1 : -1)
                      : 0.0;
                  return Transform.translate(
                      offset: Offset(dx, 0), child: child);
                },
                child: Container(
                  decoration: glow
                      ? BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.7),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                        )
                      : null,
                  child: ChunkyButton(
                    onTap: () => _pick(i),
                    color: AppColors.white,
                    borderColor:
                        glow ? AppColors.gold : AppColors.border,
                    width: double.infinity,
                    child: Text(
                      widget.choices[i],
                      style: AppTextStyles.font(context,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          if (showGlow)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l.lesson_quiz_glowHint,
                style: AppTextStyles.font(context,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldDark,
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
