import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData light = _buildTheme(isDark: false);
  static ThemeData dark = _buildTheme(isDark: true);

  static ThemeData _buildTheme({required bool isDark}) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final background =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor =
        isDark ? AppColors.textLightDark : AppColors.textDarkLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final outlineColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    final outlineVariantColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    final inputBackground =
        isDark ? AppColors.inputBackgroundDark : AppColors.inputBackgroundLight;

    final baseTextTheme = AppTypography.baseTextTheme();
    final textTheme = baseTextTheme.apply(
      bodyColor: textColor,
      displayColor: textColor,
    );
    final labelLarge = textTheme.labelLarge ?? const TextStyle(fontSize: 16);
    final labelMedium = textTheme.labelMedium ?? const TextStyle(fontSize: 14);

    Color tint(Color color, double amount) {
      return Color.lerp(color, Colors.white, amount)!;
    }

    Color shade(Color color, double amount) {
      return Color.lerp(color, Colors.black, amount)!;
    }

    final primary = isDark ? AppColors.yellowDark : AppColors.yellowLight;
    final secondary = isDark ? AppColors.redDark : AppColors.redLight;
    final onSecondary = isDark ? AppColors.textLightDark : Colors.white;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      secondary: secondary,
      brightness: brightness,
      surface: surface,
      outline: outlineColor,
      outlineVariant: outlineVariantColor,
      error: secondary,
    ).copyWith(
      primary: primary,
      secondary: secondary,
      onPrimary: AppColors.textDarkLight,
      onSecondary: onSecondary,
      onSurface: textColor,
    );

    final inputHover = tint(inputBackground, 0.04);
    final primaryHover = tint(colorScheme.primary, 0.06);
    final primaryPressed = shade(colorScheme.primary, 0.08);
    final textHover = tint(colorScheme.primary, 0.06);
    final textPressed = shade(colorScheme.primary, 0.06);

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: outlineColor),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size.fromHeight(54),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          textStyle: WidgetStatePropertyAll(
            labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return primaryPressed;
              }
              if (states.contains(WidgetState.hovered)) {
                return primaryHover;
              }
              return colorScheme.primary;
            },
          ),
          foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
          shadowColor: WidgetStatePropertyAll(
            colorScheme.primary.withValues(alpha: 0.28),
          ),
          elevation: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.hovered)) {
                return 4;
              }
              if (states.contains(WidgetState.pressed)) {
                return 2;
              }
              return 3;
            },
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size.fromHeight(52),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          textStyle: WidgetStatePropertyAll(
            labelLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return textPressed;
              }
              if (states.contains(WidgetState.hovered)) {
                return textHover;
              }
              return colorScheme.primary;
            },
          ),
          side: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.hovered)) {
                return BorderSide(color: colorScheme.outline, width: 2);
              }
              if (states.contains(WidgetState.pressed)) {
                return BorderSide(color: colorScheme.outline, width: 1.5);
              }
              return BorderSide(color: colorScheme.outline, width: 1.5);
            },
          ),
          overlayColor: WidgetStatePropertyAll(
            colorScheme.primary.withValues(alpha: 0.08),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size.fromHeight(44),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          textStyle: WidgetStatePropertyAll(
            labelMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return textPressed;
              }
              if (states.contains(WidgetState.hovered)) {
                return textHover;
              }
              return colorScheme.primary;
            },
          ),
          overlayColor: WidgetStatePropertyAll(
            colorScheme.primary.withValues(alpha: 0.08),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        hoverColor: inputHover,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outlineColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outlineColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? AppColors.mutedSurfaceDark : AppColors.mutedSurfaceLight,
        selectedColor: colorScheme.secondary.withValues(alpha: 0.16),
        labelStyle: labelMedium.copyWith(color: textColor),
        secondaryLabelStyle: labelMedium.copyWith(color: colorScheme.secondary),
        side: WidgetStateBorderSide.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(
                color: colorScheme.secondary.withValues(alpha: 0.4),
              );
            }
            return BorderSide(color: muted.withValues(alpha: 0.3));
          },
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: colorScheme.secondary,
        textColor: colorScheme.onSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        textStyle: labelMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.secondary,
        linearTrackColor: colorScheme.secondary.withValues(alpha: 0.16),
        circularTrackColor: colorScheme.secondary.withValues(alpha: 0.16),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        shadowColor: isDark ? Colors.black45 : Colors.black12,
        scrolledUnderElevation: 3,
      ),
      useMaterial3: true,
    );
  }
}
