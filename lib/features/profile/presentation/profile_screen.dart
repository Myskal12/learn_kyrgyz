import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/adaptive_panel_grid.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../auth/providers/auth_provider.dart';
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
    final weeklyChallenge = progress.weeklyChallenge;
    final auth = ref.watch(authProvider);
    final rankingTitle = profileProvider.isGuest
        ? 'Конок режиминде рейтинг жок'
        : 'Рейтингди ачыңыз';
    final rankingSubtitle = profileProvider.isGuest
        ? 'Кирсеңиз, орун көрүнөт.'
        : 'Ордуңузду ушул жерден көрөсүз.';

    return AppShell(
      title: context.tr(ky: 'Профиль', en: 'Profile', ru: 'Профиль'),
      subtitle: context.tr(
        ky: 'Жеке маалымат',
        en: 'Personal overview',
        ru: 'Личный обзор',
      ),
      activeTab: AppTab.profile,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text(
            context.tr(ky: 'Профиль', en: 'Profile', ru: 'Профиль'),
            style: AppTextStyles.heading.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr(
              ky: 'Жеке баракчаңыз',
              en: 'Your personal page',
              ru: 'Ваша личная страница',
            ),
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
                  children: [
                    ProfileAvatar(avatar: profile.avatar),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.nickname,
                            style: AppTextStyles.title.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lv ${progress.journeyLevel} · ${progress.journeyRank}',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppChip(
                      label: '${progress.streakDays} күн',
                      variant: AppChipVariant.defaultChip,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroStatPill(
                      value: '${progress.totalXp} XP',
                      label: 'Жалпы күч',
                    ),
                    _HeroStatPill(
                      value: '${progress.completedDailyQuestsCount}/3',
                      label: 'Күндүк квест',
                    ),
                    _HeroStatPill(
                      value:
                          '${weeklyChallenge.activeDays}/${weeklyChallenge.targetActiveDays}',
                      label: 'Апталык ритм',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!profileProvider.isGuest && auth.requiresEmailVerification) ...[
            AppCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: AppColors.accent.withValues(alpha: 0.08),
              borderColor: AppColors.accent.withValues(alpha: 0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email али ырастала элек',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Бул милдеттүү тоскоолдук эмес. Кааласаңыз азыр, болбосо кийин жөндөөлөрдөн бүтүрөсүз.',
                    style: AppTextStyles.muted,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    variant: AppButtonVariant.outlined,
                    fullWidth: true,
                    onPressed: () =>
                        context.push('/verify-email?returnTo=/profile'),
                    child: const Text('Email ырастоо'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            context.tr(ky: 'Статистика', en: 'Stats', ru: 'Статистика'),
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
              _StatCard(value: '${progress.totalXp}', label: 'XP'),
              _StatCard(value: progress.streakDays.toString(), label: 'Серия'),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: AppColors.accent.withValues(alpha: 0.06),
            borderColor: AppColors.accent.withValues(alpha: 0.14),
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
                            weeklyChallenge.title,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weeklyChallenge.description,
                            style: AppTextStyles.muted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppChip(
                      label: weeklyChallenge.isCompleted ? 'Даяр' : 'Жумада',
                      variant: weeklyChallenge.isCompleted
                          ? AppChipVariant.success
                          : AppChipVariant.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ProfileProgressBar(value: weeklyChallenge.progress),
                const SizedBox(height: 10),
                Text(
                  '${weeklyChallenge.activeDays}/${weeklyChallenge.targetActiveDays} күн · ${weeklyChallenge.weeklyXp}/${weeklyChallenge.targetXp} XP',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 12),
                AppButton(
                  variant: AppButtonVariant.outlined,
                  fullWidth: true,
                  onPressed: () => context.push('/leaderboard'),
                  child: const Text('Рейтинг жана апта барагы'),
                ),
              ],
            ),
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
            context.tr(ky: 'Рейтинг', en: 'Leaderboard', ru: 'Рейтинг'),
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
            context.tr(
              ky: 'Аккаунт жана купуялык',
              en: 'Account and privacy',
              ru: 'Аккаунт и приватность',
            ),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            onTap: () => context.push('/settings'),
            child: Row(
              children: [
                _CircleIcon(
                  icon: Icons.shield_outlined,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Профиль, email жана жөндөөлөр',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Жеке маалымат, тема, окуу багыты жана укуктук документтер ушул жерде.',
                        style: AppTextStyles.muted,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
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

class _HeroStatPill extends StatelessWidget {
  const _HeroStatPill({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
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

class _ProfileProgressBar extends StatelessWidget {
  const _ProfileProgressBar({required this.value});

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
