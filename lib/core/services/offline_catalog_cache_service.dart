import 'dart:convert';

import '../../data/models/category_model.dart';
import '../../data/models/quiz_question_model.dart';
import '../../data/models/sentence_model.dart';
import '../../data/models/word_model.dart';
import '../utils/learning_direction.dart';
import 'local_storage_service.dart';

class OfflineCatalogCacheService {
  OfflineCatalogCacheService(this._storage);

  static const _categoriesKey = 'offline_catalog.categories';

  final LocalStorageService _storage;

  Future<List<CategoryModel>> readCategories() async {
    return _readList(_categoriesKey, (json) => CategoryModel.fromJson(json));
  }

  Future<void> writeCategories(List<CategoryModel> categories) async {
    await _writeList(
      _categoriesKey,
      categories.map((category) => category.toJson()).toList(),
    );
  }

  Future<List<WordModel>> readWords(String categoryId) async {
    return _readList(_wordsKey(categoryId), WordModel.fromJson);
  }

  Future<void> writeWords(String categoryId, List<WordModel> words) async {
    await _writeList(
      _wordsKey(categoryId),
      words.map((word) => word.toJson()).toList(),
    );
  }

  Future<List<SentenceModel>> readSentences(String categoryId) async {
    return _readList(
      _sentencesKey(categoryId),
      (json) => SentenceModel.fromJson((json['id'] ?? '').toString(), json),
    );
  }

  Future<void> writeSentences(
    String categoryId,
    List<SentenceModel> sentences,
  ) async {
    await _writeList(
      _sentencesKey(categoryId),
      sentences
          .map((sentence) => {'id': sentence.id, ...sentence.toJson()})
          .toList(),
    );
  }

  Future<List<QuizQuestionModel>> readQuizQuestions(
    String categoryId,
    LearningDirection direction,
  ) async {
    return _readList(
      _quizKey(categoryId, direction),
      (json) => QuizQuestionModel.fromJson((json['id'] ?? '').toString(), json),
    );
  }

  Future<void> writeQuizQuestions(
    String categoryId,
    LearningDirection direction,
    List<QuizQuestionModel> questions,
  ) async {
    await _writeList(
      _quizKey(categoryId, direction),
      questions
          .map((question) => {'id': question.id, ...question.toJson()})
          .toList(),
    );
  }

  Future<List<T>> _readList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final raw = await _storage.getString(key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final data = jsonDecode(raw) as List<dynamic>;
      return data
          .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _writeList(
    String key,
    List<Map<String, dynamic>> payload,
  ) async {
    await _storage.setString(key, jsonEncode(payload));
  }

  String _wordsKey(String categoryId) => 'offline_catalog.words.$categoryId';

  String _sentencesKey(String categoryId) =>
      'offline_catalog.sentences.$categoryId';

  String _quizKey(String categoryId, LearningDirection direction) =>
      'offline_catalog.quiz.${direction.name}.$categoryId';
}
