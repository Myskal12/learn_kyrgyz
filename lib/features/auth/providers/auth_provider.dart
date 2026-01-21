import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/services/firebase_service.dart';
import '../repository/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(FirebaseService service)
    : _repo = AuthRepository(service),
      _logged = service.currentUserId != null;

  final AuthRepository _repo;

  bool _loading = false;
  bool get isLoading => _loading;

  bool _logged;
  bool get logged => _logged;

  String? _error;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.login(email, password);
      _logged = _repo.isLogged;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _messageForCode(e);
      return false;
    } catch (e) {
      _error = 'Белгисиз ката. Кийин кайра аракет кылыңыз.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final ok = await _repo.loginWithGoogle();
      _logged = _repo.isLogged;
      if (!ok) {
        _error = 'Google аккаунту тандалган жок.';
      }
      return ok;
    } on FirebaseAuthException catch (e) {
      _error = _messageForCode(e);
      return false;
    } catch (_) {
      _error = 'Google кирүүсү ишке ашкан жок';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String email,
    String password, {
    String? nickname,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.register(email, password, nickname: nickname);
      _logged = _repo.isLogged;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _messageForCode(e);
      return false;
    } catch (e) {
      _error = 'Катталуу ишке ашкан жок. Кайра аракет кылыңыз.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _logged = _repo.isLogged;
    notifyListeners();
  }

  String _messageForCode(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Мындай email менен колдонуучу табылган жок.';
      case 'wrong-password':
        return 'Сырсөз туура эмес.';
      case 'invalid-email':
        return 'Email дареги туура эмес форматта.';
      case 'email-already-in-use':
        return 'Бул email мурунтан колдонулуп жатат.';
      case 'weak-password':
        return 'Сырсөз күчтүү эмес. 6 символдон узун болсун.';
      default:
        return e.message ?? 'Аныкталбаган ката.';
    }
  }
}

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref.read(firebaseServiceProvider));
});
