import '../../../core/services/firebase_service.dart';
import '../../../data/models/word_model.dart';

class WordsRepository {
  WordsRepository(this._service) {
    for (final word in _service.allWords) {
      _idMap[word.id] = word;
    }
  }

  final FirebaseService _service;
  final Map<String, List<WordModel>> _cache = {};
  final Map<String, WordModel> _idMap = {};

  Future<List<WordModel>> fetchWordsByCategory(String categoryId) async {
    final words = await _service.fetchWordsByCategory(categoryId);
    _cache[categoryId] = words;
    for (final word in words) {
      _idMap[word.id] = word;
    }
    return words;
  }

  List<WordModel> getCachedWords(String categoryId) {
    if (_cache.containsKey(categoryId)) {
      return _cache[categoryId]!;
    }
    return _service.getCachedWords(categoryId);
  }

  List<WordModel> get allWords => _service.allWords;

  WordModel? findByEnglish(String english) {
    final lower = english.toLowerCase();
    for (final word in allWords) {
      if (word.english.toLowerCase() == lower) {
        return word;
      }
    }
    return null;
  }

  WordModel? findByKyrgyz(String kyrgyz) {
    final lower = kyrgyz.toLowerCase();
    for (final word in allWords) {
      if (word.kyrgyz.toLowerCase() == lower) {
        return word;
      }
    }
    return null;
  }

  WordModel? findById(String id) {
    return _idMap[id];
  }
}
