import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/app_text_styles.dart';

enum AppButtonVariant { primary, outlined, accent, success, danger }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.fullWidth = false,
    this.disabled = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;
  final bool disabled;

  EdgeInsets get _padding {
    switch (size) {
      case AppButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case AppButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double get _radius {
    switch (size) {
      case AppButtonSize.sm:
        return 14;
      case AppButtonSize.md:
        return 18;
      case AppButtonSize.lg:
        return 20;
    }
  }

  double get _fontSize {
    switch (size) {
      case AppButtonSize.sm:
        return 14;
      case AppButtonSize.md:
        return 16;
      case AppButtonSize.lg:
        return 18;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || onPressed == null;

    Color? backgroundColor;
    Color foregroundColor;
    Border? border;
    List<BoxShadow>? shadow;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = AppColors.textDark;
        shadow = [
          BoxShadow(
            color: const Color.fromRGBO(242, 177, 61, 0.32),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ];
        break;
      case AppButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.accent;
        border = Border.all(color: AppColors.accent, width: 2);
        break;
      case AppButtonVariant.accent:
        backgroundColor = AppColors.accent;
        foregroundColor = Colors.white;
        shadow = [
          BoxShadow(
            color: const Color.fromRGBO(198, 40, 40, 0.32),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ];
        break;
      case AppButtonVariant.success:
        backgroundColor = AppColors.success;
        foregroundColor = Colors.white;
        shadow = [
          BoxShadow(
            color: const Color.fromRGBO(56, 142, 60, 0.3),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ];
        break;
      case AppButtonVariant.danger:
        backgroundColor = AppColors.accent;
        foregroundColor = Colors.white;
        break;
    }

    final decoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(_radius),
      border: border,
      boxShadow: shadow,
    );

    final labelStyle = AppTextStyles.body.copyWith(
      fontSize: _fontSize,
      fontWeight: FontWeight.w600,
      color: foregroundColor,
    );

    return Opacity(
      opacity: isDisabled ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(_radius),
          child: Ink(
            decoration: decoration,
            child: Container(
              width: fullWidth ? double.infinity : null,
              padding: _padding,
              alignment: Alignment.center,
              child: IconTheme(
                data: IconThemeData(color: foregroundColor, size: _fontSize + 2),
                child: DefaultTextStyle(style: labelStyle, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
