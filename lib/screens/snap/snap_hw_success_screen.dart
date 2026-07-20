import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/bounce_in.dart';
import '../../widgets/chunky_button.dart';

class SnapHwSuccessScreen extends StatefulWidget {
  const SnapHwSuccessScreen({super.key});

  @override
  State<SnapHwSuccessScreen> createState() => _SnapHwSuccessScreenState();
}

class _SnapHwSuccessScreenState extends State<SnapHwSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showExplainPrompt());
  }

  void _showExplainPrompt() {
    final l = context.l10n;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.snap_hw_success_explainBack,
                textAlign: TextAlign.center,
                style: AppTextStyles.font(context,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _OutlineButton(
                      label: l.snap_hw_success_no,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OrangeButton(
                      label: l.snap_hw_success_yes,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/snap-hw-explain');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ..._confetti(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BounceIn(
                        child: Image.asset(
                          'assets/images/fox_sunglasses.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, _) => const Icon(
                              Icons.pets_rounded,
                              color: AppColors.primary,
                              size: 140),
                        ),
                      ),
                      const SizedBox(height: 24),
                      BounceIn(
                        delay: const Duration(milliseconds: 200),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🎉',
                                style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 6),
                            Text(
                              l.snap_hw_success_greatJob,
                              style: AppTextStyles.font(context,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l.snap_hw_success_doneGreat,
                        style: AppTextStyles.font(context,
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      BounceIn(
                        delay: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border:
                                Border.all(color: AppColors.border, width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🏆',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(
                                l.snap_hw_success_earned100,
                                style: AppTextStyles.font(context,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  child: _OrangeButton(
                    label: l.snap_button_continue,
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (r) => false),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<Widget> _confetti() {
    final items = [
      _C(dx: 20, dy: 50, color: Colors.red, w: 8, h: 20, angle: 0.3),
      _C(dx: 70, dy: 25, color: Colors.green, w: 6, h: 16, angle: -0.6),
      _C(dx: 130, dy: 15, color: Colors.blue, w: 10, h: 10, angle: 0.8),
      _C(dx: 190, dy: 35, color: Colors.orange, w: 6, h: 18, angle: 0.1),
      _C(dx: 250, dy: 20, color: Colors.green, w: 8, h: 22, angle: -0.4),
      _C(dx: 305, dy: 45, color: Colors.red, w: 7, h: 14, angle: 0.7),
      _C(dx: 345, dy: 75, color: Colors.yellow, w: 9, h: 12, angle: -0.5),
      _C(dx: 8, dy: 105, color: Colors.blue, w: 5, h: 18, angle: 0.2),
      _C(dx: 355, dy: 115, color: Colors.orange, w: 7, h: 16, angle: -0.3),
      _C(dx: 95, dy: 65, color: Colors.purple, w: 6, h: 20, angle: 0.9),
      _C(dx: 220, dy: 85, color: Colors.teal, w: 8, h: 12, angle: -0.7),
      _C(dx: 160, dy: 40, color: Colors.yellow, w: 7, h: 18, angle: 0.5),
      _C(dx: 290, dy: 70, color: Colors.blue, w: 5, h: 14, angle: -0.2),
    ];
    return items
        .map((c) => Positioned(
              left: c.dx,
              top: c.dy,
              child: Transform.rotate(
                angle: c.angle,
                child: Container(
                  width: c.w,
                  height: c.h,
                  decoration: BoxDecoration(
                    color: c.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ))
        .toList();
  }
}

class _C {
  final double dx, dy, w, h, angle;
  final Color color;
  const _C(
      {required this.dx,
      required this.dy,
      required this.color,
      required this.w,
      required this.h,
      required this.angle});
}

class _OrangeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OrangeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChunkyButton(
      onTap: onTap,
      color: AppColors.primary,
      width: double.infinity,
      height: 52,
      child: Text(label,
          style: AppTextStyles.font(context,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white)),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChunkyButton(
      onTap: onTap,
      color: Colors.white,
      edgeColor: AppColors.border,
      borderColor: AppColors.border,
      height: 52,
      child: Text(label,
          style: AppTextStyles.font(context,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.primary)),
    );
  }
}
