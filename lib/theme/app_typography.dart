import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  static TextTheme baseTextTheme() => GoogleFonts.manropeTextTheme();

  static TextTheme themedTextTheme() => baseTextTheme().apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      );
}

class AppTextStyles {
  static TextStyle get heading => GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textDark,
      );

  static TextStyle get title => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      );

  static TextStyle get body => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      );

  static TextStyle get muted => GoogleFonts.manrope(
        fontSize: 14,
        color: AppColors.muted,
      );

  static TextStyle get caption => GoogleFonts.manrope(
        fontSize: 13,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
      );
}
