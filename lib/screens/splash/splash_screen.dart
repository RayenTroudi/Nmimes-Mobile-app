import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/auth_state.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Intro: logo pops in, then name + tagline follow.
  late final AnimationController _introCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final AnimationController _nameCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final AnimationController _taglineCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  // Continuous blink/pulse loop on the logo + breathing glow rings.
  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );

  // Loading dots bounce loop.
  late final AnimationController _dotsCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _logoScaleIn = CurvedAnimation(
    parent: _introCtrl,
    curve: Curves.elasticOut,
  );

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    _dotsCtrl.repeat();
    await _introCtrl.forward();
    if (!mounted) return;

    // Start the blink loop once the logo has landed.
    _pulseCtrl.repeat(reverse: true);
    _nameCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    _taglineCtrl.forward();

    // Hold the blinking logo, then navigate (same auth gating as before).
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final authState = context.read<AuthState>();
    if (authState.isAuthenticated && authState.selectedStudentId != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (authState.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/child-access-code');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    _pulseCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  Widget _blinkingLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_introCtrl, _pulseCtrl]),
      builder: (context, child) {
        final pulse = Curves.easeInOut.transform(_pulseCtrl.value);
        final scale = _logoScaleIn.value * (1.0 + 0.06 * pulse);
        final ringAlpha = 0.14 * (1 - pulse) * _introCtrl.value;
        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Breathing glow rings behind the logo.
              Container(
                width: 240 + 24 * pulse,
                height: 240 + 24 * pulse,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: ringAlpha * 0.5),
                ),
              ),
              Container(
                width: 190 + 16 * pulse,
                height: 190 + 16 * pulse,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: ringAlpha),
                ),
              ),
              // The blinking logo itself.
              Transform.scale(
                scale: scale,
                child: Opacity(
                  // Blink: dips softly and comes back with the pulse.
                  opacity: (0.75 + 0.25 * (1 - pulse)).clamp(0.0, 1.0),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
      child: Image.asset(
        'assets/images/nmimes_logo.png',
        width: 160,
        height: 160,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _bouncingDots() {
    const colors = [AppColors.primary, AppColors.blue, AppColors.green];
    return AnimatedBuilder(
      animation: _dotsCtrl,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            // Phase-shift each dot for a wave; bounce with a sine-like curve.
            final t = (_dotsCtrl.value + i * 0.18) % 1.0;
            final bounce = t < 0.5
                ? Curves.easeOut.transform(t * 2)
                : Curves.easeIn.transform(2 - t * 2);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.translate(
                offset: Offset(0, -10 * bounce),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[i],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            _blinkingLogo(),
            const SizedBox(height: 8),
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _nameCtrl,
                curve: Curves.elasticOut,
              ),
              child: FadeTransition(
                opacity: _nameCtrl,
                child: Text(
                  'Nmimes',
                  style: AppTextStyles.font(context,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _taglineCtrl,
              child: Text(
                context.l10n.splash_tagline,
                style: AppTextStyles.font(context,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary),
              ),
            ),
            const Spacer(flex: 3),
            _bouncingDots(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
