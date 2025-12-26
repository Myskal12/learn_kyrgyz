import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/learning_session_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../categories/providers/categories_provider.dart';
import '../../profile/providers/progress_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesProvider>().load();
      context.read<ProgressProvider>().load();
      context.read<LearningSessionProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final categories = context.watch<CategoriesProvider>();
    final session = context.watch<LearningSessionProvider>();

    final featured = categories.categories.take(3).toList();
    final lastCategoryId = session.lastCategoryId;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _HeroBanner(onStartLesson: () => context.push('/categories')),
            const SizedBox(height: 20),
            _ProgressRow(progress: progress),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => context.push(
                (lastCategoryId == null || lastCategoryId.isEmpty)
                    ? '/categories'
                    : '/flashcards/$lastCategoryId',
              ),
              child: const Text(
                'Улантуу',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 28),
            Text('Активдүү темалар', style: AppTextStyles.title),
            const SizedBox(height: 12),
            if (categories.isLoading && featured.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              ...featured.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MiniLessonCard(
                    title: item.title,
                    subtitle: item.description,
                    onTap: () => context.push('/flashcards/${item.id}'),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            const _QuickLinks(),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onStartLesson});

  final VoidCallback onStartLesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _PatternOverlay()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Үйрөнө башта',
                style: AppTextStyles.heading.copyWith(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Бүгүн 10 мүнөт жетиштүү. Кыска тапшырмалар менен тилди бекемде.',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 18),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onStartLesson,
                child: const Text(
                  'Жаңы сабак',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatternOverlay extends StatelessWidget {
  const _PatternOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _PatternPainter()));
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    const waveHeight = 20.0;
    const waveLength = 60.0;
    for (double y = 10; y < size.height; y += 40) {
      path
        ..reset()
        ..moveTo(0, y);
      for (double x = 0; x <= size.width; x += waveLength) {
        path.quadraticBezierTo(
          x + waveLength / 4,
          y - waveHeight,
          x + waveLength / 2,
          y,
        );
        path.quadraticBezierTo(
          x + 3 * waveLength / 4,
          y + waveHeight,
          x + waveLength,
          y,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.progress});

  final ProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    final items = [
      _ProgressInfo(
        icon: Icons.local_fire_department,
        label: 'Streak',
        value: '${progress.streakDays} күн',
      ),
      _ProgressInfo(
        icon: Icons.menu_book_rounded,
        label: 'Сөздөр',
        value: progress.totalWordsMastered.toString(),
      ),
      _ProgressInfo(
        icon: Icons.verified_rounded,
        label: 'Тактык',
        value: '${progress.accuracyPercent}%',
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
          children: items
              .map((item) => SizedBox(width: width, child: item))
              .toList(),
        );
      },
    );
  }
}

class _ProgressInfo extends StatelessWidget {
  const _ProgressInfo({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.title.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.muted),
        ],
      ),
    );
  }
}

class _MiniLessonCard extends StatelessWidget {
  const _MiniLessonCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.menu_book_rounded),
              ),
              const SizedBox(width: 12),
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
                      style: AppTextStyles.muted,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks();

  @override
  Widget build(BuildContext context) {
    final links = [
      _QuickLink(
        icon: Icons.flash_on,
        label: 'Экспресс-квиз',
        onTap: () => context.push('/quick-quiz'),
      ),
      _QuickLink(
        icon: Icons.auto_stories,
        label: 'Карточкалар',
        onTap: () => context.push('/categories'),
      ),
      _QuickLink(
        icon: Icons.emoji_events,
        label: 'Лидерборд',
        onTap: () => context.push('/leaderboard'),
      ),
    ];

    return Wrap(spacing: 12, runSpacing: 12, children: links);
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 64) / 2;
    final targetWidth = width < 160 ? double.infinity : width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: targetWidth,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.body,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
