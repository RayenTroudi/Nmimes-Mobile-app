import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'points_card.dart';

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  // Row-major order matching Figma grid (left→right, top→bottom)
  // (assetName, locked)
  static const _avatars = [
    ('nmimes_celebrate', false),   // row1 col1 — unlocked
    ('nmimes_matcha',    false),   // row1 col2 — unlocked + default selected
    ('nmimes_surprised1', true),   // row1 col3 — locked
    ('nmimes_cry',       true),    // row2 col1 — locked
    ('nmimes_inlove',    true),    // row2 col2 — locked
    ('nmimes_like_sideprofile', true), // row2 col3 — locked
    ('nmimes_football1', true),    // row3 col1 — locked
    ('nmimes_kiss',      true),    // row3 col2 — locked
    ('nmimes_surprised2', true),   // row3 col3 — locked
  ];

  // matcha (index 1) is selected by default per Figma checkmark
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF2E2E2E), size: 22),
                    ),
                  ),
                  Text(
                    context.l10n.avatar_title,
                    style: AppTextStyles.font(context,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E2E2E),
                    ),
                  ),
                ],
              ),
            ),

            // ── Earned Points card ───────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ProfilePointsCard(),
            ),
            const SizedBox(height: 20),

            // ── Select Avatar label ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                context.l10n.avatar_selectLabel,
                style: AppTextStyles.font(context,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E2E2E),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Avatar grid ─────────────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 1,
                ),
                itemCount: _avatars.length,
                itemBuilder: (_, i) => _AvatarCell(
                  asset: _avatars[i].$1,
                  locked: _avatars[i].$2,
                  selected: _selected == i,
                  onTap: _avatars[i].$2
                      ? null
                      : () => setState(() => _selected = i),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarCell extends StatelessWidget {
  final String asset;
  final bool locked;
  final bool selected;
  final VoidCallback? onTap;

  const _AvatarCell({
    required this.asset,
    required this.locked,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Avatar image in circle
          ClipOval(
            child: Image.asset(
              'assets/images/$asset.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFE8E8E8),
                child: const Icon(Icons.person_rounded,
                    color: Colors.grey, size: 48),
              ),
            ),
          ),

          // Dark scrim overlay for locked
          if (locked)
            ClipOval(
              child: Container(
                color: const Color(0xFF131313).withValues(alpha: 0.5),
              ),
            ),

          // Lock icon overlay (locked) or check (selected + unlocked)
          if (locked)
            Center(
              child: Icon(
                Icons.lock_rounded,
                color: const Color(0xFFFFBF1D),
                size: 28,
              ),
            )
          else if (selected)
            Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Color(0xFF2E2E2E), size: 30),
              ),
            ),
        ],
      ),
    );
  }
}
