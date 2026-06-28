import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';

class AlgebraStartScreen extends StatelessWidget {
  const AlgebraStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => Navigator.pop(context),
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
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, e, st) => Image.asset(
                    'assets/images/onboarding_char2.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx2, e2, st2) =>
                        const Text('🏆', style: TextStyle(fontSize: 60)),
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
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD6A7), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      // Orange header block
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF79C09),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // Abacus icon
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.calculate_outlined,
                                color: Color(0xFFF79C09),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.l10n.algebra_title,
                              style: AppTextStyles.font(context,
                                fontSize: 22,
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
                        icon: Icons.help_outline_rounded,
                        label: context.l10n.algebra_questions_label,
                        value: context.l10n.algebra_questions_value,
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
                      _InfoRow(
                        color: const Color(0xFFE2562C),
                        bgColor: const Color(0x14E2562C),
                        borderColor: const Color(0x3DE2562C),
                        icon: Icons.bolt_outlined,
                        label: context.l10n.algebra_combo_label,
                        value: context.l10n.algebra_combo_value,
                      ),
                      const SizedBox(height: 10),

                      const Spacer(),

                      // Start button
                      SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                              context, '/algebra-challenge'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                              side:
                                  const BorderSide(color: Colors.white, width: 1),
                            ),
                          ),
                          child: Text(
                            context.l10n.algebra_start_challenge,
                            style: AppTextStyles.font(context,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
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
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF101828),
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
