import '../../../core/services/firebase_service.dart';


class AuthRepository {
  final FirebaseService _service;
  AuthRepository(this._service);

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _service.saveUserProgress(email, const {});
    return true;
  }

  Future<bool> register(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    await _service.saveUserProgress(email, const {});
    return true;
  }
}
