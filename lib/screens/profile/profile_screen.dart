import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import 'points_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Avatar radius + how much of it overlaps into the cream section
    const double avatarSize = 100;
    const double avatarOverlap = 50; // half the avatar dips into cream

    return ColoredBox(
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Orange section: status bar + "Profile" title only ──────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Text(
                'Profile',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Gap between title and the avatar boundary
          const SizedBox(height: 20),

          // ── Boundary zone: avatar straddles orange → cream ─────────
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cream body with rounded top corners
                Positioned.fill(
                  top: avatarOverlap,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF7E8),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                          20, avatarOverlap + 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // "John" name sits just below the avatar
                          Text(
                            'John',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E2E2E),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Earned Points card
                          const ProfilePointsCard(),
                          const SizedBox(height: 16),

                          // Help row
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/help'),
                            child: Container(
                              height: 60,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFFE0E0E0)),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Help',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2E2E2E),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Log Out row
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/logout'),
                            child: Container(
                              height: 60,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBD7C8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFFE62929)),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Log Out',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFE62929),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Avatar circle positioned to straddle the boundary
                Positioned(
                  top: 0,
                  left: 20,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: avatarSize,
                        height: avatarSize,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/nmimes_front.png',
                            width: avatarSize,
                            height: avatarSize,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: const Color(0xFFE8E8E8),
                              child: const Icon(Icons.person_rounded,
                                  color: Colors.grey, size: 60),
                            ),
                          ),
                        ),
                      ),
                      // Edit badge — bottom-right of avatar
                      Positioned(
                        right: -4,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/avatar'),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded,
                                color: AppColors.primary, size: 15),
                          ),
                        ),
                      ),
                    ],
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
