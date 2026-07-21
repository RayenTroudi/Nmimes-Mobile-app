import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/chunky_button.dart';

enum BalanceMode {
  intro, // seesaw rocks, then settles level: "an equation is a balance"
  removeFive, // -5 chips lift off BOTH pans, equation morphs to 2x = 10
}

/// Steps 2 & 4 — the equation as an animated seesaw. The beam tilts with
/// a damped rock; in [BalanceMode.removeFive] the "5" chips float off
/// both pans simultaneously while the scale stays perfectly level.
class BalanceScaleStep extends StatefulWidget {
  final BalanceMode mode;
  final VoidCallback onComplete;

  const BalanceScaleStep({
    super.key,
    required this.mode,
    required this.onComplete,
  });

  @override
  State<BalanceScaleStep> createState() => _BalanceScaleStepState();
}

class _BalanceScaleStepState extends State<BalanceScaleStep>
    with TickerProviderStateMixin {
  // Damped rocking of the beam (intro), or a tiny settle wiggle (remove).
  late final AnimationController _rock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  // Drives the -5 chips floating up and fading out.
  late final AnimationController _lift = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  bool _removed = false; // equation label switched to 2x = 10
  bool _ready = false; // continue button enabled

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await _rock.forward();
    if (!mounted) return;
    if (widget.mode == BalanceMode.intro) {
      setState(() => _ready = true);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    await _lift.forward();
    if (!mounted) return;
    setState(() {
      _removed = true;
      _ready = true;
    });
  }

  @override
  void dispose() {
    _rock.dispose();
    _lift.dispose();
    super.dispose();
  }

  /// Damped oscillation: rocks ±10° and settles to level.
  double get _angle {
    final t = _rock.value;
    return math.sin(t * math.pi * 4) * (1 - t) * 0.17;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isIntro = widget.mode == BalanceMode.intro;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          Text(
            isIntro ? l.lesson_balance_title : l.lesson_remove_title,
            textAlign: TextAlign.center,
            style: AppTextStyles.font(context,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isIntro ? l.lesson_balance_body : l.lesson_remove_body,
            textAlign: TextAlign.center,
            style: AppTextStyles.font(context,
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const Spacer(),

          // The scale itself
          SizedBox(
            height: 260,
            child: AnimatedBuilder(
              animation: Listenable.merge([_rock, _lift]),
              builder: (context, _) => CustomPaint(
                size: const Size(double.infinity, 260),
                painter: _ScalePainter(angle: _angle),
                child: _PanContents(
                  angle: _angle,
                  lift: _lift.value,
                  removed: _removed,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Equation label that morphs after removal
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
              child: child,
            ),
            child: Text(
              _removed ? '2x = 10' : '2x + 5 = 15',
              key: ValueKey(_removed),
              style: AppTextStyles.font(context,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: _removed ? AppColors.green : AppColors.primary,
              ),
            ),
          ),
          if (_removed) ...[
            const SizedBox(height: 6),
            Text(
              l.lesson_remove_done,
              style: AppTextStyles.font(context,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
          ],

          const Spacer(),
          ChunkyButton(
            onTap: _ready ? widget.onComplete : null,
            color: _ready ? AppColors.primary : AppColors.locked,
            width: double.infinity,
            child: Text(
              l.snap_button_continue,
              style: AppTextStyles.font(context,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _ready ? AppColors.white : AppColors.lockedIcon,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Pan contents (weight chips hanging over each pan) ───────────────────────

class _PanContents extends StatelessWidget {
  final double angle;
  final double lift; // 0..1 progress of the -5 chips flying away
  final bool removed;

  const _PanContents({
    required this.angle,
    required this.lift,
    required this.removed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        const h = 260.0;
        final center = Offset(w / 2, h * 0.42);
        final halfBeam = math.min(w * 0.38, 150.0);
        final leftEnd = center +
            Offset(-halfBeam * math.cos(angle), -halfBeam * math.sin(angle));
        final rightEnd = center +
            Offset(halfBeam * math.cos(angle), halfBeam * math.sin(angle));
        const panDrop = 54.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Left pan chips: x, x, 5
            Positioned(
              left: leftEnd.dx - 54,
              top: leftEnd.dy + panDrop - 34,
              child: Row(
                children: [
                  const _WeightChip(label: 'x', color: AppColors.primary),
                  const SizedBox(width: 4),
                  const _WeightChip(label: 'x', color: AppColors.primary),
                  const SizedBox(width: 4),
                  _FlyawayChip(label: '5', lift: lift, removed: removed),
                ],
              ),
            ),
            // Right pan chips: 10 (+ 5 that flies away)
            Positioned(
              left: rightEnd.dx - 40,
              top: rightEnd.dy + panDrop - 34,
              child: Row(
                children: [
                  const _WeightChip(label: '10', color: AppColors.blue),
                  const SizedBox(width: 4),
                  _FlyawayChip(label: '5', lift: lift, removed: removed),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WeightChip extends StatelessWidget {
  final String label;
  final Color color;
  const _WeightChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.edgeFor(color),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.font(context,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

/// The "5" chip that floats up and fades out during [BalanceMode.removeFive].
class _FlyawayChip extends StatelessWidget {
  final String label;
  final double lift;
  final bool removed;
  const _FlyawayChip(
      {required this.label, required this.lift, required this.removed});

  @override
  Widget build(BuildContext context) {
    if (removed) return const SizedBox(width: 32, height: 30);
    return Transform.translate(
      offset: Offset(0, -60 * lift),
      child: Opacity(
        opacity: (1 - lift).clamp(0.0, 1.0),
        child: const _WeightChip(label: '5', color: AppColors.pink),
      ),
    );
  }
}

// ─── The scale drawing (post, beam, pans, strings) ───────────────────────────

class _ScalePainter extends CustomPainter {
  final double angle;
  _ScalePainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final halfBeam = math.min(size.width * 0.38, 150.0);

    final post = Paint()
      ..color = AppColors.primaryDark
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final beamPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final stringPaint = Paint()
      ..color = AppColors.textHint
      ..strokeWidth = 2.5;
    final panPaint = Paint()..color = AppColors.gold;
    final panEdge = Paint()
      ..color = AppColors.goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Post + base
    canvas.drawLine(
        center, Offset(center.dx, size.height * 0.92), post);
    canvas.drawLine(
      Offset(center.dx - 44, size.height * 0.92),
      Offset(center.dx + 44, size.height * 0.92),
      post,
    );

    // Beam
    final leftEnd = center +
        Offset(-halfBeam * math.cos(angle), -halfBeam * math.sin(angle));
    final rightEnd = center +
        Offset(halfBeam * math.cos(angle), halfBeam * math.sin(angle));
    canvas.drawLine(leftEnd, rightEnd, beamPaint);

    // Pivot cap
    canvas.drawCircle(center, 8, Paint()..color = AppColors.primaryDark);

    // Pans hang straight down from each beam end
    for (final end in [leftEnd, rightEnd]) {
      final panCenter = end + const Offset(0, 54);
      canvas.drawLine(end, panCenter + const Offset(-26, -6), stringPaint);
      canvas.drawLine(end, panCenter + const Offset(26, -6), stringPaint);
      final panRect = Rect.fromCenter(
          center: panCenter, width: 76, height: 22);
      final rrect =
          RRect.fromRectAndRadius(panRect, const Radius.circular(11));
      canvas.drawRRect(rrect, panPaint);
      canvas.drawRRect(rrect, panEdge);
    }
  }

  @override
  bool shouldRepaint(_ScalePainter old) => old.angle != angle;
}
