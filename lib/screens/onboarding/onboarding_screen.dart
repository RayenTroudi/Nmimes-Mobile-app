import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/onboarding_dots.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

List<_OnboardingData> _buildPages(BuildContext context) => [
  _OnboardingData(
    image: 'assets/images/onboarding_snap.png',
    title: context.l10n.onboarding_title_snapIt,
    badge: context.l10n.onboarding_badge_snapIt,
    body: context.l10n.onboarding_body_snapIt,
  ),
  _OnboardingData(
    image: 'assets/images/onboarding_understand.png',
    title: context.l10n.onboarding_title_understand,
    badge: context.l10n.onboarding_badge_understand,
    body: context.l10n.onboarding_body_understand,
  ),
  _OnboardingData(
    image: 'assets/images/onboarding_play.png',
    title: context.l10n.onboarding_title_play,
    badge: context.l10n.onboarding_badge_play,
    body: context.l10n.onboarding_body_play,
  ),
  _OnboardingData(
    image: 'assets/images/onboarding_rewards.png',
    title: context.l10n.onboarding_title_rewards,
    badge: context.l10n.onboarding_badge_rewards,
    body: context.l10n.onboarding_body_rewards,
  ),
];

class _OnboardingData {
  final String image;
  final String title;
  final String badge;
  final String body;
  const _OnboardingData({
    required this.image,
    required this.title,
    required this.badge,
    required this.body,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _current = 0;

  void _next(List<_OnboardingData> pages) {
    if (_current < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/choose-role');
    }
  }

  void _back() {
    if (_current > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (i) => setState(() => _current = i),
        itemCount: pages.length,
        itemBuilder: (_, i) => _OnboardingPage(
          data: pages[i],
          current: _current,
          total: pages.length,
          onNext: () => _next(pages),
          onBack: _back,
          isLast: _current == pages.length - 1,
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final int current;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isLast;

  const _OnboardingPage({
    required this.data,
    required this.current,
    required this.total,
    required this.onNext,
    required this.onBack,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Illustration area — full image from Figma
          SizedBox(
            height: h * 0.46,
            child: Center(
              child: Image.asset(
                data.image,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // White rounded card
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.font(context,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      data.badge,
                      style: AppTextStyles.font(context,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    data.body,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.font(context,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  // Progress bar indicator (thin Duolingo-style)
                  OnboardingDots(count: total, current: current),
                  const SizedBox(height: 20),

                  PrimaryButton(
                    label: isLast
                        ? context.l10n.onboarding_button_start
                        : context.l10n.onboarding_button_next,
                    onTap: onNext,
                  ),

                  if (current > 0) ...[
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: context.l10n.onboarding_button_back,
                      onTap: onBack,
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
