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
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (!force && _categories.isNotEmpty) return;
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
}

final categoriesProvider = ChangeNotifierProvider<CategoriesProvider>((ref) {
  return CategoriesProvider(
    ref.read(categoriesRepositoryProvider),
    ref.read(wordsRepositoryProvider),
  );
});
