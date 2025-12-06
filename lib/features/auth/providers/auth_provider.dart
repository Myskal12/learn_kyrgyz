import 'package:flutter/material.dart';
import '../repository/auth_repository.dart';
import '../../../core/services/firebase_service.dart';


class AuthProvider extends ChangeNotifier {
final AuthRepository _repo;
bool _loading = false;
bool get isLoading => _loading;
bool _logged = false;
bool get logged => _logged;


AuthProvider(FirebaseService service) : _repo = AuthRepository(service);


Future<bool> login(String email, String password) async {
_loading = true;
notifyListeners();
final ok = await _repo.login(email, password);
_loading = false;
_logged = ok;
notifyListeners();
return ok;
}


Future<bool> register(String email, String password) async {
_loading = true;
notifyListeners();
final ok = await _repo.register(email, password);
_loading = false;
_logged = ok;
notifyListeners();
return ok;
}


void logout() {
_logged = false;
notifyListeners();
}
}