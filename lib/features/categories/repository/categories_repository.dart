import '../../../core/services/firebase_service.dart';
import '../../../core/services/offline_catalog_cache_service.dart';
import '../../../data/models/category_model.dart';

class CategoriesRepository {
  final FirebaseService _service;
  final OfflineCatalogCacheService _offlineCache;
  List<CategoryModel> _memoryCache = [];

  CategoriesRepository(this._service, this._offlineCache);

  Future<List<CategoryModel>> fetchCategories({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _memoryCache.isNotEmpty) {
      return List<CategoryModel>.of(_memoryCache);
    }

    final cached = await _offlineCache.readCategories();
    if (_memoryCache.isEmpty && cached.isNotEmpty) {
      _memoryCache = cached;
    }

    try {
      final remote = await _service.fetchCategories();
      if (remote.isNotEmpty) {
        _memoryCache = remote;
        await _offlineCache.writeCategories(remote);
        return List<CategoryModel>.of(remote);
      }
    } catch (_) {}

    if (_memoryCache.isNotEmpty) {
      return List<CategoryModel>.of(_memoryCache);
    }

    return cached;
  }
}
