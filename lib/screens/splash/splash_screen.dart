import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

// Character entry config
class _CharConfig {
  const _CharConfig({
    required this.asset,
    required this.width,
    required this.height,
    required this.entryOffset,   // where it slides IN from (e.g. Offset(-2, 0) = from left)
    required this.exitOffset,    // where it slides OUT to
    required this.left,          // Positioned.left (null if using right)
    required this.right,         // Positioned.right (null if using left)
    required this.bottom,        // Positioned.bottom
    required this.entryDelay,    // ms before entry starts
  });
  final String asset;
  final double width;
  final double height;
  final Offset entryOffset;
  final Offset exitOffset;
  final double? left;
  final double? right;
  final double bottom;
  final int entryDelay;
}

const _chars = [
  _CharConfig(
    asset: 'assets/images/onboarding_understand.png',
    width: 130, height: 130,
    entryOffset: Offset(-2, 0), exitOffset: Offset(-2, 0),
    left: 10, right: null, bottom: 160,
    entryDelay: 0,
  ),
  _CharConfig(
    asset: 'assets/images/fox_soccer.png',
    width: 120, height: 120,
    entryOffset: Offset(2, 0), exitOffset: Offset(2, 0),
    left: null, right: 10, bottom: 170,
    entryDelay: 400,
  ),
  _CharConfig(
    asset: 'assets/images/fox_gift.png',
    width: 120, height: 120,
    entryOffset: Offset(-2, 0), exitOffset: Offset(-2, 0),
    left: 60, right: null, bottom: 155,
    entryDelay: 800,
  ),
  _CharConfig(
    asset: 'assets/images/avatar_default.png',
    width: 120, height: 120,
    entryOffset: Offset(2, 0), exitOffset: Offset(2, 0),
    left: null, right: 60, bottom: 155,
    entryDelay: 1200,
  ),
  _CharConfig(
    asset: 'assets/images/yippyee.png',
    width: 150, height: 150,
    entryOffset: Offset(0, -2), exitOffset: Offset(0, 2),
    left: null, right: null, bottom: 120,
    entryDelay: 1600,
  ),
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // One entry + one exit controller per character
  late final List<AnimationController> _entryCtrl;
  late final List<AnimationController> _exitCtrl;

  // Logo + text
  late final AnimationController _logoCtrl;
  late final AnimationController _nameFadeCtrl;
  late final AnimationController _taglineFadeCtrl;

  bool _showLogo = false;

  @override
  void initState() {
    super.initState();

    _entryCtrl = List.generate(
      _chars.length,
      (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 300)),
    );
    _exitCtrl = List.generate(
      _chars.length,
      (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 250)),
    );
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _nameFadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _taglineFadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Phase 1: characters slide in, staggered based on entryDelay config
    for (int i = 0; i < _chars.length; i++) {
      final delay = i == 0 ? 0 : (_chars[i].entryDelay - _chars[i - 1].entryDelay);
      await Future.delayed(Duration(milliseconds: delay));
      if (!mounted) return;
      if (i == _chars.length - 1) {
        await _entryCtrl[i].forward();  // wait for last entry to finish before hold
      } else {
        _entryCtrl[i].forward();
      }
    }

    // Phase 2: group photo hold (wait for last entry to finish + 300ms hold)
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Phase 3: all scatter simultaneously
    for (final ctrl in _exitCtrl) {
      ctrl.forward();
    }

    // Phase 4: logo drops in after scatter completes
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _showLogo = true);
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _nameFadeCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _taglineFadeCtrl.forward();

    // Phase 5: navigate
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  void dispose() {
    for (final c in _entryCtrl) {
      c.dispose();
    }
    for (final c in _exitCtrl) {
      c.dispose();
    }
    _logoCtrl.dispose();
    _nameFadeCtrl.dispose();
    _taglineFadeCtrl.dispose();
    super.dispose();
  }

  Widget _buildCharacter(int index, BoxConstraints constraints) {
    final cfg = _chars[index];

    final entryAnim = SlideTransition(
      position: Tween<Offset>(begin: cfg.entryOffset, end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl[index], curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: cfg.exitOffset).animate(
          CurvedAnimation(parent: _exitCtrl[index], curve: Curves.easeIn),
        ),
        child: Image.asset(cfg.asset, width: cfg.width, height: cfg.height, fit: BoxFit.contain),
      ),
    );

    // yippyee (index 4) is centered horizontally
    if (index == 4) {
      return Positioned(
        bottom: cfg.bottom,
        left: (constraints.maxWidth - cfg.width) / 2,
        child: entryAnim,
      );
    }

    return Positioned(
      bottom: cfg.bottom,
      left: cfg.left,
      right: cfg.right,
      child: entryAnim,
    );
  }

  Widget _buildLogo() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -3), end: Offset.zero).animate(
        CurvedAnimation(parent: _logoCtrl, curve: const ElasticOutCurve(0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/nmimes_logo.png', width: 160, height: 160, fit: BoxFit.contain),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _nameFadeCtrl,
            child: Text(
              'Nmimes',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          FadeTransition(
            opacity: _taglineFadeCtrl,
            child: Text(
              'Math, made Simple...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Characters layer
              for (int i = 0; i < _chars.length; i++)
                _buildCharacter(i, constraints),

              // Logo — centered in upper half, only shown after scatter
              if (_showLogo)
                Positioned(
                  top: constraints.maxHeight * 0.28,
                  left: 0,
                  right: 0,
                  child: Center(child: _buildLogo()),
                ),
            ],
          );
        },
      ),
    );
  }
}
