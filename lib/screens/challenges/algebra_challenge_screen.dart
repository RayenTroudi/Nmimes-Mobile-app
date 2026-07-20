import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/app_progress_bar.dart';

class _Question {
  final String question;
  final List<String> choices;
  final int correctIndex;

  const _Question({
    required this.question,
    required this.choices,
    required this.correctIndex,
  });
}

const _questions = [
  _Question(
    question: 'Solve: 2x + 5 = 13',
    choices: ['x = 3', 'x = 4', 'x = 5', 'x = 6'],
    correctIndex: 1,
  ),
  _Question(
    question: 'Simplify: 3x + 2x',
    choices: ['5x', '6x', '5x²', '3x'],
    correctIndex: 0,
  ),
  _Question(
    question: 'Solve: x - 7 = 12',
    choices: ['x = 17', 'x = 19', 'x = 5', 'x = 20'],
    correctIndex: 1,
  ),
  _Question(
    question: 'Solve: 3x = 18',
    choices: ['x = 5', 'x = 6', 'x = 7', 'x = 9'],
    correctIndex: 1,
  ),
  _Question(
    question: 'Expand: 2(x + 3)',
    choices: ['2x + 3', '2x + 6', 'x + 6', '2x + 5'],
    correctIndex: 1,
  ),
  _Question(
    question: 'Solve: x/4 = 5',
    choices: ['x = 9', 'x = 15', 'x = 20', 'x = 1'],
    correctIndex: 2,
  ),
  _Question(
    question: 'Simplify: 4x - x',
    choices: ['3x', '4x', '5x', 'x'],
    correctIndex: 0,
  ),
  _Question(
    question: 'Solve: 2x - 3 = 7',
    choices: ['x = 4', 'x = 5', 'x = 6', 'x = 2'],
    correctIndex: 1,
  ),
  _Question(
    question: 'Factor: x² + 5x + 6',
    choices: ['(x+2)(x+3)', '(x+1)(x+6)', '(x+3)(x+2)', '(x+4)(x+2)'],
    correctIndex: 0,
  ),
  _Question(
    question: 'Solve: 5x + 2 = 3x + 10',
    choices: ['x = 3', 'x = 4', 'x = 5', 'x = 6'],
    correctIndex: 1,
  ),
];

class AlgebraChallengeScreen extends StatefulWidget {
  const AlgebraChallengeScreen({super.key});

  @override
  State<AlgebraChallengeScreen> createState() =>
      _AlgebraChallengeScreenState();
}

class _AlgebraChallengeScreenState extends State<AlgebraChallengeScreen> {
  int _index = 0;
  int? _selectedIndex;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _lives = 3;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _solved = 0;

  _Question get _q => _questions[_index];

  void _select(int choiceIdx) {
    if (_selectedIndex != null) return;
    HapticFeedback.lightImpact();
    final correct = choiceIdx == _q.correctIndex;
    setState(() {
      _selectedIndex = choiceIdx;
      _isCorrect = correct;
      _showFeedback = true;
      if (correct) {
        _solved++;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _score += 10 + (_streak > 1 ? (_streak - 1) * 5 : 0);
      } else {
        _streak = 0;
        _lives--;
      }
    });

    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      if (_lives <= 0 || _index >= _questions.length - 1) {
        Navigator.pushReplacementNamed(
          context,
          '/algebra-done',
          arguments: {
            'score': _score,
            'solved': _solved,
            'total': _questions.length,
            'bestStreak': _bestStreak,
          },
        );
      } else {
        setState(() {
          _index++;
          _selectedIndex = null;
          _showFeedback = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_index) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Duolingo-style lesson top bar: X + thick progress + hearts + score
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Close button
                      GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          barrierColor: Colors.black.withValues(alpha: 0.3),
                          builder: (_) => const _LeaveDialog(),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: AppColors.textHint, size: 28),
                      ),
                      const SizedBox(width: 12),
                      // Progress bar fills the row
                      Expanded(
                        child: AppProgressBar(value: progress),
                      ),
                      const SizedBox(width: 12),
                      // Lives
                      Row(
                        children: List.generate(
                          3,
                          (i) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 1.5),
                            child: Icon(
                              i < _lives
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: AppColors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Score
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                              color: AppColors.border,
                              width: AppSizes.cardBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppColors.gold, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$_score',
                              style: AppTextStyles.font(context,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Question counter
                  Text(
                    context.l10n.algebra_question_of(_index + 1, _questions.length),
                    style: AppTextStyles.font(context,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Question card + choices
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                      color: AppColors.border, width: AppSizes.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question icon + text
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFFFD6A7), width: 1),
                          ),
                          child: const Icon(Icons.calculate_outlined,
                              color: Color(0xFFF79C09), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _q.question,
                            style: AppTextStyles.font(context,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E2E2E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Choices
                    ...List.generate(_q.choices.length, (i) {
                      final isSelected = _selectedIndex == i;
                      final isCorrectChoice =
                          i == _q.correctIndex && _showFeedback;
                      final isWrongSelected =
                          isSelected && _showFeedback && !_isCorrect;

                      Color bgColor = AppColors.white;
                      Color borderColor = AppColors.border;
                      Color textColor = AppColors.textPrimary;
                      Widget? trailing;

                      if (_showFeedback) {
                        if (isCorrectChoice) {
                          bgColor = const Color(0xFFDCFCE7);
                          borderColor = const Color(0xFF35A468);
                          textColor = const Color(0xFF35A468);
                          trailing = Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFF35A468),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                color: Colors.white, size: 14),
                          );
                        } else if (isWrongSelected) {
                          bgColor = const Color(0xFFFFE2E2);
                          borderColor = const Color(0xFFE2562C);
                          textColor = const Color(0xFFE2562C);
                          trailing = Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE2562C),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          );
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _select(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                  color: borderColor,
                                  width: AppSizes.cardBorder),
                              boxShadow: _showFeedback
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: borderColor,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _q.choices[i],
                                    style: AppTextStyles.font(context,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                ?trailing,
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Feedback bar
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showFeedback
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    decoration: BoxDecoration(
                      color: _isCorrect
                          ? AppColors.successBg
                          : AppColors.errorBg,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.lg)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            _isCorrect
                                ? 'assets/images/nmimes_inlove.png'
                                : 'assets/images/nmimes_surprised2.png',
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, e, st) => Text(
                              _isCorrect ? '😍' : '😲',
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isCorrect
                                    ? context.l10n.algebra_feedback_correct
                                    : context.l10n.algebra_feedback_wrong,
                                style: AppTextStyles.font(context,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _isCorrect
                                      ? AppColors.greenDark
                                      : AppColors.redDark,
                                ),
                              ),
                              Text(
                                _isCorrect
                                    ? context.l10n.algebra_feedback_correct_sub
                                    : context.l10n.algebra_feedback_wrong_sub,
                                style: AppTextStyles.font(context,
                                  fontSize: 13,
                                  color: const Color(0xFF364153),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _LeaveDialog extends StatelessWidget {
  const _LeaveDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              context.l10n.algebra_leave_title,
              style: AppTextStyles.font(context,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.algebra_leave_body,
              style: AppTextStyles.font(context,
                fontSize: 14,
                color: const Color(0xFF5A6677),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF101828),
                      side: const BorderSide(color: Color(0xFFD1D5DC)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      context.l10n.algebra_leave_stay,
                      style: AppTextStyles.font(context, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false, arguments: 2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE2562C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      context.l10n.algebra_leave_leave,
                      style: AppTextStyles.font(context, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
