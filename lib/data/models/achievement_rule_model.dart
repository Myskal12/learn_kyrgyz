import 'package:flutter/widgets.dart';

import '../../core/localization/app_copy.dart';

enum AchievementMetric {
  totalWordsMastered,
  accuracyPercent,
  streakDays,
  totalLearningSeconds,
  totalXp,
}

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
    AchievementRuleModel(
      id: 'streak_fire',
      title: 'Серия оту',
      description: '7 күн катары менен практикага келдиңиз.',
      metric: AchievementMetric.streakDays,
      target: 7,
      order: 50,
    ),
    AchievementRuleModel(
      id: 'time_keeper',
      title: 'Убакыт сакчысы',
      description: '1 саат окуу убактысын топтодуңуз.',
      metric: AchievementMetric.totalLearningSeconds,
      target: 3600,
      order: 60,
    ),
    AchievementRuleModel(
      id: 'xp_flow',
      title: 'XP агымы',
      description: '250 XP топтодуңуз.',
      metric: AchievementMetric.totalXp,
      target: 250,
      order: 70,
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
    required int streakDays,
    required int totalLearningSeconds,
    required int totalXp,
  }) {
    switch (metric) {
      case AchievementMetric.totalWordsMastered:
        return totalWordsMastered >= target;
      case AchievementMetric.accuracyPercent:
        return accuracyPercent >= target;
      case AchievementMetric.streakDays:
        return streakDays >= target;
      case AchievementMetric.totalLearningSeconds:
        return totalLearningSeconds >= target;
      case AchievementMetric.totalXp:
        return totalXp >= target;
    }
  }

  String titleOf(BuildContext context) {
    switch (id) {
      case 'first_star':
        return context.tr(
          ky: 'Алгачкы жылдыз',
          en: 'First star',
          ru: 'Первая звезда',
        );
      case 'steady_learner':
        return context.tr(
          ky: 'Туруктуу үйрөнүүчү',
          en: 'Steady learner',
          ru: 'Стабильный ученик',
        );
      case 'big_jump':
        return context.tr(
          ky: 'Чоң секирик',
          en: 'Big jump',
          ru: 'Большой скачок',
        );
      case 'accurate_answers':
        return context.tr(
          ky: 'Так жооптор',
          en: 'Accurate answers',
          ru: 'Точные ответы',
        );
      case 'streak_fire':
        return context.tr(
          ky: 'Серия оту',
          en: 'Streak fire',
          ru: 'Огонь серии',
        );
      case 'time_keeper':
        return context.tr(
          ky: 'Убакыт сакчысы',
          en: 'Time keeper',
          ru: 'Хранитель времени',
        );
      case 'xp_flow':
        return context.tr(ky: 'XP агымы', en: 'XP flow', ru: 'Поток XP');
      default:
        return title;
    }
  }

  String descriptionOf(BuildContext context) {
    switch (id) {
      case 'first_star':
        return context.tr(
          ky: '5 сөздү жаттадыңыз.',
          en: 'You memorized 5 words.',
          ru: 'Вы запомнили 5 слов.',
        );
      case 'steady_learner':
        return context.tr(
          ky: '15 сөздү үйрөндүңүз.',
          en: 'You learned 15 words.',
          ru: 'Вы выучили 15 слов.',
        );
      case 'big_jump':
        return context.tr(
          ky: '30 сөздү топтодуңуз.',
          en: 'You collected 30 words.',
          ru: 'Вы собрали 30 слов.',
        );
      case 'accurate_answers':
        return context.tr(
          ky: 'Тактык 80% же андан жогору.',
          en: 'Accuracy is 80% or higher.',
          ru: 'Точность 80% или выше.',
        );
      case 'streak_fire':
        return context.tr(
          ky: '7 күн катары менен практикага келдиңиз.',
          en: 'You practiced 7 days in a row.',
          ru: 'Вы практиковались 7 дней подряд.',
        );
      case 'time_keeper':
        return context.tr(
          ky: '1 саат окуу убактысын топтодуңуз.',
          en: 'You accumulated 1 hour of study time.',
          ru: 'Вы накопили 1 час учебного времени.',
        );
      case 'xp_flow':
        return context.tr(
          ky: '250 XP топтодуңуз.',
          en: 'You earned 250 XP.',
          ru: 'Вы набрали 250 XP.',
        );
      default:
        return description;
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
      case 'streak_days':
      case 'streakdays':
      case 'streak':
        return AchievementMetric.streakDays;
      case 'total_learning_seconds':
      case 'totallearningseconds':
      case 'learning_seconds':
      case 'learningseconds':
      case 'time':
        return AchievementMetric.totalLearningSeconds;
      case 'total_xp':
      case 'totalxp':
      case 'xp':
        return AchievementMetric.totalXp;
      default:
        return null;
    }
  }
}
