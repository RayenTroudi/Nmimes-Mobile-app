import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Splash sequence (matching Figma frames):
// Phase 0 (0–500ms):    blank cream bg
// Phase 1 (500–1100ms): logo fades in
// Phase 2 (1100–1800ms): "Nmimes" text fades in below logo
// Phase 3 (1800–2600ms): bg flips to orange, white card with logo+text+tagline
// Phase 4 (2600ms+):     fox mascot fades in (cream bg returns), navigate away
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  int _phase = 0;

  late final AnimationController _logoFade;
  late final AnimationController _textFade;
  late final AnimationController _foxFade;
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();

    _logoFade = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _textFade = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _foxFade  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _bounce   = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _phase = 1);
    _logoFade.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _phase = 2);
    _textFade.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _phase = 3);

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _phase = 4);
    _foxFade.forward();

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  void dispose() {
    _logoFade.dispose();
    _textFade.dispose();
    _foxFade.dispose();
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Phase 3 = orange bg, all others = cream
    final bgColor = _phase == 3 ? AppColors.primary : AppColors.background;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      color: bgColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: _buildPhaseContent()),
      ),
    );
  }

  Widget _buildPhaseContent() {
    if (_phase == 4) {
      // Fox mascot with gentle bounce
      return AnimatedBuilder(
        animation: _bounce,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, Tween<double>(begin: 0, end: -10).evaluate(
            CurvedAnimation(parent: _bounce, curve: Curves.easeInOut),
          )),
          child: child,
        ),
        child: FadeTransition(
          opacity: _foxFade,
          child: Image.asset(
            'assets/images/nmimes_front.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    if (_phase == 3) {
      // White card with logo + "Nmimes" + tagline on orange bg
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Image.asset(
                'assets/images/nmimes_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nmimes',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Math, made Simple...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      );
    }

    // Phases 0–2: logo and text fading in on cream bg
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: _logoFade,
          child: Image.asset(
            'assets/images/nmimes_front.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 14),
        FadeTransition(
          opacity: _textFade,
          child: Text(
            'Nmimes',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
