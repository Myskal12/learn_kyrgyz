import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/app_providers.dart';
import '../services/local_storage_service.dart';

class LearningSessionProvider extends ChangeNotifier {
  LearningSessionProvider(this._storage);

  static const _lastCategoryKey = 'last_category_id';
  final LocalStorageService _storage;

  String? _lastCategoryId;
  String? get lastCategoryId => _lastCategoryId;

  Future<void> load() async {
    _lastCategoryId = await _storage.getString(_lastCategoryKey);
    notifyListeners();
  }

  Future<void> setLastCategoryId(String categoryId) async {
    final trimmed = categoryId.trim();
    if (trimmed.isEmpty) return;
    _lastCategoryId = trimmed;
    notifyListeners();
    await _storage.setString(_lastCategoryKey, trimmed);
  }
}

final learningSessionProvider =
    ChangeNotifierProvider<LearningSessionProvider>((ref) {
  final storage = ref.read(localStorageServiceProvider);
  final provider = LearningSessionProvider(storage);
  unawaited(provider.load());
  return provider;
});
