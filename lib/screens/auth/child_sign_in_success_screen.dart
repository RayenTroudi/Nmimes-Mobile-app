import 'dart:math';
import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class ChildSignInSuccessScreen extends StatefulWidget {
  const ChildSignInSuccessScreen({super.key});

  @override
  State<ChildSignInSuccessScreen> createState() =>
      _ChildSignInSuccessScreenState();
}

class _ChildSignInSuccessScreenState extends State<ChildSignInSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    });
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
          // Confetti layer
          const _Confetti(),

          // Content
          FadeTransition(
            opacity: _fadeIn,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/yippyee.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    context.l10n.childSuccess_title,
                    style: AppTextStyles.font(context,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.childSuccess_body,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.font(context,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text(
                          context.l10n.childSuccess_button_continue,
                          style: AppTextStyles.font(context,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
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

class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = Random();
  late final List<_ConfettiPiece> _pieces;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
    _pieces = List.generate(
      40,
      (_) => _ConfettiPiece(
        x: _rng.nextDouble(),
        delay: _rng.nextDouble() * 0.5,
        color: [
          AppColors.primary,
          AppColors.pink,
          AppColors.green,
          AppColors.blue,
          const Color(0xFFFFD700),
        ][_rng.nextInt(5)],
        size: 6 + _rng.nextDouble() * 8,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final h = MediaQuery.of(context).size.height;
        final w = MediaQuery.of(context).size.width;
        return Stack(
          children: _pieces.map((p) {
            final t = ((_ctrl.value - p.delay).clamp(0.0, 1.0));
            return Positioned(
              left: p.x * w,
              top: -20 + t * (h * 0.7),
              child: Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: t * 6,
                  child: Container(
                    width: p.size,
                    height: p.size * 0.5,
                    color: p.color,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ConfettiPiece {
  final double x;
  final double delay;
  final Color color;
  final double size;
  const _ConfettiPiece({
    required this.x,
    required this.delay,
    required this.color,
    required this.size,
  });
}
