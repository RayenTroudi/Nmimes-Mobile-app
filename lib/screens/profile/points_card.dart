import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class ProfilePointsCard extends StatelessWidget {
  final int? points;
  const ProfilePointsCard({super.key, this.points});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/rewards'),
      child: Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/icon_trophy.png',
            width: 31,
            height: 31,
            color: Colors.white,
            errorBuilder: (_, _, _) => const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 31),
          ),
          const SizedBox(width: 12),
          Text(
            context.l10n.pointsCard_label,
            style: AppTextStyles.font(context,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points?.toString() ?? '150',
                style: AppTextStyles.font(context,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                context.l10n.pointsCard_unit,
                style: AppTextStyles.font(context,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFEDD4),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
