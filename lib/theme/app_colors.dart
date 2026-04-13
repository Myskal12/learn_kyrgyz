import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool _isDark = false;

  static void setDark(bool value) {
    _isDark = value;
  }

  static bool get isDark => _isDark;

  static const _Palette _lightPalette = _Palette(
    background: Color(0xFFF9FBFF),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF162033),
    textSecondary: Color(0xFF54657C),
    secondary: Color(0xFFF2F7FF),
    mutedSurface: Color(0xFFF7FAFE),
    inputBackground: Color(0xFFFCFDFF),
    switchBackground: Color(0xFFD2DCE9),
    border: Color.fromRGBO(37, 99, 235, 0.1),
    outline: Color(0xFFDCE6F3),
    primary: Color(0xFF2563EB),
    primaryPressed: Color(0xFF1D4ED8),
    accent: Color(0xFFF59E0B),
    accentPressed: Color(0xFFD97706),
    error: Color(0xFFDC2626),
    success: Color(0xFF16A34A),
    link: Color(0xFF2563EB),
    warning: Color(0xFFF59E0B),
    cardShadow: Color.fromRGBO(76, 104, 148, 0.1),
    sidebar: Color(0xFFFFFFFF),
    sidebarAccent: Color(0xFFF8FBFF),
    sidebarBorder: Color.fromRGBO(37, 99, 235, 0.08),
    navInactive: Color(0xFF64748B),
  );

  static const _Palette _darkPalette = _Palette(
    background: Color(0xFF0B1220),
    surface: Color(0xFF131D31),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFA8B3C7),
    secondary: Color(0xFF1B2941),
    mutedSurface: Color(0xFF1E2D45),
    inputBackground: Color(0xFF16243A),
    switchBackground: Color(0xFF334155),
    border: Color.fromRGBO(148, 163, 184, 0.22),
    outline: Color(0xFF304155),
    primary: Color(0xFF60A5FA),
    primaryPressed: Color(0xFF3B82F6),
    accent: Color(0xFFFBBF24),
    accentPressed: Color(0xFFF59E0B),
    error: Color(0xFFF87171),
    success: Color(0xFF34D399),
    link: Color(0xFF93C5FD),
    warning: Color(0xFFFBBF24),
    cardShadow: Color.fromRGBO(0, 0, 0, 0.35),
    sidebar: Color(0xFF0F172A),
    sidebarAccent: Color(0xFF16243A),
    sidebarBorder: Color(0xFF22324A),
    navInactive: Color(0xFF94A3B8),
  );

  static _Palette get _activePalette => _isDark ? _darkPalette : _lightPalette;

  static Color get primary => _activePalette.primary;
  static Color get primaryPressed => _activePalette.primaryPressed;
  static Color get accent => _activePalette.accent;
  static Color get accentPressed => _activePalette.accentPressed;
  static Color get error => _activePalette.error;
  static Color get success => _activePalette.success;
  static Color get link => _activePalette.link;
  static Color get warning => _activePalette.warning;
  static Color get outline => _activePalette.outline;
  static Color get border => _activePalette.border;
  static Color get secondary => _activePalette.secondary;
  static Color get mutedSurface => _activePalette.mutedSurface;
  static Color get inputBackground => _activePalette.inputBackground;
  static Color get switchBackground => _activePalette.switchBackground;
  static Color get sidebar => _activePalette.sidebar;
  static Color get sidebarAccent => _activePalette.sidebarAccent;
  static Color get sidebarBorder => _activePalette.sidebarBorder;
  static Color get navInactive => _activePalette.navInactive;
  static Color get background => _activePalette.background;
  static Color get surface => _activePalette.surface;
  static Color get textDark => _activePalette.textPrimary;
  static Color get muted => _activePalette.textSecondary;
  static Color get cardShadow => _activePalette.cardShadow;
}

class _Palette {
  const _Palette({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.secondary,
    required this.mutedSurface,
    required this.inputBackground,
    required this.switchBackground,
    required this.border,
    required this.outline,
    required this.primary,
    required this.primaryPressed,
    required this.accent,
    required this.accentPressed,
    required this.error,
    required this.success,
    required this.link,
    required this.warning,
    required this.cardShadow,
    required this.sidebar,
    required this.sidebarAccent,
    required this.sidebarBorder,
    required this.navInactive,
  });

  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color secondary;
  final Color mutedSurface;
  final Color inputBackground;
  final Color switchBackground;
  final Color border;
  final Color outline;
  final Color primary;
  final Color primaryPressed;
  final Color accent;
  final Color accentPressed;
  final Color error;
  final Color success;
  final Color link;
  final Color warning;
  final Color cardShadow;
  final Color sidebar;
  final Color sidebarAccent;
  final Color sidebarBorder;
  final Color navInactive;
}
