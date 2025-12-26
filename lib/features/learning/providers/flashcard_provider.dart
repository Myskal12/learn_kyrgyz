import 'package:flutter/material.dart';

import '../../../data/models/sentence_model.dart';
import '../../../data/models/word_model.dart';
import '../../profile/providers/progress_provider.dart';
import '../repository/sentences_repository.dart';
import '../repository/words_repository.dart';

enum FlashcardStage { learning, review, completed }

class FlashcardProvider extends ChangeNotifier {
  FlashcardProvider(this._repo, this._sentencesRepo, this._progress);

  final WordsRepository _repo;
  final SentencesRepository _sentencesRepo;
  final ProgressProvider _progress;

  List<WordModel> _allWords = [];
  List<WordModel> _deck = [];
  Map<String, SentenceModel> _sentencesByWordId = {};
  int _index = 0;
  bool _loading = false;
  bool _showTranslation = false;
  FlashcardStage _stage = FlashcardStage.learning;
  final List<WordModel> _pendingReview = [];
  final List<WordModel> _mistakeHistory = [];
  int _correctCount = 0;
  int _wrongCount = 0;

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
  int get totalWords => _allWords.length;
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;
  List<WordModel> get mistakes => List.unmodifiable(_mistakeHistory);

  Future<void> load(String categoryId) async {
    _loading = true;
    notifyListeners();
    _sentencesByWordId = {};
    final wordsFuture = _repo.fetchWordsByCategory(categoryId);
    List<SentenceModel> sentences = const [];
    try {
      sentences = await _sentencesRepo.fetchSentencesByCategory(categoryId);
    } catch (_) {
      sentences = const [];
    }
    _sentencesByWordId = _indexSentences(sentences);

    _allWords = await wordsFuture;
    _deck = List.of(_allWords);
    _index = 0;
    _showTranslation = false;
    _stage = FlashcardStage.learning;
    _pendingReview.clear();
    _mistakeHistory.clear();
    _correctCount = 0;
    _wrongCount = 0;
    _loading = false;
    notifyListeners();
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

  void reveal() {
    _showTranslation = !_showTranslation;
    if (_showTranslation && current != null) {
      _progress.markWordSeen(current!.id);
    }
    notifyListeners();
  }

  void markAnswer(bool isCorrect) {
    final word = current;
    if (word == null) return;
    if (isCorrect) {
      _correctCount++;
      _progress.markWordMastered(word.id);
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
      _progress.markWordSeen(word.id);
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
    notifyListeners();
  }
}
