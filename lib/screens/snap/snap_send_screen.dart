import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

// ─── Entry: "Let's find out the solution" intro ───────────────────────────────

class SnapSendScreen extends StatelessWidget {
  const SnapSendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: l.snap_send_title,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Problem card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _ProblemCard(equation: '2x + 5 = 15'),
                  ),
                  const SizedBox(height: 60),
                  // Fox + speech bubble
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset(
                          'assets/images/fox_sunglasses.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, _) => const Icon(
                            Icons.pets_rounded,
                            color: AppColors.primary,
                            size: 90,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SpeechBubble(
                            text: l.snap_send_foxSpeech,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: _OrangeButton(
                label: l.snap_button_letsFind,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _UnderstandingScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Understanding screen ─────────────────────────────────────────────────────

class _UnderstandingScreen extends StatelessWidget {
  const _UnderstandingScreen();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(
              title: l.snap_send_title,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProblemCard(equation: '2x + 5 = 15'),
                    const SizedBox(height: 24),
                    Text(
                      l.snap_understanding_title,
                      style: AppTextStyles.font(context,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Card 1
                    _WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.snap_understand_card1_title,
                            style: AppTextStyles.font(context,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _bodyText(context, 'We need to find '),
                          _inlineRow([
                            _bodyText(context, 'x is a hidden number '),
                            const Text('❓', style: TextStyle(fontSize: 14)),
                          ]),
                          const SizedBox(height: 6),
                          _bodyText(context, 'This question says:'),
                          const SizedBox(height: 4),
                          _inlineRow([
                            const Text('👉 ', style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(
                                '2 times a number, then add 5, gives 15',
                                style: AppTextStyles.font(context,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 6),
                          _bodyText(context, 'So we are asking:'),
                          const SizedBox(height: 4),
                          Text(
                            'What number makes this true?',
                            style: AppTextStyles.font(context,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Card 2
                    _WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _inlineRow([
                            const Text('💡 ', style: TextStyle(fontSize: 13)),
                            Text(
                              l.snap_understand_card2_title,
                              style: AppTextStyles.font(context,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          _inlineRow([
                            _bodyText(context, 'If the hidden number was '),
                            Text(
                              '5:',
                              style: AppTextStyles.font(context,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 4),
                          _boldText(context, '2 × 5 = 10'),
                          _boldText(context, '10 + 5 = 15'),
                          const SizedBox(height: 4),
                          _inlineRow([
                            Text(
                              'Wow! ',
                              style: AppTextStyles.font(context,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            _bodyText(context, 'That works 🎉'),
                          ]),
                          _inlineRow([
                            _bodyText(context, 'So maybe '),
                            _boldText(context, 'x = 5'),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Formula card
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.snap_formula_label,
                                  style: AppTextStyles.font(context,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ax + b = c',
                                  style: AppTextStyles.font(context,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            'assets/images/foxWithSunGlass.png',
                            width: 56,
                            height: 56,
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, _) => const Icon(
                              Icons.pets_rounded,
                              color: AppColors.primary,
                              size: 44,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: _OrangeButton(
                label: l.snap_button_letsSolve,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _SolutionScreen(stepIndex: 0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Solution steps data ──────────────────────────────────────────────────────

class _StepData {
  final String label;
  final String symbol;
  final bool symbolIsIcon; // green check vs orange text
  final List<_Line> lines;
  final bool isFinalAnswer;
  final bool isVerification;
  const _StepData({
    required this.label,
    required this.symbol,
    this.symbolIsIcon = false,
    required this.lines,
    this.isFinalAnswer = false,
    this.isVerification = false,
  });
}

class _Line {
  final String text;
  final bool bold;
  const _Line(this.text, {this.bold = false});
}

const _solutionSteps = [
  // Step 0 — Step 1: Take away 5
  _StepData(
    label: '✨ Now Let\'s Solve It Properly',
    symbol: '– 5',
    lines: [
      _Line('Step 1: Take away 5', bold: false),
      _Line('We have:'),
      _Line('2x + 5 = 15', bold: true),
      _Line('Take away 5 from both sides:'),
      _Line('2x = 10', bold: true),
    ],
  ),
  // Step 1 — Step 2: Split into 2 parts
  _StepData(
    label: 'Step 2: Split into 2 parts',
    symbol: '÷',
    lines: [
      _Line('Now:'),
      _Line('2x = 10', bold: true),
      _Line('That means:'),
      _Line('2 times x = 10', bold: true),
      _Line('So divide 10 into 2 equal parts:'),
      _Line('x = 5', bold: true),
    ],
  ),
  // Step 2 — Final Answer
  _StepData(
    label: '🎉 Final Answer:',
    symbol: '',
    isFinalAnswer: true,
    lines: [
      _Line('x = 5'),
    ],
  ),
  // Step 3 — Put 5 back (verification)
  _StepData(
    label: 'Put 5 back:',
    symbol: '✓',
    symbolIsIcon: true,
    isVerification: true,
    lines: [
      _Line('We have:'),
      _Line('2x + 5 = 15', bold: true),
      _Line('Put x = 5 back into the equation:'),
      _Line('2(5) + 5 = 15', bold: true),
      _Line('10 + 5 = 15', bold: true),
      _Line('15 = 15 ✅', bold: true),
      _Line('Great job! You found the hidden number 🌟', bold: true),
    ],
  ),
];

// ─── Solution screen (shared for all steps) ───────────────────────────────────

class _SolutionScreen extends StatelessWidget {
  final int stepIndex;
  const _SolutionScreen({required this.stepIndex});

  bool get _isLast => stepIndex == _solutionSteps.length - 1;

  @override
  Widget build(BuildContext context) {
    final step = _solutionSteps[stepIndex];
    final l = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(
              title: l.snap_send_title,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProblemCard(equation: '2x + 5 = 15'),
                    const SizedBox(height: 24),
                    Text(
                      l.snap_solution_title,
                      style: AppTextStyles.font(context,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _WhiteCard(
                      borderColor: step.isFinalAnswer
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  step.label,
                                  style: AppTextStyles.font(context,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: step.isVerification
                                        ? AppColors.textSecondary
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                              if (step.isFinalAnswer)
                                Image.asset(
                                  'assets/images/fox_soccer.png',
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.contain,
                                  errorBuilder: (ctx, err, _) => const Icon(
                                    Icons.pets_rounded,
                                    color: AppColors.primary,
                                    size: 40,
                                  ),
                                )
                              else if (step.symbolIsIcon)
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF35A468),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                )
                              else if (step.symbol.isNotEmpty)
                                Text(
                                  step.symbol,
                                  style: AppTextStyles.font(context,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...step.lines.map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                line.text,
                                style: AppTextStyles.font(context,
                                  fontSize: 14,
                                  fontWeight: line.bold
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Back + Next/Done buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Row(
                children: [
                  _OutlineButton(
                    label: l.snap_button_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OrangeButton(
                      label: _isLast ? l.snap_button_done : l.snap_button_nextStep,
                      onTap: () {
                        if (_isLast) {
                          _showMakeSenseDialog(context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _SolutionScreen(
                                stepIndex: stepIndex + 1,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMakeSenseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const _MakeSenseDialog(),
    );
  }
}

// ─── "Does this make sense?" dialog ──────────────────────────────────────────

class _MakeSenseDialog extends StatelessWidget {
  const _MakeSenseDialog();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
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
                  l.snap_makeSense_question,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.font(context,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _OutlineButton(
                        label: l.snap_makeSense_notYet,
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.pop(context); // go back to prev step
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OrangeButton(
                        label: l.snap_makeSense_yes,
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/snap-success',
                            (r) => r.settings.name == '/home',
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.snap_makeSense_quickCheck,
                        style: AppTextStyles.font(context,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Put x = 5 back into the equation:',
                        style: AppTextStyles.font(context,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '2(5) + 5 = 10 + 5 = 15 ✓',
                        style: AppTextStyles.font(context,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
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
          Text(
            title,
            style: AppTextStyles.font(context,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  final String equation;
  const _ProblemCard({required this.equation});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l.snap_solveFor,
            style: AppTextStyles.font(context,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            equation,
            style: AppTextStyles.font(context,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  const _WhiteCard({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String text;
  const _SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.font(context,
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = AppColors.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const r = 14.0;
    const tailH = 14.0;
    final bH = size.height - tailH;
    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
      ..lineTo(size.width, bH - r)
      ..arcToPoint(Offset(size.width - r, bH), radius: const Radius.circular(r))
      ..lineTo(r + 30, bH)
      ..lineTo(r + 20, bH + tailH)
      ..lineTo(r + 10, bH)
      ..lineTo(r, bH)
      ..arcToPoint(Offset(0, bH - r), radius: const Radius.circular(r))
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: const Radius.circular(r))
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_BubblePainter _) => false;
}

Widget _bodyText(BuildContext context, String t) => Text(
      t,
      style: AppTextStyles.font(context,
          fontSize: 13, color: AppColors.textPrimary),
    );

Widget _boldText(BuildContext context, String t) => Text(
      t,
      style: AppTextStyles.font(context,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary),
    );

Widget _inlineRow(List<Widget> children) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );

class _OrangeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OrangeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          border: const Border.fromBorderSide(
              BorderSide(color: Colors.white, width: 2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.font(context,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.font(context,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
