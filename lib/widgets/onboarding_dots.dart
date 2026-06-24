import 'package:flutter/material.dart';
import '../theme/colors.dart';

class OnboardingDots extends StatelessWidget {
  final int count;
  final int current;

  const OnboardingDots({super.key, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 40 : 16,
          height: 16,
          decoration: BoxDecoration(
            color: active ? AppColors.dotActive : AppColors.dotInactive,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
