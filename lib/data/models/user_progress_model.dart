class UserProgressModel {
  final String userId;
  final Map<String, int> correctByWordId;
  final Map<String, int> seenByWordId;

  UserProgressModel({
    required this.userId,
    Map<String, int>? correctByWordId,
    Map<String, int>? seenByWordId,
  })  : correctByWordId = correctByWordId ?? {},
        seenByWordId = seenByWordId ?? {};

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    final correct = <String, int>{};
    final seen = <String, int>{};
    (json['correctByWordId'] as Map<String, dynamic>? ?? {}).forEach((key, value) {
      correct[key] = (value as num).toInt();
    });
    (json['seenByWordId'] as Map<String, dynamic>? ?? {}).forEach((key, value) {
      seen[key] = (value as num).toInt();
    });

    return UserProgressModel(
      userId: json['userId'] as String? ?? 'guest',
      correctByWordId: correct,
      seenByWordId: seen,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'correctByWordId': correctByWordId,
        'seenByWordId': seenByWordId,
      };
}
