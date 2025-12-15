import 'package:flutter/material.dart';

import '../../../core/services/firebase_service.dart';
import '../../../data/models/category_model.dart';

class CategoriesProvider extends ChangeNotifier {
  CategoriesProvider(this._service);

  final FirebaseService _service;

  List<CategoryModel> _categories = [];
  bool _loading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _loading;

  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (!force && _categories.isNotEmpty) return;
    _loading = true;
    notifyListeners();
    try {
      _categories = await _service.fetchCategories();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
