import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../categories/providers/categories_provider.dart';
import '../../learning/repository/words_repository.dart';
import '../../profile/providers/progress_provider.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesProvider>().load();
      context.read<ProgressProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoriesProvider>();
    final progress = context.watch<ProgressProvider>();
    final repo = context.read<WordsRepository>();

    final practiceItems = categories.categories.take(5).map((category) {
      final words = repo.getCachedWords(category.id);
      final mastery = progress.completionForCategory(words);
      final remaining = (words.length - (words.length * mastery))
          .clamp(0, words.length)
          .round();
      return _PracticeItem(
        title: category.title,
        subtitle: category.description,
        remaining: remaining,
        onReview: () => GoRouter.of(context).push('/flashcards/${category.id}'),
        onSentenceBuilder: () =>
            GoRouter.of(context).push('/sentence-builder/${category.id}'),
        onQuiz: () => GoRouter.of(context).push('/quiz/${category.id}'),
      );
    }).toList();

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Бүгүн кайталайбыз',
              style: AppTextStyles.heading.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              '5–10 сөз, тез текшерүү жана коротулган убакыт — максимум 10 мүнөт.',
              style: AppTextStyles.body.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            _HintCard(),
            const SizedBox(height: 20),
            if (practiceItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Категорияларды жүктөөдө... Сабактарды кошкондон кийин бул бөлүк пайда болот.',
                  style: AppTextStyles.body,
                ),
              )
            else
              ...practiceItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: item,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
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
            blurRadius: 14,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Тез практика', style: AppTextStyles.title),
          const SizedBox(height: 8),
          Text(
            'Карточкалар → сүйлөм → тест. Ар бир кадамдан кийин дароо жооп чыгат.',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PracticeAction(
                icon: Icons.visibility,
                label: 'Сөздү көрсөт',
                onTap: () => GoRouter.of(context).push('/flashcards/basic'),
              ),
              _PracticeAction(
                icon: Icons.view_week_rounded,
                label: 'Сүйлөм түзүү',
                onTap: () =>
                    GoRouter.of(context).push('/sentence-builder/basic'),
              ),
              _PracticeAction(
                icon: Icons.lightbulb,
                label: 'Подсказка',
                onTap: () => GoRouter.of(context).push('/quick-quiz'),
              ),
              _PracticeAction(
                icon: Icons.science,
                label: 'Экспресс тест',
                onTap: () => GoRouter.of(context).push('/quick-quiz'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PracticeAction extends StatelessWidget {
  const _PracticeAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.accent.withValues(alpha: 0.2),
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _PracticeItem extends StatelessWidget {
  const _PracticeItem({
    required this.title,
    required this.subtitle,
    required this.remaining,
    required this.onReview,
    required this.onSentenceBuilder,
    required this.onQuiz,
  });

  final String title;
  final String subtitle;
  final int remaining;
  final VoidCallback onReview;
  final VoidCallback onSentenceBuilder;
  final VoidCallback onQuiz;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Text(
            remaining > 0
                ? '$remaining сөздү кайтала'
                : 'Бул сабак даяр. Кайра тест тапшыргыла.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: onReview,
                  child: const Text('Карточкалар'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: onQuiz,
                  child: const Text('Тез тест'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onSentenceBuilder,
              icon: const Icon(Icons.view_week_rounded),
              label: const Text('Сүйлөм түзүү'),
            ),
          ),
        ],
      ),
    );
  }
}
