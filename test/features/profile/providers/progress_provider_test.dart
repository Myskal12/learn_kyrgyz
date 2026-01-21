import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_kyrgyz/features/profile/providers/progress_provider.dart';
import 'package:learn_kyrgyz/core/services/firebase_service.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';
import 'package:learn_kyrgyz/data/models/user_progress_model.dart';

// Mocks
class MockLocalStorageService implements LocalStorageService {
  String? _data;

  @override
  Future<String?> getString(String key) async => _data;

  @override
  Future<void> setString(String key, String value) async {
    _data = value;
  }
}

class MockFirebaseService implements FirebaseService {
  final StreamController<String?> _userController = StreamController<String?>();

  @override
  Stream<String?> get userStream => _userController.stream;

  void emitUser(String? uid) => _userController.add(uid);

  @override
  Future<void> saveUserProgress(UserProgressModel progress) async {}

  @override
  Future<void> updateUserStats({
    required String uid,
    required int totalMastered,
    required int totalSessions,
    required int accuracy,
  }) async {}

  @override
  Future<UserProgressModel?> fetchUserProgress(String uid) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ProgressProvider', () {
    late ProgressProvider provider;
    late MockLocalStorageService storage;
    late MockFirebaseService firebase;

    setUp(() {
      storage = MockLocalStorageService();
      firebase = MockFirebaseService();
      provider = ProgressProvider(storage, firebase);
    });

    test('initial state is empty', () {
      expect(provider.totalReviewSessions, 0);
      expect(provider.accuracyPercent, 0);
      expect(provider.totalWordsMastered, 0);
    });

    test('markWordSeen updates totals and accuracy', () {
      provider.markWordSeen('word1');

      // 1 exposure, 0 mastered. Accuracy = 0.
      expect(provider.totalReviewSessions, 1);
      expect(provider.accuracyPercent, 0);

      provider.markWordSeen('word1');
      // 2 exposures, 0 mastered.
      expect(provider.totalReviewSessions, 2);
    });

    test('markWordMastered updates totals and accuracy', () {
      provider.markWordMastered('word1');

      // markWordMastered calls markWordSeen first.
      // So 1 exposure, 1 mastered. Accuracy = 100%.
      expect(provider.totalReviewSessions, 1);
      expect(provider.totalWordsMastered, 1);
      expect(provider.accuracyPercent, 100);

      provider.markWordSeen('word1');
      // 2 exposures, 1 mastered. Accuracy = 50%.
      expect(provider.totalReviewSessions, 2);
      expect(provider.totalWordsMastered, 1); // Key count is still 1
      expect(provider.accuracyPercent, 50);
    });

    test('load recalculates totals correctly', () async {
      // Setup stored data
      final progress = UserProgressModel(
        userId: 'guest',
        seenByWordId: {'w1': 10, 'w2': 5}, // 15 exposures
        correctByWordId: {'w1': 5, 'w2': 1}, // 6 mastered
      );
      await storage.setString('user_progress', jsonEncode(progress.toJson()));

      await provider.load();

      expect(provider.totalReviewSessions, 15);
      expect(provider.accuracyPercent, ((6 / 15) * 100).round()); // 40%
    });

    test('reset clears totals', () async {
      provider.markWordMastered('w1');
      expect(provider.totalReviewSessions, 1);

      await provider.reset();

      expect(provider.totalReviewSessions, 0);
      expect(provider.accuracyPercent, 0);
    });
  });
}
