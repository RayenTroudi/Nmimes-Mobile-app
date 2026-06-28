import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class SnapQuickTipsCard extends StatelessWidget {
  const SnapQuickTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA726),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.snap_widgets_quickTips,
            style: AppTextStyles.font(context,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          ...[
            l.snap_widgets_tip1,
            l.snap_widgets_tip2,
            l.snap_widgets_tip3,
          ].map((tip) => Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  '✓ $tip',
                  style: AppTextStyles.font(context,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class SnapCameraViewfinder extends StatelessWidget {
  final String hint;
  const SnapCameraViewfinder({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Inner rounded rect border
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
            ),
          ),
          // Orange corner brackets
          const Positioned(top: 24, left: 24,
              child: _Corner(flipH: false, flipV: false)),
          const Positioned(top: 24, right: 24,
              child: _Corner(flipH: true, flipV: false)),
          const Positioned(bottom: 24, left: 24,
              child: _Corner(flipH: false, flipV: true)),
          const Positioned(bottom: 24, right: 24,
              child: _Corner(flipH: true, flipV: true)),
          // Camera icon + hint
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt_outlined, size: 40,
                    color: Colors.white.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                Text(
                  hint,
                  style: AppTextStyles.font(context,
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final bool flipH, flipV;
  const _Corner({required this.flipH, required this.flipV});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flipH ? -1 : 1,
      scaleY: flipV ? -1 : 1,
      child: SizedBox(
        width: 28,
        height: 28,
        child: CustomPaint(painter: _CornerPainter()),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    const r = 10.0;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(r, 0)
      ..arcToPoint(Offset(0, r), radius: const Radius.circular(r), clockwise: false)
      ..lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}

class SnapActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final IconData icon;
  final VoidCallback onTap;

  const SnapActionButton({
    super.key,
    required this.label,
    required this.filled,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: filled
              ? const Border.fromBorderSide(
                  BorderSide(color: Colors.white, width: 2.5))
              : Border.all(color: AppColors.primary, width: 2),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20,
                color: filled ? Colors.white : AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.font(context,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
