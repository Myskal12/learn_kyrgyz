import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_kyrgyz/app/providers/app_providers.dart';
import 'package:learn_kyrgyz/core/services/firebase_service.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';
import 'package:learn_kyrgyz/data/models/user_progress_model.dart';
import 'package:learn_kyrgyz/features/extras/presentation/study_plan_screen.dart';

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
  FakeFirebaseService() : _userController = StreamController<String?>.broadcast();

  final StreamController<String?> _userController;

  @override
  String? get currentUserId => null;

  @override
  bool get isGoogleSignInSupported => true;

  @override
  String get googleSignInUnavailableMessage => 'Unavailable';

  @override
  Stream<String?> get userStream => _userController.stream;

  @override
  Future<UserProgressModel?> fetchUserProgress(String uid) async => null;

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
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('study plan roadmap renders a visible fallback layout', (
    tester,
  ) async {
    final storage = FakeLocalStorageService({
      'daily_goal_minutes': '15',
      'user_progress': jsonEncode(
        UserProgressModel(
          userId: 'guest',
          correctByWordId: const {
            'w1': 1,
            'w2': 1,
            'w3': 1,
            'w4': 1,
            'w5': 1,
            'w6': 1,
          },
          seenByWordId: const {
            'w1': 1,
            'w2': 1,
            'w3': 1,
            'w4': 1,
            'w5': 1,
            'w6': 1,
          },
          streakDays: 3,
        ).toJson(),
      ),
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
          firebaseServiceProvider.overrideWithValue(FakeFirebaseService()),
        ],
        child: const MaterialApp(home: StudyPlanScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Жолду ачып, ритмди сактаңыз'), findsOneWidget);
    expect(find.text('Азыркы этап'), findsOneWidget);
    expect(find.text('Категория roadmap'), findsOneWidget);
    expect(find.text('Практикага өтүү'), findsOneWidget);
  });
}
