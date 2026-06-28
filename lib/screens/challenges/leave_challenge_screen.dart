import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';

class LeaveChallengeScreen extends StatelessWidget {
  const LeaveChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.challenge_leave_title,
                style: AppTextStyles.font(context,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E2E2E),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.pvp_leave_body,
                style: AppTextStyles.font(context,
                  fontSize: 14,
                  color: const Color(0xFF2E2E2E),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.pvp_leave_confirm,
                style: AppTextStyles.font(context,
                  fontSize: 14,
                  color: const Color(0xFF2E2E2E),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/challenges', (r) => false),
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          context.l10n.challenge_leave_yes,
                          style: AppTextStyles.font(context,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          context.l10n.challenge_leave_no,
                          style: AppTextStyles.font(context,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
