import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/services/local_storage_service.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../data/models/word_model.dart';

class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._storage);

  static const _storageKey = 'user_progress';
  final LocalStorageService _storage;

  UserProgressModel _progress = UserProgressModel(userId: 'guest');
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await _storage.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _progress = UserProgressModel.fromJson(data);
      } catch (_) {
        _progress = UserProgressModel(userId: 'guest');
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> reset() async {
    _progress = UserProgressModel(userId: 'guest');
    _loaded = true;
    await _persist();
  }

  void markWordSeen(String wordId) {
    final current = _progress.seenByWordId[wordId] ?? 0;
    _progress.seenByWordId[wordId] = current + 1;
    _persist();
  }

  void markWordMastered(String wordId) {
    markWordSeen(wordId);
    final current = _progress.correctByWordId[wordId] ?? 0;
    _progress.correctByWordId[wordId] = current + 1;
    _persist();
  }

  int get totalWordsReviewed => _progress.seenByWordId.length;

  int get totalWordsMastered => _progress.correctByWordId.length;

  int get totalReviewSessions =>
      _progress.seenByWordId.values.fold(0, (prev, value) => prev + value);

  int get accuracyPercent {
    final exposures = _progress.seenByWordId.values.fold(0, (prev, value) => prev + value);
    if (exposures == 0) return 0;
    final masteredCount =
        _progress.correctByWordId.values.fold(0, (prev, value) => prev + value);
    return ((masteredCount / exposures) * 100).round();
  }

  double completionForCategory(List<WordModel> words) {
    if (words.isEmpty) return 0;
    final mastered = words.where((w) => _progress.correctByWordId.containsKey(w.id)).length;
    return (mastered / words.length).clamp(0, 1);
  }

  double exposureForCategory(List<WordModel> words) {
    if (words.isEmpty) return 0;
    final seen = words.where((w) => _progress.seenByWordId.containsKey(w.id)).length;
    return (seen / words.length).clamp(0, 1);
  }

  String get level {
    final mastered = totalWordsMastered;
    if (mastered >= 30) return '???? ?????????';
    if (mastered >= 15) return '???? ???????';
    return 'Башталгыч';
  }

  Future<void> _persist() async {
    final payload = jsonEncode(_progress.toJson());
    await _storage.setString(_storageKey, payload);
    notifyListeners();
  }
}
