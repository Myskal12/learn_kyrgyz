import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../learning/repository/words_repository.dart';
import '../../profile/providers/progress_provider.dart';
import '../providers/categories_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wordsRepo = context.read<WordsRepository>();
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('1-деңгээл', style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(
          'Негизги сөздөр жана темалар',
          style: AppTextStyles.heading.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          'Сабакты тандап, карточкаларды жана тапшырмаларды улантыңыз.',
          style: AppTextStyles.body.copyWith(color: AppColors.muted),
        ),
      ],
    );

    final content = Container(
      color: AppColors.background,
      child: SafeArea(
        child: Consumer2<CategoriesProvider, ProgressProvider>(
          builder: (context, categories, progress, _) {
            if (categories.categories.isEmpty && categories.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return RefreshIndicator(
              onRefresh: () => categories.load(force: true),
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: categories.categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [header, const SizedBox(height: 16)],
                    );
                  }
                  final lessonIndex = index - 1;
                  final category = categories.categories[lessonIndex];
                  final words = wordsRepo.getCachedWords(category.id);
                  final mastery = progress.completionForCategory(words);
                  final unlockThreshold = lessonIndex * 5;
                  final locked =
                      lessonIndex > 0 &&
                      progress.totalWordsMastered < unlockThreshold;
                  final completed = mastery >= 0.9;
                  return _LessonCard(
                    index: lessonIndex + 1,
                    title: category.title,
                    subtitle: category.description,
                    locked: locked,
                    completed: completed,
                    onTap: locked
                        ? null
                        : () => context.push('/flashcards/${category.id}'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(title: const Text('Уроктор')),
        body: content,
      );
    }

    return content;
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.index,
    required this.title,
    required this.subtitle,
    this.locked = false,
    this.completed = false,
    this.onTap,
  });

  final int index;
  final String title;
  final String subtitle;
  final bool locked;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusIcon = locked
        ? Icons.lock_outline
        : completed
        ? Icons.check_circle
        : Icons.play_arrow_rounded;
    final statusColor = locked
        ? AppColors.muted
        : completed
        ? AppColors.success
        : AppColors.primary;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: locked ? 0.6 : 1,
      child: Material(
        color: AppColors.accent.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.muted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(statusIcon, color: statusColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
