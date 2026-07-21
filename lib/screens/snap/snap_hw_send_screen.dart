import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';

/// Fox intro screen — the hand-off between confirming the photo and the
/// interactive walkthrough.
///
/// The four step screens that used to live in this file (tap MCQ, list MCQ,
/// type-the-answer, and the static solution wall) are now a single animated
/// player: see `homework_player/homework_player_screen.dart`.
class SnapHwSendScreen extends StatelessWidget {
  const SnapHwSendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    // IntrinsicHeight, not a bare Column: minHeight leaves the
                    // incoming height unbounded, and the Spacers below need a
                    // finite height to divide or layout throws.
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: _ProblemCard(),
                          ),
                          const Spacer(),
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/fox_sunglasses.png',
                                width: 160,
                                height: 160,
                                cacheWidth: 480,
                                fit: BoxFit.contain,
                                errorBuilder: (ctx, e, _) => const Icon(
                                  Icons.pets_rounded,
                                  color: AppColors.primary,
                                  size: 120,
                                ),
                              ),
                              Positioned(
                                top: -40,
                                right: -100,
                                child: _ThoughtBubble(
                                  text: l.snap_hw_send_thoughtBubble,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _BottomButton(
              label: l.snap_button_letsSolve,
              onTap: () => Navigator.pushNamed(context, '/homework-player'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.arrow_back,
                color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l.snap_title_homework,
              style: AppTextStyles.font(
                context,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(
                context, '/home', (r) => false),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  const _ProblemCard();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Text(
            l.snap_solveFor,
            style: AppTextStyles.font(
              context,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '2x + 5 = 15',
            style: AppTextStyles.font(
              context,
              fontSize:
                  (MediaQuery.sizeOf(context).width * 0.07).clamp(20.0, 28.0),
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThoughtBubble extends StatelessWidget {
  final String text;
  const _ThoughtBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ThoughtPainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.font(
            context,
            fontSize: 12,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _ThoughtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const r = 12.0;
    const tailH = 16.0;
    final bH = size.height - tailH;
    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
      ..lineTo(size.width, bH - r)
      ..arcToPoint(Offset(size.width - r, bH),
          radius: const Radius.circular(r))
      ..lineTo(size.width * 0.35, bH)
      ..lineTo(size.width * 0.25, bH + tailH)
      ..lineTo(size.width * 0.20, bH)
      ..lineTo(r, bH)
      ..arcToPoint(Offset(0, bH - r), radius: const Radius.circular(r))
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: const Radius.circular(r))
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_ThoughtPainter _) => false;
}

class _BottomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _BottomButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(30),
            border: const Border.fromBorderSide(
                BorderSide(color: Colors.white, width: 2.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.font(
                context,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
