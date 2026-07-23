import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/responsive.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';

class AppTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool obscure;

  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: context.rs(56)),
      child: SizedBox(
        width: 335,
        child: TextField(
          controller: controller,
          obscureText: obscure,
          style: AppTextStyles.font(context,
              fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.font(context,
                fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textHint),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                  color: AppColors.border, width: AppSizes.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: AppSizes.cardBorder),
            ),
            filled: true,
            fillColor: AppColors.white,
          ),
        ),
      ),
    );
  }
}
