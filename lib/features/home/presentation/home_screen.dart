import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../categories/providers/categories_provider.dart';
import '../../learning/repository/words_repository.dart';
import '../../profile/providers/progress_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesProvider>().load();
      context.read<ProgressProvider>().load();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordsRepo = context.read<WordsRepository>();
    return Scaffold(
      body: SafeArea(
        child: Consumer2<CategoriesProvider, ProgressProvider>(
          builder: (context, categories, progress, _) {
            final topCategory = categories.categories.isNotEmpty ? categories.categories.first : null;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LearnKyrgyz', style: AppTextStyles.heading.copyWith(color: AppColors.primary)),
                        const SizedBox(height: 6),
                        Text('Кыска сабактар, карточкалар жана квиздер менен күн сайын өсүң.', style: AppTextStyles.body.copyWith(color: AppColors.muted)),
                        const SizedBox(height: 18),
_HeroCard(animation: _controller),
                        const SizedBox(height: 18),
                        _StatsRow(progress: progress),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => context.push('/categories'),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Баштоо'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: topCategory == null ? null : () => context.push('/quiz/${topCategory.id}'),
                                icon: const Icon(Icons.question_answer),
                                label: const Text('Тез квиз'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('????????? ???????', style: AppTextStyles.title),
                        TextButton(
                          onPressed: () => context.push('/categories'),
                          child: const Text('Баарын көрүү'),
                        )
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(left: 20, bottom: 20),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 160,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: categories.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.categories.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final category = categories.categories[index];
                                  final words = wordsRepo.getCachedWords(category.id);
                                  final percent = progress.completionForCategory(words);
                                  return _CategoryChip(
                                    title: category.title,
                                    description: category.description,
                                    progress: percent,
                                    onTap: () => context.push('/flashcards/${category.id}'),
                                    onQuiz: () => context.push('/quiz/${category.id}'),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('??????? ????????', style: AppTextStyles.title),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            _QuickLink(label: 'Жетишкендиктер', icon: Icons.emoji_events, onTap: () => context.push('/achievements')),
                            _QuickLink(label: 'Күнүмдүк план', icon: Icons.calendar_today, onTap: () => context.push('/study-plan')),
                            _QuickLink(label: 'Ресурстар', icon: Icons.bookmarks, onTap: () => context.push('/resources')),
                            _QuickLink(label: 'Тез квиз', icon: Icons.flash_on, onTap: () => context.push('/quick-quiz')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.lock_open_rounded),
                label: const Text('Кирүү'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/profile'),
                icon: const Icon(Icons.person),
                label: const Text('Профиль'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final slide = (animation.value - 0.5) * 8;
        return Transform.translate(
          offset: Offset(slide, -slide / 2),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 8))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Карточкалар + квиз + үн коштолот', style: AppTextStyles.body.copyWith(color: Colors.white70)),
                      const SizedBox(height: 10),
                      Text('Жеңил башта, күн сайын практика кыл!', style: AppTextStyles.title.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.auto_stories, color: Colors.white, size: 56),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.progress});
  final ProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(label: 'Үйрөнүлгөн сөздөр', value: progress.totalWordsMastered.toString(), icon: Icons.star_rounded),
      _StatCard(label: 'Кайталоо сессиялары', value: progress.totalReviewSessions.toString(), icon: Icons.refresh_rounded),
      _StatCard(label: 'Деңгээл', value: progress.level, icon: Icons.trending_up_rounded),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 8),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 8),
              cards[2],
            ],
          );
        }
        return Row(
          children: cards.map((c) => Expanded(child: c)).toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.muted.copyWith(fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: AppTextStyles.title),
            ],
          )
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.title,
    required this.description,
    required this.progress,
    required this.onTap,
    required this.onQuiz,
  });

  final String title;
  final String description;
  final double progress;
  final VoidCallback onTap;
  final VoidCallback onQuiz;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.title),
            const SizedBox(height: 6),
            Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.muted),
            const Spacer(),
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.bg,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
            const SizedBox(height: 6),
            Text('${(progress * 100).round()}% аяктады', style: AppTextStyles.muted),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onQuiz,
                    child: const Text('Квиз', style: TextStyle(fontSize: 13)),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(label),
      onPressed: onTap,
      shape: StadiumBorder(side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2))),
    );
  }
}
