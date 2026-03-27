import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../profile/providers/progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final achievements = _buildAchievements(progress);
    final unlockedCount = achievements.where((item) => item.unlocked).length;
    final hasProgress = progress.totalWordsReviewed > 0;

    return AppShell(
      title: 'Прогресс',
      subtitle: 'Реалдуу жыйынтык',
      activeTab: AppTab.progress,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text('Прогресс', style: AppTextStyles.heading.copyWith(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            'Сакталган аракеттер, синхрондоштуруу жана жетишкендиктер',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          AppCard(
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
                          '${progress.streakDays} күн',
                          style: AppTextStyles.heading.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          progress.hasActivityToday
                              ? 'Бүгүн да активдүүсүз'
                              : 'Учурдагы серия',
                          style: AppTextStyles.muted.copyWith(
                            color: Colors.white70,
                          ),
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
                    _Metric(
                      label: 'Сөздөр',
                      value: progress.totalWordsMastered,
                    ),
                    _Metric(
                      label: 'Көрүүлөр',
                      value: progress.totalReviewSessions,
                    ),
                    _Metric(
                      label: 'Тактык',
                      value: progress.accuracyPercent,
                      suffix: '%',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ProgressSyncCard(progress: progress),
          const SizedBox(height: 20),
          Text(
            'Статус',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (!hasProgress)
            SizedBox(
              height: 260,
              child: AppEmptyState(
                title: 'Азырынча прогресс жок',
                message:
                    'Биринчи карточканы, сүйлөмдү же квизди өткөндөн кийин статистика ушул жерде пайда болот.',
                icon: Icons.insights_outlined,
                actionLabel: 'Биринчи сабакты ачуу',
                onAction: () => context.go('/categories'),
              ),
            )
          else
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Апталык бөлүштүрүү эсептелбейт',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Азыркы версия күндөр же мүнөттөр боюнча тарыхты сактабайт. Ошондуктан бул экран жалпы көрүлгөн сөздөрдү, тактыкты жана серияны гана чынчыл көрсөтөт.',
                    style: AppTextStyles.muted,
                  ),
                ],
              ),
            ),
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
