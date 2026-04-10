import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool _isDark = false;

  static void setDark(bool value) {
    _isDark = value;
  }

  static const backgroundLight = Color(0xFFFBF5EE);
  static const backgroundDark = Color(0xFF11161D);
  static const surfaceLight = Color(0xFFFFF9F2);
  static const surfaceDark = Color(0xFF18212D);

  static const textDarkLight = Color(0xFF2A1C17);
  static const textLightDark = Color(0xFFF1F4F8);
  static const mutedLight = Color(0xFF7A5A4E);
  static const mutedDark = Color(0xFFA4B2C2);

  static const secondaryLight = Color(0xFFF4E6DA);
  static const secondaryDark = Color(0xFF223040);
  static const mutedSurfaceLight = Color(0xFFF1DFCF);
  static const mutedSurfaceDark = Color(0xFF223040);
  static const inputBackgroundLight = Color(0xFFFFF6ED);
  static const inputBackgroundDark = Color(0xFF243241);
  static const switchBackgroundLight = Color(0xFFE2D6C6);
  static const switchBackgroundDark = Color(0xFF314457);
  static const borderLight = Color.fromRGBO(122, 90, 78, 0.16);
  static const borderDark = Color.fromRGBO(241, 244, 248, 0.14);

  static const royalBlueLight = Color(0xFFB61E2E);
  static const royalBlueDark = Color(0xFFFF6B7A);
  static const royalBluePressedLight = Color(0xFF86111E);
  static const royalBluePressedDark = Color(0xFFD94B5B);
  static const sunsetOrangeLight = Color(0xFFF0B53A);
  static const sunsetOrangeDark = Color(0xFFFFCC67);
  static const sunsetOrangePressedLight = Color(0xFFD59819);
  static const sunsetOrangePressedDark = Color(0xFFE7B74D);
  static const errorLight = Color(0xFFC62828);
  static const errorDark = Color(0xFFE57373);

  static const successLight = Color(0xFF388E3C);
  static const successDark = Color(0xFF81C784);

  static const linkLight = Color(0xFF1976D2);
  static const linkDark = Color(0xFF7EC0FF);

  static const warningLight = Color(0xFFFFA000);
  static const warningDark = Color(0xFFFFC164);

  static const outlineLight = Color(0xFFE6D3C1);
  static const outlineDark = Color(0xFF314457);

  static const cardShadowLight = Color.fromRGBO(17, 24, 39, 0.08);
  static const cardShadowDark = Color.fromRGBO(0, 0, 0, 0.28);

  static const sidebarLight = Color(0xFFFDF9F3);
  static const sidebarDark = Color(0xFF16202B);
  static const sidebarAccentLight = Color(0xFFF6EFE4);
  static const sidebarAccentDark = Color(0xFF223040);
  static const sidebarBorderLight = Color.fromRGBO(31, 31, 31, 0.08);
  static const sidebarBorderDark = Color(0xFF2E3B4A);

  static Color get primary => _isDark ? royalBlueDark : royalBlueLight;
  static Color get primaryPressed =>
      _isDark ? royalBluePressedDark : royalBluePressedLight;
  static Color get accent => _isDark ? sunsetOrangeDark : sunsetOrangeLight;
  static Color get accentPressed =>
      _isDark ? sunsetOrangePressedDark : sunsetOrangePressedLight;
  static Color get error => _isDark ? errorDark : errorLight;
  static Color get success => _isDark ? successDark : successLight;
  static Color get link => _isDark ? linkDark : linkLight;
  static Color get warning => _isDark ? warningDark : warningLight;
  static Color get outline => _isDark ? outlineDark : outlineLight;
  static Color get border => _isDark ? borderDark : borderLight;
  static Color get secondary => _isDark ? secondaryDark : secondaryLight;
  static Color get mutedSurface =>
      _isDark ? mutedSurfaceDark : mutedSurfaceLight;
  static Color get inputBackground =>
      _isDark ? inputBackgroundDark : inputBackgroundLight;
  static Color get switchBackground =>
      _isDark ? switchBackgroundDark : switchBackgroundLight;
  static Color get sidebar => _isDark ? sidebarDark : sidebarLight;
  static Color get sidebarAccent =>
      _isDark ? sidebarAccentDark : sidebarAccentLight;
  static Color get sidebarBorder =>
      _isDark ? sidebarBorderDark : sidebarBorderLight;
  static Color get navInactive =>
      _isDark ? textLightDark.withValues(alpha: 0.58) : const Color(0xFF9CA3AF);

  static Color get background => _isDark ? backgroundDark : backgroundLight;
  static Color get surface => _isDark ? surfaceDark : surfaceLight;
  static Color get textDark => _isDark ? textLightDark : textDarkLight;
  static Color get muted => _isDark ? mutedDark : mutedLight;

  static Color get cardShadow => _isDark ? cardShadowDark : cardShadowLight;
}
