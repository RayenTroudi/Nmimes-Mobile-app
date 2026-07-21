import 'package:flutter/material.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/bounce_in.dart';
import '../../../widgets/chunky_button.dart';

/// Step 1 — the equation appears piece by piece with bouncy entrances,
/// and the mystery `x` pulses with a "?". The fox invites the child in.
class IntroEquationStep extends StatefulWidget {
  final VoidCallback onComplete;
  const IntroEquationStep({super.key, required this.onComplete});

  @override
  State<IntroEquationStep> createState() => _IntroEquationStepState();
}

class _IntroEquationStepState extends State<IntroEquationStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Widget _piece(String text, int order, {bool isMystery = false}) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMystery ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isMystery ? AppColors.primaryDark : AppColors.border,
          width: AppSizes.cardBorder,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.font(context,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: isMystery ? AppColors.white : AppColors.textPrimary,
        ),
      ),
    );

    final child = isMystery
        ? AnimatedBuilder(
            animation: _pulse,
            builder: (context, c) => Transform.scale(
              scale: 1.0 + 0.08 * Curves.easeInOut.transform(_pulse.value),
              child: c,
            ),
            child: chip,
          )
        : chip;

    return BounceIn(
      delay: Duration(milliseconds: 250 * order),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            l.lesson_intro_title,
            textAlign: TextAlign.center,
            style: AppTextStyles.font(context,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // The equation, piece by piece: 2x  +  5  =  15
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _piece('2', 0),
              _piece('x ?', 1, isMystery: true),
              _piece('+', 2),
              _piece('5', 3),
              _piece('=', 4),
              _piece('15', 5),
            ],
          ),
          const Spacer(),
          // Fox + speech bubble
          BounceIn(
            delay: const Duration(milliseconds: 1600),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/fox_snap.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, _) => const Text(
                    '🦊',
                    style: TextStyle(fontSize: 64),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                          color: AppColors.border,
                          width: AppSizes.cardBorder),
                    ),
                    child: Text(
                      l.lesson_intro_fox,
                      style: AppTextStyles.font(context,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
          ChunkyButton(
            onTap: widget.onComplete,
            color: AppColors.primary,
            width: double.infinity,
            child: Text(
              l.snap_button_continue,
              style: AppTextStyles.font(context,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
