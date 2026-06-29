import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

// ─── Entry: Fox intro screen ──────────────────────────────────────────────────

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
                            text: l.snap_hw_send_thoughtBubble),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            _BottomButton(
              label: l.snap_button_letsSolve,
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
  int _wrongCount = 0;
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
    final l = context.l10n;
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
                    _StepLabel(step: l.snap_hw_step1_label),
                    const SizedBox(height: 12),
                    Text(
                      l.snap_hw_step1_question,
                      style: AppTextStyles.font(context,
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
                      childAspectRatio: (MediaQuery.of(context).size.width / 2 - 32) / 56,
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
                                    ? () => setState(() {
                                          _selected = o;
                                          if (o != _correct) _wrongCount++;
                                        })
                                    : null,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    if (_feedback == _FeedbackState.correct)
                      _FeedbackCard.correct(
                          message: l.snap_hw_step1_correct),
                    if (_feedback == _FeedbackState.wrong)
                      _FeedbackCard.wrong(
                          message: l.snap_hw_step1_wrong,
                          wrongCount: _wrongCount,
                          onTryAgain: () => setState(() {
                                _selected = null;
                                _wrongCount = 0;
                              })),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _BottomButton(
              label: l.snap_button_nextStep,
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
  int _wrongCount = 0;
  // index of correct answer among options (index 0 = "Subtract 5 from both sides")
  static const _correctIndex = 0;

  _FeedbackState _feedbackFor(List<String> options) {
    if (_selected == null) return _FeedbackState.none;
    return _selected == options[_correctIndex]
        ? _FeedbackState.correct
        : _FeedbackState.wrong;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = [
      l.snap_hw_step2_option1,
      l.snap_hw_step2_option2,
      l.snap_hw_step2_option3,
      l.snap_hw_step2_option4,
    ];
    final feedback = _feedbackFor(options);
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
                    _StepLabel(step: l.snap_hw_step2_label),
                    const SizedBox(height: 12),
                    Text(
                      l.snap_hw_step2_question,
                      style: AppTextStyles.font(context,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...options.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final o = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ListOption(
                          label: o,
                          state: _selected == null
                              ? _TileState.idle
                              : _selected == o
                                  ? (idx == _correctIndex
                                      ? _TileState.correct
                                      : _TileState.wrong)
                                  : _TileState.idle,
                          onTap: _selected == null
                              ? () => setState(() {
                                    _selected = o;
                                    if (idx != _correctIndex) _wrongCount++;
                                  })
                              : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    if (feedback == _FeedbackState.correct)
                      _FeedbackCard.correct(
                          message: l.snap_hw_step2_correct_msg),
                    if (feedback == _FeedbackState.wrong)
                      _FeedbackCard.wrong(
                          message: l.snap_hw_step2_wrong,
                          wrongCount: _wrongCount,
                          onTryAgain: () => setState(() {
                                _selected = null;
                                _wrongCount = 0;
                              })),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _BottomButton(
              label: l.snap_button_nextStep,
              enabled: feedback == _FeedbackState.correct,
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
  int _wrongCount = 0;
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
      if (answer == _correct) {
        _feedback = _FeedbackState.correct;
      } else {
        _feedback = _FeedbackState.wrong;
        _wrongCount++;
      }
    });
  }

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProblemCard(),
                    const SizedBox(height: 24),
                    _StepLabel(step: l.snap_hw_step3_label),
                    const SizedBox(height: 12),
                    Text(
                      l.snap_hw_step3_question,
                      style: AppTextStyles.font(context,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.snap_hw_step3_hint,
                      style: AppTextStyles.font(context,
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l.snap_hw_step3_x_prefix,
                          style: AppTextStyles.font(context,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          width: (MediaQuery.of(context).size.width * 0.26).clamp(80.0, 120.0),
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
                            style: AppTextStyles.font(context,
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
                      _FeedbackCard.correct(message: l.snap_hw_step3_correct),
                    if (_feedback == _FeedbackState.wrong)
                      _FeedbackCard.wrong(
                          message: l.snap_hw_step3_wrong,
                          wrongCount: _wrongCount,
                          onTryAgain: () {
                            _controller.clear();
                            setState(() {
                              _feedback = _FeedbackState.none;
                              _wrongCount = 0;
                            });
                          }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (_feedback == _FeedbackState.none)
              _BottomButton(
                label: l.snap_button_check,
                enabled: true,
                onTap: _check,
              )
            else
              _BottomButton(
                label: l.snap_button_nextStep,
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
    final l = context.l10n;
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
                    _StepLabel(step: l.snap_hw_completeSolution_label),
                    const SizedBox(height: 16),
                    _SolutionStepCard(
                      stepLabel: l.snap_hw_cs_step1_label,
                      title: null,
                      lines: [l.snap_hw_cs_step1_line1],
                    ),
                    const SizedBox(height: 12),
                    _SolutionStepCard(
                      stepLabel: l.snap_hw_cs_step2_label,
                      title: l.snap_hw_step2_option1,
                      lines: [
                        l.snap_hw_cs_step2_line1,
                        '2x + 5 = 15',
                        l.snap_hw_cs_step2_line3,
                        '2x + 5 - 5 = 15 - 5',
                        '2x = 10',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SolutionStepCard(
                      stepLabel: l.snap_hw_cs_step3_label,
                      title: l.snap_hw_step2_option2,
                      lines: [
                        l.snap_hw_cs_step3_line1,
                        '2x = 10',
                        l.snap_hw_cs_step3_line3,
                        l.snap_hw_cs_step3_line4,
                        l.snap_hw_cs_step3_line5,
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
              label: l.snap_button_done,
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
              style: AppTextStyles.font(context,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
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
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
            l.snap_solveFor,
            style: AppTextStyles.font(context,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '2x + 5 = 15',
            style: AppTextStyles.font(context,
              fontSize: (MediaQuery.of(context).size.width * 0.07).clamp(20.0, 28.0),
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
          style: AppTextStyles.font(context,
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
            style: AppTextStyles.font(context,
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
          style: AppTextStyles.font(context,
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
  final bool isCorrect;
  final String message;
  final int wrongCount;
  final VoidCallback? onTryAgain;

  const _FeedbackCard({
    required this.isCorrect,
    required this.message,
    this.wrongCount = 0,
    this.onTryAgain,
  });

  factory _FeedbackCard.correct({required String message}) => _FeedbackCard(
        isCorrect: true,
        message: message,
      );

  factory _FeedbackCard.wrong({
    required String message,
    required int wrongCount,
    required VoidCallback onTryAgain,
  }) =>
      _FeedbackCard(
        isCorrect: false,
        message: message,
        wrongCount: wrongCount,
        onTryAgain: onTryAgain,
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (isCorrect) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF237A4B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.font(context,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Wrong answer card — Figma: #e2562c bg, cornerRadius 16, padding 24
    final showActions = wrongCount >= 2;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE2562C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lightbulb_outline_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.snap_hw_letsLearnTogether,
                  style: AppTextStyles.font(context,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!showActions) ...[
            // First wrong: hint text + Try Again button
            Text(
              message,
              style: AppTextStyles.font(context,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onTryAgain,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Text(
                    l.snap_hw_button_tryAgain,
                    style: AppTextStyles.font(context,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE2562C),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Second+ wrong: 3 action cards
            _ActionRow(
              icon: Icons.play_circle_fill_rounded,
              iconColor: const Color(0xFF26C6A2),
              label: l.snap_hw_watchLesson,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _ActionRow(
              icon: Icons.lightbulb_rounded,
              iconColor: const Color(0xFFFFB300),
              label: l.snap_hw_viewExample,
              onTap: onTryAgain,
            ),
            const SizedBox(height: 10),
            _ActionRow(
              icon: Icons.close_rounded,
              iconColor: const Color(0xFFE2562C),
              label: l.snap_hw_skipStep,
              onTap: onTryAgain,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.font(context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
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
            style: AppTextStyles.font(context,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 4),
            Text(
              title!,
              style: AppTextStyles.font(context,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          ...lines.map((line) {
            final isBold = line.startsWith('2x') ||
                line.startsWith('x =') ||
                line.startsWith('x+') ||
                line == 'x = 5';
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                line,
                style: AppTextStyles.font(context,
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
    final l = context.l10n;
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
                  l.snap_hw_finalAnswer,
                  style: AppTextStyles.font(context,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'x = 5',
                  style: AppTextStyles.font(context,
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
          style: AppTextStyles.font(context,
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
              style: AppTextStyles.font(context,
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
