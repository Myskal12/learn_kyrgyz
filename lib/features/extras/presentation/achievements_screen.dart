import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../profile/providers/progress_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final trophies = [
      _Achievement(
        title: 'Алгачкы жылдыз',
        description: '5 сөздү жаттадыңыз.',
        unlocked: progress.totalWordsMastered >= 5,
      ),
      _Achievement(
        title: 'Туруктуу үйрөнүүчү',
        description: '15 сөздү үйрөндүңүз.',
        unlocked: progress.totalWordsMastered >= 15,
      ),
      _Achievement(
        title: 'Чоң секирик',
        description: '30 сөздү топтодуңуз.',
        unlocked: progress.totalWordsMastered >= 30,
      ),
      _Achievement(
        title: 'Так жооптор',
        description: 'Тактык 80% же андан жогору.',
        unlocked: progress.accuracyPercent >= 80,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Жетишкендиктер')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: trophies.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = trophies[index];
          return ListTile(
            tileColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: Icon(
              item.unlocked ? Icons.emoji_events : Icons.lock_outline,
              color: item.unlocked ? Colors.amber : Colors.grey,
            ),
            title: Text(item.title, style: AppTextStyles.title),
            subtitle: Text(item.description),
            trailing: item.unlocked
                ? const Icon(Icons.check, color: Colors.green)
                : null,
          );
        },
      ),
    );
  }
}

class _Achievement {
  const _Achievement({
    required this.title,
    required this.description,
    required this.unlocked,
  });
  final String title;
  final String description;
  final bool unlocked;
}
