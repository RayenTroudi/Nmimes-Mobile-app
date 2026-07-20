import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';

// Mock child model
class _Child {
  final String name;
  final String grade;
  final int points;
  final bool isPremium;
  const _Child(this.name, this.grade, this.points, this.isPremium);
}

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  static const _children = [
    _Child('Alex', 'Grade 5', 320, false),
    _Child('Sam', 'Grade 3', 180, true),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          // ── Orange header ─────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      l10n.parentsView_profile_title,
                      style: AppTextStyles.font(context,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Avatar + name + email in the orange section
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 32),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6), width: 3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'assets/images/foxWithSunGlass.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.parentsView_profile_name,
                  style: AppTextStyles.font(context,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.parentsView_profile_email,
                  style: AppTextStyles.font(context,
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.80),
                  ),
                ),
              ],
            ),
          ),

          // ── Cream card ────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── My Children title + Add button ──────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.parentsView_section_children,
                            style: AppTextStyles.font(context,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/parent-setup'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.parentsView_button_addChild,
                                  style: AppTextStyles.font(context,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Child cards ─────────────────────────────────
                    ..._children.map((child) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ChildCard(child: child),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Child card ────────────────────────────────────────────────────────────────

class _ChildCard extends StatelessWidget {
  final _Child child;
  const _ChildCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPremium = child.isPremium;

    final planBg = isPremium
        ? const Color(0xFFE8F5E9)
        : AppColors.primary.withValues(alpha: 0.10);
    final planBorder =
        isPremium ? const Color(0xFF4CAF50) : AppColors.primary;
    final planText =
        isPremium ? const Color(0xFF388E3C) : AppColors.primary;
    final planLabel = isPremium
        ? l10n.parentsView_child_plan_premium
        : l10n.parentsView_child_plan_free;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: avatar + name + plan badge
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4E4C3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    child.name[0],
                    style: AppTextStyles.font(context,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: AppTextStyles.font(context,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${child.grade}  •  ${child.points} ${l10n.parentsView_label_points}',
                      style: AppTextStyles.font(context,
                        fontSize: 12,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: planBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: planBorder),
                ),
                child: Text(
                  planLabel,
                  style: AppTextStyles.font(context,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: planText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Change Plan button
          _ActionBtn(
            label: l10n.parentsView_button_changePlan,
            icon: Icons.swap_horiz_rounded,
            onTap: () => Navigator.pushNamed(
                context, '/subscription',
                arguments: 1),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.font(context,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
