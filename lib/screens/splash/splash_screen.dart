import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/auth_state.dart';
import '../../services/supabase_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

/// Orange brand launch screen: the logo sits in a white badge that
/// blinks (soft pulse + glow) over the full brand-orange background,
/// matching the native splash color for a seamless launch.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final AnimationController _nameCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final AnimationController _taglineCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  // Continuous blink loop on the logo badge.
  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  // Loading dots bounce loop.
  late final AnimationController _dotsCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _badgeScaleIn = CurvedAnimation(
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

    _pulseCtrl.repeat(reverse: true);
    _nameCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    _taglineCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 1700));
    if (!mounted) return;
    final authState = context.read<AuthState>();
    if (!authState.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (SupabaseService().isStudentSession) {
      // Students own their session outright and go straight to the app.
      Navigator.pushReplacementNamed(context, '/home');
    } else if (authState.selectedStudentId != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Signed-in parent: land on the parent dashboard.
      Navigator.pushReplacementNamed(context, '/parents-view');
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

  Widget _blinkingBadge() {
    return AnimatedBuilder(
      animation: Listenable.merge([_introCtrl, _pulseCtrl]),
      builder: (context, child) {
        final pulse = Curves.easeInOut.transform(_pulseCtrl.value);
        final scale = _badgeScaleIn.value * (1.0 + 0.05 * pulse);
        final glow = (1 - pulse) * _introCtrl.value;
        return SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // White glow rings breathing behind the badge.
              Container(
                width: 224 + 20 * pulse,
                height: 224 + 20 * pulse,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08 * glow),
                ),
              ),
              Container(
                width: 188 + 14 * pulse,
                height: 188 + 14 * pulse,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.14 * glow),
                ),
              ),
              // White badge with the chunky 3D edge, blinking.
              Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: (0.8 + 0.2 * (1 - pulse)).clamp(0.0, 1.0),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 160,
        height: 160,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/nmimes_logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _bouncingDots() {
    return AnimatedBuilder(
      animation: _dotsCtrl,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
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
                    color:
                        Colors.white.withValues(alpha: 0.55 + 0.45 * bounce),
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.primary,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              _blinkingBadge(),
              const SizedBox(height: 12),
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
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
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
                      color: Colors.white.withValues(alpha: 0.85)),
                ),
              ),
              const Spacer(flex: 3),
              _bouncingDots(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
