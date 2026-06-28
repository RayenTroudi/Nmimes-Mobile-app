import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';

class AlgebraCompletedScreen extends StatelessWidget {
  const AlgebraCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final score = args?['score'] as int? ?? 0;
    final solved = args?['solved'] as int? ?? 0;
    final total = args?['total'] as int? ?? 10;
    final bestStreak = args?['bestStreak'] as int? ?? 0;

    final isPerfect = solved == total;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
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
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/challenges', (r) => false),
                  ),
                ],
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
                  'assets/images/nmimes_winking.png',
                  width: 124,
                  height: 124,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, e, st) => Image.asset(
                    'assets/images/onboarding_char2.png',
                    width: 124,
                    height: 124,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx2, e2, st2) =>
                        const Text('🎉', style: TextStyle(fontSize: 60)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // White card with orange border (stats only)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(30, 24, 30, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFF79C09), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isPerfect
                          ? context.l10n.algebra_completed_perfect
                          : context.l10n.algebra_completed_nice_try,
                      style: AppTextStyles.font(context,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPerfect
                          ? context.l10n.algebra_completed_perfect_sub
                          : context.l10n.algebra_completed_nice_try_sub,
                      style: AppTextStyles.font(context,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF364153),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    _StatRow(
                      label: context.l10n.challenge_total_points,
                      value: '$score',
                      bgColor: const Color(0xFFFEF2EB),
                      borderColor: const Color(0x3DF05F01),
                      labelColor: const Color(0xFF101828),
                      valueColor: const Color(0xFFF05F01),
                      labelSize: 15,
                      valueSize: 24,
                    ),
                    const SizedBox(height: 10),
                    _StatRow(
                      label: context.l10n.challenge_questions_solved,
                      value: '$solved/$total',
                      bgColor: const Color(0x140588C4),
                      borderColor: const Color(0x3D0588C4),
                      labelColor: const Color(0xFF101828),
                      valueColor: const Color(0xFF0588C4),
                      labelSize: 13,
                      valueSize: 20,
                    ),
                    const SizedBox(height: 10),
                    _StatRow(
                      label: context.l10n.challenge_best_streak,
                      value: '$bestStreak 🔥',
                      bgColor: const Color(0x14E97D9C),
                      borderColor: const Color(0x3DE97D9C),
                      labelColor: const Color(0xFF101828),
                      valueColor: const Color(0xFFE97D9C),
                      labelSize: 13,
                      valueSize: 20,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Collect Rewards button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/challenges', (r) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  child: Text(
                    context.l10n.challenge_collect_rewards,
                    style: AppTextStyles.font(context,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            // Play Again button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, '/algebra-challenge'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    context.l10n.challenge_play_again,
                    style: AppTextStyles.font(context,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color bgColor;
  final Color borderColor;
  final Color labelColor;
  final Color valueColor;
  final double labelSize;
  final double valueSize;

  const _StatRow({
    required this.label,
    required this.value,
    required this.bgColor,
    required this.borderColor,
    required this.labelColor,
    required this.valueColor,
    required this.labelSize,
    required this.valueSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.font(context,
              fontSize: labelSize,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.font(context,
              fontSize: valueSize,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
