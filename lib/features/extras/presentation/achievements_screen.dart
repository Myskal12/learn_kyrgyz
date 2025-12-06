import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_text_styles.dart';
import '../../profile/providers/progress_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final trophies = [
      _Achievement(
        title: 'Башталгыч',
        description: '5 сөздү үйрөн.',
        unlocked: progress.totalWordsMastered >= 5,
      ),
      _Achievement(
        title: 'Орто жол',
        description: '15 сөздү өздөштүр.',
        unlocked: progress.totalWordsMastered >= 15,
      ),
      _Achievement(
        title: 'Чыныгы устат',
        description: '30дан ашык сөздү бил.',
        unlocked: progress.totalWordsMastered >= 30,
      ),
      _Achievement(
        title: 'Квиз чебери',
        description: 'Квизнен 80% жыйынтык.',
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
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: Icon(
              item.unlocked ? Icons.emoji_events : Icons.lock_outline,
              color: item.unlocked ? Colors.amber : Colors.grey,
            ),
            title: Text(item.title, style: AppTextStyles.title),
            subtitle: Text(item.description),
            trailing: item.unlocked ? const Icon(Icons.check, color: Colors.green) : null,
          );
        },
      ),
    );
  }
}

class _Achievement {
  const _Achievement({required this.title, required this.description, required this.unlocked});
  final String title;
  final String description;
  final bool unlocked;
}
