import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../data/models/category_model.dart';
import '../../learning/repository/words_repository.dart';
import '../repository/categories_repository.dart';

class CategoriesProvider extends ChangeNotifier {
  CategoriesProvider(this._repository, this._wordsRepository);

  final CategoriesRepository _repository;
  final WordsRepository _wordsRepository;

  List<CategoryModel> _categories = [];
  bool _loading = false;
  bool _refreshingInBackground = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (!force && _categories.isNotEmpty) {
      unawaited(_refreshInBackground());
      return;
    }
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _categories = await _repository.fetchCategories(forceRefresh: force);
      notifyListeners();
      await _wordsRepository.prefetchCategories(
        _categories.map((category) => category.id),
      );
    } catch (_) {
      _errorMessage =
          'Категориялар жүктөлгөн жок. Интернетти текшерип кайра аракет кылыңыз.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshInBackground() async {
    if (_refreshingInBackground) return;
    _refreshingInBackground = true;
    try {
      final refreshed = await _repository.fetchCategories(forceRefresh: true);
      if (_isEquivalent(_categories, refreshed)) {
        return;
      }

      _categories = refreshed;
      notifyListeners();
      await _wordsRepository.prefetchCategories(
        _categories.map((category) => category.id),
      );
    } catch (_) {
      // Keep current categories when refresh fails.
    } finally {
      _refreshingInBackground = false;
    }
  }

  bool _isEquivalent(List<CategoryModel> a, List<CategoryModel> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final left = a[i];
      final right = b[i];
      if (left.id != right.id ||
          left.wordsCount != right.wordsCount ||
          left.title != right.title ||
          left.description != right.description) {
        return false;
      }
    }
    return true;
  }
}

final categoriesProvider = ChangeNotifierProvider<CategoriesProvider>((ref) {
  return CategoriesProvider(
    ref.read(categoriesRepositoryProvider),
    ref.read(wordsRepositoryProvider),
  );
});
