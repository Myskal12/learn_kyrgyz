import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../learning/repository/words_repository.dart';
import '../../profile/providers/progress_provider.dart';
import '../providers/categories_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

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
    return Scaffold(
      body: SafeArea(
        child: Consumer2<CategoriesProvider, ProgressProvider>(
          builder: (context, categories, progress, _) {
            return RefreshIndicator(
              onRefresh: categories.load,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    title: Text('Категориялар', style: AppTextStyles.title),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.person),
                        onPressed: () => context.push('/profile'),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Text(
                        'Ар бир темадагы сөздөрдү бүтүрүп, жетишкендигиңди байкап тур!',
                        style: AppTextStyles.body.copyWith(color: AppColors.muted),
                      ),
                    ),
                  ),
                  if (categories.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: .9,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = categories.categories[index];
                            final words = wordsRepo.getCachedWords(category.id);
                            final mastery = progress.completionForCategory(words);
                            final exposure = progress.exposureForCategory(words);
                            return _CategoryCard(
                              title: category.title,
                              description: category.description,
                              progress: mastery,
                              exposure: exposure,
                              wordsCount: category.wordsCount,
                              onTap: () => context.push('/flashcards/${category.id}'),
                              onQuiz: () => context.push('/quiz/${category.id}'),
                            );
                          },
                          childCount: categories.categories.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.description,
    required this.progress,
    required this.exposure,
    required this.wordsCount,
    required this.onTap,
    required this.onQuiz,
  });

  final String title;
  final String description;
  final double progress;
  final double exposure;
  final int wordsCount;
  final VoidCallback onTap;
  final VoidCallback onQuiz;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                child: Text(title.isNotEmpty ? title[0] : '?', style: AppTextStyles.title),
              ),
              const SizedBox(height: 12),
              Text(title, style: AppTextStyles.title),
              const SizedBox(height: 4),
              Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.muted),
              const Spacer(),
              Text('$wordsCount сөз', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _ProgressLabel(label: 'Даяр', percent: progress),
              _ProgressLabel(label: 'Көргөн', percent: exposure, color: AppColors.warning),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onTap,
                      child: const Text('Карточка'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onQuiz,
                    icon: const Icon(Icons.quiz),
                    tooltip: 'Квиз',
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressLabel extends StatelessWidget {
  const _ProgressLabel({
    required this.label,
    required this.percent,
    this.color = AppColors.accent,
  });

  final String label;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.muted),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: percent,
            backgroundColor: AppColors.bg,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 2),
        Text('${(percent * 100).round()}%', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
