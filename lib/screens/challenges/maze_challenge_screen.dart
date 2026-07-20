import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/chunky_button.dart';

// Tile types
enum _Tile { wall, path, checkpoint, goal }

// The 6×6 maze grid decoded from Figma (row-major order)
// Row 0 (top): player starts at col 0
// Checkpoints at (row2,col2) and (row3,col4)
// Goal at (row5,col5)
const _mazeGrid = [
  // col:  0        1        2        3        4        5
  [_Tile.path,  _Tile.wall,  _Tile.path,  _Tile.path,  _Tile.path,  _Tile.wall ],  // row 0
  [_Tile.path,  _Tile.wall,  _Tile.path,  _Tile.wall,  _Tile.path,  _Tile.path ],  // row 1
  [_Tile.path,  _Tile.path,  _Tile.checkpoint, _Tile.wall, _Tile.path, _Tile.wall], // row 2
  [_Tile.wall,  _Tile.path,  _Tile.wall,  _Tile.path,  _Tile.checkpoint, _Tile.path], // row 3
  [_Tile.path,  _Tile.path,  _Tile.path,  _Tile.path,  _Tile.wall,  _Tile.path ],  // row 4
  [_Tile.wall,  _Tile.wall,  _Tile.path,  _Tile.path,  _Tile.path,  _Tile.goal ],  // row 5
];

class _Question {
  final String text;
  final List<String> options;
  final int correct;
  const _Question({required this.text, required this.options, required this.correct});
}

const _questions = [
  _Question(text: 'What is 5 + 8?',      options: ['12', '13', '14', '15'], correct: 1),
  _Question(text: 'What is 9 × 3?',      options: ['24', '27', '30', '21'], correct: 1),
  _Question(text: 'What is 36 ÷ 4?',     options: ['8', '9', '10', '7'],    correct: 1),
  _Question(text: 'What is 100 - 37?',   options: ['63', '67', '73', '57'], correct: 0),
  _Question(text: 'What is 6²?',         options: ['36', '12', '30', '42'], correct: 0),
  _Question(text: 'Solve: 2x = 14',      options: ['x=6', 'x=7', 'x=8', 'x=9'], correct: 1),
  _Question(text: 'What is 15% of 80?',  options: ['10', '12', '14', '16'], correct: 1),
  _Question(text: 'What is √49?',        options: ['6', '7', '8', '9'],     correct: 1),
];

class MazeChallengeScreen extends StatefulWidget {
  const MazeChallengeScreen({super.key});

  @override
  State<MazeChallengeScreen> createState() => _MazeChallengeScreenState();
}

class _MazeChallengeScreenState extends State<MazeChallengeScreen> {
  // Player position (row, col)
  int _playerRow = 0;
  int _playerCol = 0;

  int _lives = 3;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _questionsAnswered = 0;

  // Which checkpoints have been cleared
  final Set<String> _clearedCheckpoints = {};

  // Question state
  bool _showQuestion = false;
  int _questionIndex = 0;
  int? _selectedOption;
  bool _answerLocked = false;

  // Feedback bar
  bool _showFeedback = false;
  bool _feedbackCorrect = false;

  // Pending move to apply after answering a checkpoint question
  int? _pendingRow;
  int? _pendingCol;

  String _checkpointKey(int row, int col) => '$row,$col';

  void _tryMove(int dRow, int dCol) {
    if (_showQuestion) return;
    final newRow = _playerRow + dRow;
    final newCol = _playerCol + dCol;

    if (newRow < 0 || newRow >= 6 || newCol < 0 || newCol >= 6) return;
    final tile = _mazeGrid[newRow][newCol];
    if (tile == _Tile.wall) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.selectionClick();

    final key = _checkpointKey(newRow, newCol);
    final isCheckpoint = tile == _Tile.checkpoint && !_clearedCheckpoints.contains(key);
    final isGoal = tile == _Tile.goal;

    if (isCheckpoint || isGoal) {
      // Must answer a question to enter
      setState(() {
        _pendingRow = newRow;
        _pendingCol = newCol;
        _questionIndex = (_questionsAnswered) % _questions.length;
        _selectedOption = null;
        _answerLocked = false;
        _showQuestion = true;
        _showFeedback = false;
      });
    } else {
      setState(() {
        _playerRow = newRow;
        _playerCol = newCol;
      });
    }
  }

