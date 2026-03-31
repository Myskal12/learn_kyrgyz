import '../../../core/services/firebase_service.dart';
import '../../../core/services/offline_catalog_cache_service.dart';
import '../../../data/models/sentence_model.dart';

class SentencesRepository {
  SentencesRepository(this._service, this._offlineCache);

  final FirebaseService _service;
  final OfflineCatalogCacheService _offlineCache;
  final Map<String, List<SentenceModel>> _cache = {};

  Future<List<SentenceModel>> fetchSentencesByCategory(
    String categoryId, {
    int limit = 80,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache.containsKey(categoryId)) {
      return List<SentenceModel>.of(_cache[categoryId]!);
    }

    final cached = await _offlineCache.readSentences(categoryId);
    if (cached.isNotEmpty) {
      _cache[categoryId] = List<SentenceModel>.of(cached);
    }

    try {
      final remote = await _service.fetchSentencesByCategory(
        categoryId,
        limit: limit,
      );
      if (remote.isNotEmpty) {
        _cache[categoryId] = List<SentenceModel>.of(remote);
        await _offlineCache.writeSentences(categoryId, remote);
        return List<SentenceModel>.of(remote);
      }
    } catch (_) {}

    return List<SentenceModel>.of(_cache[categoryId] ?? const []);
  }

  List<SentenceModel> getCachedSentences(String categoryId) =>
      List<SentenceModel>.of(_cache[categoryId] ?? const []);
}
