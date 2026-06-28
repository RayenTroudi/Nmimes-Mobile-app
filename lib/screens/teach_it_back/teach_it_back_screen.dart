import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/spacing.dart';
import '../../widgets/primary_button.dart';

class TeachItBackScreen extends StatelessWidget {
  const TeachItBackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.record_voice_over_outlined,
                    size: 72, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(l10n.teachItBack_title,
                  style: AppTextStyles.font(context, fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.teachItBack_subtitle,
                style: AppTextStyles.font(context, fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _FeatureRow(icon: Icons.mic_outlined, text: l10n.teachItBack_feature_record),
              const SizedBox(height: AppSpacing.md),
              _FeatureRow(icon: Icons.psychology_outlined, text: l10n.teachItBack_feature_aiEvaluates),
              const SizedBox(height: AppSpacing.md),
              _FeatureRow(icon: Icons.star_outline, text: l10n.teachItBack_feature_earnPoints),
              const SizedBox(height: AppSpacing.xxxl),
              PrimaryButton(
                label: l10n.teachItBack_button_start,
                onTap: () => Navigator.pushNamed(context, '/explaining-back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: AppSpacing.md),
        Text(text, style: AppTextStyles.font(context, fontSize: 14, color: AppColors.textPrimary)),
      ],
    );
  }
}