  void _selectOption(int idx) {
    if (_answerLocked) return;
    final correct = _questions[_questionIndex].correct;
    final isCorrect = idx == correct;
    setState(() {
      _selectedOption = idx;
      _answerLocked = true;
      _feedbackCorrect = isCorrect;
      _showFeedback = true;
      _questionsAnswered++;
      if (isCorrect) {
        _score += 30 + _streak * 10;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
      } else {
        _lives = (_lives - 1).clamp(0, 3);
        _streak = 0;
      }
    });

    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      setState(() {
        _showQuestion = false;
        _showFeedback = false;

        if (isCorrect && _pendingRow != null && _pendingCol != null) {
          final key = _checkpointKey(_pendingRow!, _pendingCol!);
          _clearedCheckpoints.add(key);
          _playerRow = _pendingRow!;
          _playerCol = _pendingCol!;
        }
        _pendingRow = null;
        _pendingCol = null;
      });

      if (_lives == 0) {
        Navigator.pushReplacementNamed(
          context,
          '/maze-done',
          arguments: {
            'score': _score,
            'solved': _questionsAnswered,
            'bestStreak': _bestStreak,
          },
        );
        return;
      }

      // Check if player reached goal
      final tile = _mazeGrid[_playerRow][_playerCol];
      if (tile == _Tile.goal) {
        _score += 100; // bonus
        Navigator.pushReplacementNamed(
          context,
          '/maze-done',
          arguments: {
            'score': _score,
            'solved': _questionsAnswered,
            'bestStreak': _bestStreak,
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Duolingo-style lesson top bar: X + hearts + score
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
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
                  // Lives
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(
                          i < _lives ? Icons.favorite : Icons.favorite_border,
                          color: AppColors.red,
                          size: 22,
                        ),
                      )),
                    ),
                  ),
                  // Score
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                          color: AppColors.border, width: AppSizes.cardBorder),
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
            ),
          ),

          // Subtitle banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Text(
              context.l10n.maze_navigate_treasure,
              style: AppTextStyles.font(context,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 14),

                // Hint bar (mascot) — top position per Figma
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                          color: AppColors.border, width: AppSizes.cardBorder),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          height: 63,
                          child: Image.asset(
                            'assets/images/onboarding_char2.png',
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, e, st) =>
                                const Text('🗺️', style: TextStyle(fontSize: 30)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.maze_use_arrows,
                                style: AppTextStyles.font(context,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF101828),
                                ),
                              ),
                              Text(
                                context.l10n.maze_reach_checkpoints,
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
                  ),
                ),

                const SizedBox(height: 14),

                // White card: maze grid + controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                          color: AppColors.border, width: AppSizes.cardBorder),
                    ),
                    child: Column(
                      children: [
                        // Maze grid
                        _MazeGrid(
                          grid: _mazeGrid,
                          playerRow: _playerRow,
                          playerCol: _playerCol,
                          clearedCheckpoints: _clearedCheckpoints,
                        ),
                        const SizedBox(height: 20),

                        // Arrow controls
                        _ArrowControls(onMove: _tryMove),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                          color: AppColors.border, width: AppSizes.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _LegendItem(
                          label: context.l10n.maze_legend_you,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFFFB86A), width: 2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Image.asset(
                              'assets/images/fi_616430.png',
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, e, st) =>
                                  const Icon(Icons.person, size: 14, color: AppColors.primaryLight),
                            ),
                          ),
                        ),
                        _LegendItem(
                          label: context.l10n.maze_legend_wall,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2939),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF101828)),
                            ),
                          ),
                        ),
                        _LegendItem(
                          label: context.l10n.maze_legend_checkpoint,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFF0B100), width: 2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.star, size: 16,
                                color: Color(0xFFF0B100)),
                          ),
                        ),
                        _LegendItem(
                          label: context.l10n.maze_legend_goal,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF51A2FF), width: 2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.diamond, size: 16,
                                color: Color(0xFF51A2FF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),

      // Question overlay
      bottomSheet: _showQuestion ? _buildQuestionSheet() : null,
    );
  }

  Widget _buildQuestionSheet() {
    final q = _questions[_questionIndex];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // White card with question
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + question text
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.quiz_outlined,
                              color: AppColors.primaryLight, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            q.text,
                            style: AppTextStyles.font(context,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF101828),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Options
                    ...List.generate(q.options.length, (i) {
                      Color bg = AppColors.white;
                      Color border = AppColors.border;
                      Color textColor = AppColors.textPrimary;
                      Widget? trailing;

                      if (_answerLocked) {
                        if (i == q.correct) {
                          bg = AppColors.successBg;
                          border = AppColors.green;
                          textColor = AppColors.greenDark;
                          trailing = const Icon(Icons.check_rounded,
                              color: AppColors.greenDark, size: 22);
                        } else if (i == _selectedOption && i != q.correct) {
                          bg = AppColors.errorBg;
                          border = AppColors.red;
                          textColor = AppColors.redDark;
                        }
                      } else if (_selectedOption == i) {
                        bg = AppColors.primary.withValues(alpha: 0.12);
                        border = AppColors.primary;
                      }

                      return GestureDetector(
                        onTap: () => _selectOption(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                                color: border, width: AppSizes.cardBorder),
                            boxShadow: _answerLocked
                                ? null
                                : [
                                    BoxShadow(
                                      color: border,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  q.options[i],
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
                      );
                    }),
                  ],
                ),
              ),

              if (_showFeedback) ...[
                const SizedBox(height: 12),
                // Feedback bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _feedbackCorrect
                        ? AppColors.successBg
                        : AppColors.errorBg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          _feedbackCorrect
                              ? 'assets/images/nmimes_inlove.png'
                              : 'assets/images/nmimes_surprised2.png',
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, e, st) => Text(
                            _feedbackCorrect ? '😍' : '😮',
                            style: const TextStyle(fontSize: 36),
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
                              _feedbackCorrect
                                  ? context.l10n.challenge_feedback_correct
                                  : context.l10n.maze_feedback_wrong,
                              style: AppTextStyles.font(context,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _feedbackCorrect
                                    ? AppColors.greenDark
                                    : AppColors.redDark,
                              ),
                            ),
                            Text(
                              _feedbackCorrect
                                  ? context.l10n.maze_feedback_correct_sub
                                  : context.l10n.maze_feedback_wrong_sub,
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
              ],

              // Bottom hint
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.quiz_outlined,
                      color: Color(0xFF101828), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.maze_answer_to_continue,
                    style: AppTextStyles.font(context,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF101828),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.maze_solve_to_keep_moving,
                style: AppTextStyles.font(context,
                  fontSize: 13,
                  color: const Color(0xFF364153),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Maze Grid Widget ─────────────────────────────────────────────────────────

class _MazeGrid extends StatelessWidget {
  final List<List<_Tile>> grid;
  final int playerRow;
  final int playerCol;
  final Set<String> clearedCheckpoints;

  const _MazeGrid({
    required this.grid,
    required this.playerRow,
    required this.playerCol,
    required this.clearedCheckpoints,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(grid.length, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(grid[row].length, (col) {
            final tile = grid[row][col];
            final isPlayer = row == playerRow && col == playerCol;
            final key = '$row,$col';
            final cleared = clearedCheckpoints.contains(key);
            return _MazeTile(
              tile: tile,
              isPlayer: isPlayer,
              isCleared: cleared,
            );
          }),
        );
      }),
    );
  }
}

