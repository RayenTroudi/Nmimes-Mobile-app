import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/fox_mascot.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  void _onNavTap(BuildContext context, int index) {
    const routes = ['/home', '/ai-chat', '/challenges', '/profile'];
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  static const _badges = [
    _Badge('⚡', 'Quick Thinker', 'Solved 10 problems under 1 min', true),
    _Badge('🏆', 'First Win', 'Complete your first challenge', true),
    _Badge('🤝', 'Team Player', 'Joined a study room', true),
    _Badge('🧙', 'Math Wizard', 'Complete 50 challenges', false),
    _Badge('💯', 'Perfect Score', 'Get 100% on exam prep', false),
    _Badge('🏅', 'Legend', 'Earn 10,000 points', false),
  ];

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _badges.where((b) => b.unlocked).length;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Orange header with rounded bottom corners
                  Container(
                    color: AppColors.primary,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text('🏆', style: TextStyle(fontSize: 26)),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Rewards',
                                            style: GoogleFonts.poppins(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "You're doing amazing!",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFFFEDD4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Circular profile avatar
                                Container(
                                  width: 107,
                                  height: 107,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: ClipOval(child: FoxMascot(size: 107)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _StatPill(
                                      icon: '⭐',
                                      label: '150',
                                      sublabel: 'Points',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _StatPill(
                                      icon: '🎖️',
                                      label: '$unlockedCount',
                                      sublabel: 'Badges',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // White content section with rounded top corners
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF7E8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4E4C3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '🏆 Collect all badges!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2E2E2E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You have $unlockedCount badges unlocked',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF5A6677),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Badge grid — two columns, rows size to tallest card
                        for (int row = 0; row < (_badges.length / 2).ceil(); row++) ...[
                          if (row > 0) const SizedBox(height: 14),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: _BadgeCard(badge: _badges[row * 2])),
                                const SizedBox(width: 14),
                                if (row * 2 + 1 < _badges.length)
                                  Expanded(child: _BadgeCard(badge: _badges[row * 2 + 1]))
                                else
                                  const Expanded(child: SizedBox()),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          BottomNavBar(
            currentIndex: 0,
            onTap: (i) => _onNavTap(context, i),
          ),
        ],
      ),
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class _Badge {
  final String icon;
  final String title;
  final String description;
  final bool unlocked;
  const _Badge(this.icon, this.title, this.description, this.unlocked);
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String icon;
  final String label;
  final String sublabel;
  const _StatPill({required this.icon, required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 32 / 24,
                ),
              ),
              Text(
                sublabel,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFFEDD4),
                  height: 16 / 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final _Badge badge;
  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    if (badge.unlocked) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 260),
        child: Container(
        padding: const EdgeInsets.all(3.45),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.72),
          border: Border.all(color: const Color(0xFFF79C09), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge.icon,
              style: const TextStyle(fontSize: 42, height: 1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                badge.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A5565),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x3DF05F01),
                borderRadius: BorderRadius.circular(1000),
              ),
              child: Text(
                '✓ UNLOCKED',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/claim-reward'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(1000),
                ),
                child: Text(
                  'Claim your Reward',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    }

    // Locked card — smaller, more padding, no chip or button
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 200),
      child: Container(
      padding: const EdgeInsets.all(24.18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.72),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 42, height: 1), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A5565),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      ),
    );
  }
}
