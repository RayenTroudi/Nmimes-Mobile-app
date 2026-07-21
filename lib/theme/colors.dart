import 'package:flutter/material.dart';

class AppColors {
  // Brand primaries — the logo orange, used for headers, buttons and the
  // full-bleed background areas across the app. Dark/light variants keep the
  // same hue: dark is the 3D bottom edge, light is icons and hairline borders.
  static const primary = Color(0xFFF05F01);
  static const primaryDark = Color(0xFFC04C01);
  static const primaryLight = Color(0xFFFC7E01);

  /// Panels sitting on the orange header — the points bar. Figma paints this
  /// as 20% white over [primary]; the flat equivalent is #F37F34, used here so
  /// the colour is exact regardless of what is painted underneath.
  static const primaryPanel = Color(0xFFF37F34);

  // Splash brand orange — the flat field the logo eyes sit on. Same value as
  // [primary]; kept separate because the native splash resources mirror it.
  static const logoOrange = Color(0xFFF05F01);
  static const eyeCream = Color(0xFFFCE9C8); // the logo's eye-blob
  static const eyePupil = Color(0xFF141414); // the logo's pupils
  static const eyelid = Color(0xFFF7C381); // blinking eyelid

  // Brand accents
  static const pink = Color(0xFFE97D9C); // Carissma
  static const green = Color(0xFF35A468); // Chateau Green
  static const blue = Color(0xFF058BC4); // Lochmara
  static const red = Color(0xFFE2562C); // Cinnabar

  // Darker "3D edge" variants of the accents (bottom border on chunky
  // buttons, map nodes, and pressed states)
  static const pinkDark = Color(0xFFC95F80);
  static const greenDark = Color(0xFF27824F);
  static const blueDark = Color(0xFF046E9B);
  static const redDark = Color(0xFFB84422);

  // Gamification
  static const gold = Color(0xFFF7C948); // completed map nodes
  static const goldDark = Color(0xFFD9A521);
  static const locked = Color(0xFFE5E5E5); // locked map nodes
  static const lockedEdge = Color(0xFFCFCFCF);
  static const lockedIcon = Color(0xFFAFAFAF);

  // Backgrounds
  static const background = Color(0xFFFFF7E8); // warm cream content sheet
  static const surface = Color(0xFFFFFFFF);
  static const cardBg = Color(0xFFFFFFFF);
  static const headerBg = primary; // orange header sections

  // Text
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF555555);
  static const textHint = Color(0xFF999999);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Misc
  static const success = Color(0xFF35A468);
  static const successBg = Color(0xFFD7FFB8); // correct-answer sheet
  static const error = Color(0xFFE2562C);
  static const errorBg = Color(0xFFFFDFE0); // wrong-answer sheet
  static const navBarBg = Color(0xFFFFFFFF);
  static const navActive = primary;
  static const navInactive = Color(0xFFBBBBBB);
  static const cardBorder = Color(0xFFE8E0D5);
  static const border = Color(0xFFE5E5E5); // flat 2px card borders

  // Card border roles. Primary action cards (Snap a Homework/Lesson and
  // friends) are outlined in brand orange to pull the eye; secondary list
  // rows sit borderless on the cream sheet and lean on their shadow instead.
  static const cardBorderPrimary = primary;
  static const cardBorderSecondary = Colors.transparent;
  static const dotActive = primary;
  static const dotInactive = Color(0xFFD9D9D9);
  static const inputBorder = Color(0xFFE0D8CC);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const dutchWhite = Color(0xFFF5E4C3); // Dutch White from palette

  /// Darker edge color matching a section accent, for 3D bottom borders.
  static Color edgeFor(Color base) {
    if (base == primary || base == primaryLight) return primaryDark;
    if (base == green) return greenDark;
    if (base == blue) return blueDark;
    if (base == pink) return pinkDark;
    if (base == red) return redDark;
    if (base == gold) return goldDark;
    if (base == locked) return lockedEdge;
    if (base == white) return border;
    return Color.lerp(base, black, 0.25)!;
  }
}
