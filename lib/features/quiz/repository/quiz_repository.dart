import '../../../core/services/firebase_service.dart';
import '../../../data/models/quiz_question_model.dart';
import '../../learning/repository/words_repository.dart';
import '../../../data/models/word_model.dart';

class QuizRepository {
  QuizRepository(this._firebase, this._wordsRepository);

  final FirebaseService _firebase;
  final WordsRepository _wordsRepository;

  Future<List<QuizQuestionModel>> fetchQuestions(
    String categoryId, {
    int limit = 20,
  }) async {
    final remote = await _firebase.fetchQuizQuestions(categoryId, limit: limit);
    if (remote.isNotEmpty) {
      return remote
          .map((q) => _normalizeRemoteQuestion(q, categoryId))
          .toList();
    }
    return _fallbackFromWords(categoryId, limit: limit);
  }

  QuizQuestionModel _normalizeRemoteQuestion(
    QuizQuestionModel question,
    String categoryId,
  ) {
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
  }) {
    final words = List<WordModel>.of(
      _wordsRepository.getCachedWords(categoryId),
    );
    if (words.isEmpty) {
      words.addAll(_wordsRepository.allWords.take(limit));
    }
    words.shuffle();
    final selected = words.take(limit).toList();
    return selected
        .map(
          (word) => QuizQuestionModel(
            id: word.id,
            question: word.english,
            correct: word.kyrgyz,
            options: _buildOptions(word),
            category: categoryId,
            level: 1,
            wordId: word.id,
          ),
        )
        .toList();
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
}
