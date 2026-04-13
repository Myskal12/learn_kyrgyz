import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/learning_direction_provider.dart';
import '../../core/localization/app_copy.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_text_styles.dart';
import '../../core/utils/learning_direction.dart';
import 'app_card.dart';

enum LearningDirectionControlTone { light, dark }

class LearningDirectionControl extends ConsumerWidget {
  const LearningDirectionControl({
    super.key,
    this.title,
    this.subtitle,
    this.tone = LearningDirectionControlTone.light,
  });

  final String? title;
  final String? subtitle;
  final LearningDirectionControlTone tone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final direction = ref.watch(learningDirectionProvider);
    final textColor = tone == LearningDirectionControlTone.dark
        ? Colors.white
        : AppColors.textDark;
    final mutedColor = tone == LearningDirectionControlTone.dark
        ? Colors.white.withValues(alpha: 0.72)
        : AppColors.muted;
    final backgroundColor = tone == LearningDirectionControlTone.dark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.surface;
    final borderColor = tone == LearningDirectionControlTone.dark
        ? Colors.white.withValues(alpha: 0.18)
        : AppColors.border;

    return AppCard(
      radius: AppCardRadius.lg,
      padding: const EdgeInsets.all(16),
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ??
                context.tr(
                  ky: 'Көнүгүү багыты',
                  en: 'Practice direction',
                  ru: 'Направление практики',
                ),
            style: AppTextStyles.body.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle ?? direction.helperTextOf(context),
            style: AppTextStyles.muted.copyWith(color: mutedColor),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final options = LearningDirection.values
                  .map(
                    (option) => _DirectionOption(
                      direction: option,
                      selected: option == direction,
                      tone: tone,
                      onTap: () => ref
                          .read(learningDirectionProvider.notifier)
                          .setDirection(option),
                    ),
                  )
                  .toList();

              if (constraints.maxWidth < 340) {
                return Column(
                  children: [
                    options[0],
                    const SizedBox(height: 10),
                    options[1],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: options[0]),
                  const SizedBox(width: 10),
                  Expanded(child: options[1]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DirectionOption extends StatelessWidget {
  const _DirectionOption({
    required this.direction,
    required this.selected,
    required this.tone,
    required this.onTap,
  });

  final LearningDirection direction;
  final bool selected;
  final LearningDirectionControlTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = tone == LearningDirectionControlTone.dark;
    final backgroundColor = isDark
        ? (selected ? Colors.white : Colors.white.withValues(alpha: 0.06))
        : (selected
              ? AppColors.primary.withValues(alpha: 0.16)
              : AppColors.mutedSurface.withValues(alpha: 0.55));
    final borderColor = isDark
        ? (selected ? Colors.white : Colors.white.withValues(alpha: 0.14))
        : (selected
              ? AppColors.primary.withValues(alpha: 0.26)
              : AppColors.border);
    final titleColor = isDark
        ? (selected ? AppColors.textDark : Colors.white)
        : AppColors.textDark;
    final subtitleColor = isDark
        ? (selected ? AppColors.muted : Colors.white.withValues(alpha: 0.72))
        : (selected ? AppColors.textDark : AppColors.muted);
    final iconColor = isDark
        ? (selected ? AppColors.primary : Colors.white.withValues(alpha: 0.72))
        : (selected ? AppColors.primary : AppColors.muted);

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key(
            direction == LearningDirection.enToKy
                ? 'direction-option-en-to-ky'
                : 'direction-option-ky-to-en',
          ),
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 20,
                  color: iconColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        direction.labelOf(context),
                        style: AppTextStyles.body.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(
                          ky: 'Суроо ${direction.promptLanguageLabelOf(context)}',
                          en: 'Prompt in ${direction.promptLanguageLabelOf(context)}',
                          ru: 'Вопрос на ${direction.promptLanguageLabelOf(context)}',
                        ),
                        style: AppTextStyles.caption.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
