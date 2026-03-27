import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/services/firebase_service.dart';
import '../../../data/models/category_model.dart';

class CategoriesProvider extends ChangeNotifier {
  CategoriesProvider(this._service);

  final FirebaseService _service;

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
      _categories = await _service.fetchCategories();
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
  final firebase = ref.read(firebaseServiceProvider);
  return CategoriesProvider(firebase);
});
