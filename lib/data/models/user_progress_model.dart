enum WordLearningState {
  newWord,
  learning,
  weak,
  reviewDue,
  strong,
  mastered;

  String get storageValue {
    switch (this) {
      case WordLearningState.newWord:
        return 'new';
      case WordLearningState.learning:
        return 'learning';
      case WordLearningState.weak:
        return 'weak';
      case WordLearningState.reviewDue:
        return 'review_due';
      case WordLearningState.strong:
        return 'strong';
      case WordLearningState.mastered:
        return 'mastered';
    }
  }

  static WordLearningState fromStorage(String? value) {
    switch (value) {
      case 'learning':
        return WordLearningState.learning;
      case 'weak':
        return WordLearningState.weak;
      case 'review_due':
        return WordLearningState.reviewDue;
      case 'strong':
        return WordLearningState.strong;
      case 'mastered':
        return WordLearningState.mastered;
      default:
        return WordLearningState.newWord;
    }
  }
}

class WordProgressRecord {
  WordProgressRecord({
    this.attemptCount = 0,
    this.successCount = 0,
    this.failureCount = 0,
    this.lastAttemptAt,
    this.lastCorrectAt,
    this.nextReviewAt,
    this.learningState = WordLearningState.newWord,
  });

  final int attemptCount;
  final int successCount;
  final int failureCount;
  final DateTime? lastAttemptAt;
  final DateTime? lastCorrectAt;
  final DateTime? nextReviewAt;
  final WordLearningState learningState;

