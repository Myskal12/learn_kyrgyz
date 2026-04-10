import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../categories/providers/categories_provider.dart';
import '../../profile/providers/progress_provider.dart';

class StudyPlanScreen extends ConsumerStatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  ConsumerState<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends ConsumerState<StudyPlanScreen> {
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
    final categoriesState = ref.watch(categoriesProvider);
    final progress = ref.watch(progressProvider);
    final onboarding = ref.watch(onboardingProvider);
    final wordsRepo = ref.read(wordsRepositoryProvider);

    final categories = categoriesState.categories;
    final tracks = categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final words = wordsRepo.getCachedWords(category.id);
      final mastered = progress.masteredWordsForCategory(words);
      final reviewDue = progress.reviewDueForCategory(words);
      final completion = progress.completionForCategory(words);
      final unlockAt = index * 5;
      final locked = index > 0 && progress.totalWordsMastered < unlockAt;
      final unlockRemaining = math.max(
        unlockAt - progress.totalWordsMastered,
        0,
      );

      return _StudyTrackSnapshot(
        category: category,
        order: index + 1,
        wordsTotal: words.length,
        mastered: mastered,
        reviewDue: reviewDue,
        completion: completion,
        locked: locked,
        unlockAt: unlockAt,
        unlockRemaining: unlockRemaining,
      );
    }).toList();

    final unlocked = tracks.where((track) => !track.locked).toList();
    final activeTrack = unlocked.firstWhere(
      (track) => track.reviewDue > 0,
      orElse: () => unlocked.firstWhere(
        (track) => track.completion < 1,
        orElse: () =>
            unlocked.isNotEmpty ? unlocked.first : _StudyTrackSnapshot.empty(),
      ),
    );

    final totalWords = tracks.fold<int>(
      0,
      (sum, track) => sum + track.wordsTotal,
    );
    final totalMastered = tracks.fold<int>(
      0,
      (sum, track) => sum + track.mastered,
    );
    final overallProgress = totalWords == 0
        ? 0.0
        : (totalMastered / totalWords).clamp(0, 1).toDouble();
    final weeklyMinutes = onboarding.dailyGoalMinutes * 7;

    Widget content;
    if (categoriesState.isLoading && categories.isEmpty) {
      content = const AppLoadingState(
        title: 'Жол картасы даярдалып жатат',
        message: 'Категориялар жана прогресс жүктөлүүдө.',
      );
    } else if (categoriesState.errorMessage != null && categories.isEmpty) {
      content = AppErrorState(
        message: categoriesState.errorMessage!,
        onAction: () => ref.read(categoriesProvider).load(force: true),
      );
    } else if (categories.isEmpty) {
      content = AppEmptyState(
        title: 'Жол картасы бош',
        message: 'Азырынча бир да категория табылган жок.',
        icon: Icons.alt_route,
        actionLabel: 'Кайра жүктөө',
        onAction: () => ref.read(categoriesProvider).load(force: true),
      );
    } else {
      content = ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text(
            'Жол картасы',
            style: AppTextStyles.heading.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            'Бул экран реалдуу категория, прогресс жана кайталоо кезеги менен эсептелет.',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          _PlanHero(
            activeTrack: activeTrack,
            overallProgress: overallProgress,
            totalMastered: totalMastered,
            totalWords: totalWords,
            weeklyMinutes: weeklyMinutes,
            streakDays: progress.streakDays,
            onOpenPrimary: () => context.push(activeTrack.primaryRoute),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Text('Категориялар', style: AppTextStyles.title)),
              AppChip(
                label:
                    '${tracks.where((track) => track.isCompleted).length}/${tracks.length} бүттү',
                variant: AppChipVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tracks.map(
            (track) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TrackCard(track: track),
            ),
          ),
        ],
      );
    }

    return AppShell(
      title: 'Жол картасы',
      subtitle: 'Категорияларга негизделген план',
      activeTab: AppTab.learn,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/profile',
      showBottomNav: false,
      child: content,
    );
  }
}

class _PlanHero extends StatelessWidget {
  const _PlanHero({
    required this.activeTrack,
    required this.overallProgress,
    required this.totalMastered,
    required this.totalWords,
    required this.weeklyMinutes,
    required this.streakDays,
    required this.onOpenPrimary,
  });

  final _StudyTrackSnapshot activeTrack;
  final double overallProgress;
  final int totalMastered;
  final int totalWords;
  final int weeklyMinutes;
  final int streakDays;
  final VoidCallback onOpenPrimary;

