import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../learning/repository/words_repository.dart';
import '../../../shared/widgets/adaptive_panel_grid.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../categories/providers/categories_provider.dart';
import '../../profile/providers/progress_provider.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressProvider).load();
      ref.read(categoriesProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final onboarding = ref.watch(onboardingProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final wordsRepo = ref.read(wordsRepositoryProvider);
    final achievements = _buildAchievements(progress);
    final unlockedCount = achievements.where((item) => item.unlocked).length;
    final hasProgress = progress.totalWordsReviewed > 0;
    final reviewCategory = _resolveReviewCategory(
      categoriesState.categories,
      progress,
      wordsRepo,
    );
    final focus = _ProgressFocus.fromState(
      progress: progress,
      dailyGoalMinutes: onboarding.dailyGoalMinutes,
      reviewCategory: reviewCategory,
    );

    return AppShell(
      title: 'Прогресс',
      subtitle: 'Реалдуу жыйынтык жана кийинки өсүү',
      activeTab: AppTab.progress,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text('Прогресс', style: AppTextStyles.heading.copyWith(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            'Кайсы жер бекеди, эмнени азыр жабуу керек жана кийинки чекит кайда экенин ушул жерден көрөсүз.',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          _HeroSummary(
            streakDays: progress.streakDays,
            totalWordsMastered: progress.totalWordsMastered,
            accuracyPercent: progress.accuracyPercent,
            reviewDueWordsCount: progress.reviewDueWordsCount,
          ),
          const SizedBox(height: 16),
          _ProgressSyncCard(progress: progress),
          const SizedBox(height: 20),
          if (!hasProgress)
            SizedBox(
              height: 280,
              child: AppEmptyState(
                title: 'Азырынча прогресс жок',
                message:
                    'Биринчи карточканы, сүйлөмдү же квизди өткөндөн кийин бул жерде review focus, milestone жана жетишкендиктер көрүнөт.',
                icon: Icons.insights_outlined,
                actionLabel: 'Биринчи сабакты ачуу',
                onAction: () => context.go('/categories'),
              ),
            )
          else ...[
            _FocusCard(focus: focus),
            const SizedBox(height: 16),
            _MilestoneCard(
              progress: progress,
              dailyGoalMinutes: onboarding.dailyGoalMinutes,
            ),
            const SizedBox(height: 16),
            _ReviewStatusCard(
              progress: progress,
              dailyGoalMinutes: onboarding.dailyGoalMinutes,
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(18),
              backgroundColor: AppColors.primary.withValues(alpha: 0.05),
              borderColor: AppColors.primary.withValues(alpha: 0.18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Чынчыл чек',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Биз азырынча жума-жума графикти сактабайбыз. Ошондуктан бул экран сизге реалдуу нерсени гана көрсөтөт: review due, алсыз сөздөр, milestone жана streak.',
                    style: AppTextStyles.muted,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Жетишкендиктер',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '$unlockedCount/${achievements.length}',
                style: AppTextStyles.muted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: achievements
                .map(
                  (achievement) => _AchievementTile(achievement: achievement),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  CategoryModel? _resolveReviewCategory(
    List<CategoryModel> categories,
    ProgressProvider progress,
    WordsRepository wordsRepo,
  ) {
    for (final category in categories) {
      final words = wordsRepo.getCachedWords(category.id);
      if (progress.reviewDueForCategory(words) > 0) {
        return category;
      }
    }
    return null;
  }

  List<_Achievement> _buildAchievements(ProgressProvider progress) {
    return [
      _Achievement(
        title: 'Алгачкы кадам',
        description: 'Биринчи сөздү ачтыңыз.',
        icon: Icons.play_circle_fill,
        colors: [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
        unlocked: progress.totalWordsReviewed >= 1,
      ),
      _Achievement(
        title: '5 сөз',
        description: '5 сөздү бекем үйрөндүңүз.',
        icon: Icons.gps_fixed,
        colors: [AppColors.primary, const Color(0xFFF7C15C)],
        unlocked: progress.totalWordsMastered >= 5,
      ),
      _Achievement(
        title: '15 сөз',
        description: '15 сөздү өздөштүрдүңүз.',
        icon: Icons.workspace_premium,
        colors: [AppColors.accent, const Color(0xFFE57373)],
        unlocked: progress.totalWordsMastered >= 15,
      ),
      _Achievement(
        title: 'Так жооптор',
        description: 'Тактык 80% же андан жогору.',
        icon: Icons.verified,
        colors: [AppColors.success, const Color(0xFF81C784)],
        unlocked:
            progress.totalReviewSessions > 0 && progress.accuracyPercent >= 80,
      ),
    ];
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({
    required this.streakDays,
    required this.totalWordsMastered,
    required this.accuracyPercent,
    required this.reviewDueWordsCount,
  });

  final int streakDays;
  final int totalWordsMastered;
  final int accuracyPercent;
  final int reviewDueWordsCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streakDays күн',
                    style: AppTextStyles.heading.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reviewDueWordsCount > 0
                        ? '$reviewDueWordsCount сөз кайра бекемдөөнү күтөт'
                        : 'Темп сакталууда',
                    style: AppTextStyles.muted.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Metric(label: 'Сөздөр', value: totalWordsMastered),
              _Metric(label: 'Тактык', value: accuracyPercent, suffix: '%'),
              _Metric(label: 'Review', value: reviewDueWordsCount),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.focus});

  final _ProgressFocus focus;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppChip(label: focus.badge, variant: focus.badgeVariant),
              if (focus.helperChip != null)
                AppChip(
                  label: focus.helperChip!,
                  variant: AppChipVariant.defaultChip,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(focus.title, style: AppTextStyles.title.copyWith(fontSize: 22)),
          const SizedBox(height: 8),
          Text(focus.message, style: AppTextStyles.body),
          const SizedBox(height: 14),
          AppButton(
            fullWidth: true,
            onPressed: () => context.go(focus.primaryRoute),
            child: Text(focus.primaryLabel),
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.progress,
    required this.dailyGoalMinutes,
  });

  final ProgressProvider progress;
  final int dailyGoalMinutes;

  @override
  Widget build(BuildContext context) {
    final target = progress.nextMilestoneTarget;
    final isMaxed = target == null;
    final label = progress.nextMilestoneLabel;
    final subtitle = isMaxed
        ? 'Сиз негизги roadmap чегинен өттүңүз. Эми ритмди сактап, review queue жана аралаш practice менен сапатты кармаңыз.'
        : 'Дагы ${progress.wordsToNextMilestone} сөз бекемдесеңиз, кийинки чекитке чыгасыз. Күндүк $dailyGoalMinutes мүнөт темп бул аралыкты тездик менен жабат.';

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Кийинки чекит',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.title.copyWith(fontSize: 22),
                ),
              ),
              AppChip(
                label: isMaxed
                    ? 'Roadmap ачык'
                    : '${progress.wordsToNextMilestone} калды',
                variant: isMaxed
                    ? AppChipVariant.success
                    : AppChipVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTextStyles.muted),
          const SizedBox(height: 14),
          _LinearProgress(value: progress.nextMilestoneProgress),
          const SizedBox(height: 8),
          Text(
            isMaxed
                ? 'Учурдагы чекиттер толук ачылган.'
                : '${progress.previousMilestoneTarget} -> $target сөз аралыгы',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _ReviewStatusCard extends StatelessWidget {
  const _ReviewStatusCard({
    required this.progress,
    required this.dailyGoalMinutes,
  });

  final ProgressProvider progress;
  final int dailyGoalMinutes;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Бүгүнкү окуу абалы',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          AdaptivePanelGrid(
            maxColumns: 3,
            minItemWidth: 110,
            spacing: 12,
            children: [
              _StatusTile(
                label: 'Review күтөт',
                value: progress.reviewDueWordsCount.toString(),
                color: AppColors.accent,
              ),
              _StatusTile(
                label: 'Алсыз сөздөр',
                value: progress.weakWordsCount.toString(),
                color: AppColors.primary,
              ),
              _StatusTile(
                label: 'Күндүк goal',
                value: '$dailyGoalMinutes мүн',
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            progress.hasReviewFocus
                ? 'Кийинки сапат өсүшү review queue жабылганда келет. Андан кийин гана жаңы режимге өтүү пайдалуураак.'
                : 'Review басымы азайды. Эми sentence builder же quiz менен активдүү колдонууга басым жасасаңыз болот.',
            style: AppTextStyles.muted,
          ),
        ],
      ),
    );
  }
}

class _ProgressSyncCard extends StatelessWidget {
  const _ProgressSyncCard({required this.progress});

  final ProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    switch (progress.syncState) {
      case ProgressSyncState.localOnly:
        return AppSyncBanner(
          title: progress.syncTitle,
          message: progress.syncSubtitle,
          icon: Icons.save_outlined,
          accentColor: AppColors.primary,
        );
      case ProgressSyncState.pending:
      case ProgressSyncState.syncing:
        return AppSyncBanner(
          title: progress.syncTitle,
          message: progress.syncSubtitle,
          icon: Icons.sync,
          accentColor: AppColors.accent,
        );
      case ProgressSyncState.synced:
        return AppSyncBanner(
          title: progress.syncTitle,
          message: progress.syncSubtitle,
          icon: Icons.cloud_done,
          accentColor: AppColors.success,
        );
      case ProgressSyncState.failed:
        return AppSyncBanner(
          title: progress.syncTitle,
          message: progress.syncSubtitle,
          icon: Icons.cloud_off,
          accentColor: AppColors.accent,
          actionLabel: 'Кайра синк кылуу',
          onAction: progress.canRetrySync ? progress.retrySync : null,
        );
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.suffix = ''});

  final String label;
  final int value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value$suffix',
          style: AppTextStyles.title.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.muted.copyWith(color: Colors.white70)),
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.title.copyWith(fontSize: 20, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.muted),
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

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement});

  final _Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: achievement.unlocked ? 1 : 0.5,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: achievement.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(achievement.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              style: AppTextStyles.muted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Achievement {
  const _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
    required this.unlocked,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;
  final bool unlocked;
}

class _ProgressFocus {
  const _ProgressFocus({
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.primaryRoute,
    required this.badge,
    required this.badgeVariant,
    this.helperChip,
  });

  final String title;
  final String message;
  final String primaryLabel;
  final String primaryRoute;
  final String badge;
  final AppChipVariant badgeVariant;
  final String? helperChip;

  factory _ProgressFocus.fromState({
    required ProgressProvider progress,
    required int dailyGoalMinutes,
    required CategoryModel? reviewCategory,
  }) {
    if (progress.reviewDueWordsCount > 0 && reviewCategory != null) {
      return _ProgressFocus(
        title: 'Алгач review кезегин жабыңыз',
        message:
            '${reviewCategory.title} ичинде мөөнөтү жеткен сөздөр бар. Кыска review цикли тактыкты тезирээк оңдойт, анан гана жаңы режимге өтүү пайдалуу.',
        primaryLabel: 'Кайталоону баштоо',
        primaryRoute: '/flashcards/${reviewCategory.id}?mode=review',
        badge: '${progress.reviewDueWordsCount} review күтөт',
        badgeVariant: AppChipVariant.accent,
        helperChip: 'Goal: $dailyGoalMinutes мүн',
      );
    }

    if (progress.weakWordsCount > 0) {
      return _ProgressFocus(
        title: 'Алсыз сөздөрдү бекемдеңиз',
        message:
            '${progress.weakWordsCount} сөз дагы эле туруксуз. Практика хабынан карточка же сүйлөм режимин ачсаңыз, recall тезирээк түзөлөт.',
        primaryLabel: 'Практикага өтүү',
        primaryRoute: '/practice',
        badge: 'Алсыз фокус',
        badgeVariant: AppChipVariant.primary,
        helperChip: '${progress.weakWordsCount} сөз',
      );
    }

    if (progress.totalWordsReviewed == 0) {
      return _ProgressFocus(
        title: 'Биринчи циклди баштаңыз',
        message:
            'Азырынча чогулган статистика жок. Алгач бир карточка же квиз циклин бүтүрсөңүз, бул жерде персоналдуу кеңеш пайда болот.',
        primaryLabel: 'Жол картасын ачуу',
        primaryRoute: '/categories',
        badge: 'Старт',
        badgeVariant: AppChipVariant.primary,
      );
    }

    return _ProgressFocus(
      title: 'Темпти сактап туруңуз',
      message:
          'Review басымы азайды. Эми $dailyGoalMinutes мүнөттүк темпти сактап, жаңы материалды quiz же sentence builder менен активдүү колдонууга өткөрүңүз.',
      primaryLabel: 'Практикага өтүү',
      primaryRoute: '/practice',
      badge: 'Таза темп',
      badgeVariant: AppChipVariant.success,
      helperChip: progress.nextMilestoneLabel,
    );
  }
}
