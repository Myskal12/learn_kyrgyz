import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/services/analytics_service.dart';
import '../../../data/models/sentence_model.dart';
import '../../../data/models/word_model.dart';
import '../../profile/providers/progress_provider.dart';
import '../repository/sentences_repository.dart';
import '../repository/words_repository.dart';

enum FlashcardStage { learning, review, completed }

enum FlashcardSessionMode { fullDeck, reviewDue }

class FlashcardProvider extends ChangeNotifier {
  FlashcardProvider(
    this._repo,
    this._sentencesRepo,
    this._progress, {
    AnalyticsService? analytics,
  }) : _analytics = analytics ?? const NoopAnalyticsService();

  final WordsRepository _repo;
  final SentencesRepository _sentencesRepo;
  final ProgressProvider _progress;
  final AnalyticsService _analytics;

  List<WordModel> _allWords = [];
  List<WordModel> _deck = [];
  Map<String, SentenceModel> _sentencesByWordId = {};
  int _index = 0;
  bool _loading = false;
  bool _showTranslation = false;
  FlashcardStage _stage = FlashcardStage.learning;
  FlashcardSessionMode _sessionMode = FlashcardSessionMode.fullDeck;
  final List<WordModel> _pendingReview = [];
  final List<WordModel> _mistakeHistory = [];
  int _correctCount = 0;
  int _wrongCount = 0;
  String? _errorMessage;
  String _categoryId = '';
  bool _completionTracked = false;

  List<WordModel> get words => _deck;
  int get index => _index;
  bool get isLoading => _loading;
  WordModel? get current => _deck.isNotEmpty ? _deck[_index] : null;
  SentenceModel? get currentSentence {
    final word = current;
    if (word == null) return null;
    return _sentencesByWordId[word.id];
  }

  bool get showTranslation => _showTranslation;
  FlashcardStage get stage => _stage;
  FlashcardSessionMode get sessionMode => _sessionMode;
  bool get isReviewQueueSession =>
      _sessionMode == FlashcardSessionMode.reviewDue;
  int get totalWords => _allWords.length;
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;
  int get accuracyPercent {
    final total = _correctCount + _wrongCount;
    if (total == 0) return 0;
    return ((_correctCount / total) * 100).round();
  }

  List<WordModel> get mistakes => List.unmodifiable(_mistakeHistory);
  String? get errorMessage => _errorMessage;

