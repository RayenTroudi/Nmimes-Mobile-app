import 'dart:math';
import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/bottom_nav_bar.dart';

class AIChatVoiceScreen extends StatefulWidget {
  const AIChatVoiceScreen({super.key});

  @override
  State<AIChatVoiceScreen> createState() => _AIChatVoiceScreenState();
}

class _AIChatVoiceScreenState extends State<AIChatVoiceScreen>
    with SingleTickerProviderStateMixin {
  bool _isSpeaking = false;
  late final AnimationController _anim;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _onNavTap(int i) {
    const routes = ['/home', '/ai-chat', '/challenges', '/profile'];
    if (i != 1) Navigator.pushReplacementNamed(context, routes[i]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/ai-chat-menu'),
                    child: const Icon(Icons.menu,
                        color: AppColors.textPrimary, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Image.asset(
                    'assets/images/fox_sunglasses.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                        Icons.pets_rounded,
                        color: AppColors.primary,
                        size: 28),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.aiChat_title,
                    style: AppTextStyles.font(context,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Let's Talk / X row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.aiChat_voice_letsTalk,
                    style: AppTextStyles.font(context,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        color: AppColors.textPrimary, size: 22),
                  ),
                ],
              ),
            ),

            // Main blob / waveform area
            Expanded(
              child: Center(
                child: _isSpeaking
                    ? _SpeakingBlob(anim: _pulse)
                    : _ListeningBlob(anim: _pulse),
              ),
            ),

            // Status label
            Text(
              _isSpeaking ? l10n.aiChat_voice_speaking : l10n.aiChat_voice_listening,
              style: AppTextStyles.font(context,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Mic button (only shown in speaking state)
            if (_isSpeaking)
              GestureDetector(
                onTap: () => setState(() => _isSpeaking = false),
                child: Container(
                  width: 72,
                  height: 72,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic_rounded,
                      color: Colors.white, size: 32),
                ),
              )
            else
              GestureDetector(
                onTap: () => setState(() => _isSpeaking = true),
                child: Container(
                  width: 72,
                  height: 72,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: const Icon(Icons.mic_rounded,
                      color: Colors.white, size: 32),
                ),
              ),

            BottomNavBar(currentIndex: 1, onTap: _onNavTap),
          ],
        ),
      ),
    );
  }
}

// ─── Listening blob (colorful overlapping circles) ────────────────────────────

class _ListeningBlob extends StatelessWidget {
  final Animation<double> anim;
  const _ListeningBlob({required this.anim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, _) {
        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer orange glow
              Transform.scale(
                scale: anim.value * 1.2,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                ),
              ),
              // Pink/rose offset blob
              Positioned(
                left: 40,
                top: 40,
                child: Transform.scale(
                  scale: anim.value,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          AppColors.pink.withValues(alpha: 0.28),
                    ),
                  ),
                ),
              ),
              // Warm amber blob
              Positioned(
                right: 30,
                bottom: 40,
                child: Transform.scale(
                  scale: anim.value * 0.95,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF59E0B)
                          .withValues(alpha: 0.22),
                    ),
                  ),
                ),
              ),
              // Middle orange
              Transform.scale(
                scale: anim.value * 1.05,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              // Core orange circle with waveform icon
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.graphic_eq_rounded,
                    color: Colors.white, size: 48),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Speaking blob (orange ring glow + teal waveform) ────────────────────────

class _SpeakingBlob extends StatelessWidget {
  final Animation<double> anim;
  const _SpeakingBlob({required this.anim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, _) {
        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Orange glow ring
              Container(
                width: 240 * anim.value,
                height: 240 * anim.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.6),
                    width: 3,
                  ),
                  color: Colors.white
                      .withValues(alpha: 0.85),
                ),
              ),
              // Teal waveform painter
              SizedBox(
                width: 260,
                height: 120,
                child: CustomPaint(
                  painter: _WaveformPainter(phase: anim.value),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double phase;
  _WaveformPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2DD4BF).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    for (int layer = 0; layer < 3; layer++) {
      final path = Path();
      final yCenter = size.height / 2;
      final amplitude = 28.0 + layer * 8;
      final freq = 2.0 + layer * 0.5;
      final phaseOffset = layer * 0.8 + phase * pi * 2;

      path.moveTo(0, yCenter);
      for (double x = 0; x <= size.width; x++) {
        final y = yCenter +
            amplitude *
                sin((x / size.width * freq * pi * 2) + phaseOffset) *
                sin(x / size.width * pi);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => old.phase != phase;
}
