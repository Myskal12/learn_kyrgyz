import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_kyrgyz/app/providers/app_providers.dart';
import 'package:learn_kyrgyz/core/services/firebase_service.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';
import 'package:learn_kyrgyz/data/models/onboarding_config_model.dart';
import 'package:learn_kyrgyz/data/models/user_progress_model.dart';
import 'package:learn_kyrgyz/features/auth/presentation/login_screen.dart';
import 'package:learn_kyrgyz/features/auth/presentation/register_screen.dart';
import 'package:learn_kyrgyz/features/onboarding/presentation/welcome_screen.dart';

class FakeLocalStorageService implements LocalStorageService {
  FakeLocalStorageService([Map<String, String>? initialValues])
    : values = {...?initialValues};

  final Map<String, String> values;

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }
}

class FakeFirebaseService implements FirebaseService {
  FakeFirebaseService()
    : _userController = StreamController<String?>.broadcast();

  final StreamController<String?> _userController;

  @override
  String? get currentUserId => null;

  @override
  bool get isGoogleSignInSupported => true;

  @override
  String get googleSignInConfigurationMessage => 'Unavailable';

  @override
  String get googleSignInUnavailableMessage => 'Unavailable';

  @override
  Stream<String?> get userStream => _userController.stream;

  @override
  Future<UserProgressModel?> fetchUserProgress(String uid) async => null;

  @override
  Future<OnboardingConfigModel?> fetchOnboardingConfig() async => null;

  @override
  Future<bool> login(String email, String password) async => true;

  @override
  Future<bool> loginWithGoogle() async => true;

  @override
  Future<bool> register(
    String email,
    String password, {
    String? nickname,
  }) async => true;

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> saveUserProgress(UserProgressModel progress) async {}

  @override
  Future<void> updateUserStats({
    required String uid,
    required int totalMastered,
    required int totalSessions,
    required int accuracy,
    required int totalXp,
    required int streakDays,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('welcome primary action stays visible on short screens', (
    tester,
  ) async {
    await _pumpScreen(tester, const WelcomeScreen(), includeProviders: true);

    final rect = tester.getRect(find.byKey(const Key('welcome-primary-cta')));
    expect(rect.bottom, lessThanOrEqualTo(560));
  });

  testWidgets('login primary action stays visible on short screens', (
    tester,
  ) async {
    await _pumpScreen(tester, const LoginScreen(), includeProviders: true);

    final rect = tester.getRect(find.byKey(const Key('login-primary-cta')));
    expect(rect.bottom, lessThanOrEqualTo(560));
  });

  testWidgets('register primary action stays visible on short screens', (
    tester,
  ) async {
    await _pumpScreen(tester, const RegisterScreen(), includeProviders: true);

    final rect = tester.getRect(find.byKey(const Key('register-primary-cta')));
    expect(rect.bottom, lessThanOrEqualTo(560));
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  Widget screen, {
  bool includeProviders = false,
}) async {
  tester.view.physicalSize = const Size(320, 560);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final child = includeProviders
      ? ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(
              FakeLocalStorageService(),
            ),
            firebaseServiceProvider.overrideWithValue(FakeFirebaseService()),
          ],
          child: MaterialApp(home: screen),
        )
      : MaterialApp(home: screen);

  await tester.pumpWidget(child);
  await tester.pumpAndSettle();
}