  Future<void> load(
    String categoryId, {
    FlashcardSessionMode mode = FlashcardSessionMode.fullDeck,
  }) async {
    _categoryId = categoryId;
    _sessionMode = mode;
    _completionTracked = false;
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    _sentencesByWordId = {};
    try {
      final wordsFuture = _repo.fetchWordsByCategory(categoryId);
      List<SentenceModel> sentences = const [];
      try {
        sentences = await _sentencesRepo.fetchSentencesByCategory(categoryId);
      } catch (_) {
        sentences = const [];
      }
      _sentencesByWordId = _indexSentences(sentences);

      final categoryWords = await wordsFuture;
      _allWords = _selectSessionWords(categoryWords, mode);
      _deck = List.of(_allWords);
      _index = 0;
      _showTranslation = false;
      _stage = FlashcardStage.learning;
      _pendingReview.clear();
      _mistakeHistory.clear();
      _correctCount = 0;
      _wrongCount = 0;
      await _trackSessionStarted();
    } catch (_) {
      _errorMessage =
          'Карточкалар жүктөлгөн жок. Интернетти текшерип кайра аракет кылыңыз.';
      _allWords = [];
      _deck = [];
      _index = 0;
      _showTranslation = false;
      _stage = FlashcardStage.learning;
      _pendingReview.clear();
      _mistakeHistory.clear();
      _correctCount = 0;
      _wrongCount = 0;
      _completionTracked = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<WordModel> _selectSessionWords(
    List<WordModel> words,
    FlashcardSessionMode mode,
  ) {
    switch (mode) {
      case FlashcardSessionMode.fullDeck:
        return List<WordModel>.of(words);
      case FlashcardSessionMode.reviewDue:
        return _progress.reviewDueWords(words);
    }
  }

  Map<String, SentenceModel> _indexSentences(List<SentenceModel> sentences) {
    final map = <String, SentenceModel>{};
    for (final sentence in sentences) {
      final wordId = (sentence.wordId ?? '').trim();
      if (wordId.isNotEmpty && !map.containsKey(wordId)) {
        map[wordId] = sentence;
        continue;
      }

      final fallback = sentence.wordEn.trim();
      if (fallback.isNotEmpty && !map.containsKey(fallback)) {
        map[fallback] = sentence;
      }
      final fallbackKy = sentence.wordKy.trim();
      if (fallbackKy.isNotEmpty && !map.containsKey(fallbackKy)) {
        map[fallbackKy] = sentence;
      }
    }
    return map;
  }

  Future<void> _trackSessionStarted() {
    if (_categoryId.isEmpty) return Future.value();
    return _analytics.track(
      'flashcards_started',
      properties: {
        'categoryId': _categoryId,
        'mode': _sessionMode.name,
        'deckSize': _allWords.length,
      },
    );
  }

  void _trackSessionCompleted() {
    if (_completionTracked || _categoryId.isEmpty) return;
    _completionTracked = true;
    unawaited(
      _analytics.track(
        'flashcards_completed',
        properties: {
          'categoryId': _categoryId,
          'mode': _sessionMode.name,
          'totalWords': _allWords.length,
          'correctCount': _correctCount,
          'wrongCount': _wrongCount,
          'accuracyPercent': accuracyPercent,
          'mistakeCount': _mistakeHistory.length,
          'usedReviewStage': _mistakeHistory.isNotEmpty,
        },
      ),
    );
  }

  void reveal() {
    if (_showTranslation || current == null) return;
    _showTranslation = true;
    notifyListeners();
  }

  void markAnswer(bool isCorrect) {
    final word = current;
    if (word == null) return;
    if (isCorrect) {
      _correctCount++;
      _progress.recordWordAttempt(word.id, isCorrect: true);
      _pendingReview.removeWhere((w) => w.id == word.id);
    } else {
      _wrongCount++;
      if (_stage == FlashcardStage.learning &&
          !_mistakeHistory.any((w) => w.id == word.id)) {
        _mistakeHistory.add(word);
      }
      final exists = _pendingReview.any((item) => item.id == word.id);
      if (!exists) {
        _pendingReview.add(word);
      }
      _progress.recordWordAttempt(word.id, isCorrect: false);
    }
    _next();
  }

  void _next() {
    if (_deck.isEmpty) {
      _completeStage();
      return;
    }
    _showTranslation = false;
    _index++;
    if (_index >= _deck.length) {
      _completeStage();
    }
    notifyListeners();
  }

  void _completeStage() {
    if (_pendingReview.isNotEmpty) {
      _deck = List.of(_pendingReview);
      _pendingReview.clear();
      _index = 0;
      _stage = FlashcardStage.review;
      _showTranslation = false;
    } else {
      _deck = [];
      _index = 0;
      _stage = FlashcardStage.completed;
      _trackSessionCompleted();
    }
  }

  void restart() {
    _deck = List.of(_allWords);
    _index = 0;
    _stage = FlashcardStage.learning;
    _showTranslation = false;
    _pendingReview.clear();
    _mistakeHistory.clear();
    _correctCount = 0;
    _wrongCount = 0;
    _completionTracked = false;
    notifyListeners();
  }

  void reviewMistakesOnly() {
    if (_mistakeHistory.isEmpty) return;
    _deck = List.of(_mistakeHistory);
    _index = 0;
    _stage = FlashcardStage.review;
    _showTranslation = false;
    _pendingReview.clear();
    _correctCount = 0;
    _wrongCount = 0;
    _completionTracked = false;
    notifyListeners();
  }
}

final flashcardProvider = ChangeNotifierProvider<FlashcardProvider>((ref) {
  return FlashcardProvider(
    ref.read(wordsRepositoryProvider),
    ref.read(sentencesRepositoryProvider),
    ref.read(progressProvider),
    analytics: ref.read(analyticsServiceProvider),
  );
});
