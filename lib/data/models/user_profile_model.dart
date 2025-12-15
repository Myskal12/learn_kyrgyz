class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.totalMastered,
    required this.totalSessions,
    required this.accuracy,
  });

  final String id;
  final String nickname;
  final String avatar;
  final int totalMastered;
  final int totalSessions;
  final int accuracy;

  factory UserProfileModel.fromJson(String id, Map<String, dynamic> json) {
    return UserProfileModel(
      id: id,
      nickname: (json['nickname'] as String?)?.trim().isNotEmpty == true
          ? json['nickname'] as String
          : 'Колдонуучу',
      avatar: json['avatar'] as String? ?? '🙂',
      totalMastered: (json['totalMastered'] as num?)?.toInt() ?? 0,
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'avatar': avatar,
    'totalMastered': totalMastered,
    'totalSessions': totalSessions,
    'accuracy': accuracy,
  };

  UserProfileModel copyWith({
    String? nickname,
    String? avatar,
    int? totalMastered,
    int? totalSessions,
    int? accuracy,
  }) {
    return UserProfileModel(
      id: id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      totalMastered: totalMastered ?? this.totalMastered,
      totalSessions: totalSessions ?? this.totalSessions,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}