class _MazeTile extends StatelessWidget {
  final _Tile tile;
  final bool isPlayer;
  final bool isCleared;

  const _MazeTile({
    required this.tile,
    required this.isPlayer,
    required this.isCleared,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color borderColor;
    Widget? inner;

    if (isPlayer) {
      bg = Colors.transparent;
      borderColor = const Color(0xFFFFB86A);
      inner = Image.asset(
        'assets/images/fi_616430.png',
        width: 30,
        height: 30,
        fit: BoxFit.contain,
        errorBuilder: (ctx, e, st) =>
            const Icon(Icons.person, color: AppColors.primaryLight, size: 22),
      );
    } else {
      switch (tile) {
        case _Tile.wall:
          bg = const Color(0xFF1E2939);
          borderColor = const Color(0xFF101828);
          break;
        case _Tile.path:
          bg = const Color(0xFFF3F4F6);
          borderColor = const Color(0xFFD1D5DC);
          break;
        case _Tile.checkpoint:
          bg = isCleared ? const Color(0xFFDCFCE7) : Colors.transparent;
          borderColor = isCleared
              ? const Color(0xFF35A468)
              : const Color(0xFFF0B100);
          inner = Icon(
            isCleared ? Icons.check : Icons.star,
            color: isCleared ? const Color(0xFF35A468) : const Color(0xFFF0B100),
            size: 18,
          );
          break;
        case _Tile.goal:
          bg = Colors.transparent;
          borderColor = const Color(0xFF51A2FF);
          inner = const Icon(Icons.diamond, color: Color(0xFF51A2FF), size: 20);
          break;
      }
    }

    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: inner,
    );
  }
}

// ─── Arrow Controls ───────────────────────────────────────────────────────────

class _ArrowControls extends StatelessWidget {
  final void Function(int dRow, int dCol) onMove;

  const _ArrowControls({required this.onMove});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Up
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ArrowBtn(icon: Icons.arrow_upward, onTap: () => onMove(-1, 0)),
          ],
        ),
        const SizedBox(height: 8),
        // Left / Down / Right
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ArrowBtn(icon: Icons.arrow_back, onTap: () => onMove(0, -1)),
            const SizedBox(width: 8),
            _ArrowBtn(icon: Icons.arrow_downward, onTap: () => onMove(1, 0)),
            const SizedBox(width: 8),
            _ArrowBtn(icon: Icons.arrow_forward, onTap: () => onMove(0, 1)),
          ],
        ),
      ],
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChunkyButton(
      onTap: onTap,
      color: AppColors.blue,
      height: 60,
      width: 64,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}

// ─── Legend Item ──────────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  final Widget child;
  final String label;

  const _LegendItem({required this.child, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.font(context,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF364153),
          ),
        ),
      ],
    );
  }
}

// ─── Leave Dialog ─────────────────────────────────────────────────────────────

class _LeaveDialog extends StatelessWidget {
  const _LeaveDialog();

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
              context.l10n.maze_leave_body,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ChunkyButton(
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (r) => false, arguments: 2),
                    color: AppColors.primary,
                    height: 50,
                    child: Text(
                      context.l10n.challenge_leave_yes,
                      style: AppTextStyles.font(context,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChunkyButton(
                    onTap: () => Navigator.pop(context),
                    color: Colors.white,
                    edgeColor: AppColors.border,
                    borderColor: AppColors.border,
                    height: 50,
                    child: Text(
                      context.l10n.challenge_leave_no,
                      style: AppTextStyles.font(context,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
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
