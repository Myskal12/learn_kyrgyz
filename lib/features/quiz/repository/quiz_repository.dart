import '../../../core/services/firebase_service.dart';
import '../../../core/services/offline_catalog_cache_service.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../data/models/quiz_question_model.dart';
import '../../learning/repository/words_repository.dart';
import '../../../data/models/word_model.dart';

class QuizRepository {
  QuizRepository(this._firebase, this._wordsRepository, this._offlineCache);

  final FirebaseService _firebase;
  final WordsRepository _wordsRepository;
  final OfflineCatalogCacheService _offlineCache;

  Future<List<QuizQuestionModel>> fetchQuestions(
    String categoryId, {
    int limit = 20,
    LearningDirection direction = LearningDirection.kyToEn,
  }) async {
    await _wordsRepository.ensureWordsLoaded(categoryId);

    final cached = await _offlineCache.readQuizQuestions(categoryId, direction);

    try {
      final remote = await _firebase.fetchQuizQuestions(
        categoryId,
        limit: limit,
      );
      if (remote.isNotEmpty) {
        final normalized = remote
            .map((q) => _normalizeRemoteQuestion(q, categoryId, direction))
            .toList();
        await _offlineCache.writeQuizQuestions(
          categoryId,
          direction,
          normalized,
        );
        return normalized;
      }
    } catch (_) {}

    if (cached.isNotEmpty) {
      return cached.take(limit).toList();
    }

    return _fallbackFromWords(categoryId, limit: limit, direction: direction);
  }

  QuizQuestionModel _normalizeRemoteQuestion(
    QuizQuestionModel question,
    String categoryId,
    LearningDirection direction,
  ) {
    if (direction == LearningDirection.kyToEn) {
      final prompt = question.correct.trim();
      final correct = question.question.trim();
      return QuizQuestionModel(
        id: question.id,
        question: prompt,
        correct: correct,
        options: _buildEnglishOptionsFromText(correct),
        category: question.category.isNotEmpty ? question.category : categoryId,
        level: question.level,
        wordId: question.wordId,
      );
    }
    final deduped = <String>{};
    for (final option in question.options) {
      final trimmed = option.trim();
      if (trimmed.isNotEmpty) deduped.add(trimmed);
    }
    if (question.correct.trim().isNotEmpty) {
      deduped.add(question.correct.trim());
    }

    final options = deduped.toList();
    if (options.length < 4) {
      final pool =
          _wordsRepository.allWords
              .map((w) => w.kyrgyz.trim())
              .where((k) => k.isNotEmpty && k != question.correct.trim())
              .toList()
            ..shuffle();
      for (final candidate in pool) {
        if (options.length >= 4) break;
        if (!options.contains(candidate)) options.add(candidate);
      }
      while (options.length < 4) {
        options.add(question.correct.trim());
      }
    }
    if (options.length > 4) {
      options.removeRange(4, options.length);
    }
    options.shuffle();

    return QuizQuestionModel(
      id: question.id,
      question: question.question,
      correct: question.correct,
      options: options,
      category: question.category.isNotEmpty ? question.category : categoryId,
      level: question.level,
      wordId: question.wordId,
    );
  }

  List<QuizQuestionModel> _fallbackFromWords(
    String categoryId, {
    required int limit,
    required LearningDirection direction,
  }) {
    final words = List<WordModel>.of(
      _wordsRepository.getCachedWords(categoryId),
    );
    if (words.isEmpty) {
      words.addAll(_wordsRepository.allWords.take(limit));
    }
    words.shuffle();
    final selected = words.take(limit).toList();
    return selected.map((word) {
      if (direction == LearningDirection.kyToEn) {
        return QuizQuestionModel(
          id: word.id,
          question: word.kyrgyz,
          correct: word.english,
          options: _buildEnglishOptions(word),
          category: categoryId,
          level: 1,
          wordId: word.id,
        );
      }
      return QuizQuestionModel(
        id: word.id,
        question: word.english,
        correct: word.kyrgyz,
        options: _buildOptions(word),
        category: categoryId,
        level: 1,
        wordId: word.id,
      );
    }).toList();
  }

  List<String> _buildOptions(WordModel word) {
    final pool =
        _wordsRepository.allWords.where((w) => w.id != word.id).toList()
          ..shuffle();
    final options = <String>[word.kyrgyz];
    for (final candidate in pool) {
      if (options.length >= 4) break;
      options.add(candidate.kyrgyz);
    }
    while (options.length < 4) {
      options.add(word.kyrgyz);
    }
    options.shuffle();
    return options;
  }

  List<String> _buildEnglishOptions(WordModel word) {
    return _buildEnglishOptionsFromText(word.english, excludedId: word.id);
  }

  List<String> _buildEnglishOptionsFromText(
    String correct, {
    String? excludedId,
  }) {
    final pool =
        _wordsRepository.allWords
            .where((w) => excludedId == null || w.id != excludedId)
            .toList()
          ..shuffle();
    final options = <String>[correct];
    for (final candidate in pool) {
      if (options.length >= 4) break;
      options.add(candidate.english);
    }
    while (options.length < 4) {
      options.add(correct);
    }
    options.shuffle();
    return options;
  }
}
