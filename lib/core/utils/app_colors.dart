import 'package:flutter/material.dart';

class AppColors {
  static bool _isDark = false;

  static void setDark(bool value) {
    _isDark = value;
  }

  static const primary = Color(0xFFC4161C);
  static const accent = Color(0xFFF4C430);
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFB71C1C);
  static const cardShadow = Color(0x1A000000);

  static Color get background =>
      _isDark ? const Color(0xFF151515) : const Color(0xFFFFF8E1);
  static Color get surface =>
      _isDark ? const Color(0xFF232323) : Colors.white;
  static Color get textDark =>
      _isDark ? const Color(0xFFF5F5F5) : const Color(0xFF1F1F1F);
  static Color get muted =>
      _isDark ? const Color(0xFFC2C2C2) : const Color(0xFF5F5F5F);
}
