import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/bounce_in.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/primary_button.dart';

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  String? _selected;

  void _continue() {
    if (_selected == null) return;
    if (_selected == 'child') {
      Navigator.pushNamed(context, '/child-sign-in');
    } else {
      Navigator.pushNamed(context, '/parent-sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background: orange header + white card
          Column(
            children: [
              // Orange header area
              SizedBox(height: screenHeight * 0.30),

              // White rounded card body
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.chooseRole_title,
                        style: AppTextStyles.font(context,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.chooseRole_subtitle,
                        style: AppTextStyles.font(context,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Role cards row
                      Row(
                        children: [
                          Expanded(
                            child: _RoleCard(
                              label: context.l10n.chooseRole_role_student,
                              subLabel: context.l10n.chooseRole_role_student_sub,
                              image: 'assets/images/char_child.png',
                              selected: _selected == 'child',
                              onTap: () => setState(() => _selected = 'child'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _RoleCard(
                              label: context.l10n.chooseRole_role_parent,
                              subLabel: context.l10n.chooseRole_role_parent_sub,
                              image: 'assets/images/char_parent.png',
                              selected: _selected == 'parent',
                              onTap: () => setState(() => _selected = 'parent'),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Continue button
                      _selected != null
                          ? PrimaryButton(
                              label:
                                  context.l10n.chooseRole_button_continue,
                              onTap: _continue,
                            )
                          : ChunkyButton(
                              onTap: null,
                              color:
                                  AppColors.primary.withValues(alpha: 0.4),
                              edgeColor:
                                  AppColors.primary.withValues(alpha: 0.2),
                              width: double.infinity,
                              child: Text(
                                context.l10n.chooseRole_button_continue
                                    .toUpperCase(),
                                style: AppTextStyles.font(context,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Foreground: char_auth image painted on top of everything
          Positioned(
            top: screenHeight * 0.30 - 110,
            left: 0,
            right: 0,
            child: Center(
              child: BounceIn(
                child: Image.asset(
                  'assets/images/char_auth.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final String subLabel;
  final String image;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.subLabel,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      image,
      width: 72,
      height: 72,
      fit: BoxFit.contain,
    );

    return TapScale(
      onTap: onTap,
      haptics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 150,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: AppSizes.cardBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            img,
            const SizedBox(height: 10),
            Text(
              label,
              style: AppTextStyles.font(context,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subLabel,
              style: AppTextStyles.font(context,
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
