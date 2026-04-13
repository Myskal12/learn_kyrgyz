import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/profile_avatar.dart';
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
    final auth = ref.watch(authProvider);

    return AppShell(
      title: context.tr(ky: 'Профиль', en: 'Profile', ru: 'Профиль'),
      subtitle: context.tr(
        ky: 'Жеке маалымат',
        en: 'Personal overview',
        ru: 'Личный обзор',
      ),
      activeTab: AppTab.profile,
      showTopNav: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        children: [
          _ProfileHero(
            nickname: profile.nickname,
            avatar: profile.avatar,
            rank: progress.journeyRankOf(context),
            level: progress.journeyLevel,
            streakDays: progress.streakDays,
          ),
          const SizedBox(height: 12),
          _StatsGrid(
            streak: progress.streakDays,
            totalXp: progress.totalXp,
            lessons: progress.totalWordsMastered,
            rankIndex: profileProvider.isGuest
                ? null
                : '#${progress.journeyLevel}',
          ),
          if (!profileProvider.isGuest && auth.requiresEmailVerification) ...[
            const SizedBox(height: 12),
            _ProfileStatusBanner(
              title: context.tr(
                ky: 'Email али ырастала элек',
                en: 'Email is not verified yet',
                ru: 'Email еще не подтвержден',
              ),
              message: context.tr(
                ky: 'Кааласаңыз азыр бүтүрүп коюңуз. Бул кадамды кийин жөндөөлөрдөн да ачасыз.',
                en: 'You can finish this now, or complete it later from settings.',
                ru: 'Можно завершить это сейчас или позже в настройках.',
              ),
              icon: Icons.mark_email_unread_outlined,
              accentColor: AppColors.accent,
              actionLabel: context.tr(
                ky: 'Email ырастоо',
                en: 'Verify email',
                ru: 'Подтвердить email',
              ),
              onAction: () => context.push('/verify-email?returnTo=/profile'),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            context.tr(ky: 'Жөндөөлөр', en: 'Settings', ru: 'Настройки'),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: context.tr(
                    ky: 'Профилди оңдоо',
                    en: 'Edit profile',
                    ru: 'Редактировать профиль',
                  ),
                  subtitle: context.tr(
                    ky: 'Аватар, аккаунт жана email башкаруу',
                    en: 'Manage avatar, account and email',
                    ru: 'Управление аватаром, аккаунтом и email',
                  ),
                  onTap: () => context.push('/settings/profile'),
                ),
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  title: context.tr(
                    ky: 'Коопсуздук жана купуялык',
                    en: 'Security and privacy',
                    ru: 'Безопасность и приватность',
                  ),
                  subtitle: context.tr(
                    ky: 'Купуялык документтери жана маанилүү аракеттер',
                    en: 'Privacy docs and critical actions',
                    ru: 'Документы приватности и важные действия',
                  ),
                  onTap: () => context.push('/settings/security'),
                ),
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  title: context.tr(
                    ky: 'Интерфейс',
                    en: 'Interface',
                    ru: 'Интерфейс',
                  ),
                  subtitle: context.tr(
                    ky: 'Тема жана тил',
                    en: 'Theme and language',
                    ru: 'Тема и язык',
                  ),
                  onTap: () => context.push('/settings/interface'),
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ProfileSyncNotice(progress: progress),
          const SizedBox(height: 12),
          AppButton(
            fullWidth: true,
            variant: profileProvider.isGuest
                ? AppButtonVariant.primary
                : AppButtonVariant.outlined,
            onPressed: () async {
              if (profileProvider.isGuest) {
                context.go('/login');
                return;
              }
              await ref.read(authProvider).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              profileProvider.isGuest
                  ? context.tr(ky: 'Кирүү', en: 'Sign in', ru: 'Войти')
                  : context.tr(ky: 'Чыгуу', en: 'Log out', ru: 'Выйти'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.nickname,
    required this.avatar,
    required this.rank,
    required this.level,
    required this.streakDays,
  });

  final String nickname;
  final String avatar;
  final String rank;
  final int level;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color.lerp(AppColors.primary, AppColors.accent, 0.25)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileAvatar(avatar: avatar, size: 80),
          const SizedBox(height: 10),
          Text(
            nickname,
            style: AppTextStyles.title.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Lv $level · $rank',
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              context.tr(
                ky: '$streakDays күндүк серия',
                en: '$streakDays day streak',
                ru: 'Серия $streakDays дней',
              ),
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.streak,
    required this.totalXp,
    required this.lessons,
    required this.rankIndex,
  });

  final int streak;
  final int totalXp;
  final int lessons;
  final String? rankIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.9,
        children: [
          _StatItem(
            icon: Icons.local_fire_department,
            label: context.tr(ky: 'Серия', en: 'Streak', ru: 'Серия'),
            value: '$streak',
            iconColor: AppColors.accent,
          ),
          _StatItem(
            icon: Icons.workspace_premium,
            label: context.tr(ky: 'XP', en: 'XP', ru: 'XP'),
            value: '$totalXp',
            iconColor: AppColors.primary,
          ),
          _StatItem(
            icon: Icons.menu_book,
            label: context.tr(ky: 'Сөздөр', en: 'Words', ru: 'Слова'),
            value: '$lessons',
            iconColor: AppColors.success,
          ),
          _StatItem(
            icon: Icons.emoji_events,
            label: context.tr(ky: 'Ранг', en: 'Rank', ru: 'Ранг'),
            value:
                rankIndex ?? context.tr(ky: 'Конок', en: 'Guest', ru: 'Гость'),
            iconColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mutedSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: AppColors.border))
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.mutedSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: AppColors.muted),
            ),
            const SizedBox(width: 10),
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
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
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
        return _ProfileStatusBanner(
          title: progress.syncTitleOf(context),
          message: progress.syncSubtitleOf(context),
          icon: Icons.save_outlined,
          accentColor: AppColors.primary,
        );
      case ProgressSyncState.pending:
      case ProgressSyncState.syncing:
        return _ProfileStatusBanner(
          title: progress.syncTitleOf(context),
          message: progress.syncSubtitleOf(context),
          icon: Icons.sync,
          accentColor: AppColors.accent,
        );
      case ProgressSyncState.synced:
        return _ProfileStatusBanner(
          title: progress.syncTitleOf(context),
          message: progress.syncSubtitleOf(context),
          icon: Icons.cloud_done,
          accentColor: AppColors.success,
        );
      case ProgressSyncState.failed:
        return _ProfileStatusBanner(
          title: progress.syncTitleOf(context),
          message: progress.syncSubtitleOf(context),
          icon: Icons.cloud_off,
          accentColor: AppColors.accent,
          actionLabel: context.tr(
            ky: 'Кайра синк',
            en: 'Retry sync',
            ru: 'Повторить синхронизацию',
          ),
          onAction: progress.canRetrySync ? progress.retrySync : null,
        );
    }
  }
}

class _ProfileStatusBanner extends StatelessWidget {
  const _ProfileStatusBanner({
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final hasAction = actionLabel != null && onAction != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.14),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 19, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(message, style: AppTextStyles.muted),
                  ],
                ),
              ),
            ],
          ),
          if (hasAction) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withValues(alpha: 0.94),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
