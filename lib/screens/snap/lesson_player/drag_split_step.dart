import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../../theme/text_styles.dart';

/// Step 5 — drag the ten "1" blocks from the tray into the two x boxes.
/// Each box holds at most five; when both are full, each x lights up as 5
/// and the player shows the success sheet.
class DragSplitStep extends StatefulWidget {
  final void Function(bool correct, {String? message}) onAnswer;
  const DragSplitStep({super.key, required this.onAnswer});

  @override
  State<DragSplitStep> createState() => _DragSplitStepState();
}

class _DragSplitStepState extends State<DragSplitStep> {
  static const _capacity = 5;

  /// Where each of the 10 blocks lives: null = tray, 0 = left x, 1 = right x.
  final List<int?> _placement = List.filled(10, null);
  bool _done = false;

  int _countIn(int box) => _placement.where((p) => p == box).length;

  void _drop(int blockIndex, int box) {
    if (_done || _countIn(box) >= _capacity) return;
    HapticFeedback.lightImpact();
    setState(() => _placement[blockIndex] = box);
    if (_countIn(0) == _capacity && _countIn(1) == _capacity) {
      _done = true;
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          widget.onAnswer(true, message: context.l10n.lesson_drag_done);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final trayBlocks = [
      for (var i = 0; i < 10; i++)
        if (_placement[i] == null) i
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          Text(
            l.lesson_drag_title,
            textAlign: TextAlign.center,
            style: AppTextStyles.font(context,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '2x = 10',
            style: AppTextStyles.font(context,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),

          // The two x boxes
          Row(
            children: [
              Expanded(child: _xBox(0)),
              const SizedBox(width: 16),
              Expanded(child: _xBox(1)),
            ],
          ),

          const Spacer(),

          // Tray of remaining blocks
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                  color: AppColors.border, width: AppSizes.cardBorder),
            ),
            child: trayBlocks.isEmpty
                ? Center(
                    child: Text(
                      '🎉',
                      style: const TextStyle(fontSize: 28),
                    ),
                  )
                : Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final i in trayBlocks)
                        Draggable<int>(
                          data: i,
                          feedback: _block(dragging: true),
                          childWhenDragging:
                              Opacity(opacity: 0.25, child: _block()),
                          child: _block(),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            l.lesson_drag_hint,
            textAlign: TextAlign.center,
            style: AppTextStyles.font(context,
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _xBox(int box) {
    final count = _countIn(box);
    final full = count == _capacity;
    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => !full,
      onAcceptWithDetails: (details) => _drop(details.data, box),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 150,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: full
                ? AppColors.successBg
                : hovering
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: full
                  ? AppColors.green
                  : hovering
                      ? AppColors.primary
                      : AppColors.border,
              width: full || hovering ? 3 : AppSizes.cardBorder,
            ),
          ),
          child: Column(
            children: [
              Text(
                full ? 'x = 5' : 'x',
                style: AppTextStyles.font(context,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: full ? AppColors.green : AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < count; i++) _block(small: true),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _block({bool dragging = false, bool small = false}) {
    final size = small ? 26.0 : 34.0;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(8),
          boxShadow: dragging
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: AppColors.blueDark,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            '1',
            style: TextStyle(
              fontSize: small ? 12 : 15,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
