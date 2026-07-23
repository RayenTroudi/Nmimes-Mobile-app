import 'package:flutter/widgets.dart';

/// Breakpoint-based responsive sizing, exposed on [BuildContext] to match the
/// existing `context.l10n` idiom. All values derive from [MediaQuery], so they
/// track rotation and split-screen automatically.
///
/// The app is tablet-first: `rs()` treats its argument as a size measured on
/// the reference tablet (shortest side 600). Phones scale it down; very large
/// tablets are capped so nothing balloons.
extension Responsive on BuildContext {
  Size get _size => MediaQuery.of(this).size;

  /// Shortest side is stable across rotation, so device class doesn't flip
  /// when a tablet is turned landscape.
  double get _shortest => _size.shortestSide;

  bool get isTablet => _shortest >= 600;
  bool get isSmallPhone => _shortest < 360;

  /// The clamped scale ratio applied by [rs].
  double get _scale => (_shortest / 600).clamp(0.82, 1.15);

  /// Scale a tablet-reference size to the current device class.
  double rs(double size) => size * _scale;

  /// Fraction of the screen width (e.g. `wp(0.30)` = 30% of width).
  double wp(double fraction) => _size.width * fraction;

  /// Fraction of the screen height.
  double hp(double fraction) => _size.height * fraction;

  /// Standard screen edge padding for the current device class.
  double get gutter => rs(24);
}
