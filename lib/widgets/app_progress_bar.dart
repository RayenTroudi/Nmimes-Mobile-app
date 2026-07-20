import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// Thick pill-shaped progress bar with a subtle top shine, like
/// Duolingo's lesson progress.
class AppProgressBar extends StatelessWidget {
  final double value; // 0.0 - 1.0
  final Color color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.height = AppSizes.progressBar,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        height: height,
        color: AppColors.dotInactive,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            widthFactor: value.clamp(0.0, 1.0),
            heightFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Align(
                alignment: const Alignment(0, -0.5),
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Container(
                    height: height * 0.25,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
