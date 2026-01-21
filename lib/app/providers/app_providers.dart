import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/firebase_service.dart';
import '../../core/services/local_storage_service.dart';
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

final wordsRepositoryProvider = Provider<WordsRepository>(
  (ref) => WordsRepository(ref.read(firebaseServiceProvider)),
);

final sentencesRepositoryProvider = Provider<SentencesRepository>(
  (ref) => SentencesRepository(ref.read(firebaseServiceProvider)),
);

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => QuizRepository(
    ref.read(firebaseServiceProvider),
    ref.read(wordsRepositoryProvider),
  ),
);
