import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/app_text_styles.dart';

enum AppChipVariant { defaultChip, primary, accent, success }

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.variant = AppChipVariant.defaultChip,
    this.onTap,
    this.onRemove,
  });

  final String label;
  final AppChipVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color textColor;
    Color borderColor;

    switch (variant) {
      case AppChipVariant.primary:
        background = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
        borderColor = AppColors.primary.withValues(alpha: 0.2);
        break;
      case AppChipVariant.accent:
        background = AppColors.accent.withValues(alpha: 0.1);
        textColor = AppColors.accent;
        borderColor = AppColors.accent.withValues(alpha: 0.2);
        break;
      case AppChipVariant.success:
        background = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        borderColor = AppColors.success.withValues(alpha: 0.2);
        break;
      case AppChipVariant.defaultChip:
        background = AppColors.mutedSurface;
        textColor = AppColors.textDark;
        borderColor = AppColors.border;
        break;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (onRemove != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 12,
                color: textColor,
              ),
            ),
          ),
        ],
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: DefaultTextStyle(
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
