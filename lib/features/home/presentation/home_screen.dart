import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/learning_session_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../categories/providers/categories_provider.dart';
import '../../profile/providers/progress_provider.dart';

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
    final progress = ref.watch(progressProvider);
    final categories = ref.watch(categoriesProvider);
    final session = ref.watch(learningSessionProvider);
    final featured = categories.categories.take(3).toList();
    final lastCategoryId = session.lastCategoryId ?? 'basic';

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
          AppCard(
            gradient: true,
            padding: const EdgeInsets.all(32),
            child: Stack(
              children: [
                const Positioned.fill(child: _HeroBackdrop()),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroChip(),
                    const SizedBox(height: 12),
                    Text(
                      'Үйрөнүү башта',
                      style: AppTextStyles.heading.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Күндүк практика менен ийгиликке жетиңиз',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _HeroButton(
                      label: 'Жаңы сабак',
                      onTap: () => context.push('/categories'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
          AppButton(
            fullWidth: true,
            onPressed: () => context.push('/flashcards/$lastCategoryId'),
            child: const Text('Улантуу'),
          ),
          const SizedBox(height: 24),
          Text('Активдүү темалар', style: AppTextStyles.title),
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
                          Text(
                            topic.subtitle,
                            style: AppTextStyles.muted,
                          ),
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
                      _QuickIcon(
                        icon: Icons.flash_on,
                        color: AppColors.accent,
                      ),
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
        'Күндүк максат',
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
          Text(
            value,
            style: AppTextStyles.title.copyWith(fontSize: 20),
          ),
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
