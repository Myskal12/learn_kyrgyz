import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_kyrgyz/app/providers/app_providers.dart';
import 'package:learn_kyrgyz/core/services/firebase_service.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';
import 'package:learn_kyrgyz/data/models/category_model.dart';
import 'package:learn_kyrgyz/data/models/onboarding_config_model.dart';
import 'package:learn_kyrgyz/data/models/user_progress_model.dart';
import 'package:learn_kyrgyz/data/models/word_model.dart';
import 'package:learn_kyrgyz/features/extras/presentation/study_plan_screen.dart';

class _FakeLocalStorageService implements LocalStorageService {
  _FakeLocalStorageService([Map<String, String>? initialValues])
    : values = {...?initialValues};

  final Map<String, String> values;

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }
}

class _FakeFirebaseService implements FirebaseService {
  _FakeFirebaseService()
    : _userController = StreamController<String?>.broadcast(),
      _categories = [
        CategoryModel(
          id: 'basic',
          title: 'Негизги сөздөр',
          description: 'Күнүмдүк база',
          wordsCount: 4,
        ),
        CategoryModel(
          id: 'food',
          title: 'Тамак-аш',
          description: 'Азык-түлүк сөздөрү',
          wordsCount: 2,
        ),
      ],
      _words = {
        'basic': [
          WordModel(id: 'w1', english: 'hello', kyrgyz: 'Салам', category: 'basic'),
          WordModel(id: 'w2', english: 'yes', kyrgyz: 'Ооба', category: 'basic'),
          WordModel(id: 'w3', english: 'no', kyrgyz: 'Жок', category: 'basic'),
          WordModel(id: 'w4', english: 'thanks', kyrgyz: 'Рахмат', category: 'basic'),
        ],
        'food': [
          WordModel(id: 'f1', english: 'bread', kyrgyz: 'Нан', category: 'food'),
          WordModel(id: 'f2', english: 'tea', kyrgyz: 'Чай', category: 'food'),
        ],
      };

  final StreamController<String?> _userController;
  final List<CategoryModel> _categories;
  final Map<String, List<WordModel>> _words;

  @override
  String? get currentUserId => null;

  @override
  List<WordModel> get allWords =>
      _words.values.expand((items) => items).toList(growable: false);

  @override
  bool get isGoogleSignInSupported => true;

  @override
  String get googleSignInUnavailableMessage => 'Unavailable';

  @override
  String get googleSignInConfigurationMessage => 'Unavailable';

  @override
  Stream<String?> get userStream => _userController.stream;

  @override
  Future<UserProgressModel?> fetchUserProgress(String uid) async => null;

  @override
  Future<OnboardingConfigModel?> fetchOnboardingConfig() async => null;

  @override
  Future<List<CategoryModel>> fetchCategories() async => List<CategoryModel>.of(
    _categories,
  );

  @override
  Future<List<WordModel>> fetchWordsByCategory(String categoryId) async =>
      List<WordModel>.of(_words[categoryId] ?? const []);

  @override
  List<WordModel> getCachedWords(String categoryId) =>
      List<WordModel>.of(_words[categoryId] ?? const []);

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

  testWidgets('renders data-driven roadmap with locked next category', (
    tester,
  ) async {
    final progress = UserProgressModel(
      userId: 'guest',
      correctByWordId: const {'w1': 1, 'w2': 1, 'w3': 1},
      seenByWordId: const {'w1': 1, 'w2': 1, 'w3': 1},
      streakDays: 2,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(
            _FakeLocalStorageService({
              'onboarding_completed': 'true',
              'daily_goal_minutes': '20',
              'user_progress_guest': jsonEncode(progress.toJson()),
            }),
          ),
          firebaseServiceProvider.overrideWithValue(_FakeFirebaseService()),
        ],
        child: const MaterialApp(home: StudyPlanScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Жол картасы'), findsWidgets);
    expect(
      find.text('Бул экран реалдуу категория, прогресс жана кайталоо кезеги менен эсептелет.'),
      findsOneWidget,
    );
    expect(find.text('Негизги сөздөр'), findsWidgets);
    expect(find.text('Жалпы прогресс: 50%'), findsOneWidget);
    expect(find.text('3/6 сөз'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Тамак-аш'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Тамак-аш'), findsWidgets);
    expect(find.text('Ачылууга: 2'), findsOneWidget);
    expect(
      find.text('Бул категория ачылышы үчүн дагы 2 сөз бекемдөө керек.'),
      findsOneWidget,
    );
  });
}
