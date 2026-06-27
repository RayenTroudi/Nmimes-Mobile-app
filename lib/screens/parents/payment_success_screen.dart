import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<double> _charScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeIn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _charScale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Confetti layer at the very top
          const Positioned(
            top: 0,
            left: -22,
            right: -22,
            child: _ConfettiIllustration(),
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  // Space so character sits below confetti
                  const SizedBox(height: 60),

                  // Character — fox with sunglasses (yippyee)
                  ScaleTransition(
                    scale: _charScale,
                    child: Image.asset(
                      'assets/images/yippyee.png',
                      width: 200,
                      height: 212,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // "Payment Successful"
                  Text(
                    'Payment Successful',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "You've successfully paid for your subscription.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Continue button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 70,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/parents-view', (_) => false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: const BorderSide(
                                color: AppColors.white, width: 2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confetti illustration (animated falling pieces) ───────────────────────────
class _ConfettiIllustration extends StatefulWidget {
  const _ConfettiIllustration();

  @override
  State<_ConfettiIllustration> createState() => _ConfettiIllustrationState();
}

class _ConfettiIllustrationState extends State<_ConfettiIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = Random(42);
  late final List<_Piece> _pieces;

  static const _colors = [
    Color(0xFFFF4444),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFFD700),
    Color(0xFFAA00FF),
    Color(0xFFFF6B35),
    Color(0xFF00BCD4),
  ];

  @override
  void initState() {
    super.initState();
    _pieces = List.generate(60, (i) {
      return _Piece(
        x: _rng.nextDouble(),
        startY: -0.05 - _rng.nextDouble() * 0.2,
        delay: _rng.nextDouble() * 0.5,
        speed: 0.5 + _rng.nextDouble() * 0.5,
        color: _colors[_rng.nextInt(_colors.length)],
        size: 5.0 + _rng.nextDouble() * 9,
        angle: _rng.nextDouble() * 2 * pi,
        spin: (_rng.nextBool() ? 1 : -1) * (2 + _rng.nextDouble() * 6),
        isRibbon: _rng.nextBool(),
        swayAmp: 10 + _rng.nextDouble() * 20,
        swayFreq: 1 + _rng.nextDouble() * 3,
      );
    });

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(double.infinity, 300),
            painter: _ConfettiPainter(
              pieces: _pieces,
              progress: _ctrl.value,
            ),
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double progress;

  const _ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in pieces) {
      final t = ((progress - p.delay) / p.speed).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final x = p.x * size.width + sin(t * p.swayFreq * pi * 2) * p.swayAmp;
      final y = (p.startY + t * 1.2) * size.height;
      final opacity = t < 0.7 ? 1.0 : (1.0 - (t - 0.7) / 0.3).clamp(0.0, 1.0);
      final rotation = p.angle + t * p.spin;

      paint.color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      if (p.isRibbon) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero, width: p.size * 0.35, height: p.size * 2),
            const Radius.circular(2),
          ),
          paint,
        );
      } else {
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.55),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _Piece {
  final double x, startY, delay, speed, size, angle, spin;
  final double swayAmp, swayFreq;
  final Color color;
  final bool isRibbon;

  const _Piece({
    required this.x,
    required this.startY,
    required this.delay,
    required this.speed,
    required this.size,
    required this.angle,
    required this.spin,
    required this.swayAmp,
    required this.swayFreq,
    required this.color,
    required this.isRibbon,
  });
}
