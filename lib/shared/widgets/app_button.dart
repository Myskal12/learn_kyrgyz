import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/app_text_styles.dart';

enum AppButtonVariant { primary, outlined, accent, success, danger }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatefulWidget {
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

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  EdgeInsets get _padding {
    switch (widget.size) {
      case AppButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 13);
      case AppButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 17);
    }
  }

  double get _radius {
    switch (widget.size) {
      case AppButtonSize.sm:
        return 16;
      case AppButtonSize.md:
        return 18;
      case AppButtonSize.lg:
        return 22;
    }
  }

  double get _fontSize {
    switch (widget.size) {
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
    final isDisabled = widget.disabled || widget.onPressed == null;

    Color backgroundColor;
    Color foregroundColor;
    Color depthColor;
    Border? border;
    bool showSheen = true;
    List<BoxShadow> outerShadow = [];

    switch (widget.variant) {
      case AppButtonVariant.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = Colors.white;
        depthColor = AppColors.primaryPressed;
        outerShadow = [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ];
        break;
      case AppButtonVariant.outlined:
        backgroundColor = Colors.white;
        foregroundColor = AppColors.primary;
        depthColor = AppColors.outline;
        border = Border.all(color: AppColors.outline, width: 2);
        outerShadow = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ];
        showSheen = false;
        break;
      case AppButtonVariant.accent:
        backgroundColor = AppColors.accent;
        foregroundColor = AppColors.textDark;
        depthColor = AppColors.accentPressed;
        outerShadow = [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ];
        break;
      case AppButtonVariant.success:
        backgroundColor = AppColors.success;
        foregroundColor = Colors.white;
        depthColor = const Color(0xFF2E7D32);
        outerShadow = [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ];
        break;
      case AppButtonVariant.danger:
        backgroundColor = AppColors.error;
        foregroundColor = Colors.white;
        depthColor = const Color(0xFF8E1B1B);
        outerShadow = [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ];
        break;
    }

    final labelStyle = AppTextStyles.body.copyWith(
      fontSize: _fontSize,
      fontWeight: FontWeight.w700,
      color: foregroundColor,
    );
    final pressOffset = !isDisabled && _pressed ? 4.0 : 0.0;
    final baseDepth = !isDisabled && _pressed ? 2.0 : 8.0;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, pressOffset, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: [
            BoxShadow(
              color: depthColor,
              blurRadius: 0,
              offset: Offset(0, baseDepth),
            ),
            ...outerShadow,
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : widget.onPressed,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            borderRadius: BorderRadius.circular(_radius),
            child: Ink(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(_radius),
                border: border,
              ),
              child: Stack(
                children: [
                  if (showSheen)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Container(
                        height: _padding.vertical + (_fontSize * 0.9),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(_radius),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.18),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  Container(
                    width: widget.fullWidth ? double.infinity : null,
                    padding: _padding,
                    alignment: Alignment.center,
                    child: IconTheme(
                      data: IconThemeData(
                        color: foregroundColor,
                        size: _fontSize + 2,
                      ),
                      child: DefaultTextStyle(
                        style: labelStyle,
                        child: widget.child,
                      ),
                    ),
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
