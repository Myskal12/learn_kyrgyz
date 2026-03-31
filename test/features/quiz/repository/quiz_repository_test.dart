import 'package:flutter_test/flutter_test.dart';
import 'package:learn_kyrgyz/core/services/firebase_service.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';
import 'package:learn_kyrgyz/core/services/offline_catalog_cache_service.dart';
import 'package:learn_kyrgyz/core/utils/learning_direction.dart';
import 'package:learn_kyrgyz/data/models/quiz_question_model.dart';
import 'package:learn_kyrgyz/data/models/word_model.dart';
import 'package:learn_kyrgyz/features/learning/repository/words_repository.dart';
import 'package:learn_kyrgyz/features/quiz/repository/quiz_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFirebaseService implements FirebaseService {
  _FakeFirebaseService({
    required this.words,
    required this.questionsByCategory,
  });

  final List<WordModel> words;
  final Map<String, List<QuizQuestionModel>> questionsByCategory;

  @override
  List<WordModel> get allWords => words;

  @override
  Future<List<WordModel>> fetchWordsByCategory(String categoryId) async {
    return words.where((word) => word.category == categoryId).toList();
  }

  @override
  List<WordModel> getCachedWords(String categoryId) {
    return words.where((word) => word.category == categoryId).toList();
  }

  @override
  Future<List<QuizQuestionModel>> fetchQuizQuestions(
    String categoryId, {
    int limit = 20,
  }) async {
    return questionsByCategory[categoryId] ?? const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('builds KY to EN questions without falling back to EN to KY', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cache = OfflineCatalogCacheService(LocalStorageService(prefs));

    const word = WordModel(
      id: 'travel_ticket',
      english: 'ticket',
      kyrgyz: 'Билет',
      category: 'travel',
    );
    const remoteQuestion = QuizQuestionModel(
      id: 'q1',
      question: 'ticket',
      correct: 'Билет',
      options: ['Билет', 'Поезд', 'Жол', 'Шаар'],
      category: 'travel',
      level: 1,
      wordId: 'travel_ticket',
    );

    final firebase = _FakeFirebaseService(
      words: const [word],
      questionsByCategory: const {
        'travel': [remoteQuestion],
      },
    );
    final wordsRepository = WordsRepository(firebase, cache);
    final repository = QuizRepository(firebase, wordsRepository, cache);

    final questions = await repository.fetchQuestions(
      'travel',
      direction: LearningDirection.kyToEn,
    );

    expect(questions.single.question, 'Билет');
    expect(questions.single.correct, 'ticket');
  });
}
