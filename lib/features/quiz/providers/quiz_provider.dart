import 'package:flutter/material.dart';

import '../../../data/models/word_model.dart';
import '../../profile/providers/progress_provider.dart';
import '../../learning/repository/words_repository.dart';

class QuizProvider extends ChangeNotifier {
  QuizProvider(this._repo, this._progress);

  final WordsRepository _repo;
  final ProgressProvider _progress;

  bool _isLoading = false;
  bool _isCompleted = false;
  bool _answered = false;
  int _score = 0;
  int _index = 0;
  String? _selected;
  List<WordModel> _questions = [];
  List<String> _options = [];

  bool get isLoading => _isLoading;
  bool get isCompleted => _isCompleted;
  bool get answered => _answered;
  int get score => _score;
  int get index => _index;
  String? get selected => _selected;
  WordModel? get currentWord =>
      _questions.isNotEmpty ? _questions[_index] : null;
  List<String> get options => _options;
  double get progress =>
      _questions.isEmpty ? 0 : (_index + (_answered ? 1 : 0)) / _questions.length;
  int get totalQuestions => _questions.length;

  Future<void> start(String categoryId) async {
    _isLoading = true;
    _isCompleted = false;
    _answered = false;
    _selected = null;
    _score = 0;
    _index = 0;
    notifyListeners();

    final words = await _repo.fetchWordsByCategory(categoryId);
    _questions = List<WordModel>.of(words);
    if (_questions.length > 8) {
      _questions.shuffle();
      _questions = _questions.take(8).toList();
    }
    if (_questions.length < 4) {
      final filler = _repo.allWords.where((w) => !_questions.contains(w)).take(4 - _questions.length);
      _questions.addAll(filler);
    }
    _isLoading = false;
    if (_questions.isEmpty) {
      _isCompleted = true;
    } else {
      _prepareOptions();
    }
    notifyListeners();
  }

  void _prepareOptions() {
    final current = currentWord;
    if (current == null) {
      _options = [];
      return;
    }
    final pool = _repo.allWords.where((word) => word.id != current.id).toList()..shuffle();
    final distractors = <String>{};
    for (final word in pool) {
      if (distractors.length >= 3) break;
      distractors.add(word.english);
    }
    if (distractors.length < 3) {
      for (final word in _repo.allWords) {
        if (word.id == current.id) continue;
        distractors.add(word.english);
        if (distractors.length >= 3) break;
      }
    }
    final list = [...distractors, current.english];
    while (list.length < 4) {
      list.add(current.english);
    }
    list.shuffle();
    _options = list;
    _answered = false;
    _selected = null;
  }

  void selectAnswer(String value) {
    if (_answered || currentWord == null) return;
    _answered = true;
    _selected = value;
    final correct = currentWord!.english;
    if (value == correct) {
      _score++;
      _progress.markWordMastered(currentWord!.id);
    } else {
      _progress.markWordSeen(currentWord!.id);
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (!_answered) return;
    if (_index >= _questions.length - 1) {
      _isCompleted = true;
    } else {
      _index++;
      _prepareOptions();
    }
    notifyListeners();
  }

  void restart() {
    if (_questions.isEmpty) return;
    _isCompleted = false;
    _score = 0;
    _index = 0;
    _prepareOptions();
    notifyListeners();
  }
}
