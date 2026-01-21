import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../profile/providers/progress_provider.dart';
import '../providers/categories_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wordsRepo = ref.read(wordsRepositoryProvider);
    final categories = ref.watch(categoriesProvider);
    final progress = ref.watch(progressProvider);

    final content = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        AppChip(label: '1-деңгээл', variant: AppChipVariant.primary),
        const SizedBox(height: 12),
        Text(
          'Башталгыч сабактар',
          style: AppTextStyles.heading.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          'Кыргыз тилинин негиздерин үйрөнөсүз',
          style: AppTextStyles.body.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        if (categories.isLoading && categories.categories.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          ...categories.categories.asMap().entries.map((entry) {
            final lessonIndex = entry.key;
            final category = entry.value;
            final words = wordsRepo.getCachedWords(category.id);
            final mastery = progress.completionForCategory(words);
            final remaining = (words.length - (words.length * mastery))
                .clamp(0, words.length)
                .round();
            final unlockThreshold = lessonIndex * 5;
            final locked =
                lessonIndex > 0 && progress.totalWordsMastered < unlockThreshold;
            final completed = mastery >= 0.9;
            final active = !locked && mastery > 0 && mastery < 0.9;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _LessonCard(
                index: lessonIndex + 1,
                title: category.title,
                subtitle: category.description,
                locked: locked,
                completed: completed,
                active: active,
                mastery: mastery,
                remaining: remaining,
                onTap: locked
                    ? null
                    : () => context.push('/flashcards/${category.id}'),
              ),
            );
          }),
      ],
    );

    return AppShell(
      title: 'Сабактар',
      subtitle: 'Сабак тандаңыз',
      activeTab: AppTab.learn,
      child: content,
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.locked,
    required this.completed,
    required this.active,
    required this.mastery,
    required this.remaining,
    this.onTap,
  });

  final int index;
  final String title;
  final String subtitle;
  final bool locked;
  final bool completed;
  final bool active;
  final double mastery;
  final int remaining;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.5 : 1,
      child: AppCard(
        padding: const EdgeInsets.all(20),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: locked
                    ? AppColors.mutedSurface
                    : completed
                        ? AppColors.success
                        : active
                            ? AppColors.primary
                            : AppColors.mutedSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: completed
                  ? Icon(Icons.check, color: Colors.white)
                  : locked
                      ? Icon(Icons.lock, color: AppColors.muted)
                      : Text(
                          index.toString().padLeft(2, '0'),
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: active ? AppColors.textDark : AppColors.muted,
                          ),
                        ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(subtitle, style: AppTextStyles.muted),
                          ],
                        ),
                      ),
                      if (!locked && remaining > 0)
                        AppChip(
                          label: remaining.toString(),
                          variant: AppChipVariant.accent,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (completed)
                    Row(
                      children: [
                        Icon(Icons.check, size: 16, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text(
                          'Аяктады',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  if (active) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Прогресс', style: AppTextStyles.muted),
                        Text(
                          '${(mastery * 100).round()}%',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _ProgressBar(
                      value: mastery,
                      color: AppColors.primary,
                    ),
                  ],
                  if (!locked && !completed && !active)
                    Text(
                      'Даяр',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (locked)
                    Row(
                      children: [
                        Icon(Icons.lock, size: 16, color: AppColors.muted),
                        const SizedBox(width: 6),
                        Text(
                          'Мурунку сабакты аяктаңыз',
                          style: AppTextStyles.muted,
                        ),
                      ],
                    ),
                  if (remaining > 0 && !locked && !active && !completed)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '$remaining сөз калды',
                        style: AppTextStyles.muted,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * value.clamp(0, 1);
        return Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.mutedSurface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, const Color(0xFFF7C15C)],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        );
      },
    );
  }
}
