import 'package:flutter/material.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Жөндөөлөр',
      subtitle: 'Окуу жана колдонмо параметрлери',
      activeTab: AppTab.profile,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text('Жөндөөлөр', style: AppTextStyles.heading.copyWith(fontSize: 28)),
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
                  value: '20 мүнөт',
                  action: const _MiniButton(label: 'Өзгөртүү'),
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
                    label: 'Иштейт',
                    variant: AppChipVariant.success,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsRow(
                  title: 'Күндөлүк эскертме',
                  value: '19:00',
                  trailing: _FakeToggle(active: true),
                ),
                const SizedBox(height: 8),
                _SettingsRow(
                  title: 'Апталык отчет',
                  value: 'Дүйшөмбү күнү',
                  trailing: _FakeToggle(active: false),
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
                  value: 'Кыргызча / English',
                  action: const _MiniButton(label: 'Өзгөртүү'),
                ),
                const SizedBox(height: 8),
                _SettingsRow(
                  title: 'Тема',
                  value: 'Жарык',
                  trailing: _FakeToggle(active: false),
                ),
                const SizedBox(height: 8),
                _SettingsRow(
                  title: 'Текст өлчөмү',
                  value: 'Орточо',
                  action: const _MiniButton(label: 'Өзгөртүү'),
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
                  value: 'Күйгүзүлгөн',
                  trailing: _FakeToggle(active: true),
                ),
                const SizedBox(height: 8),
                _SettingsRow(
                  title: 'Сыйлыктар',
                  value: 'Автоматтык',
                  trailing: const AppChip(
                    label: 'Активдүү',
                    variant: AppChipVariant.primary,
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
                  icon: Icons.calendar_month,
                  color: AppColors.muted,
                  title: 'Окуу календары',
                  subtitle: 'Жуманын пландарын алдын ала коюңуз',
                ),
                const SizedBox(height: 12),
                _SettingsRow(
                  title: 'Кийинки максат',
                  value: '6 сабак / жума',
                  action: const _MiniButton(label: 'Түзөтүү'),
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
                  onPressed: () {},
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
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
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
        if (action != null) action!,
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mutedSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _FakeToggle extends StatelessWidget {
  const _FakeToggle({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withValues(alpha: 0.3) : AppColors.mutedSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Align(
        alignment: active ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.muted.withValues(alpha: 0.4),
            shape: BoxShape.circle,
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
        color: color.withValues(alpha: 0.12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
