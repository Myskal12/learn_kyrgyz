import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../data/models/sentence_model.dart';
import '../../profile/providers/progress_provider.dart';
import '../repository/sentences_repository.dart';
import '../repository/words_repository.dart';

enum SentenceBuilderStage { active, completed }

class SentenceToken {
  const SentenceToken({required this.id, required this.text});

  final int id;
  final String text;
}

class SentenceBuilderProvider extends ChangeNotifier {
  SentenceBuilderProvider(
    this._sentencesRepo,
    this._wordsRepo,
    this._progress,
  );

  final SentencesRepository _sentencesRepo;
  final WordsRepository _wordsRepo;
  final ProgressProvider _progress;

  bool _isLoading = false;
  SentenceBuilderStage _stage = SentenceBuilderStage.active;
  int _index = 0;
  int _correct = 0;
  int _wrong = 0;
  bool _answered = false;
  bool _lastCorrect = false;
  String _categoryId = '';
  LearningDirection _direction = LearningDirection.enToKy;

  List<SentenceModel> _sentences = [];
  List<SentenceToken> _tokens = [];
  List<SentenceToken> _pool = [];
  final List<SentenceToken> _selected = [];
  final Set<int> _selectedIds = {};
  final List<SentenceModel> _mistakes = [];

  bool get isLoading => _isLoading;
  SentenceBuilderStage get stage => _stage;
  bool get isCompleted => _stage == SentenceBuilderStage.completed;
  LearningDirection get direction => _direction;
  int get index => _index;
  int get totalSentences => _sentences.length;
  int get correctCount => _correct;
  int get wrongCount => _wrong;
  bool get answered => _answered;
  bool get lastCorrect => _lastCorrect;
  bool get isLast => _sentences.isNotEmpty && _index >= _sentences.length - 1;
  SentenceModel? get current =>
      _sentences.isNotEmpty ? _sentences[_index] : null;
  List<SentenceToken> get selectedTokens => List.unmodifiable(_selected);
  List<SentenceToken> get availableTokens =>
      _pool.where((token) => !_selectedIds.contains(token.id)).toList();
  List<SentenceModel> get mistakes => List.unmodifiable(_mistakes);

  bool get canCheck =>
      !_answered && _tokens.isNotEmpty && _selected.length == _tokens.length;
  bool get canReset => !_answered && _selected.isNotEmpty;

  double get progress {
    if (_sentences.isEmpty) return 0;
    final answeredCount = _index + (_answered ? 1 : 0);
    return answeredCount / _sentences.length;
  }

  Future<void> load(
    String categoryId, {
    LearningDirection direction = LearningDirection.enToKy,
  }) async {
    _categoryId = categoryId;
    _direction = direction;
    _isLoading = true;
    _stage = SentenceBuilderStage.active;
    _index = 0;
    _correct = 0;
    _wrong = 0;
    _sentences = [];
    _mistakes.clear();
    _clearSelection();
    notifyListeners();

    List<SentenceModel> sentences = const [];
    try {
      sentences = await _sentencesRepo.fetchSentencesByCategory(categoryId);
    } catch (_) {
      sentences = _sentencesRepo.getCachedSentences(categoryId);
    }
    _sentences = sentences
        .where((s) => s.en.trim().isNotEmpty && s.ky.trim().isNotEmpty)
        .toList()
      ..shuffle();
    _index = 0;
    _prepareCurrent();
    _isLoading = false;
    notifyListeners();
  }

  void _prepareCurrent() {
    final sentence = current;
    if (sentence == null) {
      _tokens = [];
      _pool = [];
      _clearSelection();
      return;
    }
    final parts = _tokenize(_targetText(sentence));
    _tokens = parts
        .asMap()
        .entries
        .map((entry) => SentenceToken(id: entry.key, text: entry.value))
        .toList();
    _pool = List<SentenceToken>.of(_tokens)..shuffle();
    _clearSelection();
    _answered = false;
    _lastCorrect = false;
  }

  String _targetText(SentenceModel sentence) {
    return _direction == LearningDirection.enToKy ? sentence.ky : sentence.en;
  }

  void setDirection(LearningDirection direction) {
    if (_direction == direction) return;
    _direction = direction;
    _prepareCurrent();
    notifyListeners();
  }

  List<String> _tokenize(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const [];
    return trimmed.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  }

  void _clearSelection() {
    _selected.clear();
    _selectedIds.clear();
  }

  void selectToken(SentenceToken token) {
    if (_answered) return;
    if (_selectedIds.contains(token.id)) return;
    _selected.add(token);
    _selectedIds.add(token.id);
    notifyListeners();
  }

  void removeToken(SentenceToken token) {
    if (_answered) return;
    _selected.removeWhere((item) => item.id == token.id);
    _selectedIds.remove(token.id);
    notifyListeners();
  }

  void resetSelection() {
    if (_answered) return;
    _clearSelection();
    notifyListeners();
  }

  void check() {
    if (!canCheck) return;
    final sentence = current;
    if (sentence == null) return;
    _answered = true;
    _lastCorrect = _isSelectionCorrect();
    if (_lastCorrect) {
      _correct++;
      _markProgress(sentence, true);
    } else {
      _wrong++;
      if (!_mistakes.any((item) => item.id == sentence.id)) {
        _mistakes.add(sentence);
      }
      _markProgress(sentence, false);
    }
    notifyListeners();
  }

  bool _isSelectionCorrect() {
    if (_selected.length != _tokens.length) return false;
    for (var i = 0; i < _tokens.length; i++) {
      if (_selected[i].text != _tokens[i].text) return false;
    }
    return true;
  }

  void next() {
    if (!_answered) return;
    if (_sentences.isEmpty || _index >= _sentences.length - 1) {
      _stage = SentenceBuilderStage.completed;
      notifyListeners();
      return;
    }
    _index++;
    _prepareCurrent();
    notifyListeners();
  }

  Future<void> restart() async {
    if (_categoryId.isEmpty) return;
    await load(_categoryId);
  }

  void _markProgress(SentenceModel sentence, bool mastered) {
    final wordId = (sentence.wordId ?? '').trim();
    final wordEn = sentence.wordEn.trim();
    final wordKy = sentence.wordKy.trim();
    final highlight = sentence.highlight.trim();
    final word = wordId.isNotEmpty
        ? _wordsRepo.findById(wordId)
        : (wordEn.isNotEmpty
            ? _wordsRepo.findByEnglish(wordEn)
            : (wordKy.isNotEmpty
                ? _wordsRepo.findByKyrgyz(wordKy)
                : (highlight.isNotEmpty
                    ? (_wordsRepo.findByEnglish(highlight) ??
                        _wordsRepo.findByKyrgyz(highlight))
                    : null)));
    if (word == null) return;
    if (mastered) {
      _progress.markWordMastered(word.id);
    } else {
      _progress.markWordSeen(word.id);
    }
  }
}

final sentenceBuilderProvider =
    ChangeNotifierProvider<SentenceBuilderProvider>((ref) {
  return SentenceBuilderProvider(
    ref.read(sentencesRepositoryProvider),
    ref.read(wordsRepositoryProvider),
    ref.read(progressProvider),
  );
});
