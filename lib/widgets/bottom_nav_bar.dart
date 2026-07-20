import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/l10n_extension.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _icons = [
    Icons.home_rounded,
    Icons.auto_awesome_rounded,
    Icons.emoji_events_rounded,
    Icons.person_rounded,
  ];

  // Section colors, Duolingo-style: each tab lights up in its own color.
  static const _colors = [
    AppColors.primary,
    AppColors.blue,
    AppColors.green,
    AppColors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    final labels = [
      context.l10n.nav_home,
      context.l10n.nav_nmimes,
      context.l10n.nav_challenge,
      context.l10n.nav_profile,
    ];

    return Container(
      height: 83,
      decoration: const BoxDecoration(
        color: AppColors.navBarBg,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 2),
        ),
      ),
      child: Row(
        children: List.generate(4, (i) {
          final active = i == currentIndex;
          final color = _colors[i];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap(i);
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: 52,
                    height: 42,
                    decoration: BoxDecoration(
                      color: active
                          ? color.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: active
                          ? Border.all(color: color, width: 2)
                          : Border.all(color: Colors.transparent, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        _icons[i],
                        size: 26,
                        color: active ? color : AppColors.navInactive,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    labels[i],
                    style: AppTextStyles.font(context,
                      fontSize: 10,
                      color: active ? color : AppColors.navInactive,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
