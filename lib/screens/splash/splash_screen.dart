import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/auth_state.dart';
import '../../services/supabase_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

/// Brand launch screen on a flat orange field: the logo's two eyes sit
/// directly on the background and blink — an F7C381 eyelid sweeps down to
/// close them and back up — with the wordmark "Nmimes" set in a heavy white
/// serif to match the brand art.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Gentle eye entrance. There is no longer a native launch eye to hand off
  // from — the OS launch frame is a plain orange field — so the custom splash
  // brings its own eyes to life with a soft fade + settle (no elastic pop).
  late final AnimationController _eyeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final AnimationController _nameCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final AnimationController _taglineCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  // Continuous blink loop on the eyes (open -> close -> open, then hold open).
  late final AnimationController _blinkCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  // Loading dots bounce loop.
  late final AnimationController _dotsCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  // Eye entrance: fade from 0 and settle up from 92% with an easeOut curve —
  // a soft arrival, no overshoot.
  late final Animation<double> _eyeFade = CurvedAnimation(
    parent: _eyeCtrl,
    curve: Curves.easeOut,
  );
  late final Animation<double> _eyeScale = Tween<double>(begin: 0.92, end: 1.0)
      .animate(CurvedAnimation(parent: _eyeCtrl, curve: Curves.easeOutCubic));

  // 0 = eyes fully open, 1 = eyes fully closed. A short close/open pulse
  // near the start of each loop, open the rest of the time.
  late final Animation<double> _lid = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 40), // hold open
    TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 8), // close
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 8), // open
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 44), // hold open
  ]).animate(_blinkCtrl);

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    // The OS launch frame is a plain orange field, so the custom splash brings
    // the eyes to life: they fade in first, then start blinking, then the
    // wordmark and tagline arrive.
    _dotsCtrl.repeat();
    await _eyeCtrl.forward();
    if (!mounted) return;

    _blinkCtrl.repeat();
    _nameCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    _taglineCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 400));
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
    _eyeCtrl.dispose();
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    _blinkCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  Widget _blinkingBadge() {
    // The eyes fade in and settle (no elastic pop) on the plain orange field,
    // then run the continuous blink loop.
    return FadeTransition(
      opacity: _eyeFade,
      child: ScaleTransition(
        scale: _eyeScale,
        child: SizedBox(
          width: 104,
          height: 104,
          child: AnimatedBuilder(
            animation: _lid,
            builder: (context, _) => CustomPaint(
              painter: EyesPainter(lid: _lid.value),
              size: Size.infinite,
            ),
          ),
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
        systemNavigationBarColor: AppColors.logoOrange,
      ),
      child: Scaffold(
        backgroundColor: AppColors.logoOrange,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              _blinkingBadge(),
              const SizedBox(height: 20),
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _nameCtrl,
                  curve: Curves.elasticOut,
                ),
                child: FadeTransition(
                  opacity: _nameCtrl,
                  child: Text(
                    'Nmimes',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
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

/// Draws the logo's two eyes — a cream blob with two dark pupils — and an
/// F7C381 eyelid that closes from the top as [lid] goes 0 (open) -> 1 (closed).
class EyesPainter extends CustomPainter {
  EyesPainter({required this.lid});

  /// 0.0 = eyes fully open, 1.0 = eyes fully closed.
  final double lid;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Two overlapping circles form the cream eye-blob, matching the logo.
    final r = w * 0.30; // eye radius
    final gap = w * 0.34; // distance between eye centers
    final cy = h * 0.5;
    final leftC = Offset(w * 0.5 - gap / 2, cy);
    final rightC = Offset(w * 0.5 + gap / 2, cy);

    final cream = Paint()..color = AppColors.eyeCream;
    final pupil = Paint()..color = AppColors.eyePupil;

    // Cream backdrop (two joined circles).
    canvas.drawCircle(leftC, r, cream);
    canvas.drawCircle(rightC, r, cream);

    // Pupils sit inside each eye.
    final pr = r * 0.58;
    // Clip each pupil to its own eye circle so the closing lid can hide it
    // within the eye, and draw the lid over the pupil area.
    for (final c in [leftC, rightC]) {
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
      canvas.drawCircle(c, pr, pupil);

      if (lid > 0) {
        // Eyelid sweeps down from the top of the eye. At lid=1 it covers
        // the whole eye; a soft curved lower edge reads as a closing lid.
        final top = c.dy - r;
        final coverH = 2 * r * lid;
        final lidRect = Rect.fromLTRB(c.dx - r, top, c.dx + r, top + coverH);
        final lidPath = Path()
          ..moveTo(lidRect.left, lidRect.top)
          ..lineTo(lidRect.right, lidRect.top)
          ..lineTo(lidRect.right, lidRect.bottom)
          ..quadraticBezierTo(
            c.dx,
            lidRect.bottom + r * 0.28 * lid,
            lidRect.left,
            lidRect.bottom,
          )
          ..close();
        canvas.drawPath(lidPath, Paint()..color = AppColors.eyelid);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(EyesPainter old) => old.lid != lid;
}
