import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_kyrgyz/core/services/analytics_service.dart';
import 'package:learn_kyrgyz/core/services/firebase_service.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';
import 'package:learn_kyrgyz/data/models/sentence_model.dart';
import 'package:learn_kyrgyz/data/models/user_progress_model.dart';
import 'package:learn_kyrgyz/data/models/word_model.dart';
import 'package:learn_kyrgyz/features/learning/providers/flashcard_provider.dart';
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

class FakeWordsRepository implements WordsRepository {
  FakeWordsRepository(this._wordsByCategory);

  final Map<String, List<WordModel>> _wordsByCategory;

  @override
  List<WordModel> get allWords =>
      _wordsByCategory.values.expand((x) => x).toList();

  @override
  Future<List<WordModel>> fetchWordsByCategory(
    String categoryId, {
    bool forceRefresh = false,
  }) async => List<WordModel>.of(_wordsByCategory[categoryId] ?? const []);

  @override
  Future<void> ensureWordsLoaded(String categoryId) async {}

  @override
  Future<void> prefetchCategories(Iterable<String> categoryIds) async {}

  @override
  WordModel? findByEnglish(String english) {
    for (final word in allWords) {
      if (word.english == english) return word;
    }
    return null;
  }

  @override
  WordModel? findById(String id) {
    for (final word in allWords) {
      if (word.id == id) return word;
    }
    return null;
  }

  @override
  WordModel? findByKyrgyz(String kyrgyz) {
    for (final word in allWords) {
      if (word.kyrgyz == kyrgyz) return word;
    }
    return null;
  }

  @override
  List<WordModel> getCachedWords(String categoryId) =>
      List<WordModel>.of(_wordsByCategory[categoryId] ?? const []);
}

class FakeSentencesRepository implements SentencesRepository {
  FakeSentencesRepository(this._sentencesByCategory);

  final Map<String, List<SentenceModel>> _sentencesByCategory;

  @override
  Future<List<SentenceModel>> fetchSentencesByCategory(
    String categoryId, {
    int limit = 80,
    bool forceRefresh = false,
  }) async =>
      List<SentenceModel>.of(_sentencesByCategory[categoryId] ?? const []);

  @override
  List<SentenceModel> getCachedSentences(String categoryId) =>
      List<SentenceModel>.of(_sentencesByCategory[categoryId] ?? const []);
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

void main() {
  group('FlashcardProvider', () {
    late ProgressProvider progressProvider;
    late FlashcardProvider flashcardProvider;
    late FakeAnalyticsService analytics;

    setUp(() {
      analytics = FakeAnalyticsService();
      progressProvider = ProgressProvider(
        FakeLocalStorageService(),
        FakeFirebaseService(),
      );
      flashcardProvider = FlashcardProvider(
        FakeWordsRepository({
          'basics': const [
            WordModel(id: 'hello', english: 'Hello', kyrgyz: 'Салам'),
          ],
        }),
        FakeSentencesRepository(const {}),
        progressProvider,
        analytics: analytics,
      );
    });

    test(
      'reveal shows translation without counting a duplicate attempt',
      () async {
        await flashcardProvider.load('basics');

        flashcardProvider.reveal();
        flashcardProvider.reveal();

        expect(flashcardProvider.showTranslation, isTrue);
        expect(progressProvider.totalReviewSessions, 0);

        flashcardProvider.markAnswer(true);
        expect(progressProvider.totalReviewSessions, 1);
      },
    );

    test('review mode loads only due words for the category', () async {
      progressProvider.recordWordAttempt('hello', isCorrect: false);
      progressProvider.recordWordAttempt('easy', isCorrect: true);
      progressProvider.recordWordAttempt('easy', isCorrect: true);

      flashcardProvider = FlashcardProvider(
        FakeWordsRepository({
          'basics': const [
            WordModel(id: 'hello', english: 'Hello', kyrgyz: 'Салам'),
            WordModel(id: 'easy', english: 'Thanks', kyrgyz: 'Рахмат'),
          ],
        }),
        FakeSentencesRepository(const {}),
        progressProvider,
        analytics: analytics,
      );

      await flashcardProvider.load(
        'basics',
        mode: FlashcardSessionMode.reviewDue,
      );

      expect(flashcardProvider.isReviewQueueSession, isTrue);
      expect(flashcardProvider.totalWords, 1);
      expect(flashcardProvider.current?.id, 'hello');
    });

    test('tracks flashcard session lifecycle', () async {
      await flashcardProvider.load('basics');

      expect(analytics.events.map((event) => event.name), [
        'flashcards_started',
      ]);
      expect(analytics.events.first.properties['deckSize'], 1);

      flashcardProvider.reveal();
      flashcardProvider.markAnswer(true);

      expect(analytics.events.map((event) => event.name), [
        'flashcards_started',
        'flashcards_completed',
      ]);
      expect(analytics.events.last.properties['accuracyPercent'], 100);
      expect(analytics.events.last.properties['correctCount'], 1);
    });
  });
}
