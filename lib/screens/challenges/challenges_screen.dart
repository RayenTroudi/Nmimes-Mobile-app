import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import '../../widgets/fox_mascot.dart';
import 'join_challenge_screen.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  int _tab = 0;

  static const _soloChallenge = [
    _ChallengeData(isBanner: true),
    _ChallengeData(
      icon: '🧩',
      title: 'Puzzle Pro',
      subtitle: 'Solve 10 puzzles to get Champion badge',
      points: '+150 pts',
      pointsColor: Color(0xFFE97D9C),
      progress: 0.8,
      progressLabel: '8/10',
      difficulty: 'Medium',
      difficultyTextColor: Color(0xFFa65f00),
      difficultyBgColor: Color(0xFFFEF9C2),
    ),
    _ChallengeData(
      icon: '🏆',
      title: 'Algebra Master',
      subtitle: 'Solve 10 questions to get your Quick Thinker badge.',
      points: '+50 pts',
      pointsColor: Color(0xFF35A468),
      progress: 0.7,
      progressLabel: '7/10',
      difficulty: 'Easy',
      difficultyTextColor: Color(0xFF008236),
      difficultyBgColor: Color(0xFFDCFCE7),
      startRoute: '/algebra-start',
    ),
    _ChallengeData(
      icon: '⚡',
      title: 'Speed Demon',
      subtitle: 'Complete 5 problems to get your Math Wizard',
      points: '+100 pts',
      pointsColor: Color(0xFFFDB500),
      progress: 0.6,
      progressLabel: '3/5',
      difficulty: 'Medium',
      difficultyTextColor: Color(0xFFa65f00),
      difficultyBgColor: Color(0xFFFEF9C2),
    ),
    _ChallengeData(
      icon: '🔗',
      title: 'Perfect Chain',
      subtitle: 'Get 10 correct answers in a row and earn Perfect Scorer',
      points: '+200 pts',
      pointsColor: Color(0xFF0588C4),
      progress: 0.8,
      progressLabel: '12/15',
      difficulty: 'Hard',
      difficultyTextColor: Color(0xFFF79C09),
      difficultyBgColor: Color(0x12F79C09),
    ),
    _ChallengeData(
      icon: '🗺️',
      title: 'Maze Master',
      subtitle: 'Complete 5 mazes in a row and get Master badge',
      points: '+100 pts',
      pointsColor: Color(0xFF6A7282),
      progress: 0.6,
      progressLabel: '3/5',
      difficulty: 'Hard',
      difficultyTextColor: Color(0xFFF79C09),
      difficultyBgColor: Color(0x12F79C09),
      startRoute: '/maze-start',
    ),
    _ChallengeData(
      icon: '📐',
      title: 'Geometry God',
      subtitle: 'Master all geometry concepts and get your Legend',
      points: '+300 pts',
      pointsColor: Color(0xFFE2562C),
      isLocked: true,
    ),
  ];

  void _showChallengePopup(BuildContext context, {String startRoute = '/start-challenge'}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (_) => _ChallengeChoiceDialog(startRoute: startRoute),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          _ChallengesHeader(),
          // Tab selector
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                _TabPill(
                  label: '🎯  Challenges',
                  active: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                const SizedBox(width: 12),
                _TabPill(
                  label: '⚔️  PVP',
                  active: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tab == 0
                ? _SoloChallenges(
                    challenges: _soloChallenge,
                    onPlay: (route) => _showChallengePopup(context, startRoute: route),
                  )
                : _PVPTab(
                    onStart: () => _showChallengePopup(context),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChallengesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Challenges',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          'Ready for a new challenge?',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(child: FoxMascot(size: 52)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('❤️', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 8),
                        const Text('❤️', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 8),
                        Text('🤍',
                            style: TextStyle(
                                fontSize: 28,
                                color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '2 Lives remaining',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabPill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: active ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.cardBorder,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChallengeData {
  final bool isBanner;
  final bool isLocked;
  final String icon;
  final String title;
  final String subtitle;
  final String? points;
  final Color pointsColor;
  final double? progress;
  final String? progressLabel;
  final String? difficulty;
  final Color difficultyTextColor;
  final Color difficultyBgColor;
  final String startRoute;

  const _ChallengeData({
    this.isBanner = false,
    this.isLocked = false,
    this.icon = '',
    this.title = '',
    this.subtitle = '',
    this.points,
    this.pointsColor = const Color(0xFF35A468),
    this.progress,
    this.progressLabel,
    this.difficulty,
    this.difficultyTextColor = const Color(0xFF008236),
    this.difficultyBgColor = const Color(0xFFDCFCE7),
    this.startRoute = '/start-challenge',
  });
}

class _SoloChallenges extends StatelessWidget {
  final List<_ChallengeData> challenges;
  final void Function(String route) onPlay;

  const _SoloChallenges({required this.challenges, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      itemCount: challenges.length,
      itemBuilder: (_, i) {
        final c = challenges[i];
        if (c.isBanner) return _MotivationBanner();
        if (c.isLocked) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _LockedCard(data: c),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ChallengeCard(data: c, onPlay: () => onPlay(c.startRoute)),
        );
      },
    );
  }
}

class _MotivationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.asset(
              'assets/images/nmimes_inlove.png',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep going!',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "You're 3 away from Algebra Master! 💪",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5A6677),
                    height: 1.4,
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

class _ChallengeCard extends StatelessWidget {
  final _ChallengeData data;
  final VoidCallback onPlay;

  const _ChallengeCard({required this.data, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + title/subtitle + pts badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.icon, style: const TextStyle(fontSize: 40, height: 1)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF4A5565),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Points badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: data.pointsColor,
                  borderRadius: BorderRadius.circular(1000),
                ),
                child: Text(
                  data.points ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF364153),
                ),
              ),
              Text(
                data.progressLabel ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(1000),
            child: LinearProgressIndicator(
              value: data.progress ?? 0,
              minHeight: 10,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(data.pointsColor),
            ),
          ),
          const SizedBox(height: 12),
          // Bottom row: difficulty + Play Now
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: data.difficultyBgColor,
                  borderRadius: BorderRadius.circular(1000),
                ),
                child: Text(
                  data.difficulty ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: data.difficultyTextColor,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onPlay,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: Text(
                    'Play Now! 🎮',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  final _ChallengeData data;
  const _LockedCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.icon, style: const TextStyle(fontSize: 40, height: 1)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF4A5565),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: data.pointsColor,
                  borderRadius: BorderRadius.circular(1000),
                ),
                child: Text(
                  data.points ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '🔒 Complete previous challenges to unlock!',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6A7282),
            ),
          ),
        ],
      ),
    );
  }
}