  factory WordProgressRecord.fromJson(Map<String, dynamic> json) {
    return WordProgressRecord(
      attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 0,
      successCount: (json['successCount'] as num?)?.toInt() ?? 0,
      failureCount: (json['failureCount'] as num?)?.toInt() ?? 0,
      lastAttemptAt: _parseDate(json['lastAttemptAt']),
      lastCorrectAt: _parseDate(json['lastCorrectAt']),
      nextReviewAt: _parseDate(json['nextReviewAt']),
      learningState: WordLearningState.fromStorage(
        json['learningState'] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'attemptCount': attemptCount,
    'successCount': successCount,
    'failureCount': failureCount,
    'lastAttemptAt': lastAttemptAt?.millisecondsSinceEpoch,
    'lastCorrectAt': lastCorrectAt?.millisecondsSinceEpoch,
    'nextReviewAt': nextReviewAt?.millisecondsSinceEpoch,
    'learningState': learningState.storageValue,
  };

  WordProgressRecord copyWith({
    int? attemptCount,
    int? successCount,
    int? failureCount,
    DateTime? lastAttemptAt,
    DateTime? lastCorrectAt,
    DateTime? nextReviewAt,
    WordLearningState? learningState,
  }) {
    return WordProgressRecord(
      attemptCount: attemptCount ?? this.attemptCount,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastCorrectAt: lastCorrectAt ?? this.lastCorrectAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      learningState: learningState ?? this.learningState,
    );
  }
}

class UserProgressModel {
  final String userId;
  final Map<String, int> correctByWordId;
  final Map<String, int> seenByWordId;
  final Map<String, WordProgressRecord> wordProgressById;
  final Map<String, int> dailyActivityCountByDate;
  final Map<String, int> dailyCorrectCountByDate;
  final Map<String, int> dailyLearningSecondsByDate;
  final Map<String, int> dailyXpByDate;
  final List<String> claimedDailyQuestKeys;
  final int streakDays;
  final int totalLearningSeconds;
  final int totalXp;
  final DateTime? lastSessionAt;

  UserProgressModel({
    required this.userId,
    Map<String, int>? correctByWordId,
    Map<String, int>? seenByWordId,
    Map<String, WordProgressRecord>? wordProgressById,
    Map<String, int>? dailyActivityCountByDate,
    Map<String, int>? dailyCorrectCountByDate,
    Map<String, int>? dailyLearningSecondsByDate,
    Map<String, int>? dailyXpByDate,
    List<String>? claimedDailyQuestKeys,
    this.streakDays = 0,
    this.totalLearningSeconds = 0,
    this.totalXp = 0,
    this.lastSessionAt,
  }) : correctByWordId = correctByWordId ?? {},
       seenByWordId = seenByWordId ?? {},
       wordProgressById = wordProgressById ?? {},
       dailyActivityCountByDate = dailyActivityCountByDate ?? {},
       dailyCorrectCountByDate = dailyCorrectCountByDate ?? {},
       dailyLearningSecondsByDate = dailyLearningSecondsByDate ?? {},
       dailyXpByDate = dailyXpByDate ?? {},
       claimedDailyQuestKeys = claimedDailyQuestKeys ?? const [];

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    final correct = _parseIntMap(json['correctByWordId']);
    final seen = _parseIntMap(json['seenByWordId']);
    final dailyActivity = _parseIntMap(json['dailyActivityCountByDate']);
    final dailyCorrect = _parseIntMap(json['dailyCorrectCountByDate']);
    final dailyLearningSeconds = _parseIntMap(
      json['dailyLearningSecondsByDate'],
    );
    final dailyXp = _parseIntMap(json['dailyXpByDate']);
    final claimedDailyQuestKeys = _parseStringList(
      json['claimedDailyQuestKeys'],
    );
    final wordProgress = <String, WordProgressRecord>{};
    (json['wordProgressById'] as Map<String, dynamic>? ?? {}).forEach((
      key,
      value,
    ) {
      final data = value as Map<String, dynamic>? ?? const <String, dynamic>{};
      wordProgress[key] = WordProgressRecord.fromJson(data);
    });

    return UserProgressModel(
      userId: json['userId'] as String? ?? 'guest',
      correctByWordId: correct,
      seenByWordId: seen,
      wordProgressById: wordProgress,
      dailyActivityCountByDate: dailyActivity,
      dailyCorrectCountByDate: dailyCorrect,
      dailyLearningSecondsByDate: dailyLearningSeconds,
      dailyXpByDate: dailyXp,
      claimedDailyQuestKeys: claimedDailyQuestKeys,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      totalLearningSeconds:
          (json['totalLearningSeconds'] as num?)?.toInt() ?? 0,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      lastSessionAt: _parseDate(json['lastSessionAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'correctByWordId': correctByWordId,
    'seenByWordId': seenByWordId,
    'wordProgressById': wordProgressById.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'dailyActivityCountByDate': dailyActivityCountByDate,
    'dailyCorrectCountByDate': dailyCorrectCountByDate,
    'dailyLearningSecondsByDate': dailyLearningSecondsByDate,
    'dailyXpByDate': dailyXpByDate,
    'claimedDailyQuestKeys': claimedDailyQuestKeys,
    'streakDays': streakDays,
    'totalLearningSeconds': totalLearningSeconds,
    'totalXp': totalXp,
    'lastSessionAt': lastSessionAt?.millisecondsSinceEpoch,
  };

  UserProgressModel copyWith({
    String? userId,
    Map<String, int>? correctByWordId,
    Map<String, int>? seenByWordId,
    Map<String, WordProgressRecord>? wordProgressById,
    Map<String, int>? dailyActivityCountByDate,
    Map<String, int>? dailyCorrectCountByDate,
    Map<String, int>? dailyLearningSecondsByDate,
    Map<String, int>? dailyXpByDate,
    List<String>? claimedDailyQuestKeys,
    int? streakDays,
    int? totalLearningSeconds,
    int? totalXp,
    DateTime? lastSessionAt,
  }) {
    return UserProgressModel(
      userId: userId ?? this.userId,
      correctByWordId:
          correctByWordId ?? Map<String, int>.from(this.correctByWordId),
      seenByWordId: seenByWordId ?? Map<String, int>.from(this.seenByWordId),
      wordProgressById:
          wordProgressById ??
          Map<String, WordProgressRecord>.from(this.wordProgressById),
      dailyActivityCountByDate:
          dailyActivityCountByDate ??
          Map<String, int>.from(this.dailyActivityCountByDate),
      dailyCorrectCountByDate:
          dailyCorrectCountByDate ??
          Map<String, int>.from(this.dailyCorrectCountByDate),
      dailyLearningSecondsByDate:
          dailyLearningSecondsByDate ??
          Map<String, int>.from(this.dailyLearningSecondsByDate),
      dailyXpByDate: dailyXpByDate ?? Map<String, int>.from(this.dailyXpByDate),
      claimedDailyQuestKeys:
          claimedDailyQuestKeys ?? List<String>.from(this.claimedDailyQuestKeys),
      streakDays: streakDays ?? this.streakDays,
      totalLearningSeconds: totalLearningSeconds ?? this.totalLearningSeconds,
      totalXp: totalXp ?? this.totalXp,
      lastSessionAt: lastSessionAt ?? this.lastSessionAt,
    );
  }
}

Map<String, int> _parseIntMap(dynamic value) {
  final result = <String, int>{};
  final map = value as Map<String, dynamic>? ?? const <String, dynamic>{};
  map.forEach((key, entry) {
    result[key] = (entry as num?)?.toInt() ?? 0;
  });
  return result;
}

List<String> _parseStringList(dynamic value) {
  final raw = value as List<dynamic>? ?? const [];
  return raw
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is double) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  final maybeString = value.toString();
  if (maybeString.contains('Timestamp')) {
    try {
      final toDate = value.toDate() as DateTime;
      return toDate;
    } catch (_) {
      return null;
    }
  }
  return null;
}
