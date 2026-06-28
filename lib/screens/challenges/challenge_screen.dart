import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';

// Puzzle data: equation shown as prefix + blank + suffix, answer, wrong choices
class _Puzzle {
  final String prefix;  // text before blank, e.g. ""
  final String suffix;  // text after blank, e.g. "+ 3 = 8"
  final int answer;
  final List<int> choices;

  const _Puzzle({
    required this.prefix,
    required this.suffix,
    required this.answer,
    required this.choices,
  });

  String get equation => prefix.isEmpty ? '___ $suffix' : '$prefix ___ $suffix';
}

const _puzzles = [
  _Puzzle(prefix: '', suffix: '+ 3 = 8',  answer: 5, choices: [5, 7, 4, 6]),
  _Puzzle(prefix: '', suffix: 'x 2 = 12', answer: 6, choices: [4, 5, 6, 7]),
  _Puzzle(prefix: '', suffix: '- 4 = 9',  answer: 13, choices: [11, 13, 15, 12]),
  _Puzzle(prefix: '', suffix: '÷ 3 = 4',  answer: 12, choices: [10, 12, 9, 15]),
  _Puzzle(prefix: '', suffix: '+ 7 = 15', answer: 8, choices: [6, 8, 9, 7]),
  _Puzzle(prefix: '', suffix: 'x 4 = 20', answer: 5, choices: [4, 5, 6, 8]),
  _Puzzle(prefix: '', suffix: '- 9 = 6',  answer: 15, choices: [13, 15, 16, 14]),
  _Puzzle(prefix: '', suffix: '÷ 2 = 7',  answer: 14, choices: [12, 14, 16, 13]),
];

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  int _index = 0;
  int? _droppedAnswer;   // value dropped in the zone, null = empty
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _lives = 3;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _solved = 0;

  _Puzzle get _puzzle => _puzzles[_index];

  void _onDrop(int value) {
    if (_droppedAnswer != null) return;
    HapticFeedback.lightImpact();
    final correct = value == _puzzle.answer;
    setState(() {
      _droppedAnswer = value;
      _isCorrect = correct;
      _showFeedback = true;
      if (correct) {
        _score += 30 + _streak * 10;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _solved++;
      } else {
        _lives = (_lives - 1).clamp(0, 3);
        _streak = 0;
      }
    });
    Future.delayed(const Duration(milliseconds: 1400), _next);
  }

  void _next() {
    if (_lives == 0 || _index >= _puzzles.length - 1) {
      Navigator.pushReplacementNamed(
        context,
        '/challenge-done',
        arguments: {
          'score': _score,
          'solved': _solved,
          'total': _puzzles.length,
          'bestStreak': _bestStreak,
        },
      );
    } else {
      setState(() {
        _index++;
        _droppedAnswer = null;
        _showFeedback = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzle;
    final progress = (_index + 1) / _puzzles.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      body: Column(
        children: [
          // Orange header
          Container(
            color: const Color(0xFFF79C09),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        // Close button
                        GestureDetector(
                          onTap: () => showDialog(
                            context: context,
                            barrierColor: Colors.black.withValues(alpha: 0.3),
                            builder: (_) => const _LeaveChallengeDialog(),
                          ),
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
                        // Lives (hearts)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Icon(
                                i < _lives ? Icons.favorite : Icons.favorite_border,
                                color: Colors.white,
                                size: 22,
                              ),
                            )),
                          ),
                        ),
                        // Score pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Color(0xFFFFD475), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '$_score',
                                style: AppTextStyles.font(context,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.challenge_puzzle_of(_index + 1, _puzzles.length),
                    style: AppTextStyles.font(context,
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // White puzzle card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD6A7), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Equation header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF7EB),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.extension,
                                    color: Color(0xFFF79C09), size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                context.l10n.challenge_complete_puzzle,
                                style: AppTextStyles.font(context,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4A5565),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Equation text
                          Text(
                            puzzle.equation,
                            style: AppTextStyles.font(context,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF101828),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Drop zone
                          DragTarget<int>(
                            onWillAcceptWithDetails: (details) => _droppedAnswer == null,
                            onAcceptWithDetails: (details) => _onDrop(details.data),
                            builder: (context, candidateData, rejectedData) {
                              final isHovering = candidateData.isNotEmpty;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: _droppedAnswer != null
                                      ? (_isCorrect
                                          ? const Color(0xFFD1FAE5)
                                          : const Color(0xFFFFE4E4))
                                      : isHovering
                                          ? const Color(0xFFFFF0CC)
                                          : const Color(0xFFFFF7EA),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _droppedAnswer != null
                                        ? (_isCorrect
                                            ? const Color(0xFF35A468)
                                            : Colors.red)
                                        : isHovering
                                            ? const Color(0xFFF79C09)
                                            : const Color(0xFFF79C09),
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _droppedAnswer != null
                                      ? '$_droppedAnswer'
                                      : '?',
                                  style: AppTextStyles.font(context,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    color: _droppedAnswer != null
                                        ? (_isCorrect
                                            ? const Color(0xFF35A468)
                                            : Colors.red)
                                        : const Color(0xFFFFB86A),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // "Choose a number" label
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              context.l10n.challenge_choose_number,
                              style: AppTextStyles.font(context,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4A5565),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Draggable number tiles grid
                          Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            alignment: WrapAlignment.center,
                            children: puzzle.choices.map((n) {
                              final used = _droppedAnswer == n && _droppedAnswer != null;
                              return _DraggableTile(
                                value: n,
                                disabled: _droppedAnswer != null,
                                used: used,
                              );
                            }).toList(),
                          ),

                          const Spacer(),

                          // Hint text
                          if (_droppedAnswer == null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.touch_app_outlined,
                                    color: Color(0xFF4A5565), size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  context.l10n.challenge_drag_number,
                                  style: AppTextStyles.font(context,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF101828),
                                  ),
                                ),
                              ],
                            ),
                          if (_droppedAnswer == null)
                            const SizedBox(height: 4),
                          if (_droppedAnswer == null)
                            Text(
                              context.l10n.challenge_drop_hint,
                              style: AppTextStyles.font(context,
                                fontSize: 13,
                                color: const Color(0xFF364153),
                              ),
                              textAlign: TextAlign.center,
                            ),
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
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: _isCorrect
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFFFE4E4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isCorrect
                                    ? const Color(0xFF35A468)
                                    : Colors.red.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 55,
                                  height: 55,
                                  child: Image.asset(
                                    _isCorrect
                                        ? 'assets/images/nmimes_inlove.png'
                                        : 'assets/images/nmimes_surprised2.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (ctx, e, st) => Text(
                                      _isCorrect ? '😍' : '😮',
                                      style: const TextStyle(fontSize: 40),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _isCorrect
                                            ? context.l10n.challenge_feedback_correct
                                            : context.l10n.challenge_feedback_wrong,
                                        style: AppTextStyles.font(context,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2E2E2E),
                                        ),
                                      ),
                                      Text(
                                        _isCorrect
                                            ? context.l10n.challenge_feedback_correct_sub
                                            : context.l10n.challenge_feedback_wrong_sub(_puzzle.answer),
                                        style: AppTextStyles.font(context,
                                          fontSize: 12,
                                          color: const Color(0xFF364153),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DraggableTile extends StatelessWidget {
  final int value;
  final bool disabled;
  final bool used;

  const _DraggableTile({
    required this.value,
    required this.disabled,
    required this.used,
  });

  @override
  Widget build(BuildContext context) {
    if (used) {
      // Show ghost placeholder where the tile was
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }

    return Draggable<int>(
      data: value,
      feedback: Material(
        color: Colors.transparent,
        child: _TileContent(value: value, opacity: 1.0),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _TileContent(value: value, opacity: 0.3),
      ),
      onDragStarted: () => HapticFeedback.selectionClick(),
      child: GestureDetector(
        onTap: disabled ? null : () {
          // Tap to place (alternative to drag)
          final screen = context.findAncestorStateOfType<_ChallengeScreenState>();
          screen?._onDrop(value);
        },
        child: _TileContent(value: value, opacity: disabled ? 0.4 : 1.0),
      ),
    );
  }
}

class _TileContent extends StatelessWidget {
  final int value;
  final double opacity;

  const _TileContent({required this.value, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF79C09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF79C09).withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$value',
          style: AppTextStyles.font(context,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _LeaveChallengeDialog extends StatelessWidget {
  const _LeaveChallengeDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.challenge_leave_title,
              style: AppTextStyles.font(context,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.challenge_leave_body,
              style: AppTextStyles.font(context,
                fontSize: 14,
                color: const Color(0xFF2E2E2E),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.challenge_leave_confirm,
              style: AppTextStyles.font(context,
                fontSize: 14,
                color: const Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/challenges', (r) => false),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.l10n.challenge_leave_yes,
                        style: AppTextStyles.font(context,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.l10n.challenge_leave_no,
                        style: AppTextStyles.font(context,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
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
