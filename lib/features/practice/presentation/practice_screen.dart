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
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../categories/providers/categories_provider.dart';
import '../../profile/providers/progress_provider.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
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
    final onboarding = ref.watch(onboardingProvider);
    final session = ref.watch(learningSessionProvider);
    final wordsRepo = ref.read(wordsRepositoryProvider);

    final categories = categoriesState.categories;
    final snapshots = categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final words = wordsRepo.getCachedWords(category.id);
      final mastered = progress.masteredWordsForCategory(words);
      final seen = progress.seenWordsForCategory(words);
      final reviewDue = progress.reviewDueForCategory(words);
      final completion = progress.completionForCategory(words);
      final unlockThreshold = index * 5;
      final locked = index > 0 && progress.totalWordsMastered < unlockThreshold;
      return _CategorySnapshot(
        category: category,
        mastered: mastered,
        seen: seen,
        reviewDue: reviewDue,
        completion: completion,
        locked: locked,
      );
    }).toList();

    final continueSnapshot = _resolveContinueSnapshot(
      snapshots,
      session.lastCategoryId,
    );
    final reviewSnapshot = snapshots
        .where((item) => !item.locked && item.reviewDue > 0)
        .fold<_CategorySnapshot?>(null, (best, item) {
          if (best == null) return item;
          if (item.reviewDue > best.reviewDue) return item;
          if (item.reviewDue == best.reviewDue &&
              item.completion < best.completion) {
            return item;
          }
          return best;
        });

    final plan = _PracticePlan.fromState(
      progress: progress,
      dailyGoalMinutes: onboarding.dailyGoalMinutes,
      continueSnapshot: continueSnapshot,
      reviewSnapshot: reviewSnapshot,
    );

    final totalReviewDue = snapshots.fold<int>(
      0,
      (sum, item) => sum + item.reviewDue,
    );

    Widget body;
    if (categoriesState.isLoading && categories.isEmpty) {
      body = const AppLoadingState(
        title: 'Практика даярдалып жатат',
        message: 'Категориялар жана көнүгүүлөр тандалып жатат.',
      );
    } else if (categoriesState.errorMessage != null && categories.isEmpty) {
      body = AppErrorState(
        message: categoriesState.errorMessage!,
        onAction: () => ref.read(categoriesProvider).load(force: true),
      );
    } else if (categories.isEmpty) {
      body = AppEmptyState(
        title: 'Практика үчүн темалар жок',
        message:
            'Категориялар табылмайынча көнүгүү сценарийлерин түзө албайбыз.',
        icon: Icons.extension_outlined,
        actionLabel: 'Кайра жүктөө',
        onAction: () => ref.read(categoriesProvider).load(force: true),
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text('Практика', style: AppTextStyles.heading.copyWith(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            'Бул жерде режимди өзүңүз тандайсыз: эстөө, текшерүү же колдонуу.',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          AppCard(
            gradient: true,
            padding: const EdgeInsets.all(24),
            child: Stack(
              children: [
                const Positioned(right: -10, top: -18, child: _HeroGlow()),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _GlassTag(
                          label: 'Максат: ${onboarding.dailyGoalMinutes} мүн',
                        ),
                        _GlassTag(label: 'Серия: ${progress.streakDays} күн'),
                        _GlassTag(label: 'Кайталоо: $totalReviewDue сөз'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      plan.title,
                      style: AppTextStyles.heading.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan.subtitle,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _HeroAction(
                      label: plan.primaryLabel,
                      onTap: () => context.push(plan.primaryRoute),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Режимдер', style: AppTextStyles.title),
          const SizedBox(height: 12),
          AdaptivePanelGrid(
            maxColumns: 2,
            minItemWidth: 156,
            spacing: 12,
            children: [
              _ModeCard(
                title: 'Карточкалар',
                subtitle: 'Сөздү эстеп, ачып, дароо бекемдеңиз.',
                icon: Icons.style,
                color: AppColors.primary,
                onTap: () =>
                    context.push('/flashcards/${continueSnapshot.category.id}'),
              ),
              _ModeCard(
                title: 'Сүйлөм түзүү',
                subtitle: 'Сөздөрдү колдонууга өткөрүү үчүн тартип түзүңүз.',
                icon: Icons.subject,
                color: AppColors.success,
                onTap: () => context.push(
                  '/sentence-builder/${continueSnapshot.category.id}',
                ),
              ),
              _ModeCard(
                title: 'Экспресс-квиз',
                subtitle: 'Кыска текшерүү менен темпти жана тактыкты көрүңүз.',
                icon: Icons.flash_on,
                color: AppColors.accent,
                onTap: () => context.push('/quick-quiz'),
              ),
              _ModeCard(
                title: 'Жол картасы',
                subtitle:
                    'Бардык темаларды, кулпуларды жана прогрессти көрүңүз.',
                icon: Icons.alt_route,
                color: const Color(0xFF1976D2),
                onTap: () => context.push('/categories'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Максаттуу машыгуу', style: AppTextStyles.title),
          const SizedBox(height: 12),
          _ScenarioCard(
            title: 'Улантуу',
            subtitle:
                '${continueSnapshot.category.title} боюнча кийинки циклди баштаңыз.',
            chips: [
              '${continueSnapshot.mastered}/${continueSnapshot.totalWords} сөз',
              continueSnapshot.reviewDue > 0
                  ? '${continueSnapshot.reviewDue} сөз кайталоодо'
                  : 'Жаңы циклге даяр',
            ],
            icon: Icons.play_circle_fill,
            colors: [AppColors.primary, const Color(0xFFF7C15C)],
            primaryLabel: 'Карточкаларды ачуу',
            onPrimary: () =>
                context.push('/flashcards/${continueSnapshot.category.id}'),
            secondaryLabel: 'Сүйлөм түзүү',
            onSecondary: () => context.push(
              '/sentence-builder/${continueSnapshot.category.id}',
            ),
          ),
          const SizedBox(height: 12),
          _ScenarioCard(
            title: reviewSnapshot != null
                ? 'Ката кеткен сөздөр'
                : 'Кыска текшерүү',
            subtitle: reviewSnapshot != null
                ? '${reviewSnapshot.category.title} ичинде жооп бербей калган сөздөрдү жабыңыз.'
                : 'Бүгүнкү темпти сактоо үчүн тез квиз же жаңы тема ачыңыз.',
            chips: reviewSnapshot != null
                ? [
                    '${reviewSnapshot.reviewDue} сөз жооп күтүп турат',
                    'Максат: сапатты бекемдөө',
                  ]
                : ['5 суроо', 'Ритмди сактоо'],
            icon: reviewSnapshot != null ? Icons.refresh : Icons.flash_on,
            colors: reviewSnapshot != null
                ? [AppColors.accent, const Color(0xFFE57373)]
                : [const Color(0xFF1976D2), const Color(0xFF64B5F6)],
            primaryLabel: reviewSnapshot != null
                ? 'Кайталоону баштоо'
                : 'Квизди баштоо',
            onPrimary: () => context.push(
              reviewSnapshot != null
                  ? '/flashcards/${reviewSnapshot.category.id}?mode=review'
                  : '/quick-quiz',
            ),
            secondaryLabel: reviewSnapshot != null
                ? 'Квиз менен текшерүү'
                : 'Жол картасына өтүү',
            onSecondary: () => context.push(
              reviewSnapshot != null
                  ? '/quiz/${reviewSnapshot.category.id}'
                  : '/categories',
            ),
          ),
          const SizedBox(height: 24),
          Text('Темалар боюнча фокус', style: AppTextStyles.title),
          const SizedBox(height: 12),
          ...snapshots
              .where((item) => !item.locked)
              .take(4)
              .map(
                (snapshot) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CategoryFocusCard(snapshot: snapshot),
                ),
              ),
        ],
      );
    }

    return AppShell(
      title: 'Практика',
      subtitle: 'Режимдер жана максаттуу drills',
      activeTab: AppTab.practice,
      child: body,
    );
  }

  _CategorySnapshot _resolveContinueSnapshot(
    List<_CategorySnapshot> snapshots,
    String? lastCategoryId,
  ) {
    if (snapshots.isEmpty) {
      return _CategorySnapshot.empty();
    }

    for (final item in snapshots) {
      if (item.category.id == lastCategoryId) return item;
    }

    for (final item in snapshots) {
      if (!item.locked) return item;
    }

    return snapshots.first;
  }
}

class _HeroGlow extends StatelessWidget {
  const _HeroGlow();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.14,
      child: Container(
        width: 150,
        height: 150,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
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

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: AppTextStyles.muted),
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.icon,
    required this.colors,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final String title;
  final String subtitle;
  final List<String> chips;
  final IconData icon;
  final List<Color> colors;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 6),
                    Text(subtitle, style: AppTextStyles.muted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (chip) =>
                      AppChip(label: chip, variant: AppChipVariant.defaultChip),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          AdaptivePanelGrid(
            maxColumns: 2,
            minItemWidth: 168,
            spacing: 10,
            children: [
              _MiniActionButton(
                label: primaryLabel,
                variant: AppChipVariant.primary,
                onTap: onPrimary,
              ),
              _MiniActionButton(
                label: secondaryLabel,
                variant: AppChipVariant.accent,
                onTap: onSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryFocusCard extends StatelessWidget {
  const _CategoryFocusCard({required this.snapshot});

  final _CategorySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/flashcards/${snapshot.category.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final badge = snapshot.reviewDue > 0
                  ? AppChip(
                      label: '${snapshot.reviewDue} кайталоо',
                      variant: AppChipVariant.accent,
                    )
                  : AppChip(
                      label: '${snapshot.mastered}/${snapshot.totalWords} сөз',
                      variant: AppChipVariant.success,
                    );

              if (constraints.maxWidth < 220) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.category.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    badge,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: Text(
                      snapshot.category.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  badge,
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Text(snapshot.category.description, style: AppTextStyles.muted),
          const SizedBox(height: 12),
          _LinearProgress(value: snapshot.completion),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(snapshot.completion * 100).round()}% өздөштүрүлдү',
                style: AppTextStyles.caption,
              ),
              Text(
                snapshot.reviewDue > 0
                    ? '${snapshot.reviewDue} сөз бекемдөөнү күтөт'
                    : 'Улантууга даяр',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.label,
    required this.variant,
    required this.onTap,
  });

  final String label;
  final AppChipVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: variant == AppChipVariant.primary
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: variant == AppChipVariant.primary
                ? AppColors.primary.withValues(alpha: 0.26)
                : AppColors.accent.withValues(alpha: 0.22),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: variant == AppChipVariant.primary
                ? AppColors.primary
                : AppColors.accent,
          ),
        ),
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

class _PracticePlan {
  const _PracticePlan({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.primaryRoute,
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final String primaryRoute;

  factory _PracticePlan.fromState({
    required ProgressProvider progress,
    required int dailyGoalMinutes,
    required _CategorySnapshot continueSnapshot,
    required _CategorySnapshot? reviewSnapshot,
  }) {
    if (progress.totalWordsMastered == 0) {
      return _PracticePlan(
        title: 'Биринчи режимди тандаңыз',
        subtitle:
            '${continueSnapshot.category.title} аркылуу негизги сөздөрдү ачып, машыгуу циклин түзүңүз.',
        primaryLabel: 'Биринчи карточкалар',
        primaryRoute: '/flashcards/${continueSnapshot.category.id}',
      );
    }

    if (!progress.hasActivityToday) {
      return _PracticePlan(
        title: 'Бүгүнкү машыгууну ачыңыз',
        subtitle:
            '$dailyGoalMinutes мүнөттүк максат үчүн азыр кайсы режим ылайыктуу экенин тандаңыз.',
        primaryLabel: 'Улантуу',
        primaryRoute: '/flashcards/${continueSnapshot.category.id}',
      );
    }

    if (reviewSnapshot != null) {
      return _PracticePlan(
        title: 'Алсыз жерлерди тазалаңыз',
        subtitle:
            '${reviewSnapshot.category.title} ичинде ${reviewSnapshot.reviewDue} сөз кошумча бекемдөөнү күтүп турат.',
        primaryLabel: 'Кайталоону баштоо',
        primaryRoute: '/flashcards/${reviewSnapshot.category.id}?mode=review',
      );
    }

    return _PracticePlan(
      title: 'Режимди өзүңүз тандаңыз',
      subtitle:
          'Эстөө, текшерүү жана колдонуу сценарийлерин өзүнчө башкаруу үчүн бул экранды хаб кылып бөлдүк.',
      primaryLabel: 'Сүйлөм түзүү',
      primaryRoute: '/sentence-builder/${continueSnapshot.category.id}',
    );
  }
}

class _CategorySnapshot {
  const _CategorySnapshot({
    required this.category,
    required this.mastered,
    required this.seen,
    required this.reviewDue,
    required this.completion,
    required this.locked,
  });

  _CategorySnapshot.empty()
    : category = CategoryModel(id: 'basic', title: 'Негизги', wordsCount: 0),
      mastered = 0,
      seen = 0,
      reviewDue = 0,
      completion = 0,
      locked = false;

  final CategoryModel category;
  final int mastered;
  final int seen;
  final int reviewDue;
  final double completion;
  final bool locked;

  int get totalWords => category.wordsCount;
}
