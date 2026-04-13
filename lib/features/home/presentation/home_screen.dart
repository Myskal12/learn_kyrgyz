import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../core/providers/learning_session_provider.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_assets.dart';
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
    final weeklyChallenge = progress.weeklyChallenge;

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
    final dailyQuests = progress.dailyQuests;
    DailyQuestSnapshot? nextQuest;
    for (final quest in dailyQuests) {
      if (!quest.claimed) {
        nextQuest = quest;
        break;
      }
    }

    final recommendedAction = _RecommendedAction.fromState(
      totalWordsMastered: progress.totalWordsMastered,
      hasActivityToday: progress.hasActivityToday,
      dailyGoalMinutes: onboarding.dailyGoalMinutes,
      categoryId: focusCategory.id,
      totalReviewDue: totalReviewDue,
      reviewCategoryId: reviewCategory?.id,
    );

    return AppShell(
      title: context.tr(ky: 'Бүгүн', en: 'Today', ru: 'Сегодня'),
      subtitle: context.tr(
        ky: 'Кийинки эң жакшы кадам',
        en: 'Best next step',
        ru: 'Лучший следующий шаг',
      ),
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
                      context.tr(
                        ky: 'Кандайсың, $displayName!',
                        en: 'Hi, $displayName!',
                        ru: 'Привет, $displayName!',
                      ),
                      style: AppTextStyles.caption.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr(
                        ky: 'Бүгүн эмнеден баштайбыз?',
                        en: 'Where do we start today?',
                        ru: 'С чего начнём сегодня?',
                      ),
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 30,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recommendedAction.supportingTextOf(context),
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
                      recommendedAction.subtitleOf(context),
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
                      label: recommendedAction.primaryLabelOf(context),
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
                            context.tr(
                              ky: 'Прогрессти сактап калгыңыз келеби?',
                              en: 'Want to save your progress?',
                              ru: 'Хотите сохранить прогресс?',
                            ),
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr(
                              ky: 'Аккаунт ачсаңыз, жыйынтык аккаунтка байланат.',
                              en: 'Create an account to link results to it.',
                              ru: 'Создайте аккаунт, чтобы привязать к нему результаты.',
                            ),
                            style: AppTextStyles.muted,
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            size: AppButtonSize.sm,
                            onPressed: () => context.push('/signup'),
                            child: Text(
                              context.tr(
                                ky: 'Аккаунт ачуу',
                                en: 'Create account',
                                ru: 'Создать аккаунт',
                              ),
                            ),
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
                label: context.tr(ky: 'Серия', en: 'Streak', ru: 'Серия'),
              ),
              _StatCard(
                icon: Icons.menu_book,
                iconColor: AppColors.primary,
                value: progress.totalWordsMastered.toString(),
                label: context.tr(ky: 'Сөздөр', en: 'Words', ru: 'Слова'),
              ),
              _StatCard(
                icon: Icons.flash_on_rounded,
                iconColor: AppColors.warning,
                value: 'Lv ${progress.journeyLevel}',
                label: context.tr(ky: 'Деңгээл', en: 'Level', ru: 'Уровень'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DailyMomentumCard(
            quests: dailyQuests,
            completedCount: progress.completedDailyQuestsCount,
            todayXp: progress.todayXp,
            nextQuest: nextQuest,
            weeklyChallenge: weeklyChallenge,
          ),
          const SizedBox(height: 24),
          Text(
            context.tr(
              ky: 'Азыркы фокус',
              en: 'Current focus',
              ru: 'Текущий фокус',
            ),
            style: AppTextStyles.title,
          ),
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
        title: context.tr(
          ky: 'Негизги сабак',
          en: 'Core lesson',
          ru: 'Базовый урок',
        ),
        description: context.tr(
          ky: 'Биринчи сөздөр жана негизги конструкциялар.',
          en: 'First words and core patterns.',
          ru: 'Первые слова и базовые конструкции.',
        ),
        wordsCount: 0,
      );
    }

    for (final category in categories) {
      if (category.id == categoryId) return category;
    }
    return categories.first;
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
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Image.asset(
              AppAssets.streakFlame,
              width: 22,
              height: 22,
              fit: BoxFit.cover,
            ),
          ),
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

