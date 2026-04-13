import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/providers/learning_session_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../../shared/widgets/learning_direction_nav_button.dart';
import '../../categories/providers/categories_provider.dart';
import '../../profile/providers/progress_provider.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  static const List<_QuickStyle> _styles = [
    _QuickStyle(Icons.people_rounded, Color(0xFF2F80ED), Color(0xFFEBF4FF)),
    _QuickStyle(Icons.park_rounded, Color(0xFF10B981), Color(0xFFD1FAE5)),
    _QuickStyle(Icons.favorite_rounded, Color(0xFFF2C94C), Color(0xFFFEF9E7)),
    _QuickStyle(Icons.home_rounded, Color(0xFF8B5CF6), Color(0xFFEDE9FE)),
    _QuickStyle(Icons.restaurant_rounded, Color(0xFFF59E0B), Color(0xFFFEF3C7)),
    _QuickStyle(Icons.wb_sunny_rounded, Color(0xFF06B6D4), Color(0xFFCFFAFE)),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider).load();
      ref.read(progressProvider).load();
      ref.read(learningSessionProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);
    final progress = ref.watch(progressProvider);
    final session = ref.watch(learningSessionProvider);
    final wordsRepo = ref.read(wordsRepositoryProvider);

    final categories = categoriesState.categories;
    final defaultCategory = _resolveCategory(
      categories,
      session.lastCategoryId,
    );
    final defaultCategoryId = defaultCategory.id;
    final totalReviewDue = categories.fold<int>(0, (sum, category) {
      final words = wordsRepo.getCachedWords(category.id);
      return sum + progress.reviewDueForCategory(words);
    });

    Widget body;
    if (categoriesState.isLoading && categories.isEmpty) {
      body = AppLoadingState(
        title: context.tr(
          ky: 'Практика жүктөлүүдө',
          en: 'Practice is loading',
          ru: 'Практика загружается',
        ),
        message: context.tr(
          ky: 'Категориялар жана прогресс абалы алынууда.',
          en: 'Fetching categories and progress snapshots.',
          ru: 'Загружаются категории и снимки прогресса.',
        ),
      );
    } else if (categoriesState.errorMessage != null && categories.isEmpty) {
      body = AppErrorState(
        message: categoriesState.errorMessage!,
        onAction: () => ref.read(categoriesProvider).load(force: true),
      );
    } else if (categories.isEmpty) {
      body = AppEmptyState(
        title: context.tr(
          ky: 'Категориялар табылган жок',
          en: 'No categories found',
          ru: 'Категории не найдены',
        ),
        message: context.tr(
          ky: 'Практиканы баштоо үчүн категорияларды кайра жүктөңүз.',
          en: 'Please reload categories to start practice.',
          ru: 'Перезагрузите категории, чтобы начать практику.',
        ),
        icon: Icons.extension_outlined,
        actionLabel: context.tr(
          ky: 'Кайра жүктөө',
          en: 'Reload',
          ru: 'Перезагрузить',
        ),
        onAction: () => ref.read(categoriesProvider).load(force: true),
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          Text(
            context.tr(ky: 'Практика', en: 'Practice', ru: 'Практика'),
            style: AppTextStyles.heading.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr(
              ky: 'Билимиңизди бекемдеп, өркүндөтүңүз',
              en: 'Review and improve your skills',
              ru: 'Закрепляйте и улучшайте навыки',
            ),
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                label: context.tr(
                  ky: '${categories.length} категория',
                  en: '${categories.length} categories',
                  ru: '${categories.length} категорий',
                ),
              ),
              _InfoPill(
                label: context.tr(
                  ky: '$totalReviewDue кайталоо кезекте',
                  en: '$totalReviewDue review due',
                  ru: '$totalReviewDue на повторении',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            context.tr(
              ky: 'Практика режимдери',
              en: 'Practice Modes',
              ru: 'Режимы практики',
            ),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            title: context.tr(
              ky: 'Карточкалар',
              en: 'Flashcards',
              ru: 'Карточки',
            ),
            subtitle: context.tr(
              ky: 'Сөздөрдү категория боюнча кайталаңыз',
              en: 'Review vocabulary by category',
              ru: 'Повторяйте словарь по категориям',
            ),
            icon: Icons.repeat_rounded,
            onTap: () => context.push('/flashcards/$defaultCategoryId'),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            title: context.tr(
              ky: 'Сүйлөм куруу',
              en: 'Sentence Builder',
              ru: 'Сборка предложений',
            ),
            subtitle: context.tr(
              ky: 'Сүйлөм которууну машыктырыңыз',
              en: 'Practice translating sentences',
              ru: 'Тренируйте перевод предложений',
            ),
            icon: Icons.translate_rounded,
            onTap: () => context.push('/sentence-builder/$defaultCategoryId'),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            title: context.tr(ky: 'Квиз', en: 'Quiz', ru: 'Квиз'),
            subtitle: context.tr(
              ky: 'Тез раунддарда эсиңизди текшериңиз',
              en: 'Test your recall in quick rounds',
              ru: 'Проверьте память в быстрых раундах',
            ),
            icon: Icons.flash_on_rounded,
            onTap: () => context.push('/quiz/$defaultCategoryId'),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr(
              ky: 'Ыкчам практика',
              en: 'Quick Practice',
              ru: 'Быстрая практика',
            ),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 700;
              final crossAxisCount = wide ? 3 : 2;
              final ratio = wide ? 1.36 : 1.12;

              return GridView.builder(
                itemCount: categories.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: ratio,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final style = _styles[index % _styles.length];
                  final words = wordsRepo.getCachedWords(category.id);
                  final count = words.isEmpty
                      ? category.wordsCount
                      : words.length;
                  final reviewDue = progress.reviewDueForCategory(words);

                  return _QuickPracticeCard(
                    category: category,
                    wordsCount: count,
                    reviewDue: reviewDue,
                    style: style,
                    onTap: () => context.push('/flashcards/${category.id}'),
                  );
                },
              );
            },
          ),
        ],
      );
    }

    return AppShell(
      title: context.tr(ky: 'Практика', en: 'Practice', ru: 'Практика'),
      subtitle: context.tr(
        ky: 'Билимиңизди бекемдеп, өркүндөтүңүз',
        en: 'Review and improve your skills',
        ru: 'Закрепляйте и улучшайте навыки',
      ),
      activeTab: AppTab.practice,
      topNavTrailing: const LearningDirectionNavButton(),
      topNavTrailingWidth: 108,
      child: body,
    );
  }

  CategoryModel _resolveCategory(List<CategoryModel> categories, String? id) {
    if (categories.isEmpty) {
      return CategoryModel(
        id: 'basic',
        title: 'Basics',
        description: 'Core starter category.',
        wordsCount: 0,
      );
    }

    for (final category in categories) {
      if (category.id == id) return category;
    }
    return categories.first;
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      showShadow: false,
      radius: AppCardRadius.md,
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.outline,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.secondary,
            ),
            child: Icon(icon, size: 24, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mutedSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _QuickPracticeCard extends StatelessWidget {
  const _QuickPracticeCard({
    required this.category,
    required this.wordsCount,
    required this.reviewDue,
    required this.style,
    required this.onTap,
  });

  final CategoryModel category;
  final int wordsCount;
  final int reviewDue;
  final _QuickStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      showShadow: false,
      radius: AppCardRadius.md,
      padding: const EdgeInsets.all(12),
      borderColor: AppColors.outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: style.background,
            ),
            child: Icon(style.icon, color: style.iconColor, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            category.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            reviewDue > 0
                ? context.tr(
                    ky: '$wordsCount сөз · $reviewDue кайталоо',
                    en: '$wordsCount words · $reviewDue review',
                    ru: '$wordsCount слов · $reviewDue повтор',
                  )
                : context.tr(
                    ky: '$wordsCount сөз',
                    en: '$wordsCount words',
                    ru: '$wordsCount слов',
                  ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _QuickStyle {
  const _QuickStyle(this.icon, this.iconColor, this.background);

  final IconData icon;
  final Color iconColor;
  final Color background;
}
