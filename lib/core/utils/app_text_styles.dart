import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle heading = GoogleFonts.manrope(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static TextStyle title = GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle body = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle muted = GoogleFonts.manrope(
    fontSize: 14,
    color: const Color(0xFF5F5F5F),
  );

  static TextStyle caption = GoogleFonts.manrope(
    fontSize: 13,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w600,
  );
}
