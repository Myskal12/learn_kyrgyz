import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_kyrgyz/core/services/firebase_service.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';
import 'package:learn_kyrgyz/core/services/offline_catalog_cache_service.dart';
import 'package:learn_kyrgyz/data/models/word_model.dart';
import 'package:learn_kyrgyz/features/learning/repository/words_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFirebaseService implements FirebaseService {
  final List<WordModel> _words;

  MockFirebaseService(this._words);

  @override
  List<WordModel> get allWords => _words;

  @override
  Future<List<WordModel>> fetchWordsByCategory(String categoryId) async {
    return [];
  }

  @override
  List<WordModel> getCachedWords(String categoryId) {
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

void main() {
  test('WordsRepository findById benchmark', () async {
    final int wordCount = 10000;
    final List<WordModel> words = List.generate(wordCount, (index) {
      return WordModel(
        id: 'word_$index',
        english: 'english_$index',
        kyrgyz: 'kyrgyz_$index',
      );
    });

    final mockService = MockFirebaseService(words);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);
    final cache = OfflineCatalogCacheService(storage);
    final repository = WordsRepository(mockService, cache);

    final targetId = 'word_${wordCount - 1}';

    final stopwatch = Stopwatch()..start();
    final iterations = 1000;

    for (int i = 0; i < iterations; i++) {
      final result = repository.findById(targetId);
      if (result == null || result.id != targetId) {
        fail('Word not found or incorrect word found');
      }
    }

    stopwatch.stop();

    debugPrint('--------------------------------------------------');
    debugPrint('Benchmark Results:');
    debugPrint(
      'Total time for $iterations iterations: ${stopwatch.elapsedMilliseconds} ms',
    );
    debugPrint(
      'Average time per call: ${stopwatch.elapsedMicroseconds / iterations} µs',
    );
    debugPrint('--------------------------------------------------');
  });
}
