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
          Text(
            '$displayName, салам!',
            style: AppTextStyles.heading.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 6),
          Text(
            recommendedAction.supportingText,
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
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
                    _HeroChip(
                      goalMinutes: onboarding.dailyGoalMinutes,
                      streakDays: progress.streakDays,
                      reviewDue: totalReviewDue,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      recommendedAction.title,
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
                            'Катталып алсаңыз, жыйынтыктар Firebase менен синхрондолот.',
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
          Text('Бүгүнкү план', style: AppTextStyles.title),
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
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Экрандардын жаңы ролу',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Бул экран эми “эмне кылышым керек?” деген суроого жооп берет. Терең машыгуу үчүн Практикага, ал эми толук сабак тартиби үчүн Жол картасына өтөсүз.',
                  style: AppTextStyles.muted,
                ),
              ],
            ),
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

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.goalMinutes,
    required this.streakDays,
    required this.reviewDue,
  });

  final int goalMinutes;
  final int streakDays;
  final int reviewDue;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _GlassTag(label: 'Максат: $goalMinutes мүн'),
        _GlassTag(label: 'Серия: $streakDays күн'),
        _GlassTag(label: 'Кайталоо: $reviewDue'),
      ],
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
            onPressed: () => context.push('/categories'),
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
        subtitle:
            'Алгач категория тандап, биринчи flashcard циклин аягына чыгарыңыз.',
        supportingText:
            'Бул экран эми жөн гана модулдар жыйындысы эмес, бүгүнкү эң жакшы стартты көрсөтөт.',
        primaryLabel: 'Сабак тандаңыз',
        primaryRoute: '/categories',
      );
    }

    if (totalReviewDue > 0 && reviewCategoryId != null) {
      return _RecommendedAction(
        title: 'Адегенде кайталоону жабыңыз',
        subtitle:
            '$totalReviewDue сөз кайра бекемдөөнү күтүп турат. Кыска review цикли ритмди түздөйт.',
        supportingText:
            'Эстеп калган сөздөрдү эмес, мөөнөтү жеткен сөздөрдү биринчи жабуу retention үчүн пайдалуураак.',
        primaryLabel: 'Кайталоону баштоо',
        primaryRoute: '/flashcards/$reviewCategoryId?mode=review',
      );
    }

    if (!hasActivityToday) {
      return _RecommendedAction(
        title: 'Бүгүнкү максатты ач',
        subtitle:
            '$dailyGoalMinutes мүнөттүк практика үчүн акыркы сабакка кайтып, серияны сактаңыз.',
        supportingText:
            'Негизги аракетти жогоруга чыгардык: бүгүн эмнеден баштоо керек экени дароо көрүнөт.',
        primaryLabel: 'Практиканы улантуу',
        primaryRoute: '/flashcards/$categoryId',
      );
    }

    return _RecommendedAction(
      title: 'Бүгүн жакшы темптесиз',
      subtitle:
          'Натыйжаны бекемдөө үчүн кыска текшерүү же колдонуу режимине өтүңүз.',
      supportingText:
          'Home эми кийинки кадамды берет, ал эми режим тандоону Практикага өткөрөт.',
      primaryLabel: 'Экспресс-квиз',
      primaryRoute: '/quick-quiz',
    );
  }
}