class _PVPTab extends StatelessWidget {
  final VoidCallback onStart;
  const _PVPTab({required this.onStart});

  static const _leaders = [
    _LeaderEntry('🥇', 'Ahmed K.', '🔥 15 days streak', '2450', false, true),
    _LeaderEntry('🥈', 'Sara M.', '🔥 12 days streak', '1850', false, true),
    _LeaderEntry('🥉', 'Meriam (You)', '🔥 10 days streak', '1650', true, true),
    _LeaderEntry('#4', 'Meriam', '🔥 09 days streak', '1550', false, false),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        // Yellow PVP banner card
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF79C09),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PVP\nChallenges',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "See how you're doing",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFCE7F3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('⚔️', style: TextStyle(fontSize: 48)),
                ],
              ),
              const SizedBox(height: 16),
              // Start Challenge button
              GestureDetector(
                onTap: onStart,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Start Challenge 🎯',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Leaderboard card
        Container(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD6A8), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    'Leaderboard',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF101828),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (final entry in _leaders) ...[
                _LeaderRow(entry: entry),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderEntry {
  final String medal;
  final String name;
  final String streak;
  final String points;
  final bool isYou;
  final bool hasMedalEmoji;
  const _LeaderEntry(this.medal, this.name, this.streak, this.points, this.isYou, this.hasMedalEmoji);
}

class _LeaderRow extends StatelessWidget {
  final _LeaderEntry entry;
  const _LeaderRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final bg = entry.isYou ? const Color(0x99F05F01) : (entry.hasMedalEmoji ? Colors.transparent : const Color(0xFFF9FAFB));
    final textColor = entry.isYou ? Colors.white : const Color(0xFF0A0A0A);
    final subColor = entry.isYou ? Colors.white : const Color(0xFF4A5565);
    final ptsSubColor = entry.isYou ? Colors.white : const Color(0xFF6A7282);
    final border = entry.isYou
        ? Border.all(color: AppColors.primary, width: 1)
        : (entry.hasMedalEmoji
            ? Border.all(color: const Color(0xFFFFF085), width: 1)
            : Border.all(color: const Color(0xFFFFF085), width: 1));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(13),
        border: border,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              entry.medal,
              style: GoogleFonts.poppins(
                fontSize: entry.hasMedalEmoji ? 28 : 20,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                Text(
                  entry.streak,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.points,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              Text(
                'points',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ptsSubColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChallengeChoiceDialog extends StatelessWidget {
  final String startRoute;
  const _ChallengeChoiceDialog({this.startRoute = '/start-challenge'});

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  'PVP Challenge',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20, color: Color(0xFF2E2E2E)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, startRoute);
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Start Challenge',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
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
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        barrierColor: Colors.black.withValues(alpha: 0.3),
                        builder: (_) => const JoinChallengeScreen(),
                      );
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Join Challenge',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
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
    );
  }
}
