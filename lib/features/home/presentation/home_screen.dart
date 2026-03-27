import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/onboarding_provider.dart';
import '../../../core/providers/learning_session_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
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
    final categories = ref.watch(categoriesProvider);
    final profileState = ref.watch(userProfileProvider);
    final session = ref.watch(learningSessionProvider);
    final featured = categories.categories.take(3).toList();
    final firstCategoryId = categories.categories.isNotEmpty
        ? categories.categories.first.id
        : 'basic';
    final lastCategoryId = session.lastCategoryId ?? firstCategoryId;
    final displayName = profileState.isGuest
        ? 'Конок'
        : profileState.profile.nickname;

    final recommendedAction = _RecommendedAction.fromState(
      totalWordsMastered: progress.totalWordsMastered,
      hasActivityToday: progress.hasActivityToday,
      dailyGoalMinutes: onboarding.dailyGoalMinutes,
      categoryId: lastCategoryId,
    );

    final fallbackTopics = [
      _TopicCardData(
        title: 'Саламдашуу жана таанышуу',
        subtitle: '3/8 сабактар',
        colors: [AppColors.primary, const Color(0xFFF7C15C)],
        icon: Icons.menu_book,
      ),
      _TopicCardData(
        title: 'Күнүмдүк сүйлөшүү',
        subtitle: '2/6 сабактар',
        colors: [AppColors.accent, const Color(0xFFB71C1C)],
        icon: Icons.gps_fixed,
      ),
      _TopicCardData(
        title: 'Саякат жана багыт',
        subtitle: '1/5 сабактар',
        colors: [const Color(0xFF1976D2), const Color(0xFF1565C0)],
        icon: Icons.emoji_events,
      ),
    ];

    final topics = featured.isEmpty
        ? fallbackTopics
        : featured
              .map(
                (item) => _TopicCardData(
                  title: item.title,
                  subtitle: item.description,
                  colors: [AppColors.primary, const Color(0xFFF7C15C)],
                  icon: Icons.menu_book,
                  route: '/flashcards/${item.id}',
                ),
              )
              .toList();

    return AppShell(
      title: 'Үйрөнүү',
      subtitle: 'Күндүк практика',
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
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () =>
                          context.push(recommendedAction.secondaryRoute),
                      child: Text(
                        recommendedAction.secondaryLabel,
                        style: AppTextStyles.body.copyWith(color: Colors.white),
                      ),
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
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  iconColor: AppColors.accent,
                  value: progress.streakDays.toString(),
                  label: 'Күн',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.menu_book,
                  iconColor: AppColors.primary,
                  value: progress.totalWordsMastered.toString(),
                  label: 'Сөздөр',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.gps_fixed,
                  iconColor: AppColors.success,
                  value: '${progress.accuracyPercent}%',
                  label: 'Тактык',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Кийинки кадамдар', style: AppTextStyles.title),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  title: progress.totalWordsMastered == 0
                      ? 'Биринчи сабак'
                      : 'Улантуу',
                  subtitle: progress.totalWordsMastered == 0
                      ? 'Категория тандап баштаңыз'
                      : 'Акыркы категорияга кайтыңыз',
                  icon: Icons.play_circle_fill,
                  color: AppColors.primary,
                  onTap: () => context.push(
                    progress.totalWordsMastered == 0
                        ? '/categories'
                        : '/flashcards/$lastCategoryId',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  title: 'Тез квиз',
                  subtitle: '5 суроо менен билимиңизди текшериңиз',
                  icon: Icons.flash_on,
                  color: AppColors.accent,
                  onTap: () => context.push('/quick-quiz'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Тандалган темалар', style: AppTextStyles.title),
          const SizedBox(height: 12),
          ...topics.map(
            (topic) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                onTap: () => context.push(topic.route ?? '/categories'),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: topic.colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(topic.icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.title,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(topic.subtitle, style: AppTextStyles.muted),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.muted),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Тез шилтемелер', style: AppTextStyles.title),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () => context.push('/quiz/basic'),
                  child: Column(
                    children: [
                      _QuickIcon(icon: Icons.flash_on, color: AppColors.accent),
                      const SizedBox(height: 8),
                      Text(
                        'Экспресс-квиз',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () => context.push('/flashcards/$lastCategoryId'),
                  child: Column(
                    children: [
                      _QuickIcon(
                        icon: Icons.menu_book,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Карточкалар',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () => context.push('/leaderboard'),
                  child: Column(
                    children: [
                      _QuickIcon(
                        icon: Icons.emoji_events,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Рейтинг',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
  const _HeroChip({required this.goalMinutes, required this.streakDays});

  final int goalMinutes;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _GlassTag(label: 'Максат: $goalMinutes мүн'),
        _GlassTag(label: 'Серия: $streakDays күн'),
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

class _ActionCard extends StatelessWidget {
  const _ActionCard({
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
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuickIcon(icon: icon, color: color),
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

class _TopicCardData {
  const _TopicCardData({
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.icon,
    this.route,
  });

  final String title;
  final String subtitle;
  final List<Color> colors;
  final IconData icon;
  final String? route;
}

class _RecommendedAction {
  const _RecommendedAction({
    required this.title,
    required this.subtitle,
    required this.supportingText,
    required this.primaryLabel,
    required this.primaryRoute,
    required this.secondaryLabel,
    required this.secondaryRoute,
  });

  final String title;
  final String subtitle;
  final String supportingText;
  final String primaryLabel;
  final String primaryRoute;
  final String secondaryLabel;
  final String secondaryRoute;

  factory _RecommendedAction.fromState({
    required int totalWordsMastered,
    required bool hasActivityToday,
    required int dailyGoalMinutes,
    required String categoryId,
  }) {
    if (totalWordsMastered == 0) {
      return const _RecommendedAction(
        title: 'Биринчи сабакты башта',
        subtitle:
            'Негизги категориядан өтүп, биринчи flashcard циклин аяктаңыз.',
        supportingText: 'Бүгүн биринчи кадамды жасап, баштапкы ритмди түзөбүз.',
        primaryLabel: 'Сабак тандаңыз',
        primaryRoute: '/categories',
        secondaryLabel: 'Тез баштоо',
        secondaryRoute: '/flashcards/basic',
      );
    }

    if (!hasActivityToday) {
      return _RecommendedAction(
        title: 'Бүгүнкү максатты ач',
        subtitle:
            '$dailyGoalMinutes мүнөттүк практика үчүн акыркы сабагыңызга кайтыңыз.',
        supportingText:
            'Серияны сактоо үчүн бүгүн жок дегенде бир сессия жасаңыз.',
        primaryLabel: 'Практиканы улантуу',
        primaryRoute: '/flashcards/$categoryId',
        secondaryLabel: 'Кыска квиз',
        secondaryRoute: '/quick-quiz',
      );
    }

    return _RecommendedAction(
      title: 'Бүгүн жакшы башталды',
      subtitle: 'Күндүк темпти бекемдөө үчүн дагы бир кыска аракет жасаңыз.',
      supportingText:
          'Сиз бүгүн активдүүсүз. Эми квиз же сүйлөм түзүү менен натыйжаны бекемдеңиз.',
      primaryLabel: 'Экспресс-квиз',
      primaryRoute: '/quick-quiz',
      secondaryLabel: 'Сүйлөм түзүү',
      secondaryRoute: '/sentence-builder/$categoryId',
    );
  }
}
