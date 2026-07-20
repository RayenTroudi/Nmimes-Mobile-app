import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/chunky_button.dart';

class StartChallengeScreen extends StatelessWidget {
  const StartChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Back arrow
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Color(0xFF2E2E2E), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Character image in circle
            Center(
              child: Container(
                width: 158,
                height: 158,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/onboarding_char2.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, e, st) => const Text(
                    '🧩',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // White info card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                        color: AppColors.border, width: AppSizes.cardBorder),
                  ),
                  child: Column(
                    children: [
                      // Orange header block
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.primaryDark,
                              offset: Offset(0, AppSizes.buttonEdge),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Puzzle icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.extension,
                                color: Color(0xFF6FABE6),
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.challenge_puzzle_title,
                              style: AppTextStyles.font(context,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.challenge_puzzle_subtitle,
                              style: AppTextStyles.font(context,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info rows
                      _InfoRow(
                        color: const Color(0xFF0588C4),
                        bgColor: const Color(0x140588C4),
                        borderColor: const Color(0x3D0588C4),
                        icon: Icons.track_changes_outlined,
                        label: context.l10n.challenge_how_to_play,
                        value: context.l10n.challenge_how_to_play_value,
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        color: const Color(0xFFE2562C),
                        bgColor: const Color(0x14E2562C),
                        borderColor: const Color(0x3DE2562C),
                        icon: Icons.grid_view_rounded,
                        label: context.l10n.challenge_puzzles_label,
                        value: context.l10n.challenge_puzzles_value,
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        color: const Color(0xFFE97D9C),
                        bgColor: const Color(0x14E97D9C),
                        borderColor: const Color(0x3DE97D9C),
                        icon: Icons.favorite_border,
                        label: context.l10n.challenge_lives_label,
                        value: context.l10n.challenge_lives_value,
                      ),
                      const SizedBox(height: 10),

                      // Points reward box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7EB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF79C09), width: 1),
                        ),
                        child: Column(
                          children: [
                            // Trophy icon
                            Image.asset(
                              'assets/images/trophy.png',
                              width: 36,
                              height: 36,
                              errorBuilder: (ctx, e, st) =>
                                  const Icon(Icons.emoji_events, color: Color(0xFFF79C09), size: 36),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.l10n.challenge_earn_300,
                              style: AppTextStyles.font(context,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2E2E2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.l10n.challenge_bonus_streak,
                              style: AppTextStyles.font(context,
                                fontSize: 13,
                                color: const Color(0xFF5A6677),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Start button
                      ChunkyButton(
                        onTap: () =>
                            Navigator.pushNamed(context, '/challenge'),
                        color: AppColors.primary,
                        width: double.infinity,
                        child: Text(
                          context.l10n.challenge_start_puzzle,
                          style: AppTextStyles.font(context,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.font(context,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.font(context,
                    fontSize: 12,
                    color: const Color(0xFF4A5565),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
