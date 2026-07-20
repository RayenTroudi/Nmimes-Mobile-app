import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/fox_mascot.dart';
import 'join_challenge_screen.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  int _tab = 0;

  static List<_ChallengeData> _buildChallenges(BuildContext context) {
    final l = context.l10n;
    return [
      _ChallengeData(
        icon: '🧩',
        title: l.challenge_title_puzzlePro,
        subtitle: l.challenge_subtitle_puzzlePro,
        points: '+150 pts',
        pointsColor: const Color(0xFFE97D9C),
        progress: 0.8,
        progressLabel: '8/10',
        difficulty: l.challenge_difficulty_medium,
      ),
      _ChallengeData(
        icon: '🏆',
        title: l.challenge_title_algebraMaster,
        subtitle: l.challenge_subtitle_algebraMaster,
        points: '+50 pts',
        pointsColor: const Color(0xFF35A468),
        progress: 0.7,
        progressLabel: '7/10',
        difficulty: l.challenge_difficulty_easy,
        startRoute: '/algebra-start',
      ),
      _ChallengeData(
        icon: '⚡',
        title: l.challenge_title_speedDemon,
        subtitle: l.challenge_subtitle_speedDemon,
        points: '+100 pts',
        pointsColor: const Color(0xFFFDB500),
        progress: 0.6,
        progressLabel: '3/5',
        difficulty: l.challenge_difficulty_medium,
      ),
      _ChallengeData(
        icon: '🔗',
        title: l.challenge_title_perfectChain,
        subtitle: l.challenge_subtitle_perfectChain,
        points: '+200 pts',
        pointsColor: const Color(0xFF0588C4),
        progress: 0.8,
        progressLabel: '12/15',
        difficulty: l.challenge_difficulty_hard,
      ),
      _ChallengeData(
        icon: '🗺️',
        title: l.challenge_title_mazeMaster,
        subtitle: l.challenge_subtitle_mazeMaster,
        points: '+100 pts',
        pointsColor: const Color(0xFF6A7282),
        progress: 0.6,
        progressLabel: '3/5',
        difficulty: l.challenge_difficulty_hard,
        startRoute: '/maze-start',
      ),
      _ChallengeData(
        icon: '📐',
        title: l.challenge_title_geometryGod,
        subtitle: l.challenge_subtitle_geometryGod,
        points: '+300 pts',
        pointsColor: const Color(0xFFE2562C),
        isLocked: true,
      ),
    ];
  }

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
                  label: context.l10n.challenge_tab_challenges,
                  active: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                const SizedBox(width: 12),
                _TabPill(
                  label: context.l10n.challenge_tab_pvp,
                  active: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tab == 0
                ? _ChallengeMap(
                    challenges: _buildChallenges(context),
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
                          context.l10n.challenge_title,
                          style: AppTextStyles.font(context,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          context.l10n.challenge_subtitle,
                          style: AppTextStyles.font(context,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
              // Stat bar: lives + points, Duolingo-style chips
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: AppSizes.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text('❤️', style: TextStyle(fontSize: 22)),
                            SizedBox(width: 6),
                            Text('❤️', style: TextStyle(fontSize: 22)),
                            SizedBox(width: 6),
                            Text('🤍', style: TextStyle(fontSize: 22)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.challenge_lives_remaining,
                          style: AppTextStyles.font(context,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            '150',
                            style: AppTextStyles.font(context,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
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
      child: TapScale(
        onTap: onTap,
        haptics: true,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.border,
              width: AppSizes.cardBorder,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.font(context,
                fontSize: 14,
                fontWeight: FontWeight.w800,
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
  final bool isLocked;
  final String icon;
  final String title;
  final String subtitle;
  final String? points;
  final Color pointsColor;
  final double? progress;
  final String? progressLabel;
  final String? difficulty;
  final String startRoute;

  const _ChallengeData({
    this.isLocked = false,
    this.icon = '',
    this.title = '',
    this.subtitle = '',
    this.points,
    this.pointsColor = const Color(0xFF35A468),
    this.progress,
    this.progressLabel,
    this.difficulty,
    this.startRoute = '/start-challenge',
  });
}

enum _NodeState { active, open, completed, locked }

/// Duolingo-style learning path: challenges as big circular 3D nodes on
/// a winding vertical path, grouped into colored units.
class _ChallengeMap extends StatelessWidget {
  final List<_ChallengeData> challenges;
  final void Function(String route) onPlay;

  const _ChallengeMap({required this.challenges, required this.onPlay});

  _NodeState _stateFor(int index) {
    final c = challenges[index];
    if (c.isLocked) return _NodeState.locked;
    if ((c.progress ?? 0) >= 1.0) return _NodeState.completed;
    final isFirstOpen = !challenges
        .take(index)
        .any((p) => !p.isLocked && (p.progress ?? 0) < 1.0);
    return isFirstOpen ? _NodeState.active : _NodeState.open;
  }

  @override
  Widget build(BuildContext context) {
    // TODO(backend): completed/locked states come from hardcoded
    // presentation data; wire to per-child completion once it exists.
    final unit1 = challenges.take(3).toList();
    final unit2 = challenges.skip(3).toList();

    var nodeIndex = 0;
    final rows = <Widget>[
      _UnitBanner(
        title: context.l10n.map_unit1_title,
        subtitle: context.l10n.map_unit1_subtitle,
        color: AppColors.primary,
      ),
      const SizedBox(height: AppSpacing.md),
      for (final c in unit1) _pathRow(context, c, nodeIndex++),
      _UnitBanner(
        title: context.l10n.map_unit2_title,
        subtitle: context.l10n.map_unit2_subtitle,
        color: AppColors.blue,
      ),
      const SizedBox(height: AppSpacing.md),
      for (final c in unit2) _pathRow(context, c, nodeIndex++),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: rows,
    );
  }

  Widget _pathRow(BuildContext context, _ChallengeData c, int index) {
    // Winding S-curve: nodes swing center → side → center → other side.
    final dx = math.sin(index * math.pi / 2) * 0.7;
    final state = _stateFor(index);
    final unitColor = index < 3 ? AppColors.primary : AppColors.blue;
    final showMascot = index % 3 == 1;

    return SizedBox(
      height: 158,
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional(dx, 0),
            child: _MapNode(
              data: c,
              state: state,
              color: unitColor,
              onTap: () {
                if (state == _NodeState.locked) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.sm)),
                      content: Text(
                        context.l10n.challenge_locked_unlock,
                        style: AppTextStyles.font(context,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white),
                      ),
                    ));
                  return;
                }
                onPlay(c.startRoute);
              },
            ),
          ),
          if (showMascot)
            Align(
              alignment: AlignmentDirectional(-dx.sign * 0.9, 0.2),
              child: const FoxMascot(size: 64, variant: 'happy'),
            ),
        ],
      ),
    );
  }
}

