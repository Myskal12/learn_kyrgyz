import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool _isDark = false;

  static void setDark(bool value) {
    _isDark = value;
  }

  static const backgroundLight = Color(0xFFF7F4EF);
  static const backgroundDark = Color(0xFF121212);
  static const surfaceLight = Color(0xFFFDF9F3);
  static const surfaceDark = Color(0xFF1E1E1E);

  static const textDarkLight = Color(0xFF1F1F1F);
  static const textLightDark = Color(0xFFE0E0E0);
  static const mutedLight = Color(0xFF666666);
  static const mutedDark = Color(0xFFB0B0B0);

  static const secondaryLight = Color(0xFFF1E9DA);
  static const secondaryDark = Color(0xFF2A2A2A);
  static const mutedSurfaceLight = Color(0xFFEFE8DD);
  static const mutedSurfaceDark = Color(0xFF242424);
  static const inputBackgroundLight = Color(0xFFFFF1DE);
  static const inputBackgroundDark = Color(0xFF242424);
  static const switchBackgroundLight = Color(0xFFE2D6C6);
  static const switchBackgroundDark = Color(0xFF2B2B2B);
  static const borderLight = Color.fromRGBO(31, 31, 31, 0.08);
  static const borderDark = Color.fromRGBO(224, 224, 224, 0.12);

  static const yellowLight = Color(0xFFF2B13D);
  static const yellowDark = Color(0xFFF8C877);
  static const redLight = Color(0xFFC62828);
  static const redDark = Color(0xFFE57373);

  static const successLight = Color(0xFF388E3C);
  static const successDark = Color(0xFF81C784);

  static const linkLight = Color(0xFF1976D2);
  static const linkDark = Color(0xFF64B5F6);

  static const warningLight = Color(0xFFFFA000);
  static const warningDark = Color(0xFFFFB74D);

  static const outlineLight = Color(0xFFE4DDD4);
  static const outlineDark = Color(0xFF2E2E2E);

  static const cardShadowLight = Color(0x1F000000);
  static const cardShadowDark = Color(0x33000000);

  static const sidebarLight = Color(0xFFFDF9F3);
  static const sidebarDark = Color(0xFF1A1A1A);
  static const sidebarAccentLight = Color(0xFFF7EAD6);
  static const sidebarAccentDark = Color(0xFF2A2A2A);
  static const sidebarBorderLight = Color.fromRGBO(31, 31, 31, 0.08);
  static const sidebarBorderDark = Color(0xFF2E2E2E);

  static Color get primary => _isDark ? yellowDark : yellowLight;
  static Color get accent => _isDark ? redDark : redLight;
  static Color get error => _isDark ? redDark : redLight;
  static Color get success => _isDark ? successDark : successLight;
  static Color get link => _isDark ? linkDark : linkLight;
  static Color get warning => _isDark ? warningDark : warningLight;
  static Color get outline => _isDark ? outlineDark : outlineLight;
  static Color get border => _isDark ? borderDark : borderLight;
  static Color get secondary => _isDark ? secondaryDark : secondaryLight;
  static Color get mutedSurface => _isDark ? mutedSurfaceDark : mutedSurfaceLight;
  static Color get inputBackground =>
      _isDark ? inputBackgroundDark : inputBackgroundLight;
  static Color get switchBackground =>
      _isDark ? switchBackgroundDark : switchBackgroundLight;
  static Color get sidebar => _isDark ? sidebarDark : sidebarLight;
  static Color get sidebarAccent =>
      _isDark ? sidebarAccentDark : sidebarAccentLight;
  static Color get sidebarBorder =>
      _isDark ? sidebarBorderDark : sidebarBorderLight;

  static Color get background => _isDark ? backgroundDark : backgroundLight;
  static Color get surface => _isDark ? surfaceDark : surfaceLight;
  static Color get textDark => _isDark ? textLightDark : textDarkLight;
  static Color get muted => _isDark ? mutedDark : mutedLight;

  static Color get cardShadow => _isDark ? cardShadowDark : cardShadowLight;
}
