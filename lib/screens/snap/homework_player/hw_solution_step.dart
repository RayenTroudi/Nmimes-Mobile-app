import 'package:flutter/material.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/bounce_in.dart';
import 'homework_steps.dart';
import 'homework_widgets.dart';

/// Step 4 — the worked solution, revealed one card at a time instead of
/// dumped as a static wall, then a count-up verification that lands on
/// `x = 5`.
class HwSolutionStep extends StatefulWidget {
  final HwStep step;
  final VoidCallback onComplete;

  const HwSolutionStep({
    super.key,
    required this.step,
    required this.onComplete,
  });

  @override
  State<HwSolutionStep> createState() => _HwSolutionStepState();
}

class _HwSolutionStepState extends State<HwSolutionStep>
    with SingleTickerProviderStateMixin {
  /// How many solution cards have been revealed so far.
  int _revealed = 0;
  bool _checked = false;

  late final AnimationController _count = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    // Cascade the cards in, then run the verification count-up.
    for (var i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 550));
      if (!mounted) return;
      setState(() => _revealed = i + 1);
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    await _count.forward();
    if (!mounted) return;
    setState(() => _checked = true);
    widget.onComplete();
  }

  @override
  void dispose() {
    _count.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    final cards = <Widget>[
      _SolutionCard(
        stepLabel: l.snap_hw_cs_step1_label,
        title: null,
        lines: [l.snap_hw_cs_step1_line1],
      ),
      _SolutionCard(
        stepLabel: l.snap_hw_cs_step2_label,
        title: l.snap_hw_step2_option1,
        lines: [
          l.snap_hw_cs_step2_line1,
          '2x + 5 = 15',
          l.snap_hw_cs_step2_line3,
          '2x + 5 - 5 = 15 - 5',
          '2x = 10',
        ],
      ),
      _SolutionCard(
        stepLabel: l.snap_hw_cs_step3_label,
        title: l.snap_hw_step2_option2,
        lines: [
          l.snap_hw_cs_step3_line1,
          '2x = 10',
          l.snap_hw_cs_step3_line3,
          l.snap_hw_cs_step3_line4,
          l.snap_hw_cs_step3_line5,
          'x = 5',
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HwStepLabel(label: widget.step.label!(l)),
        const SizedBox(height: 16),
        for (var i = 0; i < cards.length; i++) ...[
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _revealed > i
                ? BounceIn(child: cards[i])
                : const SizedBox(width: double.infinity),
          ),
          if (_revealed > i) const SizedBox(height: 12),
        ],

        // Verification count-up: 2(5) + 5 → 15.
        if (_revealed >= 3)
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _count,
              builder: (context, _) {
                final value =
                    (15 * Curves.easeOut.transform(_count.value)).round();
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _checked ? AppColors.successBg : AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: _checked ? AppColors.green : AppColors.border,
                      width: AppSizes.cardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.snap_hw_finalAnswer,
                              style: AppTextStyles.font(
                                context,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _checked
                                    ? AppColors.green
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '2(5) + 5 = $value',
                              style: AppTextStyles.font(
                                context,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_checked)
                        const BounceIn(
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.green,
                            size: 40,
                          ),
                        )
                      else
                        Image.asset(
                          'assets/images/nmimes_front.png',
                          width: 44,
                          height: 44,
                          cacheWidth: 132,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, e, _) => const Icon(
                            Icons.pets_rounded,
                            color: AppColors.primary,
                            size: 36,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SolutionCard extends StatelessWidget {
  final String stepLabel;
  final String? title;
  final List<String> lines;

  const _SolutionCard({
    required this.stepLabel,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: AppSizes.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepLabel,
            style: AppTextStyles.font(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 4),
            Text(
              title!,
              style: AppTextStyles.font(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          ...lines.map((line) {
            final isBold = line.startsWith('2x') || line.startsWith('x =');
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                line,
                style: AppTextStyles.font(
                  context,
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
