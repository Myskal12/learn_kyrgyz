import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/user_profile_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key, this.initialLimit = 10});

  final int initialLimit;

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaderboardProvider).load(limit: widget.initialLimit);
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboard = ref.watch(leaderboardProvider);
    final profileState = ref.watch(userProfileProvider);
    final progress = ref.watch(progressProvider);
    final weeklyChallenge = progress.weeklyChallenge;
    final currentLimit = leaderboard.currentLimit;
    final entries =
        leaderboard.entries.map(_LeaderboardEntry.fromUserProfile).toList()
          ..sort((a, b) {
            final scoreCompare = b.points.compareTo(a.points);
            if (scoreCompare != 0) return scoreCompare;
            return b.accuracy.compareTo(a.accuracy);
          });
    final currentUserId = profileState.isGuest ? null : profileState.profile.id;
    final currentIndex = currentUserId == null
        ? -1
        : entries.indexWhere((entry) => entry.id == currentUserId);

    Widget content;
    if (leaderboard.isLoading && entries.isEmpty) {
      content = const AppLoadingState(
        title: 'Рейтинг жүктөлүүдө',
        message: 'Тизмедеги акыркы катышуучулар даярдалып жатат.',
      );
    } else if (leaderboard.errorMessage != null && entries.isEmpty) {
      content = AppErrorState(
        message: leaderboard.errorMessage!,
        onAction: () => ref.read(leaderboardProvider).load(force: true),
      );
    } else {
      content = ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text('Рейтинг', style: AppTextStyles.heading.copyWith(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            'Катышуучулар жана орундар',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          _LeaderboardSummaryCard(
            isGuest: profileState.isGuest,
            currentIndex: currentIndex,
            entries: entries,
            progress: progress,
          ),
          const SizedBox(height: 16),
          _SyncNotice(progress: progress),
          if (leaderboard.errorMessage != null && entries.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppSyncBanner(
              title: 'Тизме толук жаңыланган жок',
              message: leaderboard.errorMessage!,
              icon: Icons.cloud_off,
              accentColor: AppColors.accent,
              actionLabel: 'Кайра жүктөө',
              onAction: () => ref
                  .read(leaderboardProvider)
                  .load(force: true, limit: currentLimit),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Топ оюнчулар',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              AppChip(
                label: 'Көрсөтүлдү: ${entries.length}',
                variant: AppChipVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            SizedBox(
              height: 260,
              child: AppEmptyState(
                title: 'Лидерборд азырынча бош',
                message: 'Азырынча катышуучу жок.',
                icon: Icons.emoji_events_outlined,
                actionLabel: 'Кайра жүктөө',
                onAction: () => ref
                    .read(leaderboardProvider)
                    .load(force: true, limit: currentLimit),
              ),
            )
          else
            ...entries.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final highlight = _highlightForIndex(index);
              final highlightColors = _highlightColors(highlight);
              final isTop = index < 3;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ProfileAvatar(avatar: item.avatar, size: 52),
                          Positioned(
                            left: -6,
                            top: -6,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: isTop
                                    ? LinearGradient(colors: highlightColors)
                                    : null,
                                color: isTop ? null : AppColors.mutedSurface,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: isTop
                                  ? Icon(
                                      index == 0
                                          ? Icons.workspace_premium
                                          : index == 1
                                          ? Icons.emoji_events
                                          : Icons.star,
                                      color: AppColors.textDark,
                                      size: 14,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: AppTextStyles.caption.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.muted,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AppChip(
                                  label: 'Lv ${item.level}',
                                  variant: AppChipVariant.defaultChip,
                                ),
                                const SizedBox(width: 8),
                                if (item.id == currentUserId)
                                  const AppChip(
                                    label: 'Сиз',
                                    variant: AppChipVariant.primary,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.xp} XP · ${item.activity} аракет · ${item.accuracy}% тактык',
                              style: AppTextStyles.muted,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                AppChip(
                                  label: '${item.streakDays} күн серия',
                                  variant: item.streakDays >= 7
                                      ? AppChipVariant.success
                                      : AppChipVariant.accent,
                                ),
                                AppChip(
                                  label: item.rank,
                                  variant: AppChipVariant.defaultChip,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          if (!leaderboard.isExpanded && entries.isNotEmpty) ...[
            const SizedBox(height: 4),
            AppButton(
              fullWidth: true,
              variant: AppButtonVariant.outlined,
              onPressed: leaderboard.isLoading
                  ? null
                  : () => ref.read(leaderboardProvider).loadExpanded(),
              child: const Text('Алгачкы 100 оюнчуну көрсөтүү'),
            ),
          ],
          const SizedBox(height: 8),
          _WeeklyChallengeCard(challenge: weeklyChallenge),
        ],
      );
    }

    return AppShell(
      title: context.tr(ky: 'Рейтинг', en: 'Leaderboard', ru: 'Рейтинг'),
      subtitle: context.tr(
        ky: 'Жума жана сезон',
        en: 'Week and season',
        ru: 'Неделя и сезон',
      ),
      activeTab: AppTab.progress,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/progress',
      showBottomNav: false,
      child: content,
    );
  }

  _Highlight _highlightForIndex(int index) {
    switch (index) {
      case 0:
        return _Highlight.gold;
      case 1:
        return _Highlight.silver;
      case 2:
        return _Highlight.bronze;
      default:
        return _Highlight.none;
    }
  }

  List<Color> _highlightColors(_Highlight highlight) {
    switch (highlight) {
      case _Highlight.gold:
        return [AppColors.primary, const Color(0xFFF7C15C)];
      case _Highlight.silver:
        return [
          AppColors.muted.withValues(alpha: 0.3),
          AppColors.muted.withValues(alpha: 0.1),
        ];
      case _Highlight.bronze:
        return [const Color(0xFFC47A3A), const Color(0xFFE3A870)];
      case _Highlight.none:
        return [AppColors.mutedSurface, AppColors.mutedSurface];
    }
  }
}

class _LeaderboardSummaryCard extends StatelessWidget {
  const _LeaderboardSummaryCard({
    required this.isGuest,
    required this.currentIndex,
    required this.entries,
    required this.progress,
  });

  final bool isGuest;
  final int currentIndex;
  final List<_LeaderboardEntry> entries;
  final ProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    final localPoints = progress.totalXp;

    String title;
    String subtitle;
    if (isGuest) {
      title = 'Конок режиминде рейтинг жок';
      subtitle = 'Кирсеңиз, орун көрүнөт.';
    } else if (entries.isEmpty) {
      title = 'Лидерборд жаңыдан толот';
      subtitle = 'Азырынча тизмеде катышуучу жок.';
    } else if (currentIndex >= 0) {
      title = '${currentIndex + 1}-орун';
      subtitle = 'Учурдагы ордуңуз.';
    } else {
      title = 'Топ тизмеге чыга элексиз';
      subtitle = 'Дагы бир аз упай топтоңуз.';
    }

    return AppCard(
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
                    'Сиздин абал',
                    style: AppTextStyles.muted.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: AppTextStyles.heading.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              Container(
                width: 72,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(AppAssets.trophies, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _GlassChip(label: '$localPoints XP'),
              const SizedBox(width: 8),
              _GlassChip(label: '${progress.streakDays} күн катар'),
              const SizedBox(width: 8),
              _GlassChip(label: 'Lv ${progress.journeyLevel}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyChallengeCard extends StatelessWidget {
  const _WeeklyChallengeCard({required this.challenge});

  final WeeklyChallengeSnapshot challenge;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CircleIcon(icon: Icons.emoji_events, color: AppColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Апталык чакырык',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(challenge.description, style: AppTextStyles.muted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProgressBar(value: challenge.progress),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${challenge.activeDays}/${challenge.targetActiveDays} күн · ${challenge.weeklyXp}/${challenge.targetXp} XP',
                style: AppTextStyles.muted,
              ),
              Text(
                challenge.isCompleted ? 'Жабылды' : 'Улантыңыз',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SyncNotice extends StatelessWidget {
  const _SyncNotice({required this.progress});

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

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.label});

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
        style: AppTextStyles.caption.copyWith(color: Colors.white),
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
        color: color.withValues(alpha: 0.12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

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

class _LeaderboardEntry {
  const _LeaderboardEntry({
    required this.id,
    required this.name,
    required this.avatar,
    required this.points,
    required this.xp,
    required this.activity,
    required this.accuracy,
    required this.streakDays,
    required this.level,
    required this.rank,
  });

  factory _LeaderboardEntry.fromUserProfile(UserProfileModel user) {
    return _LeaderboardEntry(
      id: user.id,
      name: user.nickname,
      avatar: user.avatar,
      points: user.leaderboardScore,
      xp: user.totalXp,
      activity: user.totalSessions,
      accuracy: user.accuracy,
      streakDays: user.streakDays,
      level: user.journeyLevel,
      rank: user.journeyRank,
    );
  }

  final String id;
  final String name;
  final String avatar;
  final int points;
  final int xp;
  final int activity;
  final int accuracy;
  final int streakDays;
  final int level;
  final String rank;
}

enum _Highlight { none, gold, silver, bronze }
