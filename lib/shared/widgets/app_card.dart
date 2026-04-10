import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';

enum AppCardRadius { md, lg, xl }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.gradient = false,
    this.radius = AppCardRadius.xl,
    this.padding,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool gradient;
  final AppCardRadius radius;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;

  double get _radiusValue {
    switch (radius) {
      case AppCardRadius.md:
        return 18;
      case AppCardRadius.lg:
        return 24;
      case AppCardRadius.xl:
        return 28;
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: gradient
          ? null
          : (backgroundColor ?? AppColors.surface.withValues(alpha: 0.9)),
      gradient: gradient
          ? LinearGradient(
              colors: [
                AppColors.primary,
                Color.lerp(AppColors.primary, AppColors.accent, 0.38)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      borderRadius: BorderRadius.circular(_radiusValue),
      border: Border.all(
        color: gradient
            ? Colors.white.withValues(alpha: 0.08)
            : (borderColor ?? AppColors.border),
      ),
      boxShadow: [
        BoxShadow(
          color: gradient
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.cardShadow,
          blurRadius: gradient ? 28 : 22,
          offset: Offset(0, gradient ? 14 : 10),
        ),
      ],
    );

    final content = ClipRRect(
      borderRadius: BorderRadius.circular(_radiusValue),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient
                      ? [
                          Colors.white.withValues(alpha: 0.14),
                          Colors.transparent,
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                ),
              ),
            ),
          ),
          Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ],
      ),
    );

    if (onTap == null) {
      return Container(decoration: decoration, child: content);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radiusValue),
        child: Ink(decoration: decoration, child: content),
      ),
    );
  }
}