  @override
  Widget build(BuildContext context) {
    final subtitle = activeTrack.locked
        ? 'Кийинки блок ачылышы үчүн дагы ${activeTrack.unlockRemaining} сөз бекемдеңиз.'
        : activeTrack.reviewDue > 0
        ? '${activeTrack.reviewDue} сөз кайталоодо күтүп турат.'
        : activeTrack.isCompleted
        ? 'Бул блок жабылган, кийинкисине өтсөңүз болот.'
        : 'Бул категория азыр негизги фокустунуз.';

    return AppCard(
      gradient: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _GlassTag(label: '$weeklyMinutes мүн/жума'),
              _GlassTag(label: '$streakDays күн серия'),
              _GlassTag(label: '$totalMastered/$totalWords сөз'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            activeTrack.category.title,
            style: AppTextStyles.heading.copyWith(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 14),
          _ProgressBar(value: overallProgress, color: const Color(0xFFFFF1C1)),
          const SizedBox(height: 8),
          Text(
            'Жалпы прогресс: ${(overallProgress * 100).round()}%',
            style: AppTextStyles.caption.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 14),
          AppButton(
            fullWidth: true,
            variant: AppButtonVariant.accent,
            onPressed: activeTrack.locked ? null : onOpenPrimary,
            child: Text(activeTrack.primaryLabel),
          ),
        ],
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({required this.track});

  final _StudyTrackSnapshot track;

  @override
  Widget build(BuildContext context) {
    final statusVariant = track.locked
        ? AppChipVariant.defaultChip
        : track.reviewDue > 0
        ? AppChipVariant.accent
        : track.isCompleted
        ? AppChipVariant.success
        : AppChipVariant.primary;

    return Opacity(
      opacity: track.locked ? 0.6 : 1,
      child: AppCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${track.order.toString().padLeft(2, '0')}. ${track.category.title}',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppChip(label: track.statusLabel, variant: statusVariant),
              ],
            ),
            const SizedBox(height: 6),
            Text(track.category.description, style: AppTextStyles.muted),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppChip(
                  label: '${track.wordsTotal} сөз',
                  variant: AppChipVariant.defaultChip,
                ),
                AppChip(
                  label: '${track.mastered} бекемделди',
                  variant: AppChipVariant.defaultChip,
                ),
                AppChip(
                  label: track.reviewDue > 0
                      ? '${track.reviewDue} кайталоодо'
                      : (track.locked
                            ? 'Ачылууга: ${track.unlockRemaining}'
                            : 'Кайталоо жок'),
                  variant: track.reviewDue > 0
                      ? AppChipVariant.accent
                      : AppChipVariant.defaultChip,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Прогресс', style: AppTextStyles.muted),
                Text(
                  '${(track.completion * 100).round()}%',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _ProgressBar(value: track.completion, color: AppColors.primary),
            const SizedBox(height: 14),
            if (track.locked)
              Text(
                'Бул категория ачылышы үчүн дагы ${track.unlockRemaining} сөз бекемдөө керек.',
                style: AppTextStyles.muted,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      fullWidth: true,
                      size: AppButtonSize.sm,
                      onPressed: () => context.push(track.primaryRoute),
                      child: Text(track.primaryLabel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      fullWidth: true,
                      size: AppButtonSize.sm,
                      variant: AppButtonVariant.outlined,
                      onPressed: () => context.push(track.secondaryRoute),
                      child: const Text('Сүйлөм'),
                    ),
                  ),
                ],
              ),
            if (!track.locked) ...[
              const SizedBox(height: 10),
              AppButton(
                fullWidth: true,
                size: AppButtonSize.sm,
                variant: AppButtonVariant.outlined,
                onPressed: () => context.push(track.quizRoute),
                child: const Text('Кыска квиз'),
              ),
            ],
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
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0, 1),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
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
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StudyTrackSnapshot {
  _StudyTrackSnapshot({
    required this.category,
    required this.order,
    required this.wordsTotal,
    required this.mastered,
    required this.reviewDue,
    required this.completion,
    required this.locked,
    required this.unlockAt,
    required this.unlockRemaining,
  });

  factory _StudyTrackSnapshot.empty() {
    return _StudyTrackSnapshot(
      category: CategoryModel(
        id: 'basic',
        title: 'Категория',
        description: 'Маалымат жок',
        wordsCount: 0,
      ),
      order: 1,
      wordsTotal: 0,
      mastered: 0,
      reviewDue: 0,
      completion: 0,
      locked: false,
      unlockAt: 0,
      unlockRemaining: 0,
    );
  }

  final CategoryModel category;
  final int order;
  final int wordsTotal;
  final int mastered;
  final int reviewDue;
  final double completion;
  final bool locked;
  final int unlockAt;
  final int unlockRemaining;

  bool get isCompleted => wordsTotal > 0 && mastered >= wordsTotal;

  String get statusLabel {
    if (locked) return 'Кулпуланган';
    if (reviewDue > 0) return 'Кайталоо';
    if (isCompleted) return 'Бүттү';
    return 'Активдүү';
  }

  String get primaryLabel {
    if (reviewDue > 0) return 'Кайталоо';
    return 'Карточка';
  }

  String get primaryRoute {
    if (reviewDue > 0) {
      return '/flashcards/${category.id}?mode=review';
    }
    return '/flashcards/${category.id}';
  }

  String get secondaryRoute => '/sentence-builder/${category.id}';

  String get quizRoute => '/quiz/${category.id}';
}
