import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class DoesThisMakeSenseScreen extends StatelessWidget {
  const DoesThisMakeSenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      body: Stack(
        children: [
          // Blurred background — simulated captured content
          Positioned.fill(
            child: Container(
              color: const Color(0xFFD6CEBC),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back,
                            color: AppColors.textPrimary, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Snap a Homework',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0C8B6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Solve for x:',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '2x + 5 = 15',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Modal bottom sheet style popup
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // White card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Does this make sense?',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _SenseButton(
                              label: 'Not Yet',
                              filled: false,
                              onTap: () => Navigator.pushReplacementNamed(
                                  context, '/snap-send'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SenseButton(
                              label: 'Yes',
                              filled: true,
                              onTap: () => Navigator.pushNamed(
                                  context, '/snap-success'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Below-card content (solution text visible behind)
                Container(
                  color: const Color(0xFFD6CEBC),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick check',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Put x = 5 back into the equation:',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '2(5) + 5 = 10 + 5 = 15 ✓',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom action row (Back / Done)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: const Color(0xFFD6CEBC),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Row(
                children: [
                  Expanded(
                    child: _SenseButton(
                      label: 'Back',
                      filled: false,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _SenseButton(
                      label: 'Done',
                      filled: true,
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (r) => false),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SenseButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _SenseButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: filled
              ? const Border.fromBorderSide(
                  BorderSide(color: Colors.white, width: 2.5))
              : Border.all(color: AppColors.primary, width: 2),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: filled ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
