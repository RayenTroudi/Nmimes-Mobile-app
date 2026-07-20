import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'chunky_button.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SecondaryButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChunkyButton(
      onTap: onTap,
      color: AppColors.white,
      edgeColor: AppColors.border,
      borderColor: AppColors.border,
      width: double.infinity,
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.font(context,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ).copyWith(letterSpacing: 0.8),
      ),
    );
  }
}
