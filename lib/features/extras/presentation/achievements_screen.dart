import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/achievement_rule_model.dart';
import '../../../shared/widgets/app_shell.dart';
import '../providers/content_config_provider.dart';
import '../../profile/providers/progress_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final rulesAsync = ref.watch(achievementRulesProvider);
    final trophies = rulesAsync.valueOrNull ?? AchievementRuleModel.fallback;

    return AppShell(
      title: 'Жетишкендиктер',
      subtitle: 'Ачылган жана алдыдагы белгилер',
      activeTab: AppTab.progress,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/progress',
      showBottomNav: false,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: trophies.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = trophies[index];
          final unlocked = item.isUnlocked(
            totalWordsMastered: progress.totalWordsMastered,
            accuracyPercent: progress.accuracyPercent,
            streakDays: progress.streakDays,
            totalLearningSeconds: progress.totalLearningSeconds,
            totalXp: progress.totalXp,
          );
          return ListTile(
            tileColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: Icon(
              unlocked ? Icons.emoji_events : Icons.lock_outline,
              color: unlocked ? Colors.amber : Colors.grey,
            ),
            title: Text(item.title, style: AppTextStyles.title),
            subtitle: Text(item.description),
            trailing: unlocked
                ? const Icon(Icons.check, color: Colors.green)
                : null,
          );
        },
      ),
    );
  }
}
