import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_kyrgyz/core/services/analytics_service.dart';
import 'package:learn_kyrgyz/core/services/firebase_service.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';
import 'package:learn_kyrgyz/core/utils/learning_direction.dart';
import 'package:learn_kyrgyz/data/models/quiz_question_model.dart';
import 'package:learn_kyrgyz/data/models/user_progress_model.dart';
import 'package:learn_kyrgyz/data/models/word_model.dart';
import 'package:learn_kyrgyz/features/learning/repository/words_repository.dart';
import 'package:learn_kyrgyz/features/profile/providers/progress_provider.dart';
import 'package:learn_kyrgyz/features/quiz/providers/quiz_provider.dart';
import 'package:learn_kyrgyz/features/quiz/repository/quiz_repository.dart';

class FakeLocalStorageService implements LocalStorageService {
  final Map<String, String> _values = {};

  @override
  Future<String?> getString(String key) async => _values[key];

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }
}

class FakeFirebaseService implements FirebaseService {
  FakeFirebaseService()
    : _userController = StreamController<String?>.broadcast();

  final StreamController<String?> _userController;

  @override
  Stream<String?> get userStream => _userController.stream;

  @override
  Future<UserProgressModel?> fetchUserProgress(String uid) async => null;

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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> events = [];

  @override
  Future<List<AnalyticsEvent>> readRecentEvents() async =>
      List<AnalyticsEvent>.unmodifiable(events);

  @override
  Future<void> track(
    String name, {
    Map<String, Object?> properties = const {},
  }) async {
    events.add(
      AnalyticsEvent(
        name: name,
        timestamp: DateTime(2026, 1, 1),
        properties: Map<String, dynamic>.from(properties),
      ),
    );
  }
}

class FakeWordsRepository implements WordsRepository {
  FakeWordsRepository(this._words);

  final List<WordModel> _words;

  @override
  List<WordModel> get allWords => List<WordModel>.of(_words);

  @override
  Future<void> ensureWordsLoaded(String categoryId) async {}

  @override
  Future<List<WordModel>> fetchWordsByCategory(
    String categoryId, {
    bool forceRefresh = false,
  }) async => List<WordModel>.of(_words);

  @override
  WordModel? findByEnglish(String english) {
    for (final word in _words) {
      if (word.english == english) return word;
    }
    return null;
  }

  @override
  WordModel? findById(String id) {
    for (final word in _words) {
      if (word.id == id) return word;
    }
    return null;
  }

  @override
  WordModel? findByKyrgyz(String kyrgyz) {
    for (final word in _words) {
      if (word.kyrgyz == kyrgyz) return word;
    }
    return null;
  }

  @override
  List<WordModel> getCachedWords(String categoryId) =>
      List<WordModel>.of(_words);

  @override
  Future<void> prefetchCategories(Iterable<String> categoryIds) async {}
}

class FakeQuizRepository implements QuizRepository {
  FakeQuizRepository(this._questions);

  final List<QuizQuestionModel> _questions;

  @override
  Future<List<QuizQuestionModel>> fetchQuestions(
    String categoryId, {
    int limit = 20,
    LearningDirection direction = LearningDirection.enToKy,
  }) async => List<QuizQuestionModel>.of(_questions);
}

void main() {
  test('tracks quiz session lifecycle', () async {
    final analytics = FakeAnalyticsService();
    final progress = ProgressProvider(
      FakeLocalStorageService(),
      FakeFirebaseService(),
    );
    final provider = QuizProvider(
      FakeQuizRepository([
        const QuizQuestionModel(
          id: 'hello',
          question: 'Hello',
          correct: 'Салам',
          options: ['Салам', 'Рахмат', 'Ооба', 'Жок'],
          category: 'basics',
          level: 1,
          wordId: 'hello',
        ),
      ]),
      FakeWordsRepository([
        const WordModel(id: 'hello', english: 'Hello', kyrgyz: 'Салам'),
      ]),
      progress,
      analytics: analytics,
    );

    await provider.start('basics');

    expect(analytics.events.map((event) => event.name), ['quiz_started']);
    expect(analytics.events.single.properties['questionCount'], 1);

    provider.selectAnswer('Салам');
    provider.submit();
    provider.nextQuestion();

    expect(provider.isSummary, isTrue);
    expect(analytics.events.map((event) => event.name), [
      'quiz_started',
      'quiz_completed',
    ]);
    expect(analytics.events.last.properties['mainCorrect'], 1);
    expect(analytics.events.last.properties['mainAccuracyPercent'], 100);
    expect(analytics.events.last.properties['reviewSucceeded'], isTrue);
  });
}
