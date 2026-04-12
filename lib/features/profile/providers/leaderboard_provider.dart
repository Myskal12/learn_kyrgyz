import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/services/firebase_service.dart';
import '../../../data/models/user_profile_model.dart';

class LeaderboardProvider extends ChangeNotifier {
  LeaderboardProvider(this._firebase);

  final FirebaseService _firebase;
  static const defaultLimit = 10;
  static const expandedLimit = 100;

  List<UserProfileModel> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _loaded = false;
  int _currentLimit = defaultLimit;

  List<UserProfileModel> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isLoaded => _loaded;
  String? get errorMessage => _errorMessage;
  int get currentLimit => _currentLimit;
  bool get isExpanded => _currentLimit >= expandedLimit;

  Future<void> load({bool force = false, int? limit}) async {
    final requestedLimit = (limit ?? _currentLimit).clamp(
      defaultLimit,
      expandedLimit,
    );
    if (_isLoading) return;
    if (!force && _loaded && requestedLimit == _currentLimit) return;

    _isLoading = true;
    _errorMessage = null;
    _currentLimit = requestedLimit;
    notifyListeners();

    try {
      _entries = await _firebase.fetchLeaderboard(limit: requestedLimit);
      _loaded = true;
    } catch (_) {
      _errorMessage =
          'Лидерборд жүктөлгөн жок. Интернетти текшерип кайра аракет кылыңыз.';
      _loaded = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExpanded() async {
    await load(force: true, limit: expandedLimit);
  }
}

final leaderboardProvider = ChangeNotifierProvider<LeaderboardProvider>((ref) {
  final firebase = ref.read(firebaseServiceProvider);
  return LeaderboardProvider(firebase);
});
