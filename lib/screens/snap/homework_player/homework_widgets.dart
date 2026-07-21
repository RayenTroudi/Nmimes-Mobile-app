import 'package:flutter/material.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/chunky_button.dart';

/// The equation banner that sits above every step.
///
/// Const-constructed and hoisted out of the step subtree so answering a
/// question never rebuilds or repaints it — previously each `setState`
/// re-ran `MediaQuery.of(context).size` here and repainted the card.
class HwProblemCard extends StatelessWidget {
  final String equation;
  const HwProblemCard({super.key, required this.equation});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    // Scale with the screen but stay legible on small phones and sane on
    // tablets, matching the original clamp.
    final size = (MediaQuery.sizeOf(context).width * 0.07).clamp(20.0, 28.0);

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Text(
              l.snap_solveFor,
              style: AppTextStyles.font(
                context,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              equation,
              style: AppTextStyles.font(
                context,
                fontSize: size,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fox + "Step N of 4" caption above each step's question.
class HwStepLabel extends StatelessWidget {
  final String label;
  const HwStepLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/fox_sunglasses.png',
          width: 32,
          height: 32,
          // Decode at display size rather than the source's 220x254.
          cacheWidth: 96,
          fit: BoxFit.contain,
          errorBuilder: (ctx, e, _) =>
              const Icon(Icons.pets_rounded, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.font(
              context,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Duolingo-style feedback sheet that slides up from the bottom.
///
/// Same shape as the lesson player's sheet so both flows read identically;
/// this one additionally offers the "stuck?" actions after repeated misses.
class HwFeedbackSheet extends StatelessWidget {
  final bool correct;
  final String title;
  final String detail;
  final String buttonLabel;
  final VoidCallback onPressed;

  /// After two misses the sheet offers a way out instead of just "try again".
  final bool showStuckActions;
  final VoidCallback? onSkip;

  const HwFeedbackSheet({
    super.key,
    required this.correct,
    required this.title,
    required this.detail,
    required this.buttonLabel,
    required this.onPressed,
    this.showStuckActions = false,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final accent = correct ? AppColors.success : AppColors.error;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: BoxDecoration(
          color: correct ? AppColors.successBg : AppColors.errorBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
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
                      correct ? Icons.check_rounded : Icons.lightbulb_outline_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.font(
                        context,
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
                  style: AppTextStyles.font(
                    context,
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
                  style: AppTextStyles.font(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
              if (showStuckActions && onSkip != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: onSkip,
                    child: Text(
                      l.snap_hw_skipStep,
                      style: AppTextStyles.font(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Staggered slide+fade entrance for a step's contents.
///
/// The step itself already fades in via the player's [AnimatedSwitcher];
/// this adds the per-child cascade that makes the screen feel alive.
class HwStagger extends StatelessWidget {
  final int index;
  final Widget child;

  const HwStagger({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(index),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}
