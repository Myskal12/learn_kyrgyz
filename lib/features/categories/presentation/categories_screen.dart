import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
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
      ref.read(progressProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wordsRepo = ref.read(wordsRepositoryProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final progress = ref.watch(progressProvider);
    final categories = categoriesState.categories;

    final roadmapItems = categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final words = wordsRepo.getCachedWords(category.id);
      final mastery = progress.completionForCategory(words);
      final remaining = (words.length - (words.length * mastery))
          .clamp(0, words.length)
          .round();
      final unlockThreshold = index * 5;
      final locked = index > 0 && progress.totalWordsMastered < unlockThreshold;
      final completed = mastery >= 0.9;
      final active = !locked && mastery > 0 && mastery < 0.9;
      return _RoadmapItem(
        category: category,
        index: index + 1,
        mastery: mastery,
        remaining: remaining,
        locked: locked,
        completed: completed,
        active: active,
        reviewDue: progress.reviewDueForCategory(words),
        wordsCount: words.length,
      );
    }).toList();

    final nextLesson = _resolveNextLesson(roadmapItems);
    final unlockedCount = roadmapItems.where((item) => !item.locked).length;
    final completedCount = roadmapItems.where((item) => item.completed).length;
    final totalReviewDue = roadmapItems.fold<int>(
      0,
      (sum, item) => sum + item.reviewDue,
    );

    final content = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        AppChip(
          label: context.tr(ky: '1-деңгээл', en: 'Level 1', ru: '1 уровень'),
          variant: AppChipVariant.primary,
        ),
        const SizedBox(height: 12),
        Text(
          context.tr(ky: 'Жол картасы', en: 'Roadmap', ru: 'Дорожная карта'),
          style: AppTextStyles.heading.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr(
            ky: 'Ачылган сабактарды жана кийинки кадамды көрүңүз.',
            en: 'See unlocked lessons and the next best step.',
            ru: 'Смотрите открытые уроки и следующий лучший шаг.',
          ),
          style: AppTextStyles.body.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        AppCard(
          gradient: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _GlassTag(
                          label: context.tr(
                            ky: '$unlockedCount ачылган',
                            en: '$unlockedCount unlocked',
                            ru: '$unlockedCount открыто',
                          ),
                        ),
                        _GlassTag(
                          label: context.tr(
                            ky: '$completedCount аяктаган',
                            en: '$completedCount complete',
                            ru: '$completedCount завершено',
                          ),
                        ),
                        _GlassTag(
                          label: context.tr(
                            ky: '$totalReviewDue кайталоо',
                            en: '$totalReviewDue review due',
                            ru: '$totalReviewDue на повторе',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      AppAssets.yurt,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                nextLesson != null
                    ? context.tr(
                        ky: 'Кийинки эң жакшы сабак',
                        en: 'Best next lesson',
                        ru: 'Лучший следующий урок',
                      )
                    : context.tr(
                        ky: 'Жол даяр',
                        en: 'Roadmap ready',
                        ru: 'Карта готова',
                      ),
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nextLesson?.category.title ??
                    context.tr(
                      ky: 'Бардык учурдагы сабактар бүткөн',
                      en: 'All current lessons are complete',
                      ru: 'Все текущие уроки завершены',
                    ),
                style: AppTextStyles.heading.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nextLesson != null
                    ? nextLesson.active
                          ? context.tr(
                              ky: 'Улантууга даяр.',
                              en: 'Ready to continue.',
                              ru: 'Готово к продолжению.',
                            )
                          : context.tr(
                              ky: 'Жаңы циклди ушул жерден баштаңыз.',
                              en: 'Start a new cycle from here.',
                              ru: 'Начните новый цикл отсюда.',
                            )
                    : context.tr(
                        ky: 'Эми Практикага өтүңүз.',
                        en: 'Now continue to Practice.',
                        ru: 'Теперь переходите к практике.',
                      ),
                style: AppTextStyles.body.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 18),
              AppButton(
                fullWidth: true,
                onPressed: nextLesson == null
                    ? () => context.push('/practice')
                    : () =>
                          context.push('/flashcards/${nextLesson.category.id}'),
                child: Text(
                  nextLesson == null
                      ? context.tr(
                          ky: 'Практикага өтүү',
                          en: 'Go to Practice',
                          ru: 'Перейти к практике',
                        )
                      : context.tr(
                          ky: 'Сабакты ачуу',
                          en: 'Open lesson',
                          ru: 'Открыть урок',
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (categoriesState.isLoading && categories.isEmpty)
          const SizedBox(
            height: 260,
            child: AppLoadingState(
              title: 'Сабактар жүктөлүүдө',
              message: 'Жол картасы жана статус белгилери даярдалып жатат.',
            ),
          )
        else if (categoriesState.errorMessage != null && categories.isEmpty)
          SizedBox(
            height: 280,
            child: AppErrorState(
              message: categoriesState.errorMessage!,
              onAction: () => ref.read(categoriesProvider).load(force: true),
            ),
          )
        else if (categories.isEmpty)
          SizedBox(
            height: 280,
            child: AppEmptyState(
              title: context.tr(
                ky: 'Сабактар табылган жок',
                en: 'No lessons found',
                ru: 'Уроки не найдены',
              ),
              message: context.tr(
                ky: 'Азырынча категория жок.',
                en: 'No categories available yet.',
                ru: 'Категории пока недоступны.',
              ),
              icon: Icons.menu_book_outlined,
              actionLabel: context.tr(
                ky: 'Кайра жүктөө',
                en: 'Reload',
                ru: 'Обновить',
              ),
              onAction: () => ref.read(categoriesProvider).load(force: true),
            ),
          )
        else ...[
          Text(
            context.tr(
              ky: 'Сабактардын ирети',
              en: 'Lesson order',
              ru: 'Порядок уроков',
            ),
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 12),
          ...roadmapItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final highlighted =
                nextLesson != null &&
                nextLesson.category.id == item.category.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _RoadmapEntry(
                item: item,
                highlighted: highlighted,
                showConnector: index != roadmapItems.length - 1,
                onTap: item.locked
                    ? null
                    : () => context.push('/flashcards/${item.category.id}'),
              ),
            );
          }),
        ],
      ],
    );

    return AppShell(
      title: context.tr(ky: 'Жол картасы', en: 'Roadmap', ru: 'Дорожная карта'),
      subtitle: context.tr(
        ky: 'Сабактардын ирети жана статусу',
        en: 'Lesson order and status',
        ru: 'Порядок уроков и статус',
      ),
      activeTab: AppTab.learn,
      child: content,
    );
  }

  _RoadmapItem? _resolveNextLesson(List<_RoadmapItem> items) {
    for (final item in items) {
      if (item.active) return item;
    }
    for (final item in items) {
      if (!item.locked && !item.completed) return item;
    }
    for (final item in items) {
      if (!item.locked) return item;
    }
    return null;
  }
}

