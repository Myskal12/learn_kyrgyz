import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/services/firebase_service.dart';
import '../../../data/models/user_profile_model.dart';

class LeaderboardProvider extends ChangeNotifier {
  LeaderboardProvider(this._firebase);

  final FirebaseService _firebase;

  List<UserProfileModel> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _loaded = false;

  List<UserProfileModel> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isLoaded => _loaded;
  String? get errorMessage => _errorMessage;

  Future<void> load({bool force = false, int limit = 12}) async {
    if (_isLoading) return;
    if (!force && _loaded) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = await _firebase.fetchLeaderboard(limit: limit);
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
}

final leaderboardProvider = ChangeNotifierProvider<LeaderboardProvider>((ref) {
  final firebase = ref.read(firebaseServiceProvider);
  return LeaderboardProvider(firebase);
});
