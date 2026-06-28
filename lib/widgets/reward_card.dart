import 'package:flutter/material.dart';
import '../l10n/l10n_extension.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(title,
                style: AppTextStyles.font(context, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                context.l10n.rewardCard_pts(points),
                style: AppTextStyles.font(context,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
