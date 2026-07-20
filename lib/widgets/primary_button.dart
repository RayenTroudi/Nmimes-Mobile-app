import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'chunky_button.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ChunkyButton(
      onTap: onTap,
      color: color,
      width: double.infinity,
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.font(context,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.white,
        ).copyWith(letterSpacing: 0.8),
      ),
    );
  }
}
