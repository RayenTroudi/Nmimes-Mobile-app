import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'snap_widgets.dart';

class SnapSuccessScreen extends StatefulWidget {
  const SnapSuccessScreen({super.key});

  @override
  State<SnapSuccessScreen> createState() => _SnapSuccessScreenState();
}

class _SnapSuccessScreenState extends State<SnapSuccessScreen> {
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
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.snap_success_explainBack,
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
                        child: _DialogOutlineButton(
                          label: l.snap_success_no,
                          onTap: () => Navigator.of(ctx).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DialogOrangeButton(
                          label: l.snap_success_yes,
                          onTap: () {
                            Navigator.of(ctx).pop();
                            Navigator.pushNamed(context, '/snap-explain');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      ..._confettiDots(),
                      Image.asset(
                        'assets/images/fox_sunglasses.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, _) => const Icon(
                          Icons.pets_rounded,
                          color: AppColors.primary,
                          size: 160,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 6),
                      Text(
                        l.snap_success_greatJob,
                        style: AppTextStyles.font(context,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.snap_success_solvedStepByStep,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.font(context,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          l.snap_success_earned50,
                          style: AppTextStyles.font(context,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: SnapActionButton(
                label: l.snap_button_continue,
                filled: true,
                icon: Icons.arrow_forward_rounded,
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (r) => false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<Widget> _confettiDots() {
    final items = [
      _C(dx: -120, dy: -60, color: Colors.red, size: 10, rotation: 0.3),
      _C(dx: -90, dy: -100, color: Colors.green, size: 8, rotation: -0.5),
      _C(dx: -60, dy: -130, color: Colors.blue, size: 6, rotation: 0.8),
      _C(dx: 0, dy: -140, color: Colors.orange, size: 8, rotation: 0.1),
      _C(dx: 60, dy: -130, color: Colors.green, size: 10, rotation: -0.3),
      _C(dx: 100, dy: -90, color: Colors.red, size: 7, rotation: 0.6),
      _C(dx: 120, dy: -50, color: Colors.yellow, size: 9, rotation: -0.7),
      _C(dx: -140, dy: 0, color: Colors.blue, size: 6, rotation: 0.4),
      _C(dx: 140, dy: 10, color: Colors.orange, size: 8, rotation: -0.2),
    ];
    return items
        .map((i) => Positioned(
              left: 100 + i.dx,
              top: 100 + i.dy,
              child: Transform.rotate(
                angle: i.rotation,
                child: Container(
                  width: i.size,
                  height: i.size * 2.5,
                  decoration: BoxDecoration(
                    color: i.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ))
        .toList();
  }
}

class _C {
  final double dx, dy, size, rotation;
  final Color color;
  const _C({
    required this.dx,
    required this.dy,
    required this.color,
    required this.size,
    required this.rotation,
  });
}

class _DialogOrangeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DialogOrangeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          border: const Border.fromBorderSide(
              BorderSide(color: Colors.white, width: 2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(label,
              style: AppTextStyles.font(context,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
      ),
    );
  }
}

class _DialogOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DialogOutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Center(
          child: Text(label,
              style: AppTextStyles.font(context,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ),
      ),
    );
  }
}
