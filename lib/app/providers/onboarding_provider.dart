import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/firebase_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../data/models/onboarding_config_model.dart';
import 'app_providers.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider(this._storage, this._firebase);

  static const _completedKey = 'onboarding_completed';
  static const _dailyGoalKey = 'daily_goal_minutes';

  final LocalStorageService _storage;
  final FirebaseService _firebase;

  bool _loaded = false;
  bool _completed = false;
  int _dailyGoalMinutes = OnboardingConfigModel.fallback.defaultDailyGoal;
  List<int> _dailyGoalOptions = List<int>.of(
    OnboardingConfigModel.fallback.dailyGoalOptions,
  );

  bool get isLoaded => _loaded;
  bool get isCompleted => _completed;
  int get dailyGoalMinutes => _dailyGoalMinutes;
  List<int> get dailyGoalOptions => List<int>.unmodifiable(_dailyGoalOptions);

  Future<void> load() async {
    if (_loaded) return;
    final rawCompleted = await _storage.getString(_completedKey);
    final rawDailyGoal = await _storage.getString(_dailyGoalKey);

    var config = OnboardingConfigModel.fallback;
    final remoteConfig = await _firebase.fetchOnboardingConfig();
    if (remoteConfig != null) {
      config = remoteConfig;
    }

    _dailyGoalOptions = List<int>.of(config.dailyGoalOptions);
    _completed = rawCompleted == 'true';

    final parsedDailyGoal = int.tryParse(rawDailyGoal ?? '');
    if (parsedDailyGoal != null &&
        _dailyGoalOptions.contains(parsedDailyGoal)) {
      _dailyGoalMinutes = parsedDailyGoal;
    } else {
      _dailyGoalMinutes = config.defaultDailyGoal;
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> setDailyGoalMinutes(int minutes) async {
    if (!_dailyGoalOptions.contains(minutes)) return;
    if (_dailyGoalMinutes == minutes) return;
    _dailyGoalMinutes = minutes;
    notifyListeners();
    await _storage.setString(_dailyGoalKey, minutes.toString());
  }

  Future<void> completeOnboarding() async {
    _completed = true;
    notifyListeners();
    await _storage.setString(_completedKey, 'true');
    await _storage.setString(_dailyGoalKey, _dailyGoalMinutes.toString());
  }
}

final onboardingProvider = ChangeNotifierProvider<OnboardingProvider>((ref) {
  final storage = ref.read(localStorageServiceProvider);
  final firebase = ref.read(firebaseServiceProvider);
  final provider = OnboardingProvider(storage, firebase);
  unawaited(provider.load());
  return provider;
});
