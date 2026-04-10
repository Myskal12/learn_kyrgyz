enum AchievementMetric { totalWordsMastered, accuracyPercent }

class AchievementRuleModel {
  const AchievementRuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
    required this.order,
    this.active = true,
  });

  static const fallback = <AchievementRuleModel>[
    AchievementRuleModel(
      id: 'first_star',
      title: 'Алгачкы жылдыз',
      description: '5 сөздү жаттадыңыз.',
      metric: AchievementMetric.totalWordsMastered,
      target: 5,
      order: 10,
    ),
    AchievementRuleModel(
      id: 'steady_learner',
      title: 'Туруктуу үйрөнүүчү',
      description: '15 сөздү үйрөндүңүз.',
      metric: AchievementMetric.totalWordsMastered,
      target: 15,
      order: 20,
    ),
    AchievementRuleModel(
      id: 'big_jump',
      title: 'Чоң секирик',
      description: '30 сөздү топтодуңуз.',
      metric: AchievementMetric.totalWordsMastered,
      target: 30,
      order: 30,
    ),
    AchievementRuleModel(
      id: 'accurate_answers',
      title: 'Так жооптор',
      description: 'Тактык 80% же андан жогору.',
      metric: AchievementMetric.accuracyPercent,
      target: 80,
      order: 40,
    ),
  ];

  final String id;
  final String title;
  final String description;
  final AchievementMetric metric;
  final int target;
  final int order;
  final bool active;

  bool isUnlocked({
    required int totalWordsMastered,
    required int accuracyPercent,
  }) {
    switch (metric) {
      case AchievementMetric.totalWordsMastered:
        return totalWordsMastered >= target;
      case AchievementMetric.accuracyPercent:
        return accuracyPercent >= target;
    }
  }

  factory AchievementRuleModel.fromJson(Map<String, dynamic> json) {
    final metric = _metricFromRaw(json['metric']?.toString());
    if (metric == null) {
      throw const FormatException('Invalid achievement metric');
    }

    final target = (json['target'] as num?)?.toInt();
    if (target == null || target < 0) {
      throw const FormatException('Invalid achievement target');
    }

    final id = json['id']?.toString().trim();
    final title = json['title']?.toString().trim();
    final description = json['description']?.toString().trim();

    if (id == null || id.isEmpty) {
      throw const FormatException('Achievement id is required');
    }
    if (title == null || title.isEmpty) {
      throw const FormatException('Achievement title is required');
    }
    if (description == null || description.isEmpty) {
      throw const FormatException('Achievement description is required');
    }

    return AchievementRuleModel(
      id: id,
      title: title,
      description: description,
      metric: metric,
      target: target,
      order: (json['order'] as num?)?.toInt() ?? 1000,
      active: (json['active'] as bool?) ?? true,
    );
  }

  static AchievementMetric? _metricFromRaw(String? raw) {
    if (raw == null) return null;

    final normalized = raw.trim().toLowerCase();
    switch (normalized) {
      case 'total_words_mastered':
      case 'totalwordsmastered':
      case 'words_mastered':
      case 'wordsmastered':
        return AchievementMetric.totalWordsMastered;
      case 'accuracy_percent':
      case 'accuracypercent':
      case 'accuracy':
        return AchievementMetric.accuracyPercent;
      default:
        return null;
    }
  }
}
