import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../core/localization/app_copy.dart';
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
  late final PageController _pageController;
  int _activeSection = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressProvider).load();
      ref.read(categoriesProvider).load();
      ref.read(leaderboardProvider).load(limit: 10);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _setSection(int index) {
    if (_activeSection == index) return;
    setState(() => _activeSection = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final onboarding = ref.watch(onboardingProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final leaderboard = ref.watch(leaderboardProvider);
    final wordsRepo = ref.read(wordsRepositoryProvider);
    final achievements = _buildAchievements(progress, context);
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

    return AppShell(
      title: context.tr(ky: 'Прогресс', en: 'Progress', ru: 'Прогресс'),
      subtitle: context.tr(
        ky: 'Өсүш ритми жана кийинки кадам',
        en: 'Growth rhythm and next step',
        ru: 'Ритм роста и следующий шаг',
      ),
      activeTab: AppTab.progress,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(ky: 'Прогресс', en: 'Progress', ru: 'Прогресс'),
                  style: AppTextStyles.heading.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr(
                    ky: 'Өсүшүңүздү так бөлүмдөрдө көзөмөлдөңүз.',
                    en: 'Track your growth in focused sections with less noise.',
                    ru: 'Следите за ростом в понятных и сфокусированных разделах.',
                  ),
                  style: AppTextStyles.body.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 10),
                _ProgressIntentStrip(
                  activeIndex: _activeSection,
                  onSelect: _setSection,
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                if (_activeSection != index) {
                  setState(() => _activeSection = index);
                }
              },
              children: [
                _ProgressSectionPage(
                  children: [
                    _HeroSummary(
                      progress: progress,
                      activeDaysThisWeek: progress.activeDaysThisWeek,
                      dailyGoalMinutes: onboarding.dailyGoalMinutes,
                      unlockedAchievements: unlockedCount,
                      totalAchievements: achievements.length,
                      hasProgress: hasProgress,
                    ),
                    const SizedBox(height: 12),
                    if (!hasProgress)
                      SizedBox(
                        height: 280,
                        child: AppEmptyState(
                          title: context.tr(
                            ky: 'Стартка даяр',
                            en: 'Ready to start',
                            ru: 'Готово к старту',
                          ),
                          message: context.tr(
                            ky: 'Биринчи окуу циклинен кийин ритм жана чекиттер ушул жерде көрүнөт.',
                            en: 'Your rhythm and milestones will appear after your first learning cycle.',
                            ru: 'Ритм и ключевые этапы появятся после первого учебного цикла.',
                          ),
                          icon: Icons.insights_outlined,
                          actionLabel: context.tr(
                            ky: 'Практиканы баштоо',
                            en: 'Start practice',
                            ru: 'Начать практику',
                          ),
                          onAction: () => context.go('/practice'),
                        ),
                      )
                    else ...[
                      _FocusCard(focus: focus),
                      const SizedBox(height: 12),
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
                    ],
                    const SizedBox(height: 12),
                    _AchievementWallEntryCard(
                      unlockedCount: unlockedCount,
                      totalCount: achievements.length,
                    ),
                  ],
                ),
                _ProgressSectionPage(
                  children: [
                    if (!hasProgress)
                      SizedBox(
                        height: 280,
                        child: AppEmptyState(
                          title: context.tr(
                            ky: 'Ритм боюнча маалымат азырынча жок',
                            en: 'No rhythm data yet',
                            ru: 'Данных по ритму пока нет',
                          ),
                          message: context.tr(
                            ky: 'Бир сабакты бүтүргөндөн кийин күнүмдүк ритм аналитикасы ушул жерде көрүнөт.',
                            en: 'Complete one lesson and daily rhythm analytics will appear here.',
                            ru: 'Завершите один урок, и здесь появится ежедневная аналитика ритма.',
                          ),
                          icon: Icons.auto_graph,
                          actionLabel: context.tr(
                            ky: 'Практиканы баштоо',
                            en: 'Start practice',
                            ru: 'Начать практику',
                          ),
                          onAction: () => context.go('/practice'),
                        ),
                      )
                    else ...[
                      _WeeklyRhythmCard(
                        activity: progress.recentWeekActivity,
                        streakDays: progress.streakDays,
                        totalLearningSeconds: progress.totalLearningSeconds,
                        activeDaysThisWeek: progress.activeDaysThisWeek,
                      ),
                      const SizedBox(height: 12),
                      _DailyQuestCard(
                        quests: progress.dailyQuests,
                        completedCount: progress.completedDailyQuestsCount,
                        todayXp: progress.todayXp,
                      ),
                      const SizedBox(height: 12),
                      _GrowthSnapshotCard(
                        progress: progress,
                        activeDaysThisWeek: progress.activeDaysThisWeek,
                      ),
                    ],
                  ],
                ),
                _ProgressSectionPage(
                  children: [
                    _SectionHeader(
                      title: context.tr(
                        ky: 'Лидерборд',
                        en: 'Leaderboard',
                        ru: 'Лидерборд',
                      ),
                      subtitle: context.tr(
                        ky: 'Өсүш аналитикасынан өзүнчө эң мыкты оюнчулар ушул жерде көрсөтүлөт.',
                        en: 'Top performers are isolated here to avoid mixing ranking with growth analytics.',
                        ru: 'Лучшие участники вынесены отдельно, чтобы не смешивать рейтинг с аналитикой роста.',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _LeaderboardPreviewCard(
                      players: topPlayers,
                      isLoading: leaderboard.isLoading && topPlayers.isEmpty,
                      errorMessage: leaderboard.errorMessage,
                      onRetry: () => ref
                          .read(leaderboardProvider)
                          .load(force: true, limit: 10),
                    ),
                  ],
                ),
              ],
            ),
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

  List<_Achievement> _buildAchievements(
    ProgressProvider progress,
    BuildContext context,
  ) {
    return [
      _Achievement(
        title: context.tr(
          ky: 'Алгачкы кадам',
          en: 'First step',
          ru: 'Первый шаг',
        ),
        description: context.tr(
          ky: 'Биринчи сөздү ачтыңыз.',
          en: 'You unlocked your first word.',
          ru: 'Вы открыли первое слово.',
        ),
        icon: Icons.play_circle_fill,
        colors: [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
        unlocked: progress.totalWordsReviewed >= 1,
      ),
      _Achievement(
        title: context.tr(ky: '5 сөз', en: '5 words', ru: '5 слов'),
        description: context.tr(
          ky: '5 сөздү бекем үйрөндүңүз.',
          en: 'You firmly learned 5 words.',
          ru: 'Вы уверенно выучили 5 слов.',
        ),
        icon: Icons.gps_fixed,
        colors: [AppColors.primary, const Color(0xFFF7C15C)],
        unlocked: progress.totalWordsMastered >= 5,
      ),
      _Achievement(
        title: context.tr(ky: '15 сөз', en: '15 words', ru: '15 слов'),
        description: context.tr(
          ky: '15 сөздү өздөштүрдүңүз.',
          en: 'You mastered 15 words.',
          ru: 'Вы освоили 15 слов.',
        ),
        icon: Icons.workspace_premium,
        colors: [AppColors.accent, const Color(0xFFE57373)],
        unlocked: progress.totalWordsMastered >= 15,
      ),
      _Achievement(
        title: context.tr(
          ky: 'Серия оту',
          en: 'Streak fire',
          ru: 'Огонь серии',
        ),
        description: context.tr(
          ky: '7 күн катары менен ритм сакталды.',
          en: 'You kept the rhythm for 7 days in a row.',
          ru: 'Вы держали ритм 7 дней подряд.',
        ),
        icon: Icons.local_fire_department_rounded,
        colors: [const Color(0xFFFF8A00), const Color(0xFFFFC15C)],
        unlocked: progress.streakDays >= 7,
      ),
      _Achievement(
        title: context.tr(
          ky: 'Убакыт топтоочу',
          en: 'Time collector',
          ru: 'Коллекционер времени',
        ),
        description: context.tr(
          ky: '1 саат таза окуу убактысы чогулду.',
          en: 'You collected 1 hour of pure learning time.',
          ru: 'Вы собрали 1 час чистого учебного времени.',
        ),
        icon: Icons.timelapse_rounded,
        colors: [AppColors.link, const Color(0xFF6EC6FF)],
        unlocked: progress.totalLearningSeconds >= 60 * 60,
      ),
      _Achievement(
        title: context.tr(ky: 'XP агымы', en: 'XP flow', ru: 'Поток XP'),
        description: context.tr(
          ky: '250 XP топтодуңуз.',
          en: 'You earned 250 XP.',
          ru: 'Вы набрали 250 XP.',
        ),
        icon: Icons.flash_on_rounded,
        colors: [AppColors.warning, const Color(0xFFFFD180)],
        unlocked: progress.totalXp >= 250,
      ),
      _Achievement(
        title: context.tr(
          ky: 'Так жооптор',
          en: 'Accurate answers',
          ru: 'Точные ответы',
        ),
        description: context.tr(
          ky: 'Тактык 80% же андан жогору.',
          en: 'Accuracy is 80% or higher.',
          ru: 'Точность 80% или выше.',
        ),
        icon: Icons.verified,
        colors: [AppColors.success, const Color(0xFF81C784)],
        unlocked:
            progress.totalReviewSessions > 0 && progress.accuracyPercent >= 80,
      ),
      _Achievement(
        title: context.tr(
          ky: 'Күн толук жабылды',
          en: 'Day completed',
          ru: 'День закрыт',
        ),
        description: context.tr(
          ky: 'Бүгүнкү үч квест тең аткарылды.',
          en: 'All three daily quests were completed today.',
          ru: 'Сегодня выполнены все три ежедневных квеста.',
        ),
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
        ? 'Lv ${progress.journeyLevel} · ${progress.journeyRankOf(context)}'
        : context.tr(
            ky: 'Стартка даяр',
            en: 'Ready to start',
            ru: 'Готово к старту',
          );
    final subtitle = hasProgress
        ? _weeklyRhythmLabel(context, activeDaysThisWeek)
        : context.tr(
            ky: 'Алгач бир кыска циклди бүтүрүп, ритмди ачып алыңыз.',
            en: 'Complete your first short cycle to unlock rhythm insights.',
            ru: 'Завершите первый короткий цикл, чтобы открыть аналитику ритма.',
          );
    final milestoneText = hasProgress
        ? context.tr(
            ky: '${progress.xpToNextLevel} XP кийин кийинки деңгээл ачылат.',
            en: 'Next level unlocks in ${progress.xpToNextLevel} XP.',
            ru: 'Следующий уровень откроется через ${progress.xpToNextLevel} XP.',
          )
        : context.tr(
            ky: 'Бүгүнкү чакан темп жаңы деңгээлдин башталышы болот.',
            en: 'Today\'s small pace is enough to start your next level.',
            ru: 'Сегодняшнего небольшого темпа достаточно, чтобы начать следующий уровень.',
          );

    return AppCard(
      gradient: true,
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
                      context.tr(
                        ky: 'Кыргызча өсүшүңүз',
                        en: 'Your Kyrgyz growth',
                        ru: 'Ваш прогресс в кыргызском',
                      ),
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
          const SizedBox(height: 14),
          _HeroProgressBar(
            value: hasProgress ? progress.nextMilestoneProgress : 0.04,
          ),
          const SizedBox(height: 8),
          Text(
            hasProgress
                ? milestoneText
                : context.tr(
                    ky: 'Бүгүн $dailyGoalMinutes мүнөттүк темпти баштасаңыз жетиштүү.',
                    en: 'Starting a $dailyGoalMinutes-minute pace today is enough.',
                    ru: 'Достаточно начать сегодня темп в $dailyGoalMinutes минут.',
                  ),
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroMetricPill(
                icon: Icons.auto_stories_rounded,
                value: progress.totalWordsMastered.toString(),
                label: context.tr(ky: 'Сөз', en: 'Words', ru: 'Слова'),
              ),
              _HeroMetricPill(
                icon: Icons.flash_on_rounded,
                value: '${progress.totalXp}',
                label: 'XP',
              ),
              _HeroMetricPill(
                icon: Icons.schedule_rounded,
                value: _formatLearningTimeCompact(
                  context,
                  progress.totalLearningSeconds,
                ),
                label: context.tr(ky: 'Убакыт', en: 'Time', ru: 'Время'),
              ),
              _HeroMetricPill(
                icon: Icons.calendar_today_rounded,
                value: '$activeDaysThisWeek/7',
                label: context.tr(ky: 'Апта', en: 'Week', ru: 'Неделя'),
              ),
              _HeroMetricPill(
                icon: Icons.flag_rounded,
                value: '${progress.completedDailyQuestsCount}/3',
                label: context.tr(ky: 'Квест', en: 'Quest', ru: 'Квест'),
              ),
              _HeroMetricPill(
                icon: Icons.workspace_premium_rounded,
                value: '$unlockedAchievements/$totalAchievements',
                label: context.tr(ky: 'Белги', en: 'Badge', ru: 'Знак'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _weeklyRhythmLabel(BuildContext context, int activeDays) {
    if (activeDays >= 6) {
      return context.tr(
        ky: 'Ритм абдан бекем. Темпти мыкты кармап жатасыз.',
        en: 'Your rhythm is very strong. You are holding the pace well.',
        ru: 'Ритм очень крепкий. Вы отлично удерживаете темп.',
      );
    }
    if (activeDays >= 4) {
      return context.tr(
        ky: 'Апталык ритм жакшы. Дагы бир нече күн кошсоңуз күчөйт.',
        en: 'Weekly rhythm looks good. A few more days will strengthen it.',
        ru: 'Недельный ритм хороший. Еще несколько дней сделают его сильнее.',
      );
    }
    if (activeDays >= 2) {
      return context.tr(
        ky: 'Ритм түзүлүп жатат. Серияны үзбөңүз.',
        en: 'Your rhythm is forming. Do not break the streak.',
        ru: 'Ритм формируется. Не прерывайте серию.',
      );
    }
    return context.tr(
      ky: 'Азыр темпти кайра чогултуу маанилүү.',
      en: 'It is important to rebuild the pace now.',
      ru: 'Сейчас важно заново собрать темп.',
    );
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: context.tr(
              ky: 'Өсүш картасы',
              en: 'Growth snapshot',
              ru: 'Карта роста',
            ),
            subtitle: context.tr(
              ky: 'Ушул жерден деңгээл, сөз кору, убакыт жана жооп сапаты чогуу көрүнөт.',
              en: 'Level, vocabulary, time, and answer quality appear together here.',
              ru: 'Здесь вместе видны уровень, словарь, время и качество ответов.',
            ),
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
                label: context.tr(
                  ky: 'Саякат деңгээли',
                  en: 'Journey level',
                  ru: 'Уровень пути',
                ),
                helper: context.tr(
                  ky: '${progress.journeyRankOf(context)} · ${progress.xpToNextLevel} XP калды.',
                  en: '${progress.journeyRankOf(context)} · ${progress.xpToNextLevel} XP left.',
                  ru: '${progress.journeyRankOf(context)} · осталось ${progress.xpToNextLevel} XP.',
                ),
              ),
              _InsightTile(
                icon: Icons.auto_stories_rounded,
                accent: AppColors.accent,
                value: '${progress.totalWordsMastered}',
                label: context.tr(
                  ky: 'Үйрөнүлгөн сөз',
                  en: 'Learned words',
                  ru: 'Выученные слова',
                ),
                helper: context.tr(
                  ky: 'Ар бир бекем сөз жалпы деңгээлди көтөрөт.',
                  en: 'Each solid word raises the overall level.',
                  ru: 'Каждое закрепленное слово повышает общий уровень.',
                ),
              ),
              _InsightTile(
                icon: Icons.flash_on_rounded,
                accent: AppColors.warning,
                value: '${progress.totalXp}',
                label: context.tr(
                  ky: 'Жалпы XP',
                  en: 'Total XP',
                  ru: 'Общий XP',
                ),
                helper: context.tr(
                  ky: 'Квест, убакыт жана жооптор бул метриканы толтурат.',
                  en: 'Quests, time, and answers fill this metric.',
                  ru: 'Квесты, время и ответы наполняют эту метрику.',
                ),
              ),
              _InsightTile(
                icon: Icons.schedule_rounded,
                accent: AppColors.success,
                value: _formatLearningTimeCompact(
                  context,
                  progress.totalLearningSeconds,
                ),
                label: context.tr(
                  ky: 'Жалпы убакыт',
                  en: 'Total time',
                  ru: 'Общее время',
                ),
                helper: context.tr(
                  ky: 'Бул реалдуу практика менен топтолгон убакыт.',
                  en: 'This is time accumulated through real practice.',
                  ru: 'Это время, накопленное в реальной практике.',
                ),
              ),
              _InsightTile(
                icon: Icons.gpp_good_rounded,
                accent: AppColors.link,
                value: '${progress.accuracyPercent}%',
                label: context.tr(
                  ky: 'Жооп сапаты',
                  en: 'Answer quality',
                  ru: 'Качество ответов',
                ),
                helper: context.tr(
                  ky: '$activeDaysThisWeek күн активдүүлүк менен эсептелди.',
                  en: 'Based on $activeDaysThisWeek active days.',
                  ru: 'Рассчитано по $activeDaysThisWeek активным дням.',
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
      padding: const EdgeInsets.all(18),
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
                      context.tr(
                        ky: 'Апталык ритм',
                        en: 'Weekly rhythm',
                        ru: 'Недельный ритм',
                      ),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _rhythmNarrative(context, activeDaysThisWeek),
                      style: AppTextStyles.muted,
                    ),
                  ],
                ),
              ),
              AppChip(
                label: context.tr(
                  ky: '$streakDays күн серия',
                  en: '$streakDays day streak',
                  ru: 'Серия $streakDays дней',
                ),
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
                label: context.tr(
                  ky: 'Бул апта',
                  en: 'This week',
                  ru: 'Эта неделя',
                ),
                value: _formatLearningTimeCompact(context, weeklySeconds),
                color: AppColors.primary,
              ),
              _StatusTile(
                label: context.tr(
                  ky: 'Жалпы убакыт',
                  en: 'Total time',
                  ru: 'Общее время',
                ),
                value: _formatLearningTimeCompact(
                  context,
                  totalLearningSeconds,
                ),
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bestDay == null || !bestDay.isActive
                ? context.tr(
                    ky: 'Азырынча активдүү күндөр аз. Бир кыска цикл да ритмди жандандырат.',
                    en: 'There are still few active days. Even one short cycle will wake the rhythm up.',
                    ru: 'Активных дней пока мало. Даже один короткий цикл оживит ритм.',
                  )
                : context.tr(
                    ky: 'Эң күчтүү күн: ${_weekdayLabel(bestDay.date.weekday)}. Ушул темпти жумасына $activeDaysThisWeek күн кармап калуу маанилүү.',
                    en: 'Strongest day: ${_weekdayLabel(bestDay.date.weekday)}. It is important to hold this pace for $activeDaysThisWeek days a week.',
                    ru: 'Самый сильный день: ${_weekdayLabel(bestDay.date.weekday)}. Важно удерживать такой темп $activeDaysThisWeek дней в неделю.',
                  ),
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

  String _rhythmNarrative(BuildContext context, int activeDays) {
    if (activeDays >= 6) {
      return context.tr(
        ky: 'Бул жумада практика дээрлик күн сайын жүрдү.',
        en: 'Practice happened almost every day this week.',
        ru: 'Практика была почти каждый день на этой неделе.',
      );
    }
    if (activeDays >= 4) {
      return context.tr(
        ky: 'Темп жакшы. Серияны дагы бир аз узартсаңыз күчөйт.',
        en: 'The pace is good. Extend the streak a little more to strengthen it.',
        ru: 'Темп хороший. Продлите серию ещё немного, и она станет крепче.',
      );
    }
    if (activeDays >= 2) {
      return context.tr(
        ky: 'Ритм жанданып жатат, бирок туруктуулук керек.',
        en: 'The rhythm is waking up, but it still needs consistency.',
        ru: 'Ритм оживает, но ему всё ещё нужна стабильность.',
      );
    }
    return context.tr(
      ky: 'Азырынча ритм бош. Бүгүнкү кыска практика маанилүү болот.',
      en: 'The rhythm is still empty. A short practice today will matter.',
      ru: 'Ритм пока пуст. Короткая практика сегодня будет важной.',
    );
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
      padding: const EdgeInsets.all(18),
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
                      context.tr(
                        ky: 'Бүгүнкү квесттер',
                        en: 'Today\'s quests',
                        ru: 'Квесты на сегодня',
                      ),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      allDone
                          ? context.tr(
                              ky: 'Бүгүнкү үч квест тең жабылды. Темп мыкты.',
                              en: 'All three quests are closed today. Great pace.',
                              ru: 'Все три квеста на сегодня закрыты. Отличный темп.',
                            )
                          : context.tr(
                              ky: 'Кыска тапшырмалар бүгүнкү ритмди кармап турат.',
                              en: 'Short tasks are holding today\'s rhythm.',
                              ru: 'Короткие задания поддерживают ритм сегодняшнего дня.',
                            ),
                      style: AppTextStyles.muted,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppChip(
                label: context.tr(
                  ky: '$completedCount/${quests.length} аткарылды',
                  en: '$completedCount/${quests.length} completed',
                  ru: '$completedCount/${quests.length} выполнено',
                ),
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
                  context.tr(
                    ky: 'Бүгүн +$todayXp XP топтолду.',
                    en: '+$todayXp XP earned today.',
                    ru: 'Сегодня получено +$todayXp XP.',
                  ),
                  style: AppTextStyles.caption,
                ),
              ),
              if (!allDone)
                AppButton(
                  size: AppButtonSize.sm,
                  onPressed: () => context.go(nextQuest!.route),
                  child: Text(
                    context.tr(
                      ky: 'Кийинки квест',
                      en: 'Next quest',
                      ru: 'Следующий квест',
                    ),
                  ),
                )
              else
                AppButton(
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.outlined,
                  onPressed: () =>
                      context.push('/achievements?returnTo=/progress'),
                  child: Text(
                    context.tr(
                      ky: 'Белгилерди көрүү',
                      en: 'View badges',
                      ru: 'Посмотреть достижения',
                    ),
                  ),
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
                        quest.titleOf(context),
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quest.descriptionOf(context),
                        style: AppTextStyles.caption,
                      ),
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
                  quest.claimed
                      ? context.tr(
                          ky: 'Аткарылды',
                          en: 'Completed',
                          ru: 'Выполнено',
                        )
                      : '${quest.rewardXp} XP',
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
      padding: const EdgeInsets.all(18),
      showShadow: false,
      showOverlay: false,
      backgroundColor: AppColors.surface,
      borderColor: AppColors.outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppChip(
                label: focus.badgeOf(context),
                variant: focus.badgeVariant,
              ),
              if (focus.helperChipOf(context) != null)
                AppChip(
                  label: focus.helperChipOf(context)!,
                  variant: AppChipVariant.defaultChip,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            focus.titleOf(context),
            style: AppTextStyles.title.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(focus.messageOf(context), style: AppTextStyles.body),
          const SizedBox(height: 14),
          AppButton(
            fullWidth: true,
            showShadow: false,
            showSheen: false,
            onPressed: () => context.go(focus.primaryRoute),
            child: Text(focus.primaryLabelOf(context)),
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(
              ky: 'Кийинки бийиктик',
              en: 'Next milestone',
              ru: 'Следующая высота',
            ),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            isMaxed
                ? context.tr(
                    ky: 'Чекиттер ачылды',
                    en: 'Milestones unlocked',
                    ru: 'Этапы открыты',
                  )
                : '${progress.wordsToNextMilestone}',
            style: AppTextStyles.heading.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 4),
          Text(
            isMaxed
                ? context.tr(
                    ky: 'Учурдагы негизги чекиттер толук бүттү.',
                    en: 'Current key milestones are fully completed.',
                    ru: 'Текущие ключевые этапы полностью завершены.',
                  )
                : context.tr(
                    ky: 'сөз калды · максат ${progress.nextMilestoneLabelOf(context)}',
                    en: 'words left · target ${progress.nextMilestoneLabelOf(context)}',
                    ru: 'слов осталось · цель ${progress.nextMilestoneLabelOf(context)}',
                  ),
            style: AppTextStyles.muted,
          ),
          const SizedBox(height: 14),
          _LinearProgress(value: progress.nextMilestoneProgress),
          const SizedBox(height: 10),
          Text(
            isMaxed
                ? context.tr(
                    ky: 'Эми темпти, тактыкты жана серияны бекемдесеңиз болот.',
                    en: 'Now you can strengthen pace, accuracy, and streak.',
                    ru: 'Теперь можно укреплять темп, точность и серию.',
                  )
                : context.tr(
                    ky: '$percent% өттү. Бүгүнкү $dailyGoalMinutes мүн темп бул чекитке жакындатат.',
                    en: '$percent% completed. Today\'s $dailyGoalMinutes-minute pace moves you closer.',
                    ru: '$percent% пройдено. Сегодняшний темп в $dailyGoalMinutes минут приблизит вас к цели.',
                  ),
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(
              ky: 'Практика пульсу',
              en: 'Practice pulse',
              ru: 'Пульс практики',
            ),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          AdaptivePanelGrid(
            maxColumns: 3,
            minItemWidth: 92,
            spacing: 10,
            children: [
              _StatusTile(
                label: context.tr(
                  ky: 'Кайталоо',
                  en: 'Review',
                  ru: 'Повторение',
                ),
                value: progress.reviewDueWordsCount.toString(),
                color: AppColors.accent,
              ),
              _StatusTile(
                label: context.tr(
                  ky: 'Алсыз сөз',
                  en: 'Weak words',
                  ru: 'Слабые слова',
                ),
                value: progress.weakWordsCount.toString(),
                color: AppColors.primary,
              ),
              _StatusTile(
                label: context.tr(
                  ky: 'Күндүк максат',
                  en: 'Daily goal',
                  ru: 'Дневная цель',
                ),
                value: context.tr(
                  ky: '$dailyGoalMinutes мүн',
                  en: '$dailyGoalMinutes min',
                  ru: '$dailyGoalMinutes мин',
                ),
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            progress.hasReviewFocus
                ? context.tr(
                    ky: 'Азыркы эң чоң кайтарым кайталоодо жатат.',
                    en: 'The biggest payoff right now is in review.',
                    ru: 'Самая большая отдача сейчас находится в повторении.',
                  )
                : context.tr(
                    ky: 'Кайталоо таза. Жаңы цикл же квиз үчүн жакшы учур.',
                    en: 'Review is clean. Good time for a new cycle or quiz.',
                    ru: 'Повторение чистое. Хорошее время для нового цикла или квиза.',
                  ),
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _ProgressSectionPage extends StatelessWidget {
  const _ProgressSectionPage({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: children,
    );
  }
}

class _AchievementWallEntryCard extends StatelessWidget {
  const _AchievementWallEntryCard({
    required this.unlockedCount,
    required this.totalCount,
  });

  final int unlockedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      showShadow: false,
      showOverlay: false,
      backgroundColor: AppColors.surface,
      borderColor: AppColors.outline,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.textDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(
                    ky: 'Жетишкендиктер дубалы',
                    en: 'Achievement wall',
                    ru: 'Стена достижений',
                  ),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    ky: '$unlockedCount/$totalCount ачылды. Толук маалымат жана жабык максаттар үчүн өзүнчө дубалды ачыңыз.',
                    en: '$unlockedCount of $totalCount unlocked. Open the dedicated wall for full details and locked targets.',
                    ru: 'Открыто $unlockedCount из $totalCount. Откройте отдельную стену для подробностей и закрытых целей.',
                  ),
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 10),
                AppButton(
                  size: AppButtonSize.sm,
                  showShadow: false,
                  showSheen: false,
                  onPressed: () =>
                      context.push('/achievements?returnTo=/progress'),
                  child: Text(
                    context.tr(
                      ky: 'Жетишкендиктер дубалын ачуу',
                      en: 'Open achievement wall',
                      ru: 'Открыть стену достижений',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressIntentStrip extends StatelessWidget {
  const _ProgressIntentStrip({
    required this.activeIndex,
    required this.onSelect,
  });

  final int activeIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppChip(
          label: context.tr(ky: 'Обзор', en: 'Overview', ru: 'Обзор'),
          variant: activeIndex == 0
              ? AppChipVariant.primary
              : AppChipVariant.defaultChip,
          onTap: () => onSelect(0),
        ),
        AppChip(
          label: context.tr(ky: 'Ритм', en: 'Rhythm', ru: 'Ритм'),
          variant: activeIndex == 1
              ? AppChipVariant.success
              : AppChipVariant.defaultChip,
          onTap: () => onSelect(1),
        ),
        AppChip(
          label: context.tr(
            ky: 'Лидерборд',
            en: 'Leaderboard',
            ru: 'Лидерборд',
          ),
          variant: activeIndex == 2
              ? AppChipVariant.accent
              : AppChipVariant.defaultChip,
          onTap: () => onSelect(2),
        ),
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
      return SizedBox(
        height: 220,
        child: AppLoadingState(
          title: context.tr(
            ky: 'Лидерборд жүктөлүүдө',
            en: 'Leaderboard is loading',
            ru: 'Лидерборд загружается',
          ),
          message: context.tr(
            ky: 'Топ оюнчулар даярдалып жатат.',
            en: 'Top players are being prepared.',
            ru: 'Подготавливаются лучшие игроки.',
          ),
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
              context.tr(
                ky: 'Азырынча оюнчулар көрүнбөй жатат.',
                en: 'No players are visible yet.',
                ru: 'Игроки пока не отображаются.',
              ),
              style: AppTextStyles.muted,
            ),
          const SizedBox(height: 14),
          AppButton(
            fullWidth: true,
            variant: AppButtonVariant.outlined,
            onPressed: () => context.push('/leaderboard?limit=100'),
            child: Text(
              context.tr(
                ky: 'Алгачкы 100 оюнчуну ачуу',
                en: 'Open top 100 players',
                ru: 'Открыть топ-100 игроков',
              ),
            ),
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
                context.tr(
                  ky: '${localizedJourneyRank(context, player.journeyLevel)} · ${player.streakDays} күн',
                  en: '${localizedJourneyRank(context, player.journeyLevel)} · ${player.streakDays} days',
                  ru: '${localizedJourneyRank(context, player.journeyLevel)} · ${player.streakDays} дней',
                ),
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
    required this.titleBuilder,
    required this.messageBuilder,
    required this.primaryLabelBuilder,
    required this.primaryRoute,
    required this.badgeBuilder,
    required this.badgeVariant,
    this.helperChipBuilder,
  });

  final String Function(BuildContext context) titleBuilder;
  final String Function(BuildContext context) messageBuilder;
  final String Function(BuildContext context) primaryLabelBuilder;
  final String primaryRoute;
  final String Function(BuildContext context) badgeBuilder;
  final AppChipVariant badgeVariant;
  final String Function(BuildContext context)? helperChipBuilder;

  String titleOf(BuildContext context) => titleBuilder(context);
  String messageOf(BuildContext context) => messageBuilder(context);
  String primaryLabelOf(BuildContext context) => primaryLabelBuilder(context);
  String badgeOf(BuildContext context) => badgeBuilder(context);
  String? helperChipOf(BuildContext context) =>
      helperChipBuilder?.call(context);

  factory _ProgressFocus.fromState({
    required ProgressProvider progress,
    required int dailyGoalMinutes,
    required CategoryModel? reviewCategory,
  }) {
    if (progress.reviewDueWordsCount > 0 && reviewCategory != null) {
      return _ProgressFocus(
        titleBuilder: (context) => context.tr(
          ky: 'Алгач кайталоону жабыңыз',
          en: 'Close review first',
          ru: 'Сначала закройте повторение',
        ),
        messageBuilder: (context) => context.tr(
          ky: '${reviewCategory.title} ичинде мөөнөтү жеткен сөздөр бар.',
          en: 'There are due words inside ${reviewCategory.title}.',
          ru: 'Внутри ${reviewCategory.title} есть слова с истекшим сроком.',
        ),
        primaryLabelBuilder: (context) => context.tr(
          ky: 'Кайталоону баштоо',
          en: 'Start review',
          ru: 'Начать повторение',
        ),
        primaryRoute: '/flashcards/${reviewCategory.id}?mode=review',
        badgeBuilder: (context) => context.tr(
          ky: '${progress.reviewDueWordsCount} кайталоо',
          en: '${progress.reviewDueWordsCount} reviews',
          ru: '${progress.reviewDueWordsCount} повторений',
        ),
        badgeVariant: AppChipVariant.accent,
        helperChipBuilder: (context) => context.tr(
          ky: '$dailyGoalMinutes мүн максат',
          en: '$dailyGoalMinutes min goal',
          ru: 'Цель $dailyGoalMinutes мин',
        ),
      );
    }

    if (progress.weakWordsCount > 0) {
      return _ProgressFocus(
        titleBuilder: (context) => context.tr(
          ky: 'Алсыз сөздөрдү бекемдеңиз',
          en: 'Strengthen weak words',
          ru: 'Укрепите слабые слова',
        ),
        messageBuilder: (context) => context.tr(
          ky: '${progress.weakWordsCount} сөз дагы эле туруксуз.',
          en: '${progress.weakWordsCount} words are still unstable.',
          ru: '${progress.weakWordsCount} слов всё ещё нестабильны.',
        ),
        primaryLabelBuilder: (context) => context.tr(
          ky: 'Практикага өтүү',
          en: 'Go to practice',
          ru: 'Перейти к практике',
        ),
        primaryRoute: '/practice',
        badgeBuilder: (context) => context.tr(
          ky: 'Алсыз фокус',
          en: 'Weak-word focus',
          ru: 'Фокус на слабых словах',
        ),
        badgeVariant: AppChipVariant.primary,
        helperChipBuilder: (context) => context.tr(
          ky: '${progress.weakWordsCount} сөз',
          en: '${progress.weakWordsCount} words',
          ru: '${progress.weakWordsCount} слов',
        ),
      );
    }

    if (progress.totalWordsReviewed == 0) {
      return _ProgressFocus(
        titleBuilder: (context) => context.tr(
          ky: 'Биринчи циклди баштаңыз',
          en: 'Start the first cycle',
          ru: 'Начните первый цикл',
        ),
        messageBuilder: (context) => context.tr(
          ky: 'Алгач бир кыска машыгууну бүтүрүңүз.',
          en: 'Complete one short practice first.',
          ru: 'Сначала завершите одну короткую практику.',
        ),
        primaryLabelBuilder: (context) => context.tr(
          ky: 'Практиканы баштоо',
          en: 'Start practice',
          ru: 'Начать практику',
        ),
        primaryRoute: '/practice',
        badgeBuilder: (context) =>
            context.tr(ky: 'Старт', en: 'Start', ru: 'Старт'),
        badgeVariant: AppChipVariant.primary,
      );
    }

    return _ProgressFocus(
      titleBuilder: (context) => context.tr(
        ky: 'Темпти сактап туруңуз',
        en: 'Keep the pace',
        ru: 'Сохраняйте темп',
      ),
      messageBuilder: (context) => context.tr(
        ky: '$dailyGoalMinutes мүнөттүк темпти сактаңыз.',
        en: 'Keep the $dailyGoalMinutes-minute pace.',
        ru: 'Сохраняйте темп в $dailyGoalMinutes минут.',
      ),
      primaryLabelBuilder: (context) => context.tr(
        ky: 'Практикага өтүү',
        en: 'Go to practice',
        ru: 'Перейти к практике',
      ),
      primaryRoute: '/practice',
      badgeBuilder: (context) =>
          context.tr(ky: 'Таза темп', en: 'Clean pace', ru: 'Чистый темп'),
      badgeVariant: AppChipVariant.success,
      helperChipBuilder: (context) => progress.nextMilestoneLabelOf(context),
    );
  }
}

String _formatLearningTimeCompact(BuildContext context, int totalSeconds) {
  if (totalSeconds <= 0) {
    return context.tr(ky: '0 мүн', en: '0 min', ru: '0 мин');
  }
  final duration = Duration(seconds: totalSeconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) {
    if (minutes > 0) {
      return context.tr(
        ky: '$hours с $minutes м',
        en: '$hours h $minutes m',
        ru: '$hours ч $minutes м',
      );
    }
    return context.tr(ky: '$hours с', en: '$hours h', ru: '$hours ч');
  }
  return context.tr(
    ky: '${duration.inMinutes.clamp(1, 999)} мүн',
    en: '${duration.inMinutes.clamp(1, 999)} min',
    ru: '${duration.inMinutes.clamp(1, 999)} мин',
  );
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
