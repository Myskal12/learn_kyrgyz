import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../profile/providers/progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final weeklyData = [
      _WeekData(day: 'Дш', minutes: 15, target: 20),
      _WeekData(day: 'Шш', minutes: 25, target: 20),
      _WeekData(day: 'Шр', minutes: 18, target: 20),
      _WeekData(day: 'Бш', minutes: 30, target: 20),
      _WeekData(day: 'Жм', minutes: 22, target: 20),
      _WeekData(day: 'Иш', minutes: 20, target: 20),
      _WeekData(day: 'Жк', minutes: 12, target: 20),
    ];

    final achievements = [
      _Achievement(
        title: '7 күн',
        description: '7 күн катар',
        colors: [AppColors.accent, const Color(0xFFB71C1C)],
        icon: Icons.local_fire_department,
        completed: true,
      ),
      _Achievement(
        title: '100 сөз',
        description: '100 сөз үйрөндү',
        colors: [AppColors.primary, const Color(0xFFF7C15C)],
        icon: Icons.gps_fixed,
        completed: true,
      ),
      _Achievement(
        title: 'Биринчи сабак',
        description: 'Биринчи сабакты аяктады',
        colors: [const Color(0xFF1976D2), const Color(0xFF1565C0)],
        icon: Icons.emoji_events,
        completed: true,
      ),
      _Achievement(
        title: '30 күн',
        description: '30 күн катар',
        colors: [AppColors.mutedSurface, AppColors.mutedSurface],
        icon: Icons.local_fire_department,
        completed: false,
      ),
    ];

    final maxMinutes = weeklyData.fold<int>(
      20,
      (current, data) => data.minutes > current ? data.minutes : current,
    );

    return AppShell(
      title: 'Прогресс',
      subtitle: 'Апталык жыйынтык',
      activeTab: AppTab.progress,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text('Прогресс', style: AppTextStyles.heading.copyWith(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            'Сиздин ийгилик жолуӊуз',
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
                          'Учурдагы серия',
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
                    _Metric(label: 'Сөздөр', value: progress.totalWordsMastered),
                    _Metric(
                      label: 'Сабактар',
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Жумалык активдүүлүк',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const AppChip(
                label: 'Максат: 20 мүн',
                variant: AppChipVariant.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: weeklyData.map((data) {
                      return Expanded(
                        child: _WeekBar(data: data, maxMinutes: maxMinutes),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: AppColors.border),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Бул жумада жалпы:', style: AppTextStyles.muted),
                    Text(
                      '${weeklyData.fold<int>(0, (sum, d) => sum + d.minutes)} мүнөт',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.trending_up, color: AppColors.muted),
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
                  (achievement) => Opacity(
                    opacity: achievement.completed ? 1 : 0.5,
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
                            child: Icon(
                              achievement.icon,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            achievement.title,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
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
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
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
        Text(
          label,
          style: AppTextStyles.muted.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _WeekData {
  _WeekData({required this.day, required this.minutes, required this.target});

  final String day;
  final int minutes;
  final int target;
}

class _WeekBar extends StatelessWidget {
  const _WeekBar({required this.data, required this.maxMinutes});

  final _WeekData data;
  final int maxMinutes;

  @override
  Widget build(BuildContext context) {
    final heightFactor =
        (data.minutes / maxMinutes).clamp(0.0, 1.0).toDouble();
    final metGoal = data.minutes >= data.target;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              widthFactor: 0.6,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: metGoal
                        ? [const Color(0xFF388E3C), const Color(0xFF4CAF50)]
                        : [AppColors.primary, const Color(0xFFF7C15C)],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          data.day,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _Achievement {
  _Achievement({
    required this.title,
    required this.description,
    required this.colors,
    required this.icon,
    required this.completed,
  });

  final String title;
  final String description;
  final List<Color> colors;
  final IconData icon;
  final bool completed;
}
