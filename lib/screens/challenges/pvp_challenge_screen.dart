import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/chunky_button.dart';
import 'join_challenge_screen.dart';

class PVPChallengeScreen extends StatelessWidget {
  const PVPChallengeScreen({super.key});

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.challenge_dialog_title,
                    style: AppTextStyles.font(context,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E2E2E),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 20, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ChunkyButton(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/start-challenge');
                      },
                      color: AppColors.primary,
                      height: 50,
                      child: Text(
                        context.l10n.challenge_start,
                        style: AppTextStyles.font(context,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChunkyButton(
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withValues(alpha: 0.3),
                          builder: (_) => const JoinChallengeScreen(),
                        );
                      },
                      color: Colors.white,
                      edgeColor: AppColors.border,
                      borderColor: AppColors.border,
                      height: 50,
                      child: Text(
                        context.l10n.challenge_join,
                        style: AppTextStyles.font(context,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
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
