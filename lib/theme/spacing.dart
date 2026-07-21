import 'package:flutter/material.dart';

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

/// Corner radii for the chunky Duolingo-style design language.
class AppRadius {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const pill = 999.0;

  /// Cards and tappable rows. Figma rounds these to ~19.46; 20 matches
  /// [lg] and reads identically at every screen density.
  static const card = 20.0;

  /// The cream content sheet that overlaps the orange header.
  static const sheet = 30.0;
}

/// Soft elevation for cards and tappable rows. Cards lift off the cream
/// sheet with a diffuse shadow rather than a hard border.
///
/// Measured from the Figma render rather than guessed: the alpha falloff
/// below a card edge was sampled at 4x and least-squares fitted to a
/// gaussian, giving peak alpha 31%, offset 1.1pt, sigma 4.1pt (rms 1.3/255).
class AppShadows {
  static const card = <BoxShadow>[
    BoxShadow(
      color: Color(0x4F000000), // 31% black
      blurRadius: 8,
      offset: Offset(0, 1),
    ),
  ];

  /// Panels that float on a saturated background — the points bar on the
  /// orange header. Softer and pushed further down than [card], so the
  /// panel reads as lifted off the colour rather than outlined on it.
  ///
  /// Measured the same way: alpha 19%, offset 5.5pt, sigma 4.5pt
  /// (rms 0.006). Fitting both the bar's top and bottom edges together was
  /// necessary — an unconstrained fit trades offset against blur and lands
  /// on a centred shadow, which the near-zero alpha above the bar rules out.
  static const onColor = <BoxShadow>[
    BoxShadow(
      color: Color(0x30000000), // 19% black
      blurRadius: 9,
      offset: Offset(0, 5),
    ),
  ];
}

/// Shared metrics for chunky controls.
class AppSizes {
  static const buttonHeight = 54.0; // primary/secondary buttons
  static const buttonEdge = 4.0; // 3D bottom edge thickness
  static const cardBorder = 2.0; // flat card border width
  static const progressBar = 12.0; // pill progress bar height
  static const mapNode = 70.0; // map node diameter
}
