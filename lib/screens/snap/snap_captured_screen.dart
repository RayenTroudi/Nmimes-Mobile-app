import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import 'snap_widgets.dart';

class SnapCapturedScreen extends StatelessWidget {
  const SnapCapturedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Snap a Homework',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Captured image preview with orange corner brackets
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Simulated captured content
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Solve for x:',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '2x + 5 = 15',
                                      style: GoogleFonts.poppins(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Corner brackets
                            const Positioned(top: 20, left: 20,
                                child: _CaptureCorner(flipH: false, flipV: false)),
                            const Positioned(top: 20, right: 20,
                                child: _CaptureCorner(flipH: true, flipV: false)),
                            const Positioned(bottom: 20, left: 20,
                                child: _CaptureCorner(flipH: false, flipV: true)),
                            const Positioned(bottom: 20, right: 20,
                                child: _CaptureCorner(flipH: true, flipV: true)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Got it card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA726),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Got it! 📸',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This looks like',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          Text(
                            'Homework',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Ready to make it fun!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    SnapActionButton(
                      label: 'Confirm',
                      filled: true,
                      icon: Icons.check,
                      onTap: () => Navigator.pushNamed(context, '/snap-send'),
                    ),
                    const SizedBox(height: 12),
                    SnapActionButton(
                      label: 'Take another Photo',
                      filled: false,
                      icon: Icons.camera_alt_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureCorner extends StatelessWidget {
  final bool flipH, flipV;
  const _CaptureCorner({required this.flipH, required this.flipV});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flipH ? -1 : 1,
      scaleY: flipV ? -1 : 1,
      child: SizedBox(
        width: 32,
        height: 32,
        child: CustomPaint(painter: _CaptureCornerPainter()),
      ),
    );
  }
}

class _CaptureCornerPainter extends CustomPainter {
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
      ..arcToPoint(Offset(0, r),
          radius: const Radius.circular(r), clockwise: false)
      ..lineTo(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CaptureCornerPainter old) => false;
}
