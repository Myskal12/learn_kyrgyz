import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/learning_direction_provider.dart';
import '../../../app/providers/theme_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../shared/widgets/adaptive_panel_grid.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../providers/progress_provider.dart';
import '../providers/user_profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileProvider = ref.watch(userProfileProvider);
    final profile = profileProvider.profile;
    final progress = ref.watch(progressProvider);
    final direction = ref.watch(learningDirectionProvider);
    final themeMode = ref.watch(themeModeProvider);
    final rankingTitle = profileProvider.isGuest
        ? 'Конок режиминде рейтинг жок'
        : 'Рейтингди ачыңыз';
    final rankingSubtitle = profileProvider.isGuest
        ? 'Кирсеңиз, орун көрүнөт.'
        : 'Ордуңузду ушул жерден көрөсүз.';

    final themeLabel = themeMode == ThemeMode.dark
        ? 'Караңгы'
        : themeMode == ThemeMode.light
        ? 'Жарык'
        : 'Авто';

    return AppShell(
      title: 'Профиль',
      subtitle: 'Жеке маалымат',
      activeTab: AppTab.profile,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text('Профиль', style: AppTextStyles.heading.copyWith(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            'Жеке баракчаңыз',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    profile.avatar,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.nickname, style: AppTextStyles.title),
                      const SizedBox(height: 4),
                      Text(
                        '${progress.level} · ${progress.streakDays} күн катар',
                        style: AppTextStyles.muted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Статистика',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          AdaptivePanelGrid(
            maxColumns: 3,
            minItemWidth: 92,
            children: [
              _StatCard(
                value: progress.totalWordsMastered.toString(),
                label: 'Сөздөр',
              ),
              _StatCard(
                value: progress.totalReviewSessions.toString(),
                label: 'Көрүүлөр',
              ),
              _StatCard(value: progress.streakDays.toString(), label: 'Күн'),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: AppColors.primary.withValues(alpha: 0.05),
            borderColor: AppColors.primary.withValues(alpha: 0.18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Окуу snapshot',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppChip(
                      label: '${progress.reviewDueWordsCount} кайталоо',
                      variant: progress.reviewDueWordsCount > 0
                          ? AppChipVariant.accent
                          : AppChipVariant.success,
                    ),
                    AppChip(
                      label: '${progress.weakWordsCount} алсыз сөз',
                      variant: AppChipVariant.defaultChip,
                    ),
                    AppChip(
                      label: progress.nextMilestoneLabel,
                      variant: AppChipVariant.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  progress.reviewDueWordsCount > 0
                      ? 'Адегенде кайталоону жабыңыз.'
                      : progress.wordsToNextMilestone > 0
                      ? 'Дагы ${progress.wordsToNextMilestone} сөз калды.'
                      : 'Темпти кармап туруңуз.',
                  style: AppTextStyles.muted,
                ),
                const SizedBox(height: 12),
                AppButton(
                  variant: AppButtonVariant.outlined,
                  fullWidth: true,
                  onPressed: () => context.push('/progress'),
                  child: const Text('Толук прогрессти көрүү'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _ProfileSyncNotice(progress: progress),
          const SizedBox(height: 20),
          Text(
            'Рейтинг',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            onTap: () => context.push('/leaderboard'),
            child: Row(
              children: [
                _CircleIcon(icon: Icons.emoji_events, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rankingTitle,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(rankingSubtitle, style: AppTextStyles.muted),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Параметрлер',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _SettingCard(
            icon: Icons.translate,
            iconColor: AppColors.primary,
            title: 'Көнүгүү багыты',
            subtitle: direction.helperText,
            actionLabel: 'Жөндөө',
            onAction: () => context.push('/settings'),
          ),
          const SizedBox(height: 12),
          _SettingCard(
            icon: Icons.sunny,
            iconColor: AppColors.accent,
            title: 'Тема',
            subtitle: themeLabel,
            actionLabel: 'Өзгөртүү',
            onAction: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
          const SizedBox(height: 20),
          AppButton(
            variant: AppButtonVariant.outlined,
            fullWidth: true,
            onPressed: () => context.push('/settings'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.settings, size: 18),
                SizedBox(width: 8),
                Text('Жөндөөлөрдү ачуу'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSyncNotice extends StatelessWidget {
  const _ProfileSyncNotice({required this.progress});

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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.title.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.muted),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.mutedSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CircleIcon(icon: icon, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.muted),
                  ],
                ),
              ),
            ],
          );

          if (constraints.maxWidth < 280) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 12),
                _MiniAction(label: actionLabel, onTap: onAction),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              const SizedBox(width: 12),
              _MiniAction(label: actionLabel, onTap: onAction),
            ],
          );
        },
      ),
    );
  }
}
