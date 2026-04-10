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
  String? get currentUserEmail => _repo.currentUserEmail;
  bool get requiresEmailVerification => _repo.requiresEmailVerification;
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

  Future<bool> sendEmailVerification() async {
    if (!_repo.isLogged) {
      _error = 'Адегенде аккаунтка кириңиз.';
      notifyListeners();
      return false;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.sendCurrentUserEmailVerification();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _messageForCode(e);
      return false;
    } catch (_) {
      _error = 'Ырастоо катын жөнөтүү ишке ашкан жок.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> refreshEmailVerificationStatus() async {
    if (!_repo.isLogged) {
      _error = 'Сессия аяктады. Кайра кириңиз.';
      notifyListeners();
      return false;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final verified = await _repo.refreshEmailVerificationStatus();
      _logged = _repo.isLogged;
      if (!verified && _repo.requiresEmailVerification) {
        _error = 'Email дареги али ырастала элек.';
      }
      return verified;
    } on FirebaseAuthException catch (e) {
      _error = _messageForCode(e);
      return false;
    } catch (_) {
      _error = 'Ырастоо абалын текшерүү ишке ашкан жок.';
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
      case 'network-request-failed':
        return 'Интернет байланышын текшерип, кайра аракет кылыңыз.';
      case 'user-disabled':
        return 'Бул аккаунт убактылуу өчүрүлгөн.';
      case 'user-token-expired':
        return 'Сессияңыз аяктады. Кайра кириңиз.';
      case 'google-sign-in-not-supported':
        return e.message ?? googleSignInUnavailableMessage;
      case 'google-sign-in-config-missing':
        return e.message ?? 'Google Sign-In конфигурациясы толук эмес.';
      case 'google-play-services-unavailable':
        return e.message ??
            'Google Play Services жеткиликсиз. Google APIs бар Android түзмөктү колдонуңуз.';
      case 'google-sign-in-missing-id-token':
        return e.message ?? 'Google Sign-In ID token алынган жок.';
      default:
        return e.message ?? 'Аныкталбаган ката.';
    }
  }
}

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref.read(firebaseServiceProvider));
});
