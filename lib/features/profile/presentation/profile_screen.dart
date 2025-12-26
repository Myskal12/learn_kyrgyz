import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/services/firebase_service.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../data/models/user_profile_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/user_profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final progress = context.watch<ProgressProvider>();
    final profileProvider = context.watch<UserProfileProvider>();
    final profile = profileProvider.profile;
    final firebase = context.read<FirebaseService>();

    final body = ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _ProfileHeader(
          profile: profile,
          isGuest: profileProvider.isGuest,
          onEdit: profileProvider.isGuest
              ? null
              : () => context.push('/settings'),
        ),
        const SizedBox(height: 20),
        _StatsGrid(progress: progress),
        const SizedBox(height: 20),
        _PreferenceButtons(),
        const SizedBox(height: 24),
        _LeaderboardPreview(firebase: firebase),
        const SizedBox(height: 24),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: auth.logged
              ? () => auth.logout()
              : () => context.push('/login'),
          child: Text(auth.logged ? 'Чыгуу' : 'Кирүү'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: () => progress.reset(),
          child: const Text('Прогрессти тазалоо'),
        ),
      ],
    );

    if (embedded) {
      return Container(
        color: AppColors.background,
        child: SafeArea(child: body),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SafeArea(child: body),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.isGuest,
    this.onEdit,
  });

  final UserProfileModel profile;
  final bool isGuest;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.accent.withValues(alpha: 0.2),
            child: Text(profile.avatar, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.nickname, style: AppTextStyles.title),
                const SizedBox(height: 4),
                Text(
                  isGuest ? 'Конок режиминде' : 'Аккаунт синхрондолгон',
                  style: AppTextStyles.muted,
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              tooltip: 'Өзгөртүү',
            ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.progress});

  final ProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        icon: Icons.menu_book_rounded,
        label: 'Сөздөр',
        value: progress.totalWordsMastered.toString(),
      ),
      _StatCard(
        icon: Icons.quiz,
        label: 'Тесттер',
        value: progress.totalReviewSessions.toString(),
      ),
      _StatCard(
        icon: Icons.local_fire_department,
        label: 'Streak',
        value: '${progress.streakDays} күн',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final width = isCompact
            ? constraints.maxWidth
            : (constraints.maxWidth - 24) / 3;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map((card) => SizedBox(width: width, child: card))
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.title),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.muted),
        ],
      ),
    );
  }
}

class _PreferenceButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeLabel = settings.isDark ? 'Theme: Dark' : 'Theme: Light';
    final directionLabel = 'Direction: ${settings.direction.label}';
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _PreferenceButton(
          icon: Icons.translate,
          label: directionLabel,
          onTap: settings.toggleDirection,
        ),
        _PreferenceButton(
          icon: settings.isDark ? Icons.dark_mode : Icons.light_mode,
          label: themeLabel,
          onTap: settings.toggleTheme,
        ),
      ],
    );
  }
}

class _PreferenceButton extends StatelessWidget {
  const _PreferenceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _LeaderboardPreview extends StatelessWidget {
  const _LeaderboardPreview({required this.firebase});

  final FirebaseService firebase;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase.fetchLeaderboard(limit: 3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data ?? const <UserProfileModel>[];
        if (data.isEmpty) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Лидерборд даярдалууда.', style: AppTextStyles.body),
            ),
          );
        }
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              ListTile(
                title: const Text('Лидерборд'),
                trailing: TextButton(
                  onPressed: () => context.push('/leaderboard'),
                  child: const Text('Баарын көрүү'),
                ),
              ),
              for (final user in data)
                ListTile(
                  leading: CircleAvatar(child: Text(user.avatar)),
                  title: Text(user.nickname),
                  subtitle: Text(
                    'Үйрөнгөн: ${user.totalMastered} | Тактык: ${user.accuracy}%',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
