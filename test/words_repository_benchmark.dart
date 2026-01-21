import 'package:flutter_test/flutter_test.dart';
import 'package:learn_kyrgyz/core/services/firebase_service.dart';
import 'package:learn_kyrgyz/data/models/word_model.dart';
import 'package:learn_kyrgyz/features/learning/repository/words_repository.dart';

// Mock FirebaseService to avoid real dependencies and control data
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
    // Return null or throw depending on what's needed.
    // For this benchmark, we only need allWords and maybe fetchWordsByCategory logic.
    return null;
  }
}

void main() {
  test('WordsRepository findById benchmark', () async {
    // 1. Setup large dataset
    final int wordCount = 10000;
    final List<WordModel> words = List.generate(wordCount, (index) {
      return WordModel(
        id: 'word_$index',
        english: 'english_$index',
        kyrgyz: 'kyrgyz_$index',
      );
    });

    final mockService = MockFirebaseService(words);
    final repository = WordsRepository(mockService);

    // Target the last word to force worst-case scenario for linear search
    final targetId = 'word_${wordCount - 1}';

    // 2. Measure
    final stopwatch = Stopwatch()..start();
    final iterations = 1000;

    for (int i = 0; i < iterations; i++) {
      final result = repository.findById(targetId);
      if (result == null || result.id != targetId) {
        fail('Word not found or incorrect word found');
      }
    }

    stopwatch.stop();

    print('--------------------------------------------------');
    print('Benchmark Results:');
    print('Total time for $iterations iterations: ${stopwatch.elapsedMilliseconds} ms');
    print('Average time per call: ${stopwatch.elapsedMicroseconds / iterations} µs');
    print('--------------------------------------------------');
  });
}
