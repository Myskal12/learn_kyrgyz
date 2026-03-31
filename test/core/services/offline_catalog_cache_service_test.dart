import 'package:flutter_test/flutter_test.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';
import 'package:learn_kyrgyz/core/services/offline_catalog_cache_service.dart';
import 'package:learn_kyrgyz/core/utils/learning_direction.dart';
import 'package:learn_kyrgyz/data/models/category_model.dart';
import 'package:learn_kyrgyz/data/models/quiz_question_model.dart';
import 'package:learn_kyrgyz/data/models/sentence_model.dart';
import 'package:learn_kyrgyz/data/models/word_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OfflineCatalogCacheService', () {
    late OfflineCatalogCacheService cache;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      cache = OfflineCatalogCacheService(LocalStorageService(prefs));
    });

    test('round-trips catalog entities', () async {
      final categories = [
        CategoryModel(
          id: 'travel',
          title: 'Саякат',
          description: 'Жолго байланышкан сөздөр',
          wordsCount: 3,
        ),
      ];
      final words = [
        const WordModel(
          id: 'travel_ticket',
          english: 'ticket',
          kyrgyz: 'Билет',
          category: 'travel',
        ),
      ];
      final sentences = [
        const SentenceModel(
          id: 's1',
          en: 'I bought a ticket',
          ky: 'Мен билет сатып алдым',
          category: 'travel',
          wordId: 'travel_ticket',
        ),
      ];
      final questions = [
        const QuizQuestionModel(
          id: 'q1',
          question: 'ticket',
          correct: 'Билет',
          options: ['Билет', 'Поезд', 'Жол', 'Шаар'],
          category: 'travel',
          level: 1,
          wordId: 'travel_ticket',
        ),
      ];

      await cache.writeCategories(categories);
      await cache.writeWords('travel', words);
      await cache.writeSentences('travel', sentences);
      await cache.writeQuizQuestions(
        'travel',
        LearningDirection.enToKy,
        questions,
      );

      expect((await cache.readCategories()).single.title, 'Саякат');
      expect((await cache.readWords('travel')).single.english, 'ticket');
      expect(
        (await cache.readSentences('travel')).single.wordId,
        'travel_ticket',
      );
      expect(
        (await cache.readQuizQuestions(
          'travel',
          LearningDirection.enToKy,
        )).single.correct,
        'Билет',
      );
    });
  });
}