class _DailyMomentumCard extends StatelessWidget {
  const _DailyMomentumCard({
    required this.quests,
    required this.completedCount,
    required this.todayXp,
    required this.nextQuest,
    required this.weeklyChallenge,
  });

  final List<DailyQuestSnapshot> quests;
  final int completedCount;
  final int todayXp;
  final DailyQuestSnapshot? nextQuest;
  final WeeklyChallengeSnapshot weeklyChallenge;

  @override
  Widget build(BuildContext context) {
    final allDone = nextQuest == null;
    final isDark = AppColors.isDark;
    final cardBackground = isDark
        ? AppColors.accent.withValues(alpha: 0.05)
        : Color.alphaBlend(
            AppColors.accent.withValues(alpha: 0.035),
            AppColors.surface,
          );
    final weeklyBackground = isDark
        ? AppColors.primary.withValues(alpha: 0.06)
        : Color.alphaBlend(
            AppColors.primary.withValues(alpha: 0.045),
            AppColors.surface,
          );
    return AppCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: cardBackground,
      borderColor: AppColors.accent.withValues(alpha: isDark ? 0.14 : 0.16),
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
                        ky: 'Бүгүнкү импульс',
                        en: 'Today\'s momentum',
                        ru: 'Импульс дня',
                      ),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      allDone
                          ? context.tr(
                              ky: 'Бүгүнкү квесттер толук жабылды. Темпти сактап калдыңыз.',
                              en: 'Today\'s quests are complete. You kept the pace.',
                              ru: 'Сегодняшние квесты закрыты. Вы удержали темп.',
                            )
                          : context.tr(
                              ky: 'Кыска тапшырмалар менен күндү жандуу кармаңыз.',
                              en: 'Keep the day active with short tasks.',
                              ru: 'Поддерживайте день в ритме короткими заданиями.',
                            ),
                      style: AppTextStyles.muted,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppChip(
                label: context.tr(
                  ky: '$completedCount/${quests.length} даяр',
                  en: '$completedCount/${quests.length} done',
                  ru: '$completedCount/${quests.length} готово',
                ),
                variant: allDone
                    ? AppChipVariant.success
                    : AppChipVariant.accent,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quests
                .map((quest) => _MomentumQuestPill(quest: quest))
                .toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: weeklyBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.12 : 0.16,
                ),
              ),
              boxShadow: isDark
                  ? const []
                  : [
                      BoxShadow(
                        color: AppColors.cardShadow.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weeklyChallenge.titleOf(context),
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(
                          ky: '${weeklyChallenge.activeDays}/${weeklyChallenge.targetActiveDays} күн · ${weeklyChallenge.weeklyXp}/${weeklyChallenge.targetXp} XP',
                          en: '${weeklyChallenge.activeDays}/${weeklyChallenge.targetActiveDays} days · ${weeklyChallenge.weeklyXp}/${weeklyChallenge.targetXp} XP',
                          ru: '${weeklyChallenge.activeDays}/${weeklyChallenge.targetActiveDays} дней · ${weeklyChallenge.weeklyXp}/${weeklyChallenge.targetXp} XP',
                        ),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                AppChip(
                  label: weeklyChallenge.statusLabelOf(context),
                  variant: weeklyChallenge.isCompleted
                      ? AppChipVariant.success
                      : AppChipVariant.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
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
              AppButton(
                size: AppButtonSize.sm,
                variant: allDone
                    ? AppButtonVariant.outlined
                    : AppButtonVariant.primary,
                onPressed: () => context.go(nextQuest?.route ?? '/progress'),
                child: Text(
                  allDone
                      ? context.tr(
                          ky: 'Прогрессти ачуу',
                          en: 'Open progress',
                          ru: 'Открыть прогресс',
                        )
                      : context.tr(
                          ky: 'Кийинки квест',
                          en: 'Next quest',
                          ru: 'Следующий квест',
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

class _MomentumQuestPill extends StatelessWidget {
  const _MomentumQuestPill({required this.quest});

  final DailyQuestSnapshot quest;

  @override
  Widget build(BuildContext context) {
    final isDone = quest.claimed;
    final tint = isDone ? AppColors.success : AppColors.primary;
    final isDark = AppColors.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? tint.withValues(alpha: 0.08)
            : Color.alphaBlend(
                tint.withValues(alpha: 0.045),
                AppColors.surface,
              ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tint.withValues(alpha: isDark ? 0.14 : 0.16)),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: AppColors.cardShadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDone ? Icons.check_circle_rounded : Icons.flag_rounded,
                color: tint,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                quest.titleOf(context),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(quest.progressLabelOf(context), style: AppTextStyles.caption),
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
                  hasProgress
                      ? context.tr(
                          ky: 'Акыркы же негизги сабак',
                          en: 'Latest or core lesson',
                          ru: 'Последний или основной урок',
                        )
                      : context.tr(
                          ky: 'Биринчи сабак',
                          en: 'First lesson',
                          ru: 'Первый урок',
                        ),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppChip(
                label: reviewDue > 0
                    ? context.tr(
                        ky: '$reviewDue кайталоо',
                        en: '$reviewDue reviews',
                        ru: '$reviewDue повторений',
                      )
                    : context.tr(
                        ky: 'Улантууга даяр',
                        en: 'Ready to continue',
                        ru: 'Готово к продолжению',
                      ),
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
                context.tr(
                  ky: '$masteredWords/$totalWords сөз',
                  en: '$masteredWords/$totalWords words',
                  ru: '$masteredWords/$totalWords слов',
                ),
                style: AppTextStyles.caption,
              ),
              Text(
                context.tr(
                  ky: '${(completion * 100).round()}% өздөштүрүлдү',
                  en: '${(completion * 100).round()}% mastered',
                  ru: '${(completion * 100).round()}% освоено',
                ),
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _LinearProgress(value: completion),
          const SizedBox(height: 16),
          Text(
            hasProgress
                ? context.tr(
                    ky: 'Бул сабакка кайтуу үчүн жогорку негизги аракетти колдонуңуз.',
                    en: 'Use the main action above to return to this lesson.',
                    ru: 'Используйте основное действие выше, чтобы вернуться к этому уроку.',
                  )
                : context.tr(
                    ky: 'Бул теманы баштоо үчүн жогорку негизги аракетти колдонуңуз.',
                    en: 'Use the main action above to start this topic.',
                    ru: 'Используйте основное действие выше, чтобы начать эту тему.',
                  ),
            style: AppTextStyles.muted,
          ),
          const SizedBox(height: 12),
          AppButton(
            fullWidth: true,
            variant: AppButtonVariant.outlined,
            onPressed: () => context.go('/categories'),
            child: Text(
              context.tr(
                ky: 'Жол картасын көрүү',
                en: 'View roadmap',
                ru: 'Открыть дорожную карту',
              ),
            ),
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

class _RecommendedAction {
  const _RecommendedAction({
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.supportingTextBuilder,
    required this.primaryLabelBuilder,
    required this.primaryRoute,
  });

  final String Function(BuildContext context) titleBuilder;
  final String Function(BuildContext context) subtitleBuilder;
  final String Function(BuildContext context) supportingTextBuilder;
  final String Function(BuildContext context) primaryLabelBuilder;
  final String primaryRoute;

  String titleOf(BuildContext context) => titleBuilder(context);
  String subtitleOf(BuildContext context) => subtitleBuilder(context);
  String supportingTextOf(BuildContext context) =>
      supportingTextBuilder(context);
  String primaryLabelOf(BuildContext context) => primaryLabelBuilder(context);

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
        titleBuilder: _titleStartFirstLesson,
        subtitleBuilder: _subtitleStartFirstLesson,
        supportingTextBuilder: _supportStartFirstLesson,
        primaryLabelBuilder: _primaryChooseLesson,
        primaryRoute: '/categories',
      );
    }

    if (totalReviewDue > 0 && reviewCategoryId != null) {
      return _RecommendedAction(
        titleBuilder: _titleCloseReviews,
        subtitleBuilder: (context) => context.tr(
          ky: '$totalReviewDue сөз даяр турат.',
          en: '$totalReviewDue words are ready.',
          ru: 'Готово $totalReviewDue слов.',
        ),
        supportingTextBuilder: (context) => context.tr(
          ky: 'Алгач кайталоо жакшыраак.',
          en: 'Starting with review is better.',
          ru: 'Сначала лучше закрыть повторение.',
        ),
        primaryLabelBuilder: (context) => context.tr(
          ky: 'Кайталоону баштоо',
          en: 'Start review',
          ru: 'Начать повторение',
        ),
        primaryRoute: '/flashcards/$reviewCategoryId?mode=review',
      );
    }

    if (!hasActivityToday) {
      return _RecommendedAction(
        titleBuilder: (context) => context.tr(
          ky: 'Бүгүнкү максатты ач',
          en: 'Unlock today\'s goal',
          ru: 'Откройте цель на сегодня',
        ),
        subtitleBuilder: (context) => context.tr(
          ky: '$dailyGoalMinutes мүнөт үчүн сабакты улантыңыз.',
          en: 'Continue the lesson for $dailyGoalMinutes minutes.',
          ru: 'Продолжайте урок $dailyGoalMinutes минут.',
        ),
        supportingTextBuilder: (context) => context.tr(
          ky: 'Азыркы эң туура кадам ушул.',
          en: 'This is the best next step right now.',
          ru: 'Это лучший следующий шаг прямо сейчас.',
        ),
        primaryLabelBuilder: (context) => context.tr(
          ky: 'Практиканы улантуу',
          en: 'Continue practice',
          ru: 'Продолжить практику',
        ),
        primaryRoute: '/flashcards/$categoryId',
      );
    }

    return _RecommendedAction(
      titleBuilder: (context) => context.tr(
        ky: 'Бүгүн жакшы темптесиз',
        en: 'You have a good pace today',
        ru: 'Сегодня у вас хороший темп',
      ),
      subtitleBuilder: (context) => context.tr(
        ky: 'Кыска текшерүү же колдонуу режимине өтүңүз.',
        en: 'Switch to a quick check or application mode.',
        ru: 'Перейдите в короткую проверку или прикладной режим.',
      ),
      supportingTextBuilder: (context) => context.tr(
        ky: 'Темпти кармап туруңуз.',
        en: 'Keep the pace going.',
        ru: 'Удерживайте темп.',
      ),
      primaryLabelBuilder: (context) => context.tr(
        ky: 'Экспресс-квиз',
        en: 'Quick quiz',
        ru: 'Экспресс-квиз',
      ),
      primaryRoute: '/quick-quiz',
    );
  }
}

String _titleStartFirstLesson(BuildContext context) => context.tr(
  ky: 'Бүгүн биринчи сабакты баштаңыз',
  en: 'Start your first lesson today',
  ru: 'Начните первый урок сегодня',
);

String _titleCloseReviews(BuildContext context) => context.tr(
  ky: 'Адегенде кайталоону жабыңыз',
  en: 'Close review first',
  ru: 'Сначала закройте повторение',
);

String _subtitleStartFirstLesson(BuildContext context) => context.tr(
  ky: 'Категория тандап, биринчи циклди баштаңыз.',
  en: 'Choose a category and start your first cycle.',
  ru: 'Выберите категорию и начните первый цикл.',
);

String _supportStartFirstLesson(BuildContext context) => context.tr(
  ky: 'Бүгүнкү эң жакшы старт ушул.',
  en: 'This is the best start for today.',
  ru: 'Это лучший старт на сегодня.',
);

String _primaryChooseLesson(BuildContext context) =>
    context.tr(ky: 'Сабак тандаңыз', en: 'Choose lesson', ru: 'Выбрать урок');
