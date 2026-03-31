import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/analytics_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/offline_catalog_cache_service.dart';
import '../../features/categories/repository/categories_repository.dart';
import '../../features/learning/repository/sentences_repository.dart';
import '../../features/learning/repository/words_repository.dart';
import '../../features/quiz/repository/quiz_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final firebaseServiceProvider = Provider<FirebaseService>(
  (ref) => FirebaseService(),
);

final localStorageServiceProvider = Provider<LocalStorageService>(
  (ref) => LocalStorageService(ref.watch(sharedPreferencesProvider)),
);

final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => LocalAnalyticsService(ref.watch(localStorageServiceProvider)),
);

final offlineCatalogCacheServiceProvider = Provider<OfflineCatalogCacheService>(
  (ref) => OfflineCatalogCacheService(ref.watch(localStorageServiceProvider)),
);

final categoriesRepositoryProvider = Provider<CategoriesRepository>(
  (ref) => CategoriesRepository(
    ref.read(firebaseServiceProvider),
    ref.read(offlineCatalogCacheServiceProvider),
  ),
);

final wordsRepositoryProvider = Provider<WordsRepository>(
  (ref) => WordsRepository(
    ref.read(firebaseServiceProvider),
    ref.read(offlineCatalogCacheServiceProvider),
  ),
);

final sentencesRepositoryProvider = Provider<SentencesRepository>(
  (ref) => SentencesRepository(
    ref.read(firebaseServiceProvider),
    ref.read(offlineCatalogCacheServiceProvider),
  ),
);

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => QuizRepository(
    ref.read(firebaseServiceProvider),
    ref.read(wordsRepositoryProvider),
    ref.read(offlineCatalogCacheServiceProvider),
  ),
);
