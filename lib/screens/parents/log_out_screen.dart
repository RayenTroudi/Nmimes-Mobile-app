import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/spacing.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

class LogOutScreen extends StatelessWidget {
  const LogOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      body: Center(
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
              Text('Log Out?', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Are you sure you want to log out of your parent account?',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'Yes, Log Out',
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/', (r) => false),
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                label: 'Cancel',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
