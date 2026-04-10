class OnboardingConfigModel {
  const OnboardingConfigModel({
    required this.dailyGoalOptions,
    required this.defaultDailyGoal,
  });

  static const fallback = OnboardingConfigModel(
    dailyGoalOptions: [10, 20, 30],
    defaultDailyGoal: 20,
  );

  final List<int> dailyGoalOptions;
  final int defaultDailyGoal;

  factory OnboardingConfigModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = (json['dailyGoalOptions'] as List?) ?? const [];
    final options =
        rawOptions
            .map((value) => value is num ? value.toInt() : null)
            .whereType<int>()
            .where((value) => value > 0)
            .toSet()
            .toList()
          ..sort();

    final normalizedOptions = options.isEmpty
        ? List<int>.of(fallback.dailyGoalOptions)
        : options;

    final requestedDefault = (json['defaultDailyGoal'] as num?)?.toInt();
    final normalizedDefault =
        requestedDefault != null && normalizedOptions.contains(requestedDefault)
        ? requestedDefault
        : (normalizedOptions.contains(fallback.defaultDailyGoal)
              ? fallback.defaultDailyGoal
              : normalizedOptions.first);

    return OnboardingConfigModel(
      dailyGoalOptions: normalizedOptions,
      defaultDailyGoal: normalizedDefault,
    );
  }
}
