import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../../theme/text_styles.dart';
import 'homework_steps.dart';
import 'homework_widgets.dart';

/// Step 3 — do the algebra by hand instead of typing the answer.
///
/// Two phases on one screen:
///   1. Drag the five "+5" blocks off *both* pans. Removing from one side
///      tips the scale; matching it on the other brings it level again.
///   2. With `2x = 10` left, tap to split the ten units into the two x
///      groups, which reveals `x = 5`.
///
/// This replaces a `TextField` that asked the child to type a number the
/// fox had already told them — no mechanic, and the keyboard covered the
/// feedback sheet on short screens.
class HwBalanceStep extends StatefulWidget {
  final HwStep step;
  final void Function(bool correct, {String? message}) onAnswer;

  const HwBalanceStep({super.key, required this.step, required this.onAnswer});

  @override
  State<HwBalanceStep> createState() => _HwBalanceStepState();
}

enum _Phase { removing, splitting, done }

class _HwBalanceStepState extends State<HwBalanceStep>
    with SingleTickerProviderStateMixin {
  /// How many "+5" units are still on each pan.
  int _left = 5;
  int _right = 5;

  /// Units moved into each x group during the splitting phase.
  int _groupA = 0;
  int _groupB = 0;

  _Phase _phase = _Phase.removing;

  late final AnimationController _tilt = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late Animation<double> _tiltAnim = const AlwaysStoppedAnimation(0);

  @override
  void dispose() {
    _tilt.dispose();
    super.dispose();
  }

  /// Scale angle: positive tips left-heavy. Driven by the imbalance so the
  /// child *sees* that removing from one side alone breaks the equation.
  void _retilt() {
    final target = ((_left - _right) * 0.06).clamp(-0.18, 0.18);
    _tiltAnim = Tween<double>(begin: _tiltAnim.value, end: target).animate(
      CurvedAnimation(parent: _tilt, curve: Curves.elasticOut),
    );
    _tilt.forward(from: 0);
  }

  void _removeFrom(bool left) {
    if (_phase != _Phase.removing) return;
    if (left && _left == 0) return;
    if (!left && _right == 0) return;

    HapticFeedback.lightImpact();
    setState(() {
      if (left) {
        _left--;
      } else {
        _right--;
      }
    });
    _retilt();

    if (_left == 0 && _right == 0) {
      HapticFeedback.mediumImpact();
      setState(() => _phase = _Phase.splitting);
    }
  }

  void _addToGroup(bool a) {
    if (_phase != _Phase.splitting) return;
    final placed = _groupA + _groupB;
    if (placed >= 10) return;
    if (a && _groupA >= 5) return;
    if (!a && _groupB >= 5) return;

    HapticFeedback.lightImpact();
    setState(() {
      if (a) {
        _groupA++;
      } else {
        _groupB++;
      }
    });

    if (_groupA == 5 && _groupB == 5) {
      setState(() => _phase = _Phase.done);
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        widget.onAnswer(true, message: widget.step.correct?.call(context.l10n));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final step = widget.step;
    final balanced = _left == _right;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HwStagger(index: 0, child: HwStepLabel(label: step.label!(l))),
        const SizedBox(height: 12),
        HwStagger(
          index: 1,
          child: Text(
            _phase == _Phase.removing
                ? l.lesson_remove_title
                : l.lesson_drag_title,
            style: AppTextStyles.font(
              context,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ── The scale ────────────────────────────────────────────────
        HwStagger(
          index: 2,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _tilt,
              builder: (context, child) => Transform.rotate(
                angle: _tiltAnim.value,
                child: child,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _Pan(
                      label: _phase == _Phase.removing ? '2x + $_left' : '2x',
                      units: _left,
                      unitLabel: '+1',
                      color: AppColors.blue,
                      edge: AppColors.blueDark,
                      onTap: () => _removeFrom(true),
                      enabled: _phase == _Phase.removing && _left > 0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '=',
                      style: AppTextStyles.font(
                        context,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _Pan(
                      label: _phase == _Phase.removing
                          ? '${10 + _right}'
                          : '10',
                      units: _right,
                      unitLabel: '+1',
                      color: AppColors.pink,
                      edge: AppColors.pinkDark,
                      onTap: () => _removeFrom(false),
                      enabled: _phase == _Phase.removing && _right > 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Live balance read-out — the teaching moment.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _phase == _Phase.removing
              ? Row(
                  key: ValueKey(balanced),
                  children: [
                    Icon(
                      balanced
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      size: 18,
                      color: balanced ? AppColors.green : AppColors.red,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        balanced
                            ? l.lesson_remove_done
                            : l.lesson_remove_body,
                        style: AppTextStyles.font(
                          context,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: balanced ? AppColors.green : AppColors.red,
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),

        // ── Splitting phase ──────────────────────────────────────────
        if (_phase != _Phase.removing) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _XGroup(count: _groupA, onTap: () => _addToGroup(true))),
              const SizedBox(width: 12),
              Expanded(child: _XGroup(count: _groupB, onTap: () => _addToGroup(false))),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _phase == _Phase.done
                ? l.lesson_drag_done
                : l.lesson_drag_title,
            style: AppTextStyles.font(
              context,
              fontSize: 13,
              color: _phase == _Phase.done
                  ? AppColors.green
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// One side of the balance. Tapping removes a unit.
class _Pan extends StatelessWidget {
  final String label;
  final int units;
  final String unitLabel;
  final Color color;
  final Color edge;
  final VoidCallback onTap;
  final bool enabled;

  const _Pan({
    required this.label,
    required this.units,
    required this.unitLabel,
    required this.color,
    required this.edge,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: enabled ? AppColors.primary : AppColors.border,
          width: enabled ? 3 : AppSizes.cardBorder,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.font(
              context,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                for (var i = 0; i < units; i++)
                  GestureDetector(
                    onTap: enabled ? onTap : null,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [BoxShadow(color: edge, offset: const Offset(0, 2))],
                      ),
                      child: Center(
                        child: Text(
                          unitLabel,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One of the two x groups in the splitting phase.
class _XGroup extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _XGroup({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final full = count == 5;
    return GestureDetector(
      onTap: full ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 92,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: full ? AppColors.successBg : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: full ? AppColors.green : AppColors.primary,
            width: full ? 3 : AppSizes.cardBorder,
          ),
        ),
        child: Column(
          children: [
            Text(
              full ? 'x = 5' : 'x',
              style: AppTextStyles.font(
                context,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: full ? AppColors.green : AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (var i = 0; i < count; i++)
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(4),
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
}
