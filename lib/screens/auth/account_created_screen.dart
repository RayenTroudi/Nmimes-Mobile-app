import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/bounce_in.dart';
import '../../widgets/primary_button.dart';

class AccountCreatedScreen extends StatefulWidget {
  const AccountCreatedScreen({super.key});

  @override
  State<AccountCreatedScreen> createState() => _AccountCreatedScreenState();
}

class _AccountCreatedScreenState extends State<AccountCreatedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  Timer? _autoNav;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _autoNav = Timer(const Duration(seconds: 3), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/parents-view');
  }

  @override
  void dispose() {
    _autoNav?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _Confetti(),
          FadeTransition(
            opacity: _fadeIn,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    BounceIn(
                      child: Image.asset(
                        'assets/images/yippyee.png',
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.accountCreated_title,
                      style: AppTextStyles.font(context,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.accountCreated_body,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.font(context,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: l10n.accountCreated_button,
                      onTap: () {
                        _autoNav?.cancel();
                        _navigate();
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParentSignInSuccessScreen extends StatefulWidget {
  const ParentSignInSuccessScreen({super.key});

  @override
  State<ParentSignInSuccessScreen> createState() =>
      _ParentSignInSuccessScreenState();
}

class _ParentSignInSuccessScreenState
    extends State<ParentSignInSuccessScreen>
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
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _Confetti(),
          FadeTransition(
            opacity: _fadeIn,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    const BounceIn(child: _CoolFox(size: 200)),
                    const Spacer(),
                    Text(
                      l10n.accountCreated_signInTitle,
                      style: AppTextStyles.font(context,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.accountCreated_signInBody,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.font(context,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: l10n.accountCreated_signInButton,
                      onTap: () => Navigator.pushReplacementNamed(
                          context, '/parents-view'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoolFox extends StatelessWidget {
  final double size;
  const _CoolFox({required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/fox_sunglasses.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

// Confetti layer
class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = Random();
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
    _pieces = List.generate(
      50,
      (_) => _Piece(
        x: _rng.nextDouble(),
        delay: _rng.nextDouble() * 0.4,
        color: [
          AppColors.primary,
          AppColors.pink,
          AppColors.green,
          AppColors.blue,
          const Color(0xFFFFD700),
          const Color(0xFFFF4444),
        ][_rng.nextInt(6)],
        size: 5.0 + _rng.nextDouble() * 8,
        isRibbon: _rng.nextBool(),
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
              top: -20 + t * (h * 0.65),
              child: Opacity(
                opacity: (1 - t * 0.8).clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: t * 5,
                  child: p.isRibbon
                      ? Container(
                          width: p.size * 0.4,
                          height: p.size * 2,
                          decoration: BoxDecoration(
                            color: p.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      : Container(
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

class _Piece {
  final double x, delay, size;
  final Color color;
  final bool isRibbon;
  const _Piece({
    required this.x,
    required this.delay,
    required this.size,
    required this.color,
    required this.isRibbon,
  });
}
