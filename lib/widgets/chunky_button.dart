import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/responsive.dart';

/// Duolingo-style chunky control: a solid fill with a darker 3D bottom
/// edge that presses down on tap. Used by buttons and map nodes.
class ChunkyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color? edgeColor;
  final Color? borderColor;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final bool haptics;

  const ChunkyButton({
    super.key,
    required this.child,
    required this.onTap,
    required this.color,
    this.edgeColor,
    this.borderColor,
    this.height = AppSizes.buttonHeight,
    this.width,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.haptics = true,
  });

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (widget.onTap == null) return;
    setState(() => _pressed = v);
  }

  void _activate() {
    if (widget.onTap == null) return;
    if (widget.haptics) HapticFeedback.lightImpact();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final edge = widget.edgeColor ?? AppColors.edgeFor(widget.color);
    final radius = widget.shape == BoxShape.circle
        ? null
        : (widget.borderRadius ?? BorderRadius.circular(AppRadius.md));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap == null ? null : _activate,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: context.rs(widget.height) + AppSizes.buttonEdge,
        ),
        child: SizedBox(
          width: widget.width,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            margin: EdgeInsets.only(
              top: _pressed ? AppSizes.buttonEdge : 0,
              bottom: _pressed ? 0 : AppSizes.buttonEdge,
            ),
            decoration: BoxDecoration(
              color: widget.color,
              shape: widget.shape,
              borderRadius: radius,
              border: widget.borderColor == null
                  ? null
                  : Border.all(
                      color: widget.borderColor!, width: AppSizes.cardBorder),
              boxShadow: _pressed
                  ? const []
                  : [
                      BoxShadow(
                        color: edge,
                        offset: const Offset(0, AppSizes.buttonEdge),
                      ),
                    ],
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// Subtle tap feedback for cards: scales to 0.97 while pressed.
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool haptics;

  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.haptics = false,
  });

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _pressed = false;

  void _activate() {
    if (widget.onTap == null) return;
    if (widget.haptics) HapticFeedback.lightImpact();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (widget.onTap != null) setState(() => _pressed = true);
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap == null ? null : _activate,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
