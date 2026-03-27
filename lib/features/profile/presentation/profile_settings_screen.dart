import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/learning_direction_provider.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../app/providers/theme_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../providers/progress_provider.dart';
import '../providers/user_profile_provider.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final direction = ref.watch(learningDirectionProvider);
    final onboarding = ref.watch(onboardingProvider);
    final themeMode = ref.watch(themeModeProvider);

    final themeLabel = themeMode == ThemeMode.dark
        ? 'Караңгы'
        : themeMode == ThemeMode.light
        ? 'Жарык'
        : 'Авто';

    return AppShell(
      title: 'Жөндөөлөр',
      subtitle: 'Окуу жана колдонмо параметрлери',
      activeTab: AppTab.profile,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/profile',
      showBottomNav: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text(
            'Жөндөөлөр',
            style: AppTextStyles.heading.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 6),
          Text(
            'Окуу, эскертме жана колдонмо параметрлери',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsHeader(
                  icon: Icons.flag,
                  color: AppColors.primary,
                  title: 'Окуу максаты',
                  subtitle: 'Күндүк темпти өзүңүзгө тууралаңыз',
                ),
                const SizedBox(height: 12),
                _SettingsRow(
                  title: 'Күндүк максат',
                  value: '${onboarding.dailyGoalMinutes} мүнөт',
                  action: _InlineAction(
                    label: 'Өзгөртүү',
                    onTap: () => _showDailyGoalPicker(context, ref),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsHeader(
                  icon: Icons.notifications,
                  color: AppColors.accent,
                  title: 'Эскертмелер',
                  subtitle: 'Окуу эскертмелерин башкаруу',
                  trailing: const AppChip(
                    label: 'Жакында',
                    variant: AppChipVariant.defaultChip,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsRow(
                  title: 'Күндөлүк эскертме',
                  value:
                      'Firebase Cloud Messaging азырынча туташтырылган эмес.',
                ),
                const SizedBox(height: 8),
                _SettingsRow(
                  title: 'Апталык отчет',
                  value: 'Push жана email отчеттор кийинки итерацияда кошулат.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsHeader(
                  icon: Icons.language,
                  color: AppColors.primary,
                  title: 'Тил жана көрүнүш',
                  subtitle: 'Колдонмонун көрүнүшүн ылайыктаңыз',
                ),
                const SizedBox(height: 12),
                _SettingsRow(
                  title: 'Тил багыты',
                  value: direction.label,
                  action: _InlineAction(
                    label: 'Өзгөртүү',
                    onTap: () => ref
                        .read(learningDirectionProvider.notifier)
                        .toggleDirection(),
                  ),
                ),
                const SizedBox(height: 8),
                _SettingsRow(
                  title: 'Тема',
                  value: themeLabel,
                  action: _InlineAction(
                    label: 'Алмаштыруу',
                    onTap: () =>
                        ref.read(themeModeProvider.notifier).toggleTheme(),
                  ),
                ),
                const SizedBox(height: 8),
                _SettingsRow(
                  title: 'Текст өлчөмү',
                  value: 'Орточо',
                  trailing: const AppChip(
                    label: 'Жакында',
                    variant: AppChipVariant.defaultChip,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsHeader(
                  icon: Icons.shield,
                  color: const Color(0xFF1976D2),
                  title: 'Коомчулук жана купуялык',
                  subtitle: 'Рейтинг жана профилди башкаруу',
                ),
                const SizedBox(height: 12),
                _SettingsRow(
                  title: 'Рейтингде көрүнүү',
                  value:
                      'Профиль Firebase рейтингине жалпы статистика менен чыгат.',
                ),
                const SizedBox(height: 8),
                _SettingsRow(
                  title: 'Сыйлыктар',
                  value: 'Жетишкендиктер автоматтык эсептелет.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsHeader(
                  icon: Icons.calendar_month,
                  color: AppColors.muted,
                  title: 'Окуу календары',
                  subtitle: 'Жуманын пландарын алдын ала коюңуз',
                ),
                const SizedBox(height: 12),
                _SettingsRow(
                  title: 'Кийинки максат',
                  value: '6 сабак / жума',
                  action: _InlineAction(
                    label: 'Ачуу',
                    onTap: () => context.push('/study-plan'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsHeader(
                  icon: Icons.delete_forever,
                  color: AppColors.accent,
                  title: 'Кооптуу бөлүм',
                  subtitle: 'Бул аракеттерди артка кайтаруу мүмкүн эмес',
                ),
                const SizedBox(height: 12),
                AppButton(
                  variant: AppButtonVariant.danger,
                  fullWidth: true,
                  onPressed: () => _confirmResetProgress(context, ref),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.warning, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Прогрессти өчүрүү'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmResetProgress(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Прогрессти өчүрөсүзбү?'),
          content: const Text(
            'Бул аракеттен кийин статистика, streak жана үйрөнүлгөн сөздөр тазаланат.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Жокко чыгаруу'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Өчүрүү'),
            ),
          ],
        );
      },
    );

    if (approved != true || !context.mounted) return;
    await ref.read(progressProvider).reset();
    await ref.read(userProfileProvider).refresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Прогресс тазаланды.')));
  }

  Future<void> _showDailyGoalPicker(BuildContext context, WidgetRef ref) async {
    final current = ref.read(onboardingProvider).dailyGoalMinutes;
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text('Күндүк максат', style: AppTextStyles.title),
              const SizedBox(height: 8),
              Text(
                'Сизге ыңгайлуу темпти тандаңыз.',
                style: AppTextStyles.muted,
              ),
              const SizedBox(height: 16),
              ...const [10, 20, 30].map((minutes) {
                final active = current == minutes;
                return ListTile(
                  leading: Icon(
                    active ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: active ? AppColors.primary : AppColors.muted,
                  ),
                  title: Text('$minutes мүнөт'),
                  onTap: () => Navigator.of(context).pop(minutes),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected == null) return;
    await ref.read(onboardingProvider).setDailyGoalMinutes(selected);
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CircleIcon(icon: icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.muted),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.value,
    this.action,
    this.trailing,
  });

  final String title;
  final String value;
  final Widget? action;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(value, style: AppTextStyles.muted),
            ],
          ),
        ),
        if (action != null) ...[const SizedBox(width: 12), action!],
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class _InlineAction extends StatelessWidget {
  const _InlineAction({required this.label, required this.onTap});

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
