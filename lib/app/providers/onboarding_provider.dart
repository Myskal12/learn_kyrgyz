import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/local_storage_service.dart';
import 'app_providers.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider(this._storage);

  static const _completedKey = 'onboarding_completed';
  static const _dailyGoalKey = 'daily_goal_minutes';
  static const _defaultDailyGoal = 20;

  final LocalStorageService _storage;

  bool _loaded = false;
  bool _completed = false;
  int _dailyGoalMinutes = _defaultDailyGoal;

  bool get isLoaded => _loaded;
  bool get isCompleted => _completed;
  int get dailyGoalMinutes => _dailyGoalMinutes;

  Future<void> load() async {
    if (_loaded) return;
    final rawCompleted = await _storage.getString(_completedKey);
    final rawDailyGoal = await _storage.getString(_dailyGoalKey);
    _completed = rawCompleted == 'true';
    _dailyGoalMinutes = int.tryParse(rawDailyGoal ?? '') ?? _defaultDailyGoal;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDailyGoalMinutes(int minutes) async {
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
  final provider = OnboardingProvider(storage);
  unawaited(provider.load());
  return provider;
});
