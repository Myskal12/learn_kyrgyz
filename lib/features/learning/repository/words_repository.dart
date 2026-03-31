import '../../../core/services/firebase_service.dart';
import '../../../core/services/offline_catalog_cache_service.dart';
import '../../../data/models/word_model.dart';

class WordsRepository {
  WordsRepository(this._service, this._offlineCache) {
    for (final word in _service.allWords) {
      _idMap[word.id] = word;
    }
  }

  final FirebaseService _service;
  final OfflineCatalogCacheService _offlineCache;
  final Map<String, List<WordModel>> _cache = {};
  final Map<String, WordModel> _idMap = {};

  Future<List<WordModel>> fetchWordsByCategory(
    String categoryId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache.containsKey(categoryId)) {
      return List<WordModel>.of(_cache[categoryId]!);
    }

    final cached = await _offlineCache.readWords(categoryId);
    if (cached.isNotEmpty) {
      _rememberWords(categoryId, cached);
    }

    try {
      final remote = await _service.fetchWordsByCategory(categoryId);
      if (remote.isNotEmpty) {
        _rememberWords(categoryId, remote);
        await _offlineCache.writeWords(categoryId, remote);
        return List<WordModel>.of(remote);
      }
    } catch (_) {}

    if (_cache.containsKey(categoryId)) {
      return List<WordModel>.of(_cache[categoryId]!);
    }

    final fallback = List<WordModel>.of(_service.getCachedWords(categoryId));
    if (fallback.isNotEmpty) {
      _rememberWords(categoryId, fallback);
    }
    return fallback;
  }

  Future<void> ensureWordsLoaded(String categoryId) async {
    if (_cache.containsKey(categoryId) && _cache[categoryId]!.isNotEmpty) {
      return;
    }
    await fetchWordsByCategory(categoryId);
  }

  Future<void> prefetchCategories(Iterable<String> categoryIds) async {
    await Future.wait(
      categoryIds.toSet().map((categoryId) => ensureWordsLoaded(categoryId)),
    );
  }

  void _rememberWords(String categoryId, List<WordModel> words) {
    _cache[categoryId] = List<WordModel>.of(words);
    for (final word in words) {
      _idMap[word.id] = word;
    }
  }

  List<WordModel> getCachedWords(String categoryId) {
    if (_cache.containsKey(categoryId)) {
      return _cache[categoryId]!;
    }
    return _service.getCachedWords(categoryId);
  }

  List<WordModel> get allWords => List<WordModel>.unmodifiable(_idMap.values);

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