class _UnitBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _UnitBanner({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.edgeFor(color),
            offset: const Offset(0, AppSizes.buttonEdge),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.font(context,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.font(context,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
          const Icon(Icons.menu_book_rounded,
              color: AppColors.white, size: 28),
        ],
      ),
    );
  }
}

class _MapNode extends StatelessWidget {
  final _ChallengeData data;
  final _NodeState state;
  final Color color;
  final VoidCallback onTap;

  const _MapNode({
    required this.data,
    required this.state,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (fill, content) = switch (state) {
      _NodeState.completed => (
          AppColors.gold,
          const Icon(Icons.check_rounded, color: AppColors.white, size: 34)
              as Widget,
        ),
      _NodeState.locked => (
          AppColors.locked,
          const Icon(Icons.lock_rounded,
              color: AppColors.lockedIcon, size: 30) as Widget,
        ),
      _ => (
          color,
          Text(data.icon, style: const TextStyle(fontSize: 30)) as Widget,
        ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 34,
          child: state == _NodeState.active
              ? _StartBubble(color: color)
              : null,
        ),
        ChunkyButton(
          onTap: onTap,
          color: fill,
          shape: BoxShape.circle,
          height: AppSizes.mapNode,
          width: AppSizes.mapNode,
          child: content,
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 130,
          child: Text(
            data.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.font(context,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: state == _NodeState.locked
                    ? AppColors.textHint
                    : AppColors.textPrimary),
          ),
        ),
        if (data.progressLabel != null && state != _NodeState.locked)
          Text(
            data.progressLabel!,
            style: AppTextStyles.font(context,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary),
          ),
      ],
    );
  }
}

/// Bouncing "START" bubble above the current node.
class _StartBubble extends StatefulWidget {
  final Color color;
  const _StartBubble({required this.color});

  @override
  State<_StartBubble> createState() => _StartBubbleState();
}

class _StartBubbleState extends State<_StartBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -4 * _controller.value),
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
              color: AppColors.border, width: AppSizes.cardBorder),
        ),
        child: Text(
          context.l10n.map_start,
          style: AppTextStyles.font(context,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: widget.color),
        ),
      ),
    );
  }
}

class _PVPTab extends StatelessWidget {
  final VoidCallback onStart;
  const _PVPTab({required this.onStart});

  static const _leaders = [
    _LeaderEntry('🥇', 'Ahmed K.', 15, '2450', false, true),
    _LeaderEntry('🥈', 'Sara M.', 12, '1850', false, true),
    _LeaderEntry('🥉', 'Meriam (You)', 10, '1650', true, true),
    _LeaderEntry('#4', 'Meriam', 9, '1550', false, false),
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
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryDark,
                offset: Offset(0, AppSizes.buttonEdge),
              ),
            ],
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
                          context.l10n.pvp_title,
                          style: AppTextStyles.font(context,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.pvp_subtitle,
                          style: AppTextStyles.font(context,
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
              ChunkyButton(
                onTap: onStart,
                color: Colors.white,
                edgeColor: const Color(0xFFD9A521),
                height: 48,
                width: double.infinity,
                child: Text(
                  context.l10n.pvp_start,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.font(context,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
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
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
                color: AppColors.border, width: AppSizes.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.pvp_leaderboard,
                    style: AppTextStyles.font(context,
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
  final int streakDays;
  final String points;
  final bool isYou;
  final bool hasMedalEmoji;
  const _LeaderEntry(this.medal, this.name, this.streakDays, this.points, this.isYou, this.hasMedalEmoji);
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
        : Border.all(color: const Color(0xFFFFF085), width: 1);

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
              style: AppTextStyles.font(context,
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
                  style: AppTextStyles.font(context,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                Text(
                  context.l10n.pvp_streak(entry.streakDays),
                  style: AppTextStyles.font(context,
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
                style: AppTextStyles.font(context,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              Text(
                context.l10n.pvp_points,
                style: AppTextStyles.font(context,
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
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),
                GestureDetector(
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
                      Navigator.pushNamed(context, startRoute);
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
    );
  }
}
