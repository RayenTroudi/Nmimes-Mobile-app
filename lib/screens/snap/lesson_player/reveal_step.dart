import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/bounce_in.dart';

/// Step 7 — verification: 2(5) + 5 counts up to 15, then a big green
/// "15 = 15 ✓" stamp with a star burst, and the lesson auto-completes.
class RevealStep extends StatefulWidget {
  final VoidCallback onComplete;
  const RevealStep({super.key, required this.onComplete});

  @override
  State<RevealStep> createState() => _RevealStepState();
}

class _RevealStepState extends State<RevealStep>
    with TickerProviderStateMixin {
  late final AnimationController _count = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _stamped = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await _count.forward();
    if (!mounted) return;
    setState(() => _stamped = true);
    _burst.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    widget.onComplete();
  }

  @override
  void dispose() {
    _count.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          Text(
            l.lesson_check_title,
            textAlign: TextAlign.center,
            style: AppTextStyles.font(context,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.lesson_check_body,
            textAlign: TextAlign.center,
            style: AppTextStyles.font(context,
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),

          // 2(5) + 5 = <count-up>
          AnimatedBuilder(
            animation: _count,
            builder: (context, _) {
              final value = (15 * Curves.easeOut.transform(_count.value))
                  .round();
              return Text(
                '2(5) + 5 = $value',
                style: AppTextStyles.font(context,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // The stamp + star burst
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _burst,
                  builder: (context, _) => CustomPaint(
                    size: const Size(220, 160),
                    painter: _StarBurstPainter(progress: _burst.value),
                  ),
                ),
                if (_stamped)
                  BounceIn(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: AppColors.green, width: 3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '15 = 15',
                            style: AppTextStyles.font(context,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.green,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.green, size: 34),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Spacer(),
          if (_stamped)
            BounceIn(
              delay: const Duration(milliseconds: 300),
              child: Image.asset(
                'assets/images/fox_congrats.png',
                width: 130,
                height: 130,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, _) =>
                    const Text('🎉', style: TextStyle(fontSize: 64)),
              ),
            )
          else
            const SizedBox(height: 130),
          const Spacer(),
        ],
      ),
    );
  }
}

/// Simple radial star burst that expands and fades.
class _StarBurstPainter extends CustomPainter {
  final double progress;
  _StarBurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 40 + 70 * Curves.easeOut.transform(progress);
    final opacity = (1 - progress).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: opacity)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + 0.3;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        center + dir * (radius - 14),
        center + dir * radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarBurstPainter old) => old.progress != progress;
}
