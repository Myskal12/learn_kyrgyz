import '../../../core/services/firebase_service.dart';
import '../../../data/models/category_model.dart';


class CategoriesRepository {
final FirebaseService _service;
CategoriesRepository(this._service);


Future<List<CategoryModel>> fetchCategories() async => await _service.fetchCategories();
}