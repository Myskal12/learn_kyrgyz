import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../data/models/word_model.dart';

class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._storage, this._firebase) {
    _authSub = _firebase.userStream.listen(_handleAuthChange);
  }

  static const _storageKey = 'user_progress';
  final LocalStorageService _storage;
  final FirebaseService _firebase;
  StreamSubscription<String?>? _authSub;
  String? _remoteUid;

  UserProgressModel _progress = UserProgressModel(userId: 'guest');
  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await _storage.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _progress = UserProgressModel.fromJson(data);
      } catch (_) {
        _progress = UserProgressModel(userId: 'guest');
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> reset() async {
    _progress = UserProgressModel(userId: _remoteUid ?? 'guest');
    _loaded = true;
    await _persist();
  }

  void markWordSeen(String wordId) {
    _touchSession();
    final current = _progress.seenByWordId[wordId] ?? 0;
    _progress.seenByWordId[wordId] = current + 1;
    _persist();
  }

  void markWordMastered(String wordId) {
    markWordSeen(wordId);
    final current = _progress.correctByWordId[wordId] ?? 0;
    _progress.correctByWordId[wordId] = current + 1;
    _persist();
  }

  int get totalWordsReviewed => _progress.seenByWordId.length;

  int get totalWordsMastered => _progress.correctByWordId.length;

  int get totalReviewSessions =>
      _progress.seenByWordId.values.fold(0, (prev, value) => prev + value);

  int get accuracyPercent {
    final exposures = _progress.seenByWordId.values.fold(
      0,
      (prev, value) => prev + value,
    );
    if (exposures == 0) return 0;
    final masteredCount = _progress.correctByWordId.values.fold(
      0,
      (prev, value) => prev + value,
    );
    return ((masteredCount / exposures) * 100).round();
  }

  int get streakDays => _progress.streakDays;

  bool get hasActivityToday {
    final last = _progress.lastSessionAt;
    if (last == null) return false;
    final today = DateUtils.dateOnly(DateTime.now());
    return DateUtils.isSameDay(today, DateUtils.dateOnly(last));
  }

  double completionForCategory(List<WordModel> words) {
    if (words.isEmpty) return 0;
    final mastered = words
        .where((w) => _progress.correctByWordId.containsKey(w.id))
        .length;
    return (mastered / words.length).clamp(0, 1);
  }

  double exposureForCategory(List<WordModel> words) {
    if (words.isEmpty) return 0;
    final seen = words
        .where((w) => _progress.seenByWordId.containsKey(w.id))
        .length;
    return (seen / words.length).clamp(0, 1);
  }

  String get level {
    final mastered = totalWordsMastered;
    if (mastered >= 30) return 'Алдыңкы деңгээл';
    if (mastered >= 15) return 'Орто деңгээл';
    return 'Башталгыч';
  }

  Future<void> _persist() async {
    final payload = jsonEncode(_progress.toJson());
    await _storage.setString(_storageKey, payload);
    await _syncRemote();
    notifyListeners();
  }

  Future<void> _handleAuthChange(String? uid) async {
    _remoteUid = uid;
    if (uid == null) {
      _progress = _progress.copyWith(userId: 'guest');
      await _persist();
      notifyListeners();
      return;
    }
    final remote = await _firebase.fetchUserProgress(uid);
    if (remote != null) {
      _progress = remote;
      await _persist();
    } else {
      _progress = _progress.copyWith(userId: uid);
      await _firebase.saveUserProgress(_progress);
      await _firebase.updateUserStats(
        uid: uid,
        totalMastered: totalWordsMastered,
        totalSessions: totalReviewSessions,
        accuracy: accuracyPercent,
      );
    }
    notifyListeners();
  }

  Future<void> _syncRemote() async {
    final uid = _remoteUid;
    if (uid == null) return;
    await _firebase.saveUserProgress(_progress.copyWith(userId: uid));
    await _firebase.updateUserStats(
      uid: uid,
      totalMastered: totalWordsMastered,
      totalSessions: totalReviewSessions,
      accuracy: accuracyPercent,
    );
  }

  void _touchSession() {
    final today = DateUtils.dateOnly(DateTime.now());
    final last = _progress.lastSessionAt == null
        ? null
        : DateUtils.dateOnly(_progress.lastSessionAt!);
    int streak = _progress.streakDays;
    if (last == null) {
      streak = 1;
    } else {
      final diff = today.difference(last).inDays;
      if (diff == 0) {
        streak = _progress.streakDays;
      } else if (diff == 1) {
        streak = _progress.streakDays + 1;
      } else if (diff > 1) {
        streak = 1;
      }
    }
    _progress = _progress.copyWith(streakDays: streak, lastSessionAt: today);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

final progressProvider = ChangeNotifierProvider<ProgressProvider>((ref) {
  final storage = ref.read(localStorageServiceProvider);
  final firebase = ref.read(firebaseServiceProvider);
  final provider = ProgressProvider(storage, firebase);
  unawaited(provider.load());
  return provider;
});
