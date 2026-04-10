import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../core/providers/learning_session_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../shared/widgets/adaptive_panel_grid.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../categories/providers/categories_provider.dart';
import '../../profile/providers/progress_provider.dart';
import '../../profile/providers/user_profile_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    final onboarding = ref.watch(onboardingProvider);
    final progress = ref.watch(progressProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final profileState = ref.watch(userProfileProvider);
    final session = ref.watch(learningSessionProvider);
    final wordsRepo = ref.read(wordsRepositoryProvider);

    final categories = categoriesState.categories;
    final firstCategoryId = categories.isNotEmpty
        ? categories.first.id
        : 'basic';
    final lastCategoryId = session.lastCategoryId ?? firstCategoryId;
    final focusCategory = _resolveFocusCategory(categories, lastCategoryId);
    final focusWords = wordsRepo.getCachedWords(focusCategory.id);
    final focusMastered = progress.masteredWordsForCategory(focusWords);
    final focusReviewDue = progress.reviewDueForCategory(focusWords);
    final focusCompletion = focusWords.isEmpty
        ? 0.0
        : focusMastered / focusWords.length;
    final totalReviewDue = categories.fold<int>(0, (sum, category) {
      final words = wordsRepo.getCachedWords(category.id);
      return sum + progress.reviewDueForCategory(words);
    });
    CategoryModel? reviewCategory;
    for (final category in categories) {
      final words = wordsRepo.getCachedWords(category.id);
      if (progress.reviewDueForCategory(words) > 0) {
        reviewCategory = category;
        break;
      }
    }
    final displayName = profileState.isGuest
        ? 'Конок'
        : profileState.profile.nickname;

    final recommendedAction = _RecommendedAction.fromState(
      totalWordsMastered: progress.totalWordsMastered,
      hasActivityToday: progress.hasActivityToday,
      dailyGoalMinutes: onboarding.dailyGoalMinutes,
      categoryId: focusCategory.id,
      totalReviewDue: totalReviewDue,
      reviewCategoryId: reviewCategory?.id,
    );

    final todayPlan = _buildTodayPlan(
      recommendedAction: recommendedAction,
      focusCategory: focusCategory,
      totalReviewDue: totalReviewDue,
      reviewDueForFocus: focusReviewDue,
      hasProgress: progress.totalWordsMastered > 0,
    );

    return AppShell(
      title: 'Бүгүн',
      subtitle: 'Кийинки эң жакшы кадам',
      activeTab: AppTab.learn,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Кандайсың, $displayName!',
                      style: AppTextStyles.caption.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Бүгүн эмнеден баштайбыз?',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 30,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recommendedAction.supportingText,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StreakBadge(streakDays: progress.streakDays),
            ],
          ),
          const SizedBox(height: 20),
          AppCard(
            gradient: true,
            padding: const EdgeInsets.all(28),
            child: Stack(
              children: [
                const Positioned.fill(child: _HeroBackdrop()),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _GlassTag(
                          label: focusWords.isEmpty
                              ? 'Ушул жерден баштаңыз'
                              : '${focusWords.length} сөз',
                        ),
                        const Spacer(),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      focusCategory.title,
                      style: AppTextStyles.heading.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recommendedAction.subtitle,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _HeroProgressBar(value: focusCompletion),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$focusMastered/${focusWords.length} сөз өздөштү',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                        Text(
                          focusReviewDue > 0
                              ? '$focusReviewDue сөз кайталоодо'
                              : 'Улантууга даяр',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _HeroButton(
                      label: recommendedAction.primaryLabel,
                      onTap: () => context.push(recommendedAction.primaryRoute),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (profileState.isGuest)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppCard(
                padding: const EdgeInsets.all(18),
                backgroundColor: AppColors.primary.withValues(alpha: 0.06),
                borderColor: AppColors.primary.withValues(alpha: 0.18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _QuickIcon(
                      icon: Icons.cloud_done,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Прогрессти сактап калгыңыз келеби?',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Аккаунт ачсаңыз, жыйынтык аккаунтка байланат.',
                            style: AppTextStyles.muted,
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            size: AppButtonSize.sm,
                            onPressed: () => context.push('/signup'),
                            child: const Text('Аккаунт ачуу'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          AdaptivePanelGrid(
            maxColumns: 3,
            minItemWidth: 92,
            children: [
              _StatCard(
                icon: Icons.local_fire_department,
                iconColor: AppColors.accent,
                value: progress.streakDays.toString(),
                label: 'Серия',
              ),
              _StatCard(
                icon: Icons.menu_book,
                iconColor: AppColors.primary,
                value: progress.totalWordsMastered.toString(),
                label: 'Сөздөр',
              ),
              _StatCard(
                icon: Icons.gps_fixed,
                iconColor: AppColors.success,
                value: '${progress.accuracyPercent}%',
                label: 'Тактык',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Кийинкилер', style: AppTextStyles.title),
          const SizedBox(height: 12),
          ...todayPlan.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TodayPlanCard(item: item),
            ),
          ),
          const SizedBox(height: 12),
          Text('Азыркы фокус', style: AppTextStyles.title),
          const SizedBox(height: 12),
          _FocusLessonCard(
            category: focusCategory,
            masteredWords: focusMastered,
            totalWords: focusWords.length,
            reviewDue: focusReviewDue,
            hasProgress: progress.totalWordsMastered > 0,
          ),
        ],
      ),
    );
  }

  CategoryModel _resolveFocusCategory(
    List<CategoryModel> categories,
    String categoryId,
  ) {
    if (categories.isEmpty) {
      return CategoryModel(
        id: 'basic',
        title: 'Негизги сабак',
        description: 'Биринчи сөздөр жана негизги конструкциялар.',
        wordsCount: 0,
      );
    }

    for (final category in categories) {
      if (category.id == categoryId) return category;
    }
    return categories.first;
  }

  List<_TodayPlanItem> _buildTodayPlan({
    required _RecommendedAction recommendedAction,
    required CategoryModel focusCategory,
    required int totalReviewDue,
    required int reviewDueForFocus,
    required bool hasProgress,
  }) {
    final items = <_TodayPlanItem>[
      _TodayPlanItem(
        title: recommendedAction.primaryLabel,
        subtitle: recommendedAction.subtitle,
        helper: recommendedAction.supportingText,
        icon: Icons.play_circle_fill,
        color: AppColors.primary,
        emphasized: true,
      ),
    ];

    if (totalReviewDue > 0) {
      items.add(
        _TodayPlanItem(
          title: 'Кайталоону жабыңыз',
          subtitle: '$totalReviewDue сөз кайра бекемдөөнү күтүп турат.',
          helper: reviewDueForFocus > 0
              ? '${focusCategory.title} ичинде эң жакын кайталоо бар.'
              : 'Алсыз сөздөрдү жаап, тактыкты көтөрүңүз.',
          icon: Icons.refresh,
          color: AppColors.accent,
        ),
      );
    } else {
      items.add(
        _TodayPlanItem(
          title: hasProgress
              ? 'Кыска квиз менен текшерүү'
              : 'Сабак жолун көрүү',
          subtitle: hasProgress
              ? 'Ритмди сактоо үчүн 5 суроолук текшерүү жасаңыз.'
              : 'Алгач кайсы темадан баштай турганыңызды тактаңыз.',
          helper: hasProgress
              ? 'Карточкадан кийин квиз эң жакшы кийинки кадам болот.'
              : 'Жол картасы бардык ачылган сабактарды көрсөтөт.',
          icon: hasProgress ? Icons.flash_on : Icons.alt_route,
          color: hasProgress ? AppColors.success : AppColors.primary,
        ),
      );
    }

    items.add(
      _TodayPlanItem(
        title: 'Терең машыгууга өтүңүз',
        subtitle:
            'Карточка, сүйлөм түзүү жана квиз режимдерин өзүнчө тандаңыз.',
        helper:
            'Бул экран тандоо эмес, багыт берет; машыгуу режими өзүнчө бөлүмдө.',
        icon: Icons.dashboard_customize,
        color: AppColors.success,
      ),
    );

    return items;
  }
}

class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Opacity(
        opacity: 0.12,
        child: Container(
          width: 160,
          height: 160,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streakDays});

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.local_fire_department, color: AppColors.accent, size: 20),
          const SizedBox(height: 4),
          Text(
            '$streakDays',
            style: AppTextStyles.title.copyWith(
              fontSize: 20,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
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
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroProgressBar extends StatelessWidget {
  const _HeroProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0, 1),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8C00), Color(0xFFFFB74D)],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.title.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickIcon extends StatelessWidget {
  const _QuickIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _TodayPlanCard extends StatelessWidget {
  const _TodayPlanCard({required this.item});

  final _TodayPlanItem item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuickIcon(icon: item.icon, color: item.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item.emphasized) ...[
                  const SizedBox(height: 6),
                  const AppChip(
                    label: 'Негизги кадам',
                    variant: AppChipVariant.primary,
                  ),
                ],
                const SizedBox(height: 6),
                Text(item.subtitle, style: AppTextStyles.body),
                const SizedBox(height: 6),
                Text(item.helper, style: AppTextStyles.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusLessonCard extends StatelessWidget {
  const _FocusLessonCard({
    required this.category,
    required this.masteredWords,
    required this.totalWords,
    required this.reviewDue,
    required this.hasProgress,
  });

  final CategoryModel category;
  final int masteredWords;
  final int totalWords;
  final int reviewDue;
  final bool hasProgress;

  @override
  Widget build(BuildContext context) {
    final completion = totalWords == 0 ? 0.0 : masteredWords / totalWords;
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hasProgress ? 'Акыркы же негизги сабак' : 'Биринчи сабак',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppChip(
                label: reviewDue > 0 ? '$reviewDue кайталоо' : 'Улантууга даяр',
                variant: reviewDue > 0
                    ? AppChipVariant.accent
                    : AppChipVariant.success,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            category.title,
            style: AppTextStyles.title.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(category.description, style: AppTextStyles.muted),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$masteredWords/$totalWords сөз',
                style: AppTextStyles.caption,
              ),
              Text(
                '${(completion * 100).round()}% өздөштүрүлдү',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _LinearProgress(value: completion),
          const SizedBox(height: 16),
          Text(
            hasProgress
                ? 'Бул сабакка кайтуу үчүн жогорку негизги аракетти колдонуңуз.'
                : 'Бул теманы баштоо үчүн жогорку негизги аракетти колдонуңуз.',
            style: AppTextStyles.muted,
          ),
          const SizedBox(height: 12),
          AppButton(
            fullWidth: true,
            variant: AppButtonVariant.outlined,
            onPressed: () => context.push('/study-plan'),
            child: const Text('Жол картасын көрүү'),
          ),
        ],
      ),
    );
  }
}

class _LinearProgress extends StatelessWidget {
  const _LinearProgress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.mutedSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0, 1),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, const Color(0xFFF7C15C)],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayPlanItem {
  const _TodayPlanItem({
    required this.title,
    required this.subtitle,
    required this.helper,
    required this.icon,
    required this.color,
    this.emphasized = false,
  });

  final String title;
  final String subtitle;
  final String helper;
  final IconData icon;
  final Color color;
  final bool emphasized;
}

class _RecommendedAction {
  const _RecommendedAction({
    required this.title,
    required this.subtitle,
    required this.supportingText,
    required this.primaryLabel,
    required this.primaryRoute,
  });

  final String title;
  final String subtitle;
  final String supportingText;
  final String primaryLabel;
  final String primaryRoute;

  factory _RecommendedAction.fromState({
    required int totalWordsMastered,
    required bool hasActivityToday,
    required int dailyGoalMinutes,
    required String categoryId,
    required int totalReviewDue,
    required String? reviewCategoryId,
  }) {
    if (totalWordsMastered == 0) {
      return const _RecommendedAction(
        title: 'Бүгүн биринчи сабакты баштаңыз',
        subtitle: 'Категория тандап, биринчи циклди баштаңыз.',
        supportingText: 'Бүгүнкү эң жакшы старт ушул.',
        primaryLabel: 'Сабак тандаңыз',
        primaryRoute: '/categories',
      );
    }

    if (totalReviewDue > 0 && reviewCategoryId != null) {
      return _RecommendedAction(
        title: 'Адегенде кайталоону жабыңыз',
        subtitle: '$totalReviewDue сөз даяр турат.',
        supportingText: 'Алгач кайталоо жакшыраак.',
        primaryLabel: 'Кайталоону баштоо',
        primaryRoute: '/flashcards/$reviewCategoryId?mode=review',
      );
    }

    if (!hasActivityToday) {
      return _RecommendedAction(
        title: 'Бүгүнкү максатты ач',
        subtitle: '$dailyGoalMinutes мүнөт үчүн сабакты улантыңыз.',
        supportingText: 'Азыркы эң туура кадам ушул.',
        primaryLabel: 'Практиканы улантуу',
        primaryRoute: '/flashcards/$categoryId',
      );
    }

    return _RecommendedAction(
      title: 'Бүгүн жакшы темптесиз',
      subtitle: 'Кыска текшерүү же колдонуу режимине өтүңүз.',
      supportingText: 'Темпти кармап туруңуз.',
      primaryLabel: 'Экспресс-квиз',
      primaryRoute: '/quick-quiz',
    );
  }
}
