import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class ChallengeCompletedScreen extends StatelessWidget {
  const ChallengeCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final score = args?['score'] as int? ?? 0;
    final solved = args?['solved'] as int? ?? 0;
    final total = args?['total'] as int? ?? 8;
    final bestStreak = args?['bestStreak'] as int? ?? 0;

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
                  'assets/images/onboarding_char2.png',
                  width: 124,
                  height: 124,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, e, st) =>
                      const Text('🎉', style: TextStyle(fontSize: 60)),
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
                  border: Border.all(color: const Color(0xFFF79C09), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // "Perfect!" heading
                    Text(
                      'Perfect!',
                      style: GoogleFonts.arimo(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      "You're an amazing\u{1F31F}",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5A6677),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stat rows
                    _StatRow(
                      label: 'Total Points',
                      value: '$score',
                      bgColor: const Color(0x14F05F01),
                      borderColor: const Color(0x3DF05F01),
                      labelColor: const Color(0xFF101828),
                      valueColor: const Color(0xFFF05F01),
                      labelSize: 15,
                      valueSize: 24,
                    ),
                    const SizedBox(height: 10),
                    _StatRow(
                      label: 'Questions Solved',
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
                      label: 'Best Streak',
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
                    'Collect Rewards!',
                    style: GoogleFonts.poppins(
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
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/challenge'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'Play Again',
                    style: GoogleFonts.poppins(
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
            style: GoogleFonts.poppins(
              fontSize: labelSize,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
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
