import 'package:flutter/material.dart';
import 'app_progress_bar.dart';

/// Onboarding progress, restyled as a thin Duolingo-style bar.
class OnboardingDots extends StatelessWidget {
  final int count;
  final int current;

  const OnboardingDots({super.key, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: AppProgressBar(
        value: count == 0 ? 0 : (current + 1) / count,
      ),
    );
  }
}
