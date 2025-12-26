import 'package:flutter/material.dart';

import '../../../core/utils/learning_direction.dart';
import '../../../data/models/quiz_question_model.dart';
import '../../learning/repository/words_repository.dart';
import '../../profile/providers/progress_provider.dart';
import '../repository/quiz_repository.dart';

enum QuizStage { active, summary }

class QuizProvider extends ChangeNotifier {
  QuizProvider(this._quizRepository, this._wordsRepository, this._progress);

  final QuizRepository _quizRepository;
  final WordsRepository _wordsRepository;
  final ProgressProvider _progress;

  bool _isLoading = false;
  QuizStage _stage = QuizStage.active;
  bool _isReviewRound = false;
  bool _answered = false;
  int _index = 0;
  String? _selected;
  int _mainCorrect = 0;
  int _mainWrong = 0;
  int _reviewCorrect = 0;
  int _reviewWrong = 0;
  LearningDirection _direction = LearningDirection.enToKy;

  List<QuizQuestionModel> _questions = [];
  List<QuizQuestionModel> _originalQuestions = [];
  final List<QuizQuestionModel> _pendingReview = [];
  final Map<String, QuizQuestionModel> _firstAttemptMistakes = {};
  final Map<String, QuizQuestionModel> _unresolvedMistakes = {};
  final Map<String, List<String>> _optionsCache = {};

  bool get isLoading => _isLoading;
  bool get isSummary => _stage == QuizStage.summary;
  bool get isReviewRound => _isReviewRound;
  bool get answered => _answered;
  int get index => _index;
  int get totalQuestions => _questions.length;
  int get correctAnswers => _mainCorrect;
  int get incorrectAnswers => _mainWrong;
  int get reviewCorrectAnswers => _reviewCorrect;
  int get reviewIncorrectAnswers => _reviewWrong;
  String? get selected => _selected;
  QuizQuestionModel? get currentQuestion =>
      _questions.isNotEmpty ? _questions[_index] : null;
  List<String> get options {
    final question = currentQuestion;
    if (question == null) return const [];
    return _optionsCache[question.id] ?? question.options;
  }

  double get progress {
    if (_questions.isEmpty) return 0;
    final answeredCount = _index + (_answered ? 1 : 0);
    return answeredCount / _questions.length;
  }

  List<QuizQuestionModel> get mistakeDetails =>
      _firstAttemptMistakes.values.toList();
  bool get reviewSucceeded => _unresolvedMistakes.isEmpty;
  int get unresolvedMistakesCount => _unresolvedMistakes.length;

  Future<void> start(String categoryId) async {
    _isLoading = true;
    _stage = QuizStage.active;
    _isReviewRound = false;
    _answered = false;
    _selected = null;
    _index = 0;
    _mainCorrect = 0;
    _mainWrong = 0;
    _reviewCorrect = 0;
    _reviewWrong = 0;
    _questions = [];
    _originalQuestions = [];
    _pendingReview.clear();
    _firstAttemptMistakes.clear();
    _unresolvedMistakes.clear();
    _optionsCache.clear();
    notifyListeners();

    final questions = await _quizRepository.fetchQuestions(
      categoryId,
      direction: _direction,
    );
    _questions = List.of(questions);
    _originalQuestions = List.of(_questions);
    _resetOptions();
    _isLoading = false;
    if (_questions.isEmpty) {
      _stage = QuizStage.summary;
    }
    notifyListeners();
  }

  Future<void> startWithDirection(
    String categoryId,
    LearningDirection direction,
  ) async {
    _direction = direction;
    await start(categoryId);
  }

  void _resetOptions() {
    _optionsCache.clear();
    for (final question in _questions) {
      final shuffled = List<String>.of(question.options);
      shuffled.shuffle();
      _optionsCache[question.id] = shuffled;
    }
    _answered = false;
    _selected = null;
  }

  void selectAnswer(String option) {
    if (_answered || currentQuestion == null) return;
    _selected = option;
    notifyListeners();
  }

  void submit() {
    if (_answered || currentQuestion == null || _selected == null) return;
    _answered = true;
    final question = currentQuestion!;
    final isCorrect = _selected == question.correct;
    if (!_isReviewRound) {
      if (isCorrect) {
        _mainCorrect++;
        _markProgress(question, true);
      } else {
        _mainWrong++;
        _pendingReview.add(question);
        _firstAttemptMistakes.putIfAbsent(question.id, () => question);
        _unresolvedMistakes[question.id] = question;
        _markProgress(question, false);
      }
      notifyListeners();
      return;
    }

    // Review round: one pass only. Track whether mistakes were fixed.
    if (isCorrect) {
      _reviewCorrect++;
      _unresolvedMistakes.remove(question.id);
      _markProgress(question, true);
    } else {
      _reviewWrong++;
      _markProgress(question, false);
    }
    notifyListeners();
  }

  void _markProgress(QuizQuestionModel question, bool mastered) {
    final word = question.wordId != null
        ? _wordsRepository.findById(question.wordId!)
        : (_direction == LearningDirection.kyToEn
            ? _wordsRepository.findByKyrgyz(question.question)
            : _wordsRepository.findByEnglish(question.question));
    if (word == null) return;
    if (mastered) {
      _progress.markWordMastered(word.id);
    } else {
      _progress.markWordSeen(word.id);
    }
  }

  void nextQuestion() {
    if (!_answered) return;
    if (_index >= _questions.length - 1) {
      if (!_isReviewRound && _pendingReview.isNotEmpty) {
        _questions = List.of(_pendingReview);
        _pendingReview.clear();
        _index = 0;
        _isReviewRound = true;
        _resetOptions();
      } else {
        _stage = QuizStage.summary;
        _answered = false;
        _selected = null;
      }
    } else {
      _index++;
      _answered = false;
      _selected = null;
    }
    notifyListeners();
  }

  void restartFull() {
    if (_originalQuestions.isEmpty) return;
    _questions = List.of(_originalQuestions);
    _index = 0;
    _mainCorrect = 0;
    _mainWrong = 0;
    _reviewCorrect = 0;
    _reviewWrong = 0;
    _pendingReview.clear();
    _firstAttemptMistakes.clear();
    _unresolvedMistakes.clear();
    _isReviewRound = false;
    _stage = QuizStage.active;
    _resetOptions();
    notifyListeners();
  }

  void reviewMistakesAgain() {
    final mistakes = mistakeDetails;
    if (mistakes.isEmpty) return;
    _questions = List.of(mistakes);
    _originalQuestions = List.of(mistakes);
    _pendingReview.clear();
    _firstAttemptMistakes.clear();
    _unresolvedMistakes.clear();
    _index = 0;
    _mainCorrect = 0;
    _mainWrong = 0;
    _reviewCorrect = 0;
    _reviewWrong = 0;
    _isReviewRound = false;
    _stage = QuizStage.active;
    _resetOptions();
    notifyListeners();
  }
}
