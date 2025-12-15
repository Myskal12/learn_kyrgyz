class UserProgressModel {
  final String userId;
  final Map<String, int> correctByWordId;
  final Map<String, int> seenByWordId;
  final int streakDays;
  final DateTime? lastSessionAt;

  UserProgressModel({
    required this.userId,
    Map<String, int>? correctByWordId,
    Map<String, int>? seenByWordId,
    this.streakDays = 0,
    this.lastSessionAt,
  }) : correctByWordId = correctByWordId ?? {},
       seenByWordId = seenByWordId ?? {};

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    final correct = <String, int>{};
    final seen = <String, int>{};
    (json['correctByWordId'] as Map<String, dynamic>? ?? {}).forEach((
      key,
      value,
    ) {
      correct[key] = (value as num).toInt();
    });
    (json['seenByWordId'] as Map<String, dynamic>? ?? {}).forEach((key, value) {
      seen[key] = (value as num).toInt();
    });

    return UserProgressModel(
      userId: json['userId'] as String? ?? 'guest',
      correctByWordId: correct,
      seenByWordId: seen,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      lastSessionAt: _parseDate(json['lastSessionAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'correctByWordId': correctByWordId,
    'seenByWordId': seenByWordId,
    'streakDays': streakDays,
    'lastSessionAt': lastSessionAt?.millisecondsSinceEpoch,
  };

  UserProgressModel copyWith({
    String? userId,
    Map<String, int>? correctByWordId,
    Map<String, int>? seenByWordId,
    int? streakDays,
    DateTime? lastSessionAt,
  }) {
    return UserProgressModel(
      userId: userId ?? this.userId,
      correctByWordId:
          correctByWordId ?? Map<String, int>.from(this.correctByWordId),
      seenByWordId: seenByWordId ?? Map<String, int>.from(this.seenByWordId),
      streakDays: streakDays ?? this.streakDays,
      lastSessionAt: lastSessionAt ?? this.lastSessionAt,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is double) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  // Firestore Timestamp support without depending on the type directly.
  final maybeString = value.toString();
  // ignore: avoid_dynamic_calls
  if (maybeString.contains('Timestamp')) {
    try {
      // ignore: avoid_dynamic_calls
      final toDate = value.toDate() as DateTime;
      return toDate;
    } catch (_) {
      return null;
    }
  }
  return null;
}
