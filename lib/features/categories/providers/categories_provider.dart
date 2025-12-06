import 'package:flutter/material.dart';
import '../../../data/models/category_model.dart';
import '../../../core/services/firebase_service.dart';


class CategoriesProvider extends ChangeNotifier {
final FirebaseService _service;
List<CategoryModel> _categories = [];
bool _loading = false;


CategoriesProvider(this._service);


List<CategoryModel> get categories => _categories;
bool get isLoading => _loading;


Future<void> load() async {
_loading = true;
notifyListeners();
_categories = await _service.fetchCategories();
_loading = false;
notifyListeners();
}
}