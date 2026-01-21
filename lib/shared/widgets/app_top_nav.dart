import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/app_text_styles.dart';

enum AppTopNavTone { light, dark }

class AppTopNav extends StatelessWidget {
  const AppTopNav({
    super.key,
    required this.title,
    this.subtitle = 'Кыргызча / English',
    required this.onMenuTap,
    this.onActionTap,
    this.tone = AppTopNavTone.light,
  });

  final String title;
  final String subtitle;
  final VoidCallback onMenuTap;
  final VoidCallback? onActionTap;
  final AppTopNavTone tone;

  @override
  Widget build(BuildContext context) {
    final isDark = tone == AppTopNavTone.dark;
    final backgroundColor =
        isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.background;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : AppColors.border;
    final iconColor = isDark ? Colors.white : AppColors.textDark;
    final subtitleColor =
        isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.muted;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: isDark ? 0.12 : 0.85),
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _NavIconButton(
                    icon: Icons.menu,
                    onTap: onMenuTap,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.title.copyWith(
                            fontSize: 18,
                            color: iconColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: subtitleColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _NavIconButton(
                    icon: Icons.notifications_none,
                    onTap: onActionTap,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final background = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : AppColors.surface;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.border;
    final iconColor = isDark ? Colors.white : AppColors.textDark;

    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }
}
