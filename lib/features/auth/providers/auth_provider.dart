import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/services/firebase_service.dart';
import '../auth_demo_account.dart';
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
  bool get isGoogleSignInSupported => _repo.isGoogleSignInSupported;
  String get googleSignInUnavailableMessage =>
      _repo.googleSignInUnavailableMessage;

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
      if (!isGoogleSignInSupported) {
        _error = googleSignInUnavailableMessage;
        return false;
      }
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

  Future<bool> loginWithDemoAccount() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      try {
        await _repo.login(AuthDemoAccount.email, AuthDemoAccount.password);
        _logged = _repo.isLogged;
        return true;
      } on FirebaseAuthException catch (_) {
        try {
          await _repo.register(
            AuthDemoAccount.email,
            AuthDemoAccount.password,
            nickname: AuthDemoAccount.name,
          );
          _logged = _repo.isLogged;
          return true;
        } on FirebaseAuthException catch (registerError) {
          if (registerError.code == 'email-already-in-use') {
            await _repo.login(AuthDemoAccount.email, AuthDemoAccount.password);
            _logged = _repo.isLogged;
            return true;
          }
          _error = _messageForCode(registerError);
          return false;
        }
      }
    } on FirebaseAuthException catch (e) {
      _error = _messageForCode(e);
      return false;
    } catch (_) {
      _error = 'Тест аккаунтка кирүү ишке ашкан жок.';
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

  Future<bool> sendPasswordResetEmail(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.sendPasswordResetEmail(email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _messageForCode(e);
      return false;
    } catch (_) {
      _error = 'Калыбына келтирүү шилтемесин жөнөтүү ишке ашкан жок.';
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
      case 'missing-email':
        return 'Email дарегин киргизиңиз.';
      case 'email-already-in-use':
        return 'Бул email мурунтан колдонулуп жатат.';
      case 'weak-password':
        return 'Сырсөз күчтүү эмес. 6 символдон узун болсун.';
      case 'too-many-requests':
        return 'Өтө көп аракет жасалды. Бир аздан кийин кайра кылыңыз.';
      case 'google-sign-in-not-supported':
        return e.message ?? googleSignInUnavailableMessage;
      case 'google-sign-in-config-missing':
        return e.message ?? 'Google Sign-In конфигурациясы толук эмес.';
      default:
        return e.message ?? 'Аныкталбаган ката.';
    }
  }
}

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref.read(firebaseServiceProvider));
});
