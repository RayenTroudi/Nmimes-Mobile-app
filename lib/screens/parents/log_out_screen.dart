import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/spacing.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../l10n/l10n_extension.dart';

class LogOutScreen extends StatelessWidget {
  const LogOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, size: 56, color: Colors.red),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.parentLogOut_title,
                  style: AppTextStyles.font(context,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.parentLogOut_body,
                style: AppTextStyles.font(context,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: l10n.parentLogOut_button_yes,
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/', (r) => false),
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                label: l10n.parentLogOut_button_cancel,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
