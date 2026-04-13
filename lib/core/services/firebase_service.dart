import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/models/achievement_rule_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/learning_resource_model.dart';
import '../../data/models/onboarding_config_model.dart';
import '../../data/models/quiz_question_model.dart';
import '../../data/models/sentence_model.dart';
import '../../data/models/user_progress_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/models/word_model.dart';
import '../utils/constants.dart';

/// Firebase-powered data layer with local fallbacks for offline use.
class FirebaseService {
  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn() {
    _wordsCache.addAll(
      _words.map((key, value) => MapEntry(key, List<WordModel>.of(value))),
    );
    _categoriesCache = List<CategoryModel>.of(_categories);
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  bool get isGoogleSignInSupported {
    if (kIsWeb) return true;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  String get googleSignInUnavailableMessage =>
      'Google менен кирүү бул түзмөктө жеткиликтүү эмес. Email же конок режимин колдонуңуз.';

  String get googleSignInConfigurationMessage =>
      'Google Sign-In Android үчүн толук жөндөлгөн эмес. Firebase долбоорунда SHA-1/SHA-256 кошуп, жаңы google-services.json жүктөп, колдонмону кайра куруңуз.';

  final Map<String, List<WordModel>> _words = {
    'basic': [
      WordModel(
        id: 'basics_hello',
        english: 'hello',
        kyrgyz: 'Салам',
        transcription: 'sa-lam',
        example: 'Салам! Бүгүн кантип жатасың?',
      ),
      WordModel(
        id: 'basics_thanks',
        english: 'thank you',
        kyrgyz: 'Рахмат',
        transcription: 'rah-mat',
        example: 'Рахмат, мага жардам бергениң үчүн.',
      ),
      WordModel(
        id: 'basics_yes',
        english: 'yes',
        kyrgyz: 'Ооба',
        transcription: 'oo-ba',
        example: 'Ооба, мен түшүндүм.',
      ),
      WordModel(
        id: 'basics_no',
        english: 'no',
        kyrgyz: 'Жок',
        transcription: 'zhok',
        example: 'Жок, азыр убактым жок.',
      ),
      WordModel(
        id: 'basics_please',
        english: 'please',
        kyrgyz: 'Суранам',
        transcription: 'su-ra-nam',
        example: 'Суранам, эшикти жаап кой.',
      ),
      WordModel(
        id: 'basics_good_morning',
        english: 'good morning',
        kyrgyz: 'Кутман таң',
        transcription: 'kut-man-taan',
        example: 'Кутман таң! Күнүң узун болсун.',
      ),
    ],
    'food': [
      WordModel(
        id: 'food_bread',
        english: 'bread',
        kyrgyz: 'Нан',
        transcription: 'nan',
        example: 'Базардан жаңы нан сатып алдым.',
      ),
      WordModel(
        id: 'food_tea',
        english: 'tea',
        kyrgyz: 'Чай',
        transcription: 'chai',
        example: 'Кел, бирге чай ичели.',
      ),
      WordModel(
        id: 'food_soup',
        english: 'soup',
        kyrgyz: 'Шорпо',
        transcription: 'shor-po',
        example: 'Суук күнү ысык шорпо жакшы.',
      ),
      WordModel(
        id: 'food_meat',
        english: 'meat',
        kyrgyz: 'Эт',
        transcription: 'et',
        example: 'Этти жай отто кууруп жатам.',
      ),
      WordModel(
        id: 'food_apple',
        english: 'apple',
        kyrgyz: 'Алма',
        transcription: 'al-ma',
        example: 'Бул алма абдан ширелүү экен.',
      ),
      WordModel(
        id: 'food_water',
        english: 'water',
        kyrgyz: 'Суу',
        transcription: 'suu',
        example: 'Күндү суу менен баштоону унутпа.',
      ),
    ],
    'family': [
      WordModel(
        id: 'family_mother',
        english: 'mother',
        kyrgyz: 'Апам',
        transcription: 'a-pam',
        example: 'Апам даамдуу тамак жасайт.',
      ),
      WordModel(
        id: 'family_father',
        english: 'father',
        kyrgyz: 'Атам',
        transcription: 'a-tam',
        example: 'Атам менен тоого бардым.',
      ),
      WordModel(
        id: 'family_brother',
        english: 'elder brother',
        kyrgyz: 'Агам',
        transcription: 'a-gam',
        example: 'Агам мага китеп белек кылды.',
      ),
      WordModel(
        id: 'family_sister',
        english: 'sister',
        kyrgyz: 'Карындашым',
        transcription: 'kar-yn-dashym',
        example: 'Карындашым мектепте окуйт.',
      ),
      WordModel(
        id: 'family_child',
        english: 'child',
        kyrgyz: 'Бала',
        transcription: 'ba-la',
        example: 'Бул бала оюнуна кубанып жатат.',
      ),
      WordModel(
        id: 'family_grandma',
        english: 'grandmother',
        kyrgyz: 'Чоң апа',
        transcription: 'chong-apa',
        example: 'Чоң апам жомокторду жакшы айтат.',
      ),
    ],
    'nature': [
      WordModel(
        id: 'nature_mountain',
        english: 'mountain',
        kyrgyz: 'Тоолор',
        transcription: 'too-lor',
        example: 'Тоолордо аба таза болот.',
      ),
      WordModel(
        id: 'nature_river',
        english: 'river',
        kyrgyz: 'Дарыя',
        transcription: 'da-rya',
        example: 'Дарыя жээгинде сейилдедик.',
      ),
      WordModel(
        id: 'nature_sun',
        english: 'sun',
        kyrgyz: 'Күн',
        transcription: 'kyn',
        example: 'Күн нуру жылуу сезилди.',
      ),
      WordModel(
        id: 'nature_snow',
        english: 'snow',
        kyrgyz: 'Кар',
        transcription: 'kar',
        example: 'Кар түндө көп жаады.',
      ),
      WordModel(
        id: 'nature_wind',
        english: 'wind',
        kyrgyz: 'Шамал',
        transcription: 'sha-mal',
        example: 'Шамал дарактардын жалбырагын кыймылдатты.',
      ),
      WordModel(
        id: 'nature_lake',
        english: 'lake',
        kyrgyz: 'Көл',
        transcription: 'kol',
        example: 'Ысык-Көл дүйнөгө белгилүү.',
      ),
    ],
    'animals': [
      WordModel(
        id: 'animals_horse',
        english: 'horse',
        kyrgyz: 'Ат',
        transcription: 'at',
        example: 'Кумайык ат чуркап жүрөт.',
      ),
      WordModel(
        id: 'animals_eagle',
        english: 'eagle',
        kyrgyz: 'Бүркүт',
        transcription: 'bur-kut',
        example: 'Бүркүт асманда айланып учту.',
      ),
      WordModel(
        id: 'animals_sheep',
        english: 'sheep',
        kyrgyz: 'Кой',
        transcription: 'koi',
        example: 'Койлор жайлоодо оттоп жүрөт.',
      ),
      WordModel(
        id: 'animals_dog',
        english: 'dog',
        kyrgyz: 'Ит',
        transcription: 'it',
        example: 'Ит үйдү кайтарып турат.',
      ),
      WordModel(
        id: 'animals_cat',
        english: 'cat',
        kyrgyz: 'Мышык',
        transcription: 'myshyk',
        example: 'Мышык күнгө жылынып жатат.',
      ),
      WordModel(
        id: 'animals_bird',
        english: 'bird',
        kyrgyz: 'Куш',
        transcription: 'kush',
        example: 'Куш эртең менен сайрайт.',
      ),
    ],
    'travel': [
      WordModel(
        id: 'travel_bus',
        english: 'bus',
        kyrgyz: 'Автобус',
        transcription: 'av-to-bus',
        example: 'Автобус шаардын борборуна кетти.',
      ),
      WordModel(
        id: 'travel_ticket',
        english: 'ticket',
        kyrgyz: 'Билет',
        transcription: 'bi-let',
        example: 'Билетти онлайн сатып алдым.',
      ),
      WordModel(
        id: 'travel_city',
        english: 'city',
        kyrgyz: 'Шаар',
        transcription: 'shaar',
        example: 'Бул шаарда көп музей бар.',
      ),
      WordModel(
        id: 'travel_road',
        english: 'road',
        kyrgyz: 'Жол',
        transcription: 'zhol',
        example: 'Бул жол тоого алып барат.',
      ),
      WordModel(
        id: 'travel_airport',
        english: 'airport',
        kyrgyz: 'Абамайдан',
        transcription: 'aba-mai-dan',
        example: 'Аэропортко эрте бар.',
      ),
      WordModel(
        id: 'travel_train',
        english: 'train',
        kyrgyz: 'Поезд',
        transcription: 'po-ezd',
        example: 'Поезд түштөн кийин келет.',
      ),
    ],
  };

  late final List<CategoryModel> _categories = [
    CategoryModel(
      id: 'basic',
      title: 'Негизги сөздөр',
      description: 'Күнүмдүк сүйлөшүүгө керектүү учурашуу жана сылык сөздөр.',
      wordsCount: _words['basic']!.length,
    ),
    CategoryModel(
      id: 'food',
      title: 'Тамак-аш',
      description: 'Кафеде же базарда колдонулуучу азык-түлүк сөздөрү.',
      wordsCount: _words['food']!.length,
    ),
    CategoryModel(
      id: 'family',
      title: 'Үй-бүлө',
      description: 'Жакындар, туугандар жана алар тууралуу сөздөр.',
      wordsCount: _words['family']!.length,
    ),
    CategoryModel(
      id: 'nature',
      title: 'Табият',
      description: 'Тоолор, көлдөр жана аба ырайына байланышкан сөздөр.',
      wordsCount: _words['nature']!.length,
    ),
    CategoryModel(
      id: 'animals',
      title: 'Жаныбарлар',
      description: 'Күндөлүк турмушта кездешкен жаныбарлардын аталыштары.',
      wordsCount: _words['animals']!.length,
    ),
    CategoryModel(
      id: 'travel',
      title: 'Саякат',
      description: 'Жолго даярдык жана транспорт тууралуу сөздөр.',
      wordsCount: _words['travel']!.length,
    ),
  ];

  final Map<String, List<WordModel>> _wordsCache = {};
  final Map<String, List<WordModel>> _immutableWordsCache = {};
  final Map<String, List<SentenceModel>> _sentencesCache = {};
  List<CategoryModel> _categoriesCache = [];

  int _categoryOrder(String id) {
    const order = <String, int>{
      'basic': 0,
      'family': 1,
      'food': 2,
      'clothes': 3,
      'education': 4,
      'nature': 5,
      'animals': 6,
      'transport': 7,
      'time': 8,
      'place': 9,
      'emotion': 10,
      'color': 11,
      'number': 12,
      'technology': 13,
      'sport': 14,
      'verb': 15,
      'adjective': 16,
    };
    return order[id] ?? 999;
  }

  Future<OnboardingConfigModel?> fetchOnboardingConfig() async {
    try {
      final snap = await _firestore
          .collection('app_config')
          .doc('onboarding')
          .get();
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return OnboardingConfigModel.fromJson(data);
    } catch (e) {
      debugPrint('Failed to fetch onboarding config: $e');
      return null;
    }
  }

  Future<List<AchievementRuleModel>> fetchAchievementRules() async {
    try {
      final snap = await _firestore
          .collection('app_config')
          .doc('achievements')
          .get();
      if (!snap.exists) return const [];

      final data = snap.data();
      if (data == null) return const [];

      final rawItems = (data['items'] as List?) ?? const [];
      final rules = <AchievementRuleModel>[];

      for (final item in rawItems) {
        if (item is! Map) continue;
        try {
          rules.add(
            AchievementRuleModel.fromJson(Map<String, dynamic>.from(item)),
          );
        } catch (_) {
          // Ignore malformed entries and keep valid rules.
        }
      }

      rules
        ..removeWhere((rule) => !rule.active)
        ..sort((a, b) => a.order.compareTo(b.order));
      return rules;
    } catch (e) {
      debugPrint('Failed to fetch achievements config: $e');
      return const [];
    }
  }

  Future<List<LearningResourceModel>> fetchLearningResources() async {
    try {
      final snap = await _firestore
          .collection('app_config')
          .doc('resources')
          .get();
      if (!snap.exists) return const [];

      final data = snap.data();
      if (data == null) return const [];

      final rawItems = (data['items'] as List?) ?? const [];
      final resources = <LearningResourceModel>[];

      for (final item in rawItems) {
        if (item is! Map) continue;
        try {
          resources.add(
            LearningResourceModel.fromJson(Map<String, dynamic>.from(item)),
          );
        } catch (_) {
          // Ignore malformed entries and keep valid resources.
        }
      }

      resources
        ..removeWhere((resource) => !resource.active)
        ..sort((a, b) => a.order.compareTo(b.order));
      return resources;
    } catch (e) {
      debugPrint('Failed to fetch resources config: $e');
      return const [];
    }
  }

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final snapshot = await _firestore.collection('words').get();
      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final rawCategory = doc.data()['category'];
        final category =
            (rawCategory == null || rawCategory.toString().trim().isEmpty)
            ? 'basic'
            : rawCategory.toString().trim();
        counts[category] = (counts[category] ?? 0) + 1;
      }

      final categories =
          counts.entries
              .map(
                (entry) => CategoryModel(
                  id: entry.key,
                  title: _titleForCategory(entry.key),
                  description: '${entry.value} сөз',
                  wordsCount: entry.value,
                ),
              )
              .toList()
            ..sort((a, b) {
              final orderCompare = _categoryOrder(
                a.id,
              ).compareTo(_categoryOrder(b.id));
              if (orderCompare != 0) return orderCompare;
              return a.title.compareTo(b.title);
            });
      if (categories.isNotEmpty) {
        _categoriesCache = categories;
        return categories;
      }
    } catch (e) {
      debugPrint('Failed to fetch categories from Firestore: $e');
    }
    return _categoriesCache;
  }

  Future<List<WordModel>> fetchWordsByCategory(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection('words')
          .where('category', isEqualTo: categoryId)
          .get();
      final words =
          snapshot.docs
              .map((doc) => WordModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList()
            ..sort((a, b) {
              final levelCompare = a.level.compareTo(b.level);
              if (levelCompare != 0) return levelCompare;
              return a.english.compareTo(b.english);
            });
      if (words.isNotEmpty) {
        _wordsCache[categoryId] = words;
        _immutableWordsCache.remove(categoryId);
        return words;
      }
    } catch (e) {
      debugPrint('Failed to fetch words for $categoryId: $e');
    }
    return List<WordModel>.of(
      _wordsCache[categoryId] ?? _words[categoryId] ?? const [],
    );
  }

  Future<List<SentenceModel>> fetchSentencesByCategory(
    String categoryId, {
    int limit = 80,
  }) async {
    if (categoryId.isEmpty) return const [];
    try {
      final snapshot = await _firestore
          .collection('sentences')
          .where('category', isEqualTo: categoryId)
          .limit(limit)
          .get();
      final sentences =
          snapshot.docs
              .map((doc) => SentenceModel.fromJson(doc.id, doc.data()))
              .toList()
            ..sort((a, b) {
              final levelCompare = a.level.compareTo(b.level);
              if (levelCompare != 0) return levelCompare;
              return a.en.compareTo(b.en);
            });
      if (sentences.isNotEmpty) {
        _sentencesCache[categoryId] = sentences;
        return sentences;
      }
    } catch (e) {
      debugPrint('Failed to fetch sentences for $categoryId: $e');
    }
    return List<SentenceModel>.of(_sentencesCache[categoryId] ?? const []);
  }

  List<SentenceModel> getCachedSentences(String categoryId) =>
      List<SentenceModel>.unmodifiable(_sentencesCache[categoryId] ?? const []);

  List<WordModel> getCachedWords(String categoryId) {
    if (_immutableWordsCache.containsKey(categoryId)) {
      return _immutableWordsCache[categoryId]!;
    }
    final source = _wordsCache[categoryId] ?? _words[categoryId] ?? const [];
    final immutable = List<WordModel>.unmodifiable(source);
    _immutableWordsCache[categoryId] = immutable;
    return immutable;
  }

  List<WordModel> get allWords {
    final source = _wordsCache.values.isNotEmpty
        ? _wordsCache.values
        : _words.values;
    return List<WordModel>.unmodifiable(source.expand((value) => value));
  }

  String _titleForCategory(String id) {
    switch (id) {
      case 'basic':
        return 'Негизги';
      case 'family':
        return 'Үй-бүлө';
      case 'animals':
        return 'Жаныбарлар';
      case 'food':
        return 'Тамак-аш';
      case 'verb':
        return 'Этиштер';
      case 'adjective':
        return 'Сын атооч';
      case 'emotion':
        return 'Сезимдер';
      case 'color':
        return 'Түстөр';
      case 'number':
        return 'Сандар';
      case 'transport':
        return 'Транспорт';
      case 'place':
        return 'Жайлар';
      case 'time':
        return 'Убакыт';
      case 'education':
        return 'Билим берүү';
      case 'body':
        return 'Дене мүчөлөрү';
      case 'nature':
        return 'Табият';
      case 'clothes':
        return 'Кийим';
      case 'technology':
        return 'Технология';
      case 'sport':
        return 'Спорт';
      case 'weather':
        return 'Аба ырайы';
      default:
        if (id.isEmpty) return 'Категория';
        return '${id[0].toUpperCase()}${id.substring(1)}';
    }
  }

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserEmail => _auth.currentUser?.email;
  String? get currentUserDisplayName => _auth.currentUser?.displayName;
  bool get isCurrentUserEmailVerificationRequired =>
      _requiresEmailVerification(_auth.currentUser);
  String? get currentUserFirstName {
    final raw = currentUserDisplayName?.trim();
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split(RegExp(r'\s+'));
    if (parts.isEmpty) return null;
    final first = parts.first.trim();
    return first.isEmpty ? null : first;
  }

  Stream<String?> get userStream =>
      _auth.authStateChanges().map((user) => user?.uid);

  Future<UserProgressModel?> fetchUserProgress(String uid) async {
    try {
      final snap = await _firestore.collection('userProgress').doc(uid).get();
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return UserProgressModel.fromJson({...data, 'userId': uid});
    } catch (e) {
      debugPrint('Failed to load progress for $uid: $e');
      return null;
    }
  }

  Future<void> saveUserProgress(UserProgressModel progress) async {
    final uid = progress.userId.isNotEmpty
        ? progress.userId
        : _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    try {
      await _firestore.collection('userProgress').doc(uid).set({
        'userId': uid,
        'correctByWordId': progress.correctByWordId,
        'seenByWordId': progress.seenByWordId,
        'wordProgressById': progress.wordProgressById.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'dailyActivityCountByDate': progress.dailyActivityCountByDate,
        'dailyCorrectCountByDate': progress.dailyCorrectCountByDate,
        'dailyLearningSecondsByDate': progress.dailyLearningSecondsByDate,
        'dailyXpByDate': progress.dailyXpByDate,
        'claimedDailyQuestKeys': progress.claimedDailyQuestKeys,
        'streakDays': progress.streakDays,
        'totalLearningSeconds': progress.totalLearningSeconds,
        'totalXp': progress.totalXp,
        'lastSessionAt': progress.lastSessionAt,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to save progress for $uid: $e');
      rethrow;
    }
  }

  Future<void> updateUserStats({
    required String uid,
    required int totalMastered,
    required int totalSessions,
    required int accuracy,
    required int totalXp,
    required int streakDays,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'totalMastered': totalMastered,
        'totalSessions': totalSessions,
        'accuracy': accuracy,
        'totalXp': totalXp,
        'streakDays': streakDays,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to update user stats for $uid: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    String? nickname,
    String? avatar,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        if (nickname != null) 'nickname': nickname,
        if (avatar != null) 'avatar': avatar,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to update profile for $uid: $e');
    }
  }

  Future<UserProfileModel?> fetchUserProfile(String uid) async {
    try {
      final snap = await _firestore.collection('users').doc(uid).get();
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return UserProfileModel.fromJson(uid, data);
    } catch (e) {
      debugPrint('Failed to fetch profile for $uid: $e');
      return null;
    }
  }

  Future<List<UserProfileModel>> fetchLeaderboard({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('totalXp', descending: true)
          .limit(limit)
          .get();
      final items = snapshot.docs
          .map((doc) => UserProfileModel.fromJson(doc.id, doc.data()))
          .toList();
      items.sort((a, b) {
        final scoreCompare = b.leaderboardScore.compareTo(a.leaderboardScore);
        if (scoreCompare != 0) return scoreCompare;
        final masteredCompare = b.totalMastered.compareTo(a.totalMastered);
        if (masteredCompare != 0) return masteredCompare;
        return b.accuracy.compareTo(a.accuracy);
      });
      return items;
    } catch (e) {
      debugPrint('Failed to load leaderboard: $e');
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to login: $e');
      rethrow;
    } catch (e) {
      debugPrint('Failed to login: $e');
      rethrow;
    }
  }

  Future<bool> loginWithGoogle() async {
    if (!isGoogleSignInSupported) {
      throw FirebaseAuthException(
        code: 'google-sign-in-not-supported',
        message: googleSignInUnavailableMessage,
      );
    }
    try {
      if (kIsWeb) {
        await _auth.signInWithPopup(_buildGoogleProvider());
        return true;
      }
      if (defaultTargetPlatform == TargetPlatform.windows) {
        await _auth.signInWithProvider(_buildGoogleProvider());
        return true;
      }
      final account = await _googleSignIn.signIn();
      if (account == null) return false;
      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        // Some Android/iOS devices may not return an ID token via GoogleSignIn.
        // Use Firebase native provider flow as a resilient fallback.
        if (_canUseNativeProviderFallback) {
          await _auth.signInWithProvider(_buildGoogleProvider());
          return true;
        }
        throw FirebaseAuthException(
          code: 'google-sign-in-missing-id-token',
          message:
              'Google Sign-In ID token алынган жок. Firebase конфигурациясын жана OAuth кардарын текшериңиз.',
        );
      }
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } on PlatformException catch (e) {
      debugPrint('Failed to sign in with Google: $e');
      if (_isGoogleSignInCancelled(e)) {
        return false;
      }
      if (_isAndroidGoogleConfigurationIssue(e)) {
        throw FirebaseAuthException(
          code: 'google-sign-in-config-missing',
          message: googleSignInConfigurationMessage,
        );
      }
      if (_isGooglePlayServicesIssue(e)) {
        throw FirebaseAuthException(
          code: 'google-play-services-unavailable',
          message:
              'Google Play Services жеткиликсиз же эски. Google APIs бар эмуляторду же кадимки Android түзмөктү колдонуңуз.',
        );
      }

      if (_canUseNativeProviderFallback) {
        try {
          await _auth.signInWithProvider(_buildGoogleProvider());
          return true;
        } on FirebaseAuthException {
          rethrow;
        } catch (_) {
          rethrow;
        }
      }
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to sign in with Google: $e');
      rethrow;
    } catch (e) {
      debugPrint('Failed to sign in with Google: $e');
      rethrow;
    }
  }

  Future<bool> register(
    String email,
    String password, {
    String? nickname,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final trimmedNickname = nickname?.trim();
      if (trimmedNickname != null && trimmedNickname.isNotEmpty) {
        await _auth.currentUser?.updateDisplayName(trimmedNickname);
      }
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await updateUserProfile(
          uid: uid,
          nickname: trimmedNickname?.isNotEmpty == true
              ? trimmedNickname
              : null,
        );
      }
      try {
        await sendCurrentUserEmailVerification();
      } on FirebaseAuthException catch (e) {
        debugPrint('Failed to send verification email after register: $e');
      } catch (e) {
        debugPrint('Failed to send verification email after register: $e');
      }
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to register: $e');
      rethrow;
    } catch (e) {
      debugPrint('Failed to register: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to send password reset email: $e');
      rethrow;
    } catch (e) {
      debugPrint('Failed to send password reset email: $e');
      rethrow;
    }
  }

  Future<void> sendCurrentUserEmailVerification() async {
    final user = _auth.currentUser;
    if (!_requiresEmailVerification(user)) return;
    try {
      await user!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to send verification email: $e');
      rethrow;
    } catch (e) {
      debugPrint('Failed to send verification email: $e');
      rethrow;
    }
  }

  Future<bool> refreshEmailVerificationStatus() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      await user.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to refresh email verification status: $e');
      rethrow;
    } catch (e) {
      debugPrint('Failed to refresh email verification status: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    if (!kIsWeb &&
        isGoogleSignInSupported &&
        defaultTargetPlatform != TargetPlatform.windows) {
      await _googleSignIn.signOut();
    }
  }

  GoogleAuthProvider _buildGoogleProvider() {
    final provider = GoogleAuthProvider();
    provider.setCustomParameters({'prompt': 'select_account'});
    return provider;
  }

  bool _isAndroidGoogleConfigurationIssue(PlatformException error) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    final raw = '${error.code} ${error.message} ${error.details}'.toLowerCase();
    return raw.contains('apiexception: 10') ||
        raw.contains('developer_error') ||
        raw.contains('12500');
  }

  bool get _canUseNativeProviderFallback {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  bool _isGoogleSignInCancelled(PlatformException error) {
    final raw = '${error.code} ${error.message} ${error.details}'.toLowerCase();
    return raw.contains('canceled') ||
        raw.contains('cancelled') ||
        raw.contains('sign_in_canceled') ||
        raw.contains('12501');
  }

  bool _isGooglePlayServicesIssue(PlatformException error) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    final raw = '${error.code} ${error.message} ${error.details}'.toLowerCase();
    return raw.contains('google play services') ||
        raw.contains('play services') ||
        raw.contains('service_missing') ||
        raw.contains('service_version_update_required') ||
        raw.contains('service_disabled');
  }

  bool _requiresEmailVerification(User? user) {
    if (Constants.disableEmailVerification) {
      return false;
    }
    if (user == null || user.emailVerified) return false;
    final email = user.email?.trim();
    if (email == null || email.isEmpty) return false;
    final providerIds = user.providerData.map((entry) => entry.providerId);
    return providerIds.contains(EmailAuthProvider.PROVIDER_ID);
  }

  Future<List<QuizQuestionModel>> fetchQuizQuestions(
    String categoryId, {
    int limit = 10,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('quiz');
      if (categoryId.isNotEmpty) {
        query = query.where('category', isEqualTo: categoryId);
      }

      Query<Map<String, dynamic>> typedQuery = query.where(
        'type',
        isEqualTo: 'choose_translation',
      );

      final poolLimit = (limit * 4).clamp(limit, 80).toInt();
      var snapshot = await typedQuery.limit(poolLimit).get();
      if (snapshot.docs.isEmpty) {
        snapshot = await query.limit(poolLimit).get();
      }
      final items =
          snapshot.docs
              .map((doc) => QuizQuestionModel.fromJson(doc.id, doc.data()))
              .toList()
            ..shuffle();
      return items.length > limit ? items.take(limit).toList() : items;
    } catch (e) {
      debugPrint('Failed to load quiz for $categoryId: $e');
      return const [];
    }
  }
}
