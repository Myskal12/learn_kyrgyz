import '../../../core/services/firebase_service.dart';

class AuthRepository {
  AuthRepository(this._service);

  final FirebaseService _service;

  bool get isLogged => _service.currentUserId != null;

  Future<bool> login(String email, String password) =>
      _service.login(email, password);

  Future<bool> loginWithGoogle() => _service.loginWithGoogle();

  Future<bool> register(String email, String password, {String? nickname}) =>
      _service.register(email, password, nickname: nickname);

  Future<void> logout() => _service.logout();
}
