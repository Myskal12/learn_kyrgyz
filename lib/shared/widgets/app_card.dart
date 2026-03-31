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
      color: gradient ? null : (backgroundColor ?? AppColors.surface),
      gradient: gradient
          ? LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      borderRadius: BorderRadius.circular(_radiusValue),
      border:
          gradient ? null : Border.all(color: borderColor ?? AppColors.border),
      boxShadow: [
        BoxShadow(
          color: gradient
              ? const Color.fromRGBO(31, 31, 31, 0.16)
              : const Color.fromRGBO(31, 31, 31, 0.12),
          blurRadius: gradient ? 30 : 24,
          offset: Offset(0, gradient ? 16 : 12),
        ),
      ],
    );

    final content = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
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