class _RoadmapEntry extends StatelessWidget {
  const _RoadmapEntry({
    required this.item,
    required this.highlighted,
    required this.showConnector,
    this.onTap,
  });

  final _RoadmapItem item;
  final bool highlighted;
  final bool showConnector;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final markerColor = item.locked
        ? AppColors.muted
        : item.completed
        ? AppColors.success
        : item.active
        ? AppColors.primary
        : AppColors.accent;

    return Stack(
      children: [
        if (showConnector)
          Positioned(
            left: 8,
            top: 18,
            bottom: 0,
            child: Container(width: 2, color: AppColors.border),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: markerColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: highlighted ? Colors.white : markerColor,
                      width: highlighted ? 2 : 0,
                    ),
                    boxShadow: highlighted
                        ? [
                            BoxShadow(
                              color: markerColor.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _LessonCard(
                item: item,
                highlighted: highlighted,
                onTap: onTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.item,
    required this.highlighted,
    this.onTap,
  });

  final _RoadmapItem item;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = highlighted
        ? AppColors.primary.withValues(alpha: 0.07)
        : null;
    final borderColor = highlighted
        ? AppColors.primary.withValues(alpha: 0.28)
        : null;

    return Opacity(
      opacity: item.locked ? 0.56 : 1,
      child: AppCard(
        padding: const EdgeInsets.all(18),
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final badge = AppChip(
                  label: _statusLabel(),
                  variant: item.locked
                      ? AppChipVariant.defaultChip
                      : item.completed
                      ? AppChipVariant.success
                      : item.active
                      ? AppChipVariant.primary
                      : AppChipVariant.accent,
                );
                final titleBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Сабак ${item.index.toString().padLeft(2, '0')}',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.category.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );

                if (constraints.maxWidth < 220) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [titleBlock, const SizedBox(height: 8), badge],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleBlock),
                    const SizedBox(width: 8),
                    badge,
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Text(item.category.description, style: AppTextStyles.muted),
            const SizedBox(height: 12),
            Row(
              children: [
                AppChip(
                  label: '${item.wordsCount} сөз',
                  variant: AppChipVariant.defaultChip,
                ),
                if (!item.locked) ...[
                  const SizedBox(width: 8),
                  AppChip(
                    label: item.reviewDue > 0
                        ? '${item.reviewDue} кайталоо'
                        : '${item.remaining} калды',
                    variant: item.reviewDue > 0
                        ? AppChipVariant.accent
                        : AppChipVariant.defaultChip,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (!item.locked) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Прогресс', style: AppTextStyles.muted),
                  Text(
                    '${(item.mastery * 100).round()}%',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _ProgressBar(value: item.mastery, color: AppColors.primary),
              const SizedBox(height: 12),
            ] else ...[
              Text(
                'Бул сабак ачылышы үчүн мурунку бөлүктөрдү бүтүрүңүз.',
                style: AppTextStyles.muted,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Text(
                  _actionLabel(),
                  style: AppTextStyles.body.copyWith(
                    color: item.locked ? AppColors.muted : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  item.locked ? Icons.lock : Icons.chevron_right,
                  size: 18,
                  color: item.locked ? AppColors.muted : AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel() {
    if (item.locked) return 'Кулпуланган';
    if (item.completed) return 'Аяктады';
    if (item.active) return 'Улантуу';
    return 'Кийинки';
  }

  String _actionLabel() {
    if (item.locked) return 'Азырынча ачылган жок';
    if (item.active) return 'Улантуу';
    if (item.completed) return 'Кайра өтүү';
    return 'Баштоо';
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

class _GlassTag extends StatelessWidget {
  const _GlassTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: Colors.white),
      ),
    );
  }
}

class _RoadmapItem {
  const _RoadmapItem({
    required this.category,
    required this.index,
    required this.mastery,
    required this.remaining,
    required this.locked,
    required this.completed,
    required this.active,
    required this.reviewDue,
    required this.wordsCount,
  });

  final CategoryModel category;
  final int index;
  final double mastery;
  final int remaining;
  final bool locked;
  final bool completed;
  final bool active;
  final int reviewDue;
  final int wordsCount;
}
