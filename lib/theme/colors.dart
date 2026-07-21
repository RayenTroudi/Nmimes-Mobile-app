import 'package:flutter/material.dart';

class AppColors {
  // Brand primaries
  static const primary       = Color(0xFFE8720C); // Orange Peel
  static const primaryDark   = Color(0xFFC45E00);
  static const primaryLight  = Color(0xFFF79009);

  // Splash brand orange — the flat field the logo eyes sit on
  static const logoOrange     = Color(0xFFF05F01);
  static const eyeCream        = Color(0xFFFCE9C8); // the logo's eye-blob
  static const eyePupil        = Color(0xFF141414); // the logo's pupils
  static const eyelid          = Color(0xFFF7C381); // blinking eyelid

  // Brand accents
  static const pink          = Color(0xFFE97D9C); // Carissma
  static const green         = Color(0xFF35A468); // Chateau Green
  static const blue          = Color(0xFF058BC4); // Lochmara
  static const red           = Color(0xFFE2562C); // Cinnabar

  // Darker "3D edge" variants of the accents (bottom border on chunky
  // buttons, map nodes, and pressed states)
  static const pinkDark      = Color(0xFFC95F80);
  static const greenDark     = Color(0xFF27824F);
  static const blueDark      = Color(0xFF046E9B);
  static const redDark       = Color(0xFFB84422);

  // Gamification
  static const gold          = Color(0xFFF7C948); // completed map nodes
  static const goldDark      = Color(0xFFD9A521);
  static const locked        = Color(0xFFE5E5E5); // locked map nodes
  static const lockedEdge    = Color(0xFFCFCFCF);
  static const lockedIcon    = Color(0xFFAFAFAF);

  // Backgrounds
  static const background    = Color(0xFFFAF3E8); // warm cream
  static const surface       = Color(0xFFFFFFFF);
  static const cardBg        = Color(0xFFFFFFFF);
  static const headerBg      = Color(0xFFE8720C); // orange header sections

  // Text
  static const textPrimary   = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF555555);
  static const textHint      = Color(0xFF999999);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Misc
  static const success       = Color(0xFF35A468);
  static const successBg     = Color(0xFFD7FFB8); // correct-answer sheet
  static const error         = Color(0xFFE2562C);
  static const errorBg       = Color(0xFFFFDFE0); // wrong-answer sheet
  static const navBarBg      = Color(0xFFFFFFFF);
  static const navActive     = Color(0xFFE8720C);
  static const navInactive   = Color(0xFFBBBBBB);
  static const cardBorder    = Color(0xFFE8E0D5);
  static const border        = Color(0xFFE5E5E5); // flat 2px card borders
  static const dotActive     = Color(0xFFE8720C);
  static const dotInactive   = Color(0xFFD9D9D9);
  static const inputBorder   = Color(0xFFE0D8CC);
  static const white         = Color(0xFFFFFFFF);
  static const black         = Color(0xFF000000);
  static const dutchWhite    = Color(0xFFF5E4C3); // Dutch White from palette

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
