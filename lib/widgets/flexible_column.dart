import 'package:flutter/material.dart';

/// A [Column] that fills its parent when there's room and scrolls when there
/// isn't, instead of throwing a RenderFlex overflow.
///
/// Use this for screens laid out as a fixed stack of content with a
/// [Spacer] pushing controls to the bottom. On tall screens it behaves
/// exactly like a plain Column — the Spacer distributes the slack. On short
/// screens, or when the user has a large accessibility text scale, the
/// content scrolls rather than overflowing.
///
/// [Spacer]/[Expanded] children are legal here: [IntrinsicHeight] gives the
/// column a bounded height inside the scroll view.
class FlexibleColumn extends StatelessWidget {
  const FlexibleColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding = EdgeInsets.zero,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Unbounded height (e.g. already inside a scroll view): a plain
        // Column is correct and IntrinsicHeight would throw.
        if (!constraints.hasBoundedHeight) {
          return Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: crossAxisAlignment,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          );
        }

        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  constraints.maxHeight -
                  padding.vertical.clamp(0.0, constraints.maxHeight),
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: crossAxisAlignment,
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }
}
