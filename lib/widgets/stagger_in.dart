import 'package:flutter/material.dart';

/// Slide-up + fade entrance, offset by [index] so a list of children cascades
/// in rather than appearing all at once.
///
/// Distinct from [BounceIn], which pops with an elastic overshoot and suits a
/// single hero element. This is the quieter variant for rows, cards, and form
/// fields where several things enter together and an elastic curve on each one
/// would read as noise.
///
/// The whole animation is a paint-time [Opacity] + [Transform.translate], so
/// it never triggers layout on the children it wraps.
class StaggerIn extends StatelessWidget {
  /// Position in the cascade. Each step adds [step] to the delay.
  final int index;

  /// Vertical travel, in logical pixels. Negative slides down from above.
  final double offset;

  /// Per-index delay increment.
  final Duration step;

  final Duration duration;
  final Widget child;

  const StaggerIn({
    super.key,
    required this.index,
    required this.child,
    this.offset = 16,
    this.step = const Duration(milliseconds: 70),
    this.duration = const Duration(milliseconds: 380),
  });

  @override
  Widget build(BuildContext context) {
    // The delay is folded into the duration rather than scheduled with a
    // timer: a `TweenAnimationBuilder` that starts immediately but eases over
    // a longer window costs no extra frames and cannot leak a pending
    // callback if the widget is disposed mid-entrance.
    final total = duration + step * index;

    return TweenAnimationBuilder<double>(
      // Keyed by index so reordering restarts the entrance rather than
      // animating from a neighbour's half-finished value.
      key: ValueKey(index),
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(
        // Hold at zero for this child's share of the window, then run.
        index == 0 ? 0 : (step * index).inMilliseconds / total.inMilliseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, offset * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
