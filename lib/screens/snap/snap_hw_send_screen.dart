import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

// ─── Entry: Fox intro screen ──────────────────────────────────────────────────

class SnapHwSendScreen extends StatelessWidget {
  const SnapHwSendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _ProblemCard(),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/fox_sunglasses.png',
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, e, _) => const Icon(
                            Icons.pets_rounded,
                            color: AppColors.primary,
                            size: 120),
                      ),
                      Positioned(
                        top: -40,
                        right: -100,
                        child: _ThoughtBubble(
                            text: "Let's Solve this\ntogether Step-by-Step"),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            _BottomButton(
              label: "Let's Solve",
              enabled: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _Step1Screen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 1: Tap-tile MCQ (What are we looking for?) ─────────────────────────

class _Step1Screen extends StatefulWidget {
  const _Step1Screen();

  @override
  State<_Step1Screen> createState() => _Step1ScreenState();
}

class _Step1ScreenState extends State<_Step1Screen> {
  String? _selected;
  // correct answer
  static const _correct = 'x';
  static const _options = ['x', '5', '2', '15'];

  _FeedbackState get _feedback {
    if (_selected == null) return _FeedbackState.none;
    return _selected == _correct
        ? _FeedbackState.correct
        : _FeedbackState.wrong;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProblemCard(),
                    const SizedBox(height: 24),
                    _StepLabel(step: 'Step 1:'),
                    const SizedBox(height: 12),
                    Text(
                      'What are we looking for?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      children: _options
                          .map((o) => _TileOption(
                                label: o,
                                state: _selected == null
                                    ? _TileState.idle
                                    : _selected == o
                                        ? (o == _correct
                                            ? _TileState.correct
                                            : _TileState.wrong)
                                        : _TileState.idle,
                                onTap: _selected == null
                                    ? () => setState(() => _selected = o)
                                    : null,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    if (_feedback == _FeedbackState.correct)
                      _FeedbackCard.correct(
                          message: "You're Right! 🎉\nWe want to isolate 'x'."),
                    if (_feedback == _FeedbackState.wrong)
                      _FeedbackCard.wrong(
                          message: "Hint: 'x' is the unknown.\nTry again.",
                          onTryAgain: () => setState(() => _selected = null)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _BottomButton(
              label: 'Next Step',
              enabled: _feedback == _FeedbackState.correct,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _Step2Screen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 2: Text-list MCQ (What operation cancels the +5?) ──────────────────

class _Step2Screen extends StatefulWidget {
  const _Step2Screen();

  @override
  State<_Step2Screen> createState() => _Step2ScreenState();
}

class _Step2ScreenState extends State<_Step2Screen> {
  String? _selected;
  static const _correct = 'Subtract 5 from both sides';
  static const _options = [
    'Subtract 5 from both sides',
    'Divide both sides by 2',
    'Add 5 to both sides',
    'Multiply both sides by 2',
  ];

  _FeedbackState get _feedback {
    if (_selected == null) return _FeedbackState.none;
    return _selected == _correct
        ? _FeedbackState.correct
        : _FeedbackState.wrong;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProblemCard(),
                    const SizedBox(height: 24),
                    _StepLabel(step: 'Step 2:'),
                    const SizedBox(height: 12),
                    Text(
                      'What operation cancels the +5?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._options.map((o) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ListOption(
                            label: o,
                            state: _selected == null
                                ? _TileState.idle
                                : _selected == o
                                    ? (o == _correct
                                        ? _TileState.correct
                                        : _TileState.wrong)
                                    : _TileState.idle,
                            onTap: _selected == null
                                ? () => setState(() => _selected = o)
                                : null,
                          ),
                        )),
                    const SizedBox(height: 8),
                    if (_feedback == _FeedbackState.correct)
                      _FeedbackCard.correct(
                          message:
                              "You're Amazing! 🎉\n2x+5−5 = 15−5\nso, 2x = 10"),
                    if (_feedback == _FeedbackState.wrong)
                      _FeedbackCard.wrong(
                          message:
                              "Hint: 'x' is the unknown.\nTry again.",
                          onTryAgain: () => setState(() => _selected = null)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _BottomButton(
              label: 'Next Step',
              enabled: _feedback == _FeedbackState.correct,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _Step3Screen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 3: Fill-in-blank (Compute x yourself) ───────────────────────────────

class _Step3Screen extends StatefulWidget {
  const _Step3Screen();

  @override
  State<_Step3Screen> createState() => _Step3ScreenState();
}

class _Step3ScreenState extends State<_Step3Screen> {
  final _controller = TextEditingController();
  _FeedbackState _feedback = _FeedbackState.none;
  static const _correct = '5';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    final answer = _controller.text.trim();
    if (answer.isEmpty) return;
    setState(() {
      _feedback = answer == _correct
          ? _FeedbackState.correct
          : _FeedbackState.wrong;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProblemCard(),
                    const SizedBox(height: 24),
                    _StepLabel(step: 'Step 3:'),
                    const SizedBox(height: 12),
                    Text(
                      'Compute x yourself',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '2x = 10  →  x = ?',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'x = ',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _feedback == _FeedbackState.correct
                                  ? AppColors.green
                                  : _feedback == _FeedbackState.wrong
                                      ? AppColors.red
                                      : AppColors.cardBorder,
                              width: 2,
                            ),
                          ),
                          child: TextField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (_) {
                              if (_feedback != _FeedbackState.none) {
                                setState(
                                    () => _feedback = _FeedbackState.none);
                              }
                            },
                            onSubmitted: (_) => _check(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_feedback == _FeedbackState.correct)
                      _FeedbackCard.correct(message: 'Perfect! You Solved It'),
                    if (_feedback == _FeedbackState.wrong)
                      _FeedbackCard.wrong(
                          message:
                              'If 2 times something equals 10,\nwhat do we divide by?',
                          onTryAgain: () {
                            _controller.clear();
                            setState(() => _feedback = _FeedbackState.none);
                          }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (_feedback == _FeedbackState.none)
              _BottomButton(
                label: 'Check',
                enabled: true,
                onTap: _check,
              )
            else
              _BottomButton(
                label: 'Next Step',
                enabled: _feedback == _FeedbackState.correct,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const _CompleteSolutionScreen()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Complete Solution screen ─────────────────────────────────────────────────

class _CompleteSolutionScreen extends StatelessWidget {
  const _CompleteSolutionScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProblemCard(),
                    const SizedBox(height: 24),
                    _StepLabel(step: "Let's have complete solution"),
                    const SizedBox(height: 16),
                    _SolutionStepCard(
                      stepLabel: 'Step 1:',
                      title: null,
                      lines: const ['We need to isolate x'],
                    ),
                    const SizedBox(height: 12),
                    _SolutionStepCard(
                      stepLabel: 'Step 2:',
                      title: 'Subtract 5 from both sides',
                      lines: const [
                        'We have:',
                        '2x + 5 = 15',
                        'Take away 5 from both sides:',
                        '2x + 5 - 5 = 15 - 5',
                        '2x = 10',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SolutionStepCard(
                      stepLabel: 'Step 3:',
                      title: 'Divide both sides by 2',
                      lines: const [
                        'Now:',
                        '2x = 10',
                        'That means:',
                        '2 times x = 10',
                        'So divide 10 into 2 equal parts:',
                        'x = 5',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FinalAnswerCard(),
                  ],
                ),
              ),
            ),
            _BottomButton(
              label: 'Done',
              enabled: true,
              onTap: () =>
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/snap-hw-success', (r) => false),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

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
            'Snap a Homework',
            style: GoogleFonts.poppins(
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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Solve for x:',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
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
    );
  }
}

class _StepLabel extends StatelessWidget {
  final String step;
  const _StepLabel({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/fox_sunglasses.png',
          width: 32,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (ctx, e, _) => const Icon(
            Icons.pets_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          step,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

enum _TileState { idle, correct, wrong }

enum _FeedbackState { none, correct, wrong }

class _TileOption extends StatelessWidget {
  final String label;
  final _TileState state;
  final VoidCallback? onTap;
  const _TileOption(
      {required this.label, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    switch (state) {
      case _TileState.correct:
        bg = const Color(0xFFE8F5E9);
        border = AppColors.green;
        text = AppColors.textPrimary;
        break;
      case _TileState.wrong:
        bg = const Color(0xFFFBE9E7);
        border = AppColors.red;
        text = AppColors.textPrimary;
        break;
      case _TileState.idle:
        bg = Colors.white;
        border = AppColors.cardBorder;
        text = AppColors.textPrimary;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
        ),
      ),
    );
  }
}

class _ListOption extends StatelessWidget {
  final String label;
  final _TileState state;
  final VoidCallback? onTap;
  const _ListOption(
      {required this.label, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    switch (state) {
      case _TileState.correct:
        bg = const Color(0xFFE8F5E9);
        border = AppColors.green;
        break;
      case _TileState.wrong:
        bg = const Color(0xFFFBE9E7);
        border = AppColors.red;
        break;
      case _TileState.idle:
        bg = Colors.white;
        border = AppColors.cardBorder;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final Color bg;
  final Color iconBg;
  final IconData icon;
  final String message;
  final VoidCallback? onTryAgain;

  const _FeedbackCard({
    required this.bg,
    required this.iconBg,
    required this.icon,
    required this.message,
    this.onTryAgain,
  });

  factory _FeedbackCard.correct({required String message}) => _FeedbackCard(
        bg: AppColors.green,
        iconBg: const Color(0xFF237A4B),
        icon: Icons.check_rounded,
        message: message,
      );

  factory _FeedbackCard.wrong(
          {required String message, required VoidCallback onTryAgain}) =>
      _FeedbackCard(
        bg: AppColors.primary,
        iconBg: const Color(0xFFC45E00),
        icon: Icons.lightbulb_outline_rounded,
        message: message,
        onTryAgain: onTryAgain,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message.split('\n').first,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (message.contains('\n')) ...[
            const SizedBox(height: 6),
            Text(
              message.split('\n').skip(1).join('\n'),
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (onTryAgain != null) ...[
            const SizedBox(height: 10),
            Text(
              'Try again.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SolutionStepCard extends StatelessWidget {
  final String stepLabel;
  final String? title;
  final List<String> lines;
  const _SolutionStepCard(
      {required this.stepLabel, required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepLabel,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 4),
            Text(
              title!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          ...lines.map((l) {
            final isBold = l.startsWith('2x') ||
                l.startsWith('x =') ||
                l.startsWith('x+') ||
                l == 'x = 5';
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                l,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight:
                      isBold ? FontWeight.w700 : FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FinalAnswerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  'Final Answer',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'x = 5',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/nmimes_front.png',
            width: 52,
            height: 52,
            fit: BoxFit.contain,
            errorBuilder: (ctx, e, _) => const Icon(
              Icons.pets_rounded,
              color: AppColors.primary,
              size: 40,
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
          style: GoogleFonts.poppins(
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
      ..color = AppColors.cardBorder
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
  final bool enabled;
  final VoidCallback onTap;
  const _BottomButton(
      {required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: enabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(30),
            border: const Border.fromBorderSide(
                BorderSide(color: Colors.white, width: 2.5)),
            boxShadow: enabled
                ? [
                    BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
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
