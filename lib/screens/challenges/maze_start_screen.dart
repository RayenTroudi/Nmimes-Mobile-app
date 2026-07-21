import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/flexible_column.dart';

class MazeStartScreen extends StatelessWidget {
  const MazeStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Back arrow
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),

            // Mascot in white circle
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
                  errorBuilder: (ctx, e, st) =>
                      const Text('🗺️', style: TextStyle(fontSize: 60)),
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
                      color: AppColors.border,
                      width: AppSizes.cardBorder,
                    ),
                  ),
                  child: FlexibleColumn(
                    children: [
                      // Orange header block
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
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
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.map_outlined,
                                color: Color(0xFF44C4A1),
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.maze_title,
                              style: AppTextStyles.font(
                                context,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.maze_subtitle,
                              style: AppTextStyles.font(
                                context,
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
                        value: context.l10n.maze_how_to_play_value,
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        color: const Color(0xFFE2562C),
                        bgColor: const Color(0x14E2562C),
                        borderColor: const Color(0x3DE2562C),
                        icon: Icons.emoji_events_outlined,
                        label: context.l10n.maze_goal_label,
                        value: context.l10n.maze_goal_value,
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

                      // Rewards box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7EB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primaryLight,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.diamond_outlined,
                              color: Color(0xFF75CEF9),
                              size: 36,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.l10n.maze_earn_400,
                              style: AppTextStyles.font(
                                context,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2E2E2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.l10n.challenge_bonus_streak,
                              style: AppTextStyles.font(
                                context,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
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
                            Navigator.pushNamed(context, '/maze-challenge'),
                        color: AppColors.primary,
                        width: double.infinity,
                        height: 60,
                        child: Text(
                          context.l10n.maze_start_adventure,
                          style: AppTextStyles.font(
                            context,
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
                  style: AppTextStyles.font(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.font(
                    context,
                    fontSize: 12,
                    color: const Color(0xFF5A6677),
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
