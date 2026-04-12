import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../data/models/quiz_question_model.dart';
import '../../learning/repository/words_repository.dart';
import '../../profile/providers/progress_provider.dart';
import '../repository/quiz_repository.dart';

enum QuizStage { active, summary }

class QuizProvider extends ChangeNotifier {
  QuizProvider(
    this._quizRepository,
    this._wordsRepository,
    this._progress, {
    AnalyticsService? analytics,
  }) : _analytics = analytics ?? const NoopAnalyticsService();

  final QuizRepository _quizRepository;
  final WordsRepository _wordsRepository;
  final ProgressProvider _progress;
  final AnalyticsService _analytics;

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
  String? _errorMessage;
  String _categoryId = '';
  bool _completionTracked = false;
  DateTime? _sessionStartedAt;

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
  String? get errorMessage => _errorMessage;
  int get mainAccuracyPercent {
    final total = _mainCorrect + _mainWrong;
    if (total == 0) return 0;
    return ((_mainCorrect / total) * 100).round();
  }

  Future<void> start(String categoryId) async {
    _categoryId = categoryId;
    _completionTracked = false;
    _isLoading = true;
    _errorMessage = null;
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
    _sessionStartedAt = DateTime.now();
    notifyListeners();

    try {
      final questions = await _quizRepository.fetchQuestions(
        categoryId,
        direction: _direction,
      );
      _questions = List.of(questions);
      _originalQuestions = List.of(_questions);
      _resetOptions();
      await _trackSessionStarted();
    } catch (_) {
      _errorMessage =
          'Квиз жүктөлгөн жок. Интернетти текшерип кайра аракет кылыңыз.';
      _questions = [];
      _originalQuestions = [];
      _stage = QuizStage.active;
      _answered = false;
      _selected = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _trackSessionStarted() {
    if (_categoryId.isEmpty) return Future.value();
    return _analytics.track(
      'quiz_started',
      properties: {
        'categoryId': _categoryId,
        'direction': _direction.storageValue,
        'questionCount': _questions.length,
      },
    );
  }

  void _trackSessionCompleted() {
    if (_completionTracked) return;
    _completionTracked = true;
    _recordLearningDuration();
    if (_categoryId.isEmpty) return;
    unawaited(
      _analytics.track(
        'quiz_completed',
        properties: {
          'categoryId': _categoryId,
          'direction': _direction.storageValue,
          'questionCount': _originalQuestions.length,
          'mainCorrect': _mainCorrect,
          'mainWrong': _mainWrong,
          'reviewCorrect': _reviewCorrect,
          'reviewWrong': _reviewWrong,
          'mainAccuracyPercent': mainAccuracyPercent,
          'reviewRoundUsed': _firstAttemptMistakes.isNotEmpty,
          'reviewSucceeded': reviewSucceeded,
          'unresolvedMistakes': _unresolvedMistakes.length,
        },
      ),
    );
  }

  void _recordLearningDuration() {
    final startedAt = _sessionStartedAt;
    if (startedAt == null) return;
    final elapsed = DateTime.now().difference(startedAt);
    _progress.recordLearningDuration(elapsed);
    _sessionStartedAt = null;
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
    _progress.recordWordAttempt(word.id, isCorrect: mastered);
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
        _trackSessionCompleted();
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
    _completionTracked = false;
    _sessionStartedAt = DateTime.now();
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
    _completionTracked = false;
    _sessionStartedAt = DateTime.now();
    _resetOptions();
    notifyListeners();
  }
}

final quizProvider = ChangeNotifierProvider<QuizProvider>((ref) {
  return QuizProvider(
    ref.read(quizRepositoryProvider),
    ref.read(wordsRepositoryProvider),
    ref.read(progressProvider),
    analytics: ref.read(analyticsServiceProvider),
  );
});
