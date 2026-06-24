import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _labels = ['Home', 'Nmimes', 'Challenge', 'Profile'];
  static const _icons = [
    Icons.home_rounded,
    Icons.auto_awesome_rounded,
    Icons.emoji_events_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 83,
      decoration: BoxDecoration(
        color: AppColors.navBarBg,
        border: const Border(
          top: BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(4, (i) {
          final active = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _icons[i],
                        size: 22,
                        color: active ? Colors.white : AppColors.navInactive,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _labels[i],
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: active ? AppColors.navActive : AppColors.navInactive,
                      fontWeight: FontWeight.w600,
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
