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
    required int totalXp,
    required int streakDays,
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

      // 1 attempt, 0 mastered. Accuracy = 0.
      expect(provider.totalReviewSessions, 1);
      expect(provider.accuracyPercent, 0);
      expect(
        provider.learningStateForWord('word1'),
        WordLearningState.reviewDue,
      );

      provider.markWordSeen('word1');
      expect(provider.totalReviewSessions, 2);
      expect(provider.weakWordsCount, 1);
    });

    test('markWordMastered updates totals and accuracy', () {
      provider.markWordMastered('word1');

      expect(provider.totalReviewSessions, 1);
      expect(provider.totalWordsMastered, 1);
      expect(provider.accuracyPercent, 100);
      expect(
        provider.learningStateForWord('word1'),
        WordLearningState.learning,
      );

      provider.markWordSeen('word1');
      expect(provider.totalReviewSessions, 2);
      expect(provider.totalWordsMastered, 1);
      expect(provider.accuracyPercent, 50);
    });

    test('load recalculates totals correctly', () async {
      final progress = UserProgressModel(
        userId: 'guest',
        seenByWordId: {'w1': 10, 'w2': 5},
        correctByWordId: {'w1': 5, 'w2': 1},
        totalLearningSeconds: 600,
        dailyActivityCountByDate: {'2026-01-01': 3},
        dailyLearningSecondsByDate: {'2026-01-01': 600},
      );
      await storage.setString('user_progress', jsonEncode(progress.toJson()));

      await provider.load();

      expect(provider.totalReviewSessions, 15);
      expect(provider.accuracyPercent, ((6 / 15) * 100).round());
      expect(provider.totalLearningSeconds, 600);
      expect(provider.progressForWord('w1'), isNotNull);
    });

    test('reset clears totals', () async {
      provider.markWordMastered('w1');
      expect(provider.totalReviewSessions, 1);

      await provider.reset();

      expect(provider.totalReviewSessions, 0);
      expect(provider.accuracyPercent, 0);
    });

    test('recordWordAttempt schedules review states', () {
      provider.recordWordAttempt('word1', isCorrect: false);
      expect(provider.reviewDueWordsCount, 1);
      expect(
        provider.learningStateForWord('word1'),
        WordLearningState.reviewDue,
      );

      provider.recordWordAttempt('word1', isCorrect: true);
      provider.recordWordAttempt('word1', isCorrect: true);

      expect(provider.learningStateForWord('word1'), WordLearningState.strong);
    });

    test('milestone helpers expose next target and remaining words', () {
      expect(provider.nextMilestoneTarget, 5);
      expect(provider.wordsToNextMilestone, 5);
      expect(provider.nextMilestoneProgress, 0);

      for (var i = 0; i < 6; i++) {
        provider.recordWordAttempt('word_$i', isCorrect: true);
      }

      expect(provider.nextMilestoneTarget, 15);
      expect(provider.previousMilestoneTarget, 5);
      expect(provider.wordsToNextMilestone, 9);
      expect(provider.nextMilestoneProgress, closeTo(0.1, 0.001));
    });

    test('hasReviewFocus reflects due and weak words', () async {
      expect(provider.hasReviewFocus, isFalse);

      provider.recordWordAttempt('word1', isCorrect: false);
      expect(provider.hasReviewFocus, isTrue);

      await provider.reset();
      provider.recordWordAttempt('word2', isCorrect: false);
      provider.recordWordAttempt('word2', isCorrect: false);
      expect(provider.weakWordsCount, 1);
      expect(provider.hasReviewFocus, isTrue);
    });

    test(
      'recordLearningDuration tracks total time and recent week activity',
      () {
        provider.recordLearningDuration(const Duration(minutes: 12));

        expect(provider.totalLearningSeconds, 720);
        expect(provider.activeDaysThisWeek, 1);
        expect(provider.recentWeekActivity.last.seconds, 720);
        expect(provider.recentWeekActivity.last.isActive, isTrue);
      },
    );

    test('word attempts populate daily activity history', () {
      provider.recordWordAttempt('word1', isCorrect: true);

      expect(provider.activeDaysThisWeek, 1);
      expect(provider.recentWeekActivity.last.interactions, 1);
      expect(provider.recentWeekActivity.last.isActive, isTrue);
    });

    test('xp grows with practice and exposes journey level helpers', () {
      provider.recordLearningDuration(const Duration(minutes: 5));
      provider.recordWordAttempt('word1', isCorrect: true);
      provider.recordWordAttempt('word2', isCorrect: false);

      expect(provider.totalXp, greaterThan(0));
      expect(provider.todayXp, provider.totalXp);
      expect(provider.journeyLevel, greaterThanOrEqualTo(1));
      expect(provider.xpToNextLevel, greaterThan(0));
      expect(provider.journeyLevelProgress, inInclusiveRange(0.0, 1.0));
    });

    test('daily quests claim reward once after thresholds are reached', () {
      provider.recordLearningDuration(const Duration(minutes: 10));
      for (var index = 0; index < 12; index++) {
        provider.recordWordAttempt('word_$index', isCorrect: true);
      }

      expect(provider.completedDailyQuestsCount, 3);
      final xpAfterAllQuests = provider.todayXp;

      provider.recordWordAttempt('bonus_check', isCorrect: true);

      expect(provider.completedDailyQuestsCount, 3);
      expect(provider.todayXp, xpAfterAllQuests + 12);
    });

    test('weekly challenge reflects active days and weekly xp', () {
      provider.recordLearningDuration(const Duration(minutes: 15));
      final challenge = provider.weeklyChallenge;

      expect(challenge.activeDays, 1);
      expect(challenge.weeklyXp, provider.weeklyXp);
      expect(challenge.progress, greaterThan(0));
      expect(challenge.isCompleted, isFalse);
    });
  });
}
