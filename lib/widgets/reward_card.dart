import 'package:flutter/material.dart';
import '../l10n/l10n_extension.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';
import 'chunky_button.dart';

class RewardCard extends StatelessWidget {
  final String title;
  final String icon;
  final int points;
  final VoidCallback? onTap;

  const RewardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.points,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.font(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.pink.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                context.l10n.rewardCard_pts(points),
                style: AppTextStyles.font(
                  context,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.pinkDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
