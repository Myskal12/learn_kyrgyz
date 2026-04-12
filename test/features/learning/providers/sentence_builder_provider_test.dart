import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_kyrgyz/core/services/analytics_service.dart';
import 'package:learn_kyrgyz/core/services/firebase_service.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';
import 'package:learn_kyrgyz/core/utils/learning_direction.dart';
import 'package:learn_kyrgyz/data/models/sentence_model.dart';
import 'package:learn_kyrgyz/data/models/user_progress_model.dart';
import 'package:learn_kyrgyz/data/models/word_model.dart';
import 'package:learn_kyrgyz/features/learning/providers/sentence_builder_provider.dart';
import 'package:learn_kyrgyz/features/learning/repository/sentences_repository.dart';
import 'package:learn_kyrgyz/features/learning/repository/words_repository.dart';
import 'package:learn_kyrgyz/features/profile/providers/progress_provider.dart';

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
    required int totalXp,
    required int streakDays,
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

class FakeSentencesRepository implements SentencesRepository {
  FakeSentencesRepository(this._sentences);

  final List<SentenceModel> _sentences;

  @override
  Future<List<SentenceModel>> fetchSentencesByCategory(
    String categoryId, {
    int limit = 80,
    bool forceRefresh = false,
  }) async => List<SentenceModel>.of(_sentences);

  @override
  List<SentenceModel> getCachedSentences(String categoryId) =>
      List<SentenceModel>.of(_sentences);
}

void main() {
  test('tracks sentence builder session lifecycle', () async {
    final analytics = FakeAnalyticsService();
    final progress = ProgressProvider(
      FakeLocalStorageService(),
      FakeFirebaseService(),
    );
    final provider = SentenceBuilderProvider(
      FakeSentencesRepository([
        const SentenceModel(
          id: 's1',
          en: 'I am going',
          ky: 'Мен барам',
          wordId: 'go',
          wordEn: 'Go',
          wordKy: 'Баруу',
        ),
      ]),
      FakeWordsRepository([
        const WordModel(id: 'go', english: 'Go', kyrgyz: 'Баруу'),
      ]),
      progress,
      analytics: analytics,
    );

    await provider.load('basics', direction: LearningDirection.enToKy);

    expect(analytics.events.map((event) => event.name), [
      'sentence_builder_started',
    ]);
    expect(analytics.events.single.properties['sentenceCount'], 1);

    for (final tokenText in ['Мен', 'барам']) {
      final token = provider.availableTokens.firstWhere(
        (item) => item.text == tokenText,
      );
      provider.selectToken(token);
    }

    provider.check();
    provider.next();

    expect(provider.isCompleted, isTrue);
    expect(analytics.events.map((event) => event.name), [
      'sentence_builder_started',
      'sentence_builder_completed',
    ]);
    expect(analytics.events.last.properties['correctCount'], 1);
    expect(analytics.events.last.properties['accuracyPercent'], 100);
  });
}
