import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../categories/providers/categories_provider.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final firstCategoryId =
        categories.categories.isNotEmpty ? categories.categories.first.id : 'basic';

    return AppShell(
      title: 'Практика',
      subtitle: 'Көнүгүүлөр жана тесттер',
      activeTab: AppTab.practice,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text(
            'Практика',
            style: AppTextStyles.heading.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            'Билимиңизди бекемдеп, күн сайын активдүү болуңуз',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.all(20),
            backgroundColor: AppColors.primary.withValues(alpha: 0.05),
            borderColor: AppColors.primary.withValues(alpha: 0.2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CircleIcon(
                  icon: Icons.flash_on,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Тез практика',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '5-10 мүнөт менен күндүк максатыңызга жакындайсыз',
                        style: AppTextStyles.muted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton(
                size: AppButtonSize.sm,
                onPressed: () => context.push('/flashcards/$firstCategoryId'),
                child: const Text('Карточкалар'),
              ),
              AppButton(
                size: AppButtonSize.sm,
                variant: AppButtonVariant.outlined,
                onPressed: () =>
                    context.push('/sentence-builder/$firstCategoryId'),
                child: const Text('Сүйлөм түзүү'),
              ),
              AppButton(
                size: AppButtonSize.sm,
                variant: AppButtonVariant.accent,
                onPressed: () => context.push('/quiz/$firstCategoryId'),
                child: const Text('Тез квиз'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _PracticeCard(
            title: 'Жаңы сөздөр',
            subtitle: 'Бүгүнкү 15 жаңы сөз',
            icon: Icons.menu_book,
            colors: [AppColors.primary, const Color(0xFFF7C15C)],
            onPrimary: () => context.push('/flashcards/$firstCategoryId'),
            onSecondary: () => context.push('/quiz/$firstCategoryId'),
          ),
          const SizedBox(height: 16),
          _PracticeCard(
            title: 'Грамматика',
            subtitle: 'Этиштердин келер чагы',
            icon: Icons.gps_fixed,
            colors: [AppColors.accent, const Color(0xFFB71C1C)],
            onPrimary: () => context.push('/flashcards/$firstCategoryId'),
            onSecondary: () => context.push('/quiz/$firstCategoryId'),
          ),
          const SizedBox(height: 16),
          _PracticeCard(
            title: 'Сүйлөмдөр',
            subtitle: 'Күндүк сүйлөмдөрдү түзүү',
            icon: Icons.flash_on,
            colors: [const Color(0xFF1976D2), const Color(0xFF1565C0)],
            primaryLabel: 'Сүйлөм түзүү',
            onPrimary: () => context.push('/sentence-builder/$firstCategoryId'),
            secondaryLabel: null,
            onSecondary: null,
          ),
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

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onPrimary,
    this.onSecondary,
    this.primaryLabel,
    this.secondaryLabel,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;
  final String? primaryLabel;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
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
                    const SizedBox(height: 6),
                    Text(subtitle, style: AppTextStyles.muted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  size: AppButtonSize.sm,
                  fullWidth: true,
                  onPressed: onPrimary,
                  child: Text(primaryLabel ?? 'Карточкалар'),
                ),
              ),
              if (onSecondary != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    size: AppButtonSize.sm,
                    variant: AppButtonVariant.outlined,
                    fullWidth: true,
                    onPressed: onSecondary,
                    child: Text(secondaryLabel ?? 'Тез тест'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
