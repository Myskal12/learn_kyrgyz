import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../shared/widgets/adaptive_panel_grid.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../categories/providers/categories_provider.dart';
import '../../learning/repository/words_repository.dart';
import '../../profile/providers/leaderboard_provider.dart';
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
      ref.read(leaderboardProvider).load(limit: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final onboarding = ref.watch(onboardingProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final leaderboard = ref.watch(leaderboardProvider);
    final wordsRepo = ref.read(wordsRepositoryProvider);
    final achievements = _buildAchievements(progress);
    final unlockedCount = achievements.where((item) => item.unlocked).length;
    final hasProgress =
        progress.totalWordsReviewed > 0 ||
        progress.totalLearningSeconds > 0 ||
        progress.totalXp > 0;
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
    final topPlayers = leaderboard.entries.take(10).toList();
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
    final achievementAspectRatio = textScale > 1.15
        ? 0.74
        : textScale > 1.0
        ? 0.8
        : 0.86;

    return AppShell(
      title: 'Прогресс',
      subtitle: 'Өсүш ритми жана кийинки кадам',
      activeTab: AppTab.progress,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text('Прогресс', style: AppTextStyles.heading.copyWith(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            'Өсүш, атаандаштык жана кийинки кадам ушул жерде.',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          const _ProgressIntentStrip(),
          const SizedBox(height: 20),
          _HeroSummary(
            progress: progress,
            activeDaysThisWeek: progress.activeDaysThisWeek,
            dailyGoalMinutes: onboarding.dailyGoalMinutes,
            unlockedAchievements: unlockedCount,
            totalAchievements: achievements.length,
            hasProgress: hasProgress,
          ),
          const SizedBox(height: 14),
          _ProgressSyncCard(progress: progress),
          const SizedBox(height: 20),
          if (!hasProgress)
            SizedBox(
              height: 300,
              child: AppEmptyState(
                title: 'Стартка даярсыз',
                message:
                    'Биринчи машыгуудан кийин бул жер ритм, убакыт жана өсүү менен толот.',
                icon: Icons.insights_outlined,
                actionLabel: 'Биринчи сабакты ачуу',
                onAction: () => context.go('/categories'),
              ),
            )
          else ...[
            _GrowthSnapshotCard(
              progress: progress,
              activeDaysThisWeek: progress.activeDaysThisWeek,
            ),
            const SizedBox(height: 16),
            _JourneyTrackCard(progress: progress),
            const SizedBox(height: 16),
            _WeeklyRhythmCard(
              activity: progress.recentWeekActivity,
              streakDays: progress.streakDays,
              totalLearningSeconds: progress.totalLearningSeconds,
              activeDaysThisWeek: progress.activeDaysThisWeek,
            ),
            const SizedBox(height: 16),
            _DailyQuestCard(
              quests: progress.dailyQuests,
              completedCount: progress.completedDailyQuestsCount,
              todayXp: progress.todayXp,
            ),
            const SizedBox(height: 16),
            _FocusCard(focus: focus),
            const SizedBox(height: 16),
            AdaptivePanelGrid(
              maxColumns: 2,
              minItemWidth: 220,
              spacing: 12,
              children: [
                _MilestoneCard(
                  progress: progress,
                  dailyGoalMinutes: onboarding.dailyGoalMinutes,
                ),
                _ReviewStatusCard(
                  progress: progress,
                  dailyGoalMinutes: onboarding.dailyGoalMinutes,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionHeader(
              title: 'Лидерборд',
              subtitle:
                  'Бул жерде мыкты 10 оюнчу көрүнөт. Тереңирээк тизме үчүн 100 оюнчуга өтүңүз.',
            ),
            const SizedBox(height: 12),
            _LeaderboardPreviewCard(
              players: topPlayers,
              isLoading: leaderboard.isLoading && topPlayers.isEmpty,
              errorMessage: leaderboard.errorMessage,
              onRetry: () =>
                  ref.read(leaderboardProvider).load(force: true, limit: 10),
            ),
          ],
          const SizedBox(height: 20),
          _SectionHeader(
            title: 'Жетишкендиктер',
            subtitle:
                '$unlockedCount / ${achievements.length} белги ачылды. Ар бири окуудагы чекитти көрсөтөт.',
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: achievementAspectRatio,
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
        title: 'Серия оту',
        description: '7 күн катары менен ритм сакталды.',
        icon: Icons.local_fire_department_rounded,
        colors: [const Color(0xFFFF8A00), const Color(0xFFFFC15C)],
        unlocked: progress.streakDays >= 7,
      ),
      _Achievement(
        title: 'Убакыт топтоочу',
        description: '1 саат таза окуу убактысы чогулду.',
        icon: Icons.timelapse_rounded,
        colors: [AppColors.link, const Color(0xFF6EC6FF)],
        unlocked: progress.totalLearningSeconds >= 60 * 60,
      ),
      _Achievement(
        title: 'XP агымы',
        description: '250 XP топтодуңуз.',
        icon: Icons.flash_on_rounded,
        colors: [AppColors.warning, const Color(0xFFFFD180)],
        unlocked: progress.totalXp >= 250,
      ),
      _Achievement(
        title: 'Так жооптор',
        description: 'Тактык 80% же андан жогору.',
        icon: Icons.verified,
        colors: [AppColors.success, const Color(0xFF81C784)],
        unlocked:
            progress.totalReviewSessions > 0 && progress.accuracyPercent >= 80,
      ),
      _Achievement(
        title: 'Күн толук жабылды',
        description: 'Бүгүнкү үч квест тең аткарылды.',
        icon: Icons.flag_circle_rounded,
        colors: [AppColors.primary, AppColors.accent],
        unlocked: progress.completedDailyQuestsCount >= 3,
      ),
    ];
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({
    required this.progress,
    required this.activeDaysThisWeek,
    required this.dailyGoalMinutes,
    required this.unlockedAchievements,
    required this.totalAchievements,
    required this.hasProgress,
  });

  final ProgressProvider progress;
  final int activeDaysThisWeek;
  final int dailyGoalMinutes;
  final int unlockedAchievements;
  final int totalAchievements;
  final bool hasProgress;

  @override
  Widget build(BuildContext context) {
    final title = hasProgress
        ? 'Lv ${progress.journeyLevel} · ${progress.journeyRank}'
        : 'Стартка даяр';
    final subtitle = hasProgress
        ? _weeklyRhythmLabel(activeDaysThisWeek)
        : 'Алгач бир кыска циклди бүтүрүп, ритмди ачып алыңыз.';
    final milestoneText = hasProgress
        ? '${progress.xpToNextLevel} XP кийин кийинки деңгээл ачылат.'
        : 'Бүгүнкү чакан темп жаңы деңгээлдин башталышы болот.';

    return AppCard(
      gradient: true,
      padding: const EdgeInsets.all(24),
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
                      'Кыргызча өсүшүңүз',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
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
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StreakOrb(streakDays: progress.streakDays),
            ],
          ),
          const SizedBox(height: 18),
          _HeroProgressBar(
            value: hasProgress ? progress.nextMilestoneProgress : 0.04,
          ),
          const SizedBox(height: 8),
          Text(
            hasProgress
                ? milestoneText
                : 'Бүгүн $dailyGoalMinutes мүнөттүк темпти баштасаңыз жетиштүү.',
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroMetricPill(
                icon: Icons.auto_stories_rounded,
                value: progress.totalWordsMastered.toString(),
                label: 'Сөз',
              ),
              _HeroMetricPill(
                icon: Icons.flash_on_rounded,
                value: '${progress.totalXp}',
                label: 'XP',
              ),
              _HeroMetricPill(
                icon: Icons.schedule_rounded,
                value: _formatLearningTimeCompact(
                  progress.totalLearningSeconds,
                ),
                label: 'Убакыт',
              ),
              _HeroMetricPill(
                icon: Icons.calendar_today_rounded,
                value: '$activeDaysThisWeek/7',
                label: 'Апта',
              ),
              _HeroMetricPill(
                icon: Icons.flag_rounded,
                value: '${progress.completedDailyQuestsCount}/3',
                label: 'Квест',
              ),
              _HeroMetricPill(
                icon: Icons.workspace_premium_rounded,
                value: '$unlockedAchievements/$totalAchievements',
                label: 'Белги',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _weeklyRhythmLabel(int activeDays) {
    if (activeDays >= 6) {
      return 'Ритм абдан бекем. Темпти мыкты кармап жатасыз.';
    }
    if (activeDays >= 4) {
      return 'Апталык ритм жакшы. Дагы бир нече күн кошсоңуз күчөйт.';
    }
    if (activeDays >= 2) {
      return 'Ритм түзүлүп жатат. Серияны үзбөңүз.';
    }
    return 'Азыр темпти кайра чогултуу маанилүү.';
  }
}

class _GrowthSnapshotCard extends StatelessWidget {
  const _GrowthSnapshotCard({
    required this.progress,
    required this.activeDaysThisWeek,
  });

  final ProgressProvider progress;
  final int activeDaysThisWeek;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Өсүш картасы',
            subtitle:
                'Ушул жерден деңгээл, сөз кору, убакыт жана жооп сапаты чогуу көрүнөт.',
          ),
          const SizedBox(height: 16),
          AdaptivePanelGrid(
            maxColumns: 2,
            minItemWidth: 160,
            spacing: 12,
            children: [
              _InsightTile(
                icon: Icons.trending_up_rounded,
                accent: AppColors.primary,
                value: 'Lv ${progress.journeyLevel}',
                label: 'Саякат деңгээли',
                helper:
                    '${progress.journeyRank} · ${progress.xpToNextLevel} XP калды.',
              ),
              _InsightTile(
                icon: Icons.auto_stories_rounded,
                accent: AppColors.accent,
                value: '${progress.totalWordsMastered}',
                label: 'Үйрөнүлгөн сөз',
                helper: 'Ар бир бекем сөз жалпы деңгээлди көтөрөт.',
              ),
              _InsightTile(
                icon: Icons.flash_on_rounded,
                accent: AppColors.warning,
                value: '${progress.totalXp}',
                label: 'Жалпы XP',
                helper: 'Квест, убакыт жана жооптор бул метриканы толтурат.',
              ),
              _InsightTile(
                icon: Icons.schedule_rounded,
                accent: AppColors.success,
                value: _formatLearningTimeCompact(
                  progress.totalLearningSeconds,
                ),
                label: 'Жалпы убакыт',
                helper: 'Бул реалдуу практика менен топтолгон убакыт.',
              ),
              _InsightTile(
                icon: Icons.gpp_good_rounded,
                accent: AppColors.link,
                value: '${progress.accuracyPercent}%',
                label: 'Жооп сапаты',
                helper: '$activeDaysThisWeek күн активдүүлүк менен эсептелди.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JourneyTrackCard extends StatelessWidget {
  const _JourneyTrackCard({required this.progress});

  final ProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: AppColors.primary.withValues(alpha: 0.04),
      borderColor: AppColors.primary.withValues(alpha: 0.14),
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
                      'Саякат жолу',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'XP темп, квест жана практика аркылуу топтолот.',
                      style: AppTextStyles.muted,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppChip(
                label: progress.journeyRank,
                variant: AppChipVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AdaptivePanelGrid(
            maxColumns: 3,
            minItemWidth: 110,
            spacing: 10,
            children: [
              _StatusTile(
                label: 'Деңгээл',
                value: 'Lv ${progress.journeyLevel}',
                color: AppColors.primary,
              ),
              _StatusTile(
                label: 'Бүгүн XP',
                value: '+${progress.todayXp}',
                color: AppColors.warning,
              ),
              _StatusTile(
                label: 'Жалпы XP',
                value: '${progress.totalXp}',
                color: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LinearProgress(value: progress.journeyLevelProgress),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progress.xpIntoCurrentLevel} XP ушул деңгээлде',
                style: AppTextStyles.caption,
              ),
              Text(
                '${progress.xpToNextLevel} XP калды',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyRhythmCard extends StatelessWidget {
  const _WeeklyRhythmCard({
    required this.activity,
    required this.streakDays,
    required this.totalLearningSeconds,
    required this.activeDaysThisWeek,
  });

  final List<DailyActivitySnapshot> activity;
  final int streakDays;
  final int totalLearningSeconds;
  final int activeDaysThisWeek;

  @override
  Widget build(BuildContext context) {
    final maxWeight = activity.fold<double>(0, (current, day) {
      final weight = _activityWeight(day);
      return weight > current ? weight : current;
    });
    final weeklySeconds = activity.fold<int>(
      0,
      (sum, day) => sum + day.seconds,
    );
    final bestDay = activity.fold<DailyActivitySnapshot?>(null, (best, day) {
      if (best == null) return day;
      return _activityWeight(day) > _activityWeight(best) ? day : best;
    });

    return AppCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: AppColors.secondary.withValues(alpha: 0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Апталык ритм',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _rhythmNarrative(activeDaysThisWeek),
                      style: AppTextStyles.muted,
                    ),
                  ],
                ),
              ),
              AppChip(
                label: '$streakDays күн серия',
                variant: streakDays >= 7
                    ? AppChipVariant.success
                    : AppChipVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: activity.map((day) {
              final weight = _activityWeight(day);
              final factor = maxWeight <= 0
                  ? 0.0
                  : (weight / maxWeight).clamp(0.0, 1.0);
              return Expanded(
                child: _WeekDayBar(
                  label: _weekdayLabel(day.date.weekday),
                  active: day.isActive,
                  isToday: DateUtils.isSameDay(day.date, DateTime.now()),
                  factor: factor,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          AdaptivePanelGrid(
            maxColumns: 2,
            minItemWidth: 160,
            spacing: 12,
            children: [
              _StatusTile(
                label: 'Бул апта',
                value: _formatLearningTimeCompact(weeklySeconds),
                color: AppColors.primary,
              ),
              _StatusTile(
                label: 'Жалпы убакыт',
                value: _formatLearningTimeCompact(totalLearningSeconds),
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bestDay == null || !bestDay.isActive
                ? 'Азырынча активдүү күндөр аз. Бир кыска цикл да ритмди жандандырат.'
                : 'Эң күчтүү күн: ${_weekdayLabel(bestDay.date.weekday)}. Ушул темпти жумасына $activeDaysThisWeek күн кармап калуу маанилүү.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  double _activityWeight(DailyActivitySnapshot day) {
    if (!day.isActive) return 0;
    if (day.seconds > 0) return day.seconds.toDouble();
    return (day.interactions * 45).toDouble();
  }

  String _rhythmNarrative(int activeDays) {
    if (activeDays >= 6) {
      return 'Бул жумада практика дээрлик күн сайын жүрдү.';
    }
    if (activeDays >= 4) {
      return 'Темп жакшы. Серияны дагы бир аз узартсаңыз күчөйт.';
    }
    if (activeDays >= 2) {
      return 'Ритм жанданып жатат, бирок туруктуулук керек.';
    }
    return 'Азырынча ритм бош. Бүгүнкү кыска практика маанилүү болот.';
  }
}

class _WeekDayBar extends StatelessWidget {
  const _WeekDayBar({
    required this.label,
    required this.active,
    required this.isToday,
    required this.factor,
  });

  final String label;
  final bool active;
  final bool isToday;
  final double factor;

  @override
  Widget build(BuildContext context) {
    final heightFactor = active ? factor.clamp(0.24, 1.0) : 0.12;
    final activeGradient = LinearGradient(
      colors: [AppColors.primary, AppColors.accent],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    return Column(
      children: [
        SizedBox(
          height: 92,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: 22,
              height: 92 * heightFactor,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: active ? activeGradient : null,
                color: active ? null : AppColors.mutedSurface,
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isToday
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isToday ? AppColors.primary : AppColors.muted,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyQuestCard extends StatelessWidget {
  const _DailyQuestCard({
    required this.quests,
    required this.completedCount,
    required this.todayXp,
  });

  final List<DailyQuestSnapshot> quests;
  final int completedCount;
  final int todayXp;

  @override
  Widget build(BuildContext context) {
    DailyQuestSnapshot? nextQuest;
    for (final quest in quests) {
      if (!quest.claimed) {
        nextQuest = quest;
        break;
      }
    }
    final allDone = nextQuest == null;

    return AppCard(
      padding: const EdgeInsets.all(20),
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
                      'Бүгүнкү квесттер',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      allDone
                          ? 'Бүгүнкү үч квест тең жабылды. Темп мыкты.'
                          : 'Кыска тапшырмалар бүгүнкү ритмди кармап турат.',
                      style: AppTextStyles.muted,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppChip(
                label: '$completedCount/${quests.length} аткарылды',
                variant: allDone
                    ? AppChipVariant.success
                    : AppChipVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...quests.map((quest) => _QuestProgressRow(quest: quest)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Бүгүн +$todayXp XP топтолду.',
                  style: AppTextStyles.caption,
                ),
              ),
              if (!allDone)
                AppButton(
                  size: AppButtonSize.sm,
                  onPressed: () => context.go(nextQuest!.route),
                  child: const Text('Кийинки квест'),
                )
              else
                AppButton(
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.outlined,
                  onPressed: () => context.go('/achievements'),
                  child: const Text('Белгилерди көрүү'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestProgressRow extends StatelessWidget {
  const _QuestProgressRow({required this.quest});

  final DailyQuestSnapshot quest;

  @override
  Widget build(BuildContext context) {
    final accent = quest.claimed ? AppColors.success : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.14)),
        ),
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
                        quest.title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(quest.description, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AppChip(
                  label: quest.claimed
                      ? '+${quest.rewardXp} XP'
                      : quest.displayTarget,
                  variant: quest.claimed
                      ? AppChipVariant.success
                      : AppChipVariant.defaultChip,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${quest.displayCurrent} / ${quest.displayTarget}',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  quest.claimed ? 'Аткарылды' : '${quest.rewardXp} XP',
                  style: AppTextStyles.caption.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _LinearProgress(value: quest.claimed ? 1 : quest.progress),
          ],
        ),
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
      backgroundColor: AppColors.primary.withValues(alpha: 0.05),
      borderColor: AppColors.primary.withValues(alpha: 0.14),
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
    final percent = (progress.nextMilestoneProgress * 100).round();

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Кийинки бийиктик',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            isMaxed ? 'Roadmap ачык' : '${progress.wordsToNextMilestone}',
            style: AppTextStyles.heading.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 4),
          Text(
            isMaxed
                ? 'Учурдагы негизги чекиттер толук ачылган.'
                : 'сөз калды · максат ${progress.nextMilestoneLabel}',
            style: AppTextStyles.muted,
          ),
          const SizedBox(height: 14),
          _LinearProgress(value: progress.nextMilestoneProgress),
          const SizedBox(height: 10),
          Text(
            isMaxed
                ? 'Эми темпти, тактыкты жана серияны бекемдесеңиз болот.'
                : '$percent% өттү. Бүгүнкү $dailyGoalMinutes мүн темп бул чекитке жакындатат.',
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
            'Практика пульсу',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          AdaptivePanelGrid(
            maxColumns: 3,
            minItemWidth: 92,
            spacing: 10,
            children: [
              _StatusTile(
                label: 'Кайталоо',
                value: progress.reviewDueWordsCount.toString(),
                color: AppColors.accent,
              ),
              _StatusTile(
                label: 'Алсыз сөз',
                value: progress.weakWordsCount.toString(),
                color: AppColors.primary,
              ),
              _StatusTile(
                label: 'Күндүк максат',
                value: '$dailyGoalMinutes мүн',
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            progress.hasReviewFocus
                ? 'Азыркы эң чоң кайтарым кайталоодо жатат.'
                : 'Кайталоо таза. Жаңы цикл же квиз үчүн жакшы учур.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _ProgressIntentStrip extends StatelessWidget {
  const _ProgressIntentStrip();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        AppChip(label: 'Өсүш', variant: AppChipVariant.primary),
        AppChip(label: 'Top 10', variant: AppChipVariant.accent),
        AppChip(label: 'Кийинки кадам', variant: AppChipVariant.success),
      ],
    );
  }
}

class _LeaderboardPreviewCard extends StatelessWidget {
  const _LeaderboardPreviewCard({
    required this.players,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final List<UserProfileModel> players;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 220,
        child: AppLoadingState(
          title: 'Лидерборд жүктөлүүдө',
          message: 'Топ оюнчулар даярдалып жатат.',
        ),
      );
    }

    if (errorMessage != null && players.isEmpty) {
      return SizedBox(
        height: 220,
        child: AppErrorState(message: errorMessage!, onAction: onRetry),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < players.length; index++) ...[
            _LeaderboardPreviewRow(rank: index + 1, player: players[index]),
            if (index != players.length - 1)
              Divider(color: AppColors.border, height: 20),
          ],
          if (players.isEmpty)
            Text(
              'Азырынча оюнчулар көрүнбөй жатат.',
              style: AppTextStyles.muted,
            ),
          const SizedBox(height: 14),
          AppButton(
            fullWidth: true,
            variant: AppButtonVariant.outlined,
            onPressed: () => context.push('/leaderboard?limit=100'),
            child: const Text('Алгачкы 100 оюнчуну ачуу'),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardPreviewRow extends StatelessWidget {
  const _LeaderboardPreviewRow({required this.rank, required this.player});

  final int rank;
  final UserProfileModel player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: rank <= 3
                ? AppColors.accent.withValues(alpha: 0.12)
                : AppColors.mutedSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$rank',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 10),
        ProfileAvatar(avatar: player.avatar, size: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                '${player.journeyRank} · ${player.streakDays} күн',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${player.totalXp} XP',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text('${player.accuracy}%', style: AppTextStyles.caption),
          ],
        ),
      ],
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

class _StreakOrb extends StatelessWidget {
  const _StreakOrb({required this.streakDays});

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final highlight = streakDays >= 7;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.94, end: 1.0),
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.14),
          border: Border.all(
            color: Colors.white.withValues(alpha: highlight ? 0.42 : 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Image.asset(
                AppAssets.streakFlame,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$streakDays',
              style: AppTextStyles.title.copyWith(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetricPill extends StatelessWidget {
  const _HeroMetricPill({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.accent,
    required this.value,
    required this.label,
    required this.helper,
  });

  final IconData icon;
  final Color accent;
  final String value;
  final String label;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.title.copyWith(fontSize: 22, color: accent),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(helper, style: AppTextStyles.caption),
        ],
      ),
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

class _HeroProgressBar extends StatelessWidget {
  const _HeroProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value.clamp(0, 1)),
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return FractionallySizedBox(
              widthFactor: animatedValue,
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFFFE1A7)],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTextStyles.muted),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement});

  final _Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final locked = !achievement.unlocked;
    return AppCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: locked
          ? AppColors.surface.withValues(alpha: 0.78)
          : AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Icon(
                  achievement.icon,
                  color: Colors.white.withValues(alpha: locked ? 0.7 : 1),
                  size: 28,
                ),
              ),
              const Spacer(),
              Icon(
                locked ? Icons.lock_outline : Icons.check_circle,
                size: 18,
                color: locked ? AppColors.muted : AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            achievement.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              achievement.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.muted,
            ),
          ),
        ],
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
        title: 'Алгач кайталоону жабыңыз',
        message: '${reviewCategory.title} ичинде мөөнөтү жеткен сөздөр бар.',
        primaryLabel: 'Кайталоону баштоо',
        primaryRoute: '/flashcards/${reviewCategory.id}?mode=review',
        badge: '${progress.reviewDueWordsCount} кайталоо',
        badgeVariant: AppChipVariant.accent,
        helperChip: '$dailyGoalMinutes мүн максат',
      );
    }

    if (progress.weakWordsCount > 0) {
      return _ProgressFocus(
        title: 'Алсыз сөздөрдү бекемдеңиз',
        message: '${progress.weakWordsCount} сөз дагы эле туруксуз.',
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
        message: 'Алгач бир кыска машыгууну бүтүрүңүз.',
        primaryLabel: 'Жол картасын ачуу',
        primaryRoute: '/categories',
        badge: 'Старт',
        badgeVariant: AppChipVariant.primary,
      );
    }

    return _ProgressFocus(
      title: 'Темпти сактап туруңуз',
      message: '$dailyGoalMinutes мүнөттүк темпти сактаңыз.',
      primaryLabel: 'Практикага өтүү',
      primaryRoute: '/practice',
      badge: 'Таза темп',
      badgeVariant: AppChipVariant.success,
      helperChip: progress.nextMilestoneLabel,
    );
  }
}

String _formatLearningTimeCompact(int totalSeconds) {
  if (totalSeconds <= 0) return '0 мүн';
  final duration = Duration(seconds: totalSeconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) {
    return minutes > 0 ? '$hours с $minutes м' : '$hours с';
  }
  return '${duration.inMinutes.clamp(1, 999)} мүн';
}

String _weekdayLabel(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Дш';
    case DateTime.tuesday:
      return 'Шш';
    case DateTime.wednesday:
      return 'Шр';
    case DateTime.thursday:
      return 'Бш';
    case DateTime.friday:
      return 'Жм';
    case DateTime.saturday:
      return 'Иш';
    case DateTime.sunday:
    default:
      return 'Жк';
  }
}
