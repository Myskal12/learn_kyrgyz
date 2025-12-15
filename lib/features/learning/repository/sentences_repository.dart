import '../../../core/services/firebase_service.dart';
import '../../../data/models/sentence_model.dart';

class SentencesRepository {
  SentencesRepository(this._service);

  final FirebaseService _service;
  final Map<String, List<SentenceModel>> _cache = {};

  Future<List<SentenceModel>> fetchSentencesByCategory(
    String categoryId, {
    int limit = 80,
  }) async {
    final sentences = await _service.fetchSentencesByCategory(
      categoryId,
      limit: limit,
    );
    _cache[categoryId] = sentences;
    return sentences;
  }

  List<SentenceModel> getCachedSentences(String categoryId) =>
      _cache[categoryId] ?? const [];
}
