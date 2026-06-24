import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

const _pages = [
  _OnboardingData(
    image: 'assets/images/onboarding_snap.png',
    title: 'Snap it.\nGet it.',
    badge: 'No typing. No stress.',
    body: 'Photograph your homework or lesson and\nNmimes reads it in seconds.',
  ),
  _OnboardingData(
    image: 'assets/images/onboarding_understand.png',
    title: 'Understand,\nDon\'t just copy',
    badge: 'Built to make it click',
    body: 'Clear visual explanations that teach you\nthe why, not just the answer.',
  ),
  _OnboardingData(
    image: 'assets/images/onboarding_play.png',
    title: 'Play your way\nto Mastery',
    badge: 'Math, but actually fun',
    body: 'Duel friends, join study rooms, and\nteach it back to lock it in.',
  ),
  _OnboardingData(
    image: 'assets/images/onboarding_rewards.png',
    title: 'Win Real\nRewards',
    badge: 'Effort that pays off',
    body: 'Hit your goals and unlock real\nrewards.',
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

  void _next() {
    if (_current < _pages.length - 1) {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (i) => setState(() => _current = i),
        itemCount: _pages.length,
        itemBuilder: (_, i) => _OnboardingPage(
          data: _pages[i],
          current: _current,
          total: _pages.length,
          onNext: _next,
          onBack: _back,
          isLast: _current == _pages.length - 1,
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
                    style: GoogleFonts.poppins(
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
                      style: GoogleFonts.poppins(
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
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(total, (i) {
                      final active = i == current;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 36 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.dotInactive,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        isLast ? "Let's Start" : 'Next',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  if (current > 0) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: onBack,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text(
                          'Back',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
