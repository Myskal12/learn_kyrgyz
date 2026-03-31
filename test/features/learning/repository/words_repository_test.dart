import 'package:flutter_test/flutter_test.dart';
import 'package:learn_kyrgyz/core/services/firebase_service.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';
import 'package:learn_kyrgyz/core/services/offline_catalog_cache_service.dart';
import 'package:learn_kyrgyz/data/models/word_model.dart';
import 'package:learn_kyrgyz/features/learning/repository/words_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFirebaseService implements FirebaseService {
  _FakeFirebaseService({
    required this.allWordsSeed,
    required this.remoteWordsByCategory,
    this.throwOnFetch = false,
  });

  final List<WordModel> allWordsSeed;
  final Map<String, List<WordModel>> remoteWordsByCategory;
  final bool throwOnFetch;

  @override
  List<WordModel> get allWords => allWordsSeed;

  @override
  Future<List<WordModel>> fetchWordsByCategory(String categoryId) async {
    if (throwOnFetch) {
      throw Exception('offline');
    }
    return remoteWordsByCategory[categoryId] ?? const [];
  }

  @override
  List<WordModel> getCachedWords(String categoryId) {
    return remoteWordsByCategory[categoryId] ?? const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('WordsRepository', () {
    late OfflineCatalogCacheService cache;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      cache = OfflineCatalogCacheService(LocalStorageService(prefs));
    });

    test('uses persisted offline words when remote fetch fails', () async {
      const cachedWord = WordModel(
        id: 'remote_new',
        english: 'airport',
        kyrgyz: 'Абамайдан',
        category: 'travel',
      );
      await cache.writeWords('travel', const [cachedWord]);

      final repository = WordsRepository(
        _FakeFirebaseService(
          allWordsSeed: const [],
          remoteWordsByCategory: const {},
          throwOnFetch: true,
        ),
        cache,
      );

      final result = await repository.fetchWordsByCategory('travel');

      expect(result.single.id, 'remote_new');
      expect(repository.findById('remote_new')?.english, 'airport');
    });

    test('prefetch hydrates remote-only words into lookup map', () async {
      const remoteWord = WordModel(
        id: 'festival',
        english: 'festival',
        kyrgyz: 'Майрам',
        category: 'culture',
      );
      final repository = WordsRepository(
        _FakeFirebaseService(
          allWordsSeed: const [],
          remoteWordsByCategory: const {
            'culture': [remoteWord],
          },
        ),
        cache,
      );

      await repository.prefetchCategories(const ['culture']);

      expect(repository.findById('festival')?.kyrgyz, 'Майрам');
      expect(repository.allWords.any((word) => word.id == 'festival'), isTrue);
    });
  });
}
