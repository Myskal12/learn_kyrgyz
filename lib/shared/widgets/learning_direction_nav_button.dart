import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/learning_direction_provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_text_styles.dart';
import '../../core/utils/learning_direction.dart';
import 'app_top_nav.dart';

class LearningDirectionNavButton extends ConsumerWidget {
  const LearningDirectionNavButton({
    super.key,
    this.tone = AppTopNavTone.light,
  });

  final AppTopNavTone tone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final direction = ref.watch(learningDirectionProvider);
    final isDark = tone == AppTopNavTone.dark;
    final background = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : AppColors.surface.withValues(alpha: 0.96);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : AppColors.outline.withValues(alpha: 0.92);
    final iconColor = isDark ? Colors.white : AppColors.primary;
    final textColor = isDark ? Colors.white : AppColors.textDark;

    return Tooltip(
      message: direction.helperTextOf(context),
      child: Semantics(
        button: true,
        label: direction.semanticsLabelOf(context),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                ref.read(learningDirectionProvider.notifier).toggleDirection(),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz_rounded, size: 18, color: iconColor),
                  const SizedBox(width: 6),
                  Text(
                    direction.shortLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
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
