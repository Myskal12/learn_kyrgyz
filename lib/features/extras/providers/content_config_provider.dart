import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../data/models/achievement_rule_model.dart';
import '../../../data/models/learning_resource_model.dart';

final achievementRulesProvider = FutureProvider<List<AchievementRuleModel>>((
  ref,
) async {
  final firebase = ref.read(firebaseServiceProvider);
  final remoteRules = await firebase.fetchAchievementRules();
  if (remoteRules.isNotEmpty) {
    return remoteRules;
  }
  return AchievementRuleModel.fallback;
});

final learningResourcesProvider = FutureProvider<List<LearningResourceModel>>((
  ref,
) async {
  final firebase = ref.read(firebaseServiceProvider);
  final remoteResources = await firebase.fetchLearningResources();
  if (remoteResources.isNotEmpty) {
    return remoteResources;
  }
  return LearningResourceModel.fallback;
});
