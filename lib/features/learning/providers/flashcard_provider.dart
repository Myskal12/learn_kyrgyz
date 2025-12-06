import 'package:flutter/material.dart';

import '../../../data/models/word_model.dart';
import '../../profile/providers/progress_provider.dart';
import '../repository/words_repository.dart';

class FlashcardProvider extends ChangeNotifier {
  FlashcardProvider(this._repo, this._progress);

  final WordsRepository _repo;
  final ProgressProvider _progress;

  List<WordModel> _words = [];
  int _index = 0;
  bool _loading = false;
  bool _showTranslation = false;

  List<WordModel> get words => _words;
  int get index => _index;
  bool get isLoading => _loading;
  WordModel? get current => _words.isNotEmpty ? _words[_index] : null;
  bool get showTranslation => _showTranslation;

  Future<void> load(String categoryId) async {
    _loading = true;
    notifyListeners();
    _words = await _repo.fetchWordsByCategory(categoryId);
    _index = 0;
    _showTranslation = false;
    _loading = false;
    notifyListeners();
  }

  void next() {
    if (_words.isEmpty) return;
    _index = (_index + 1) % _words.length;
    _showTranslation = false;
    notifyListeners();
  }

  void previous() {
    if (_words.isEmpty) return;
    _index = (_index - 1 + _words.length) % _words.length;
    _showTranslation = false;
    notifyListeners();
  }

  void toggleTranslation() {
    _showTranslation = !_showTranslation;
    if (_showTranslation && current != null) {
      _progress.markWordSeen(current!.id);
    }
    notifyListeners();
  }

  void markMastered() {
    if (current == null) return;
    _progress.markWordMastered(current!.id);
    notifyListeners();
  }
}
