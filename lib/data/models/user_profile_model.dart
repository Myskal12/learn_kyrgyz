import '../../core/utils/avatar_presets.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.totalMastered,
    required this.totalSessions,
    required this.accuracy,
    required this.totalXp,
    required this.streakDays,
  });

  final String id;
  final String nickname;
  final String avatar;
  final int totalMastered;
  final int totalSessions;
  final int accuracy;
  final int totalXp;
  final int streakDays;

  factory UserProfileModel.fromJson(String id, Map<String, dynamic> json) {
    return UserProfileModel(
      id: id,
      nickname: (json['nickname'] as String?)?.trim().isNotEmpty == true
          ? json['nickname'] as String
          : 'Колдонуучу',
      avatar: normalizeProfileAvatar(json['avatar'] as String?),
      totalMastered: (json['totalMastered'] as num?)?.toInt() ?? 0,
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toInt() ?? 0,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'avatar': avatar,
    'totalMastered': totalMastered,
    'totalSessions': totalSessions,
    'accuracy': accuracy,
    'totalXp': totalXp,
    'streakDays': streakDays,
  };

  UserProfileModel copyWith({
    String? nickname,
    String? avatar,
    int? totalMastered,
    int? totalSessions,
    int? accuracy,
    int? totalXp,
    int? streakDays,
  }) {
    return UserProfileModel(
      id: id,
      nickname: nickname ?? this.nickname,
      avatar: normalizeProfileAvatar(avatar ?? this.avatar),
      totalMastered: totalMastered ?? this.totalMastered,
      totalSessions: totalSessions ?? this.totalSessions,
      accuracy: accuracy ?? this.accuracy,
      totalXp: totalXp ?? this.totalXp,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  int get journeyLevel {
    var level = 1;
    while (totalXp >= _xpRequiredForLevel(level + 1)) {
      level++;
    }
    return level;
  }

  String get journeyRank {
    final level = journeyLevel;
    if (level >= 8) return 'Тоо чебери';
    if (level >= 6) return 'Ритм устаты';
    if (level >= 4) return 'Туруктуу саякатчы';
    if (level >= 2) return 'Өсүп жаткан тилчи';
    return 'Алгачкы от';
  }

  int get leaderboardScore => totalXp + (streakDays * 10) + accuracy;
}

int _xpRequiredForLevel(int level) {
  if (level <= 1) return 0;
  var total = 0;
  for (var current = 1; current < level; current++) {
    total += 80 + ((current - 1) * 35);
  }
  return total;
}
