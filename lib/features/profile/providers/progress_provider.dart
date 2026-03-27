import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../data/models/word_model.dart';

enum ProgressSyncState { localOnly, pending, syncing, synced, failed }

class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._storage, this._firebase)
    : _syncState = ProgressSyncState.localOnly {
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

  int _cachedTotalExposures = 0;
  int _cachedTotalCorrect = 0;

  ProgressSyncState _syncState;
  DateTime? _lastSyncedAt;
  String? _syncError;
  bool _syncInFlight = false;
  bool _syncQueued = false;

  bool get isGuest => _remoteUid == null;
  ProgressSyncState get syncState => _syncState;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  String? get syncError => _syncError;
  bool get canRetrySync =>
      _remoteUid != null && _syncState == ProgressSyncState.failed;

  String get syncTitle {
    switch (_syncState) {
      case ProgressSyncState.localOnly:
        return 'Жергиликтүү сакталды';
      case ProgressSyncState.pending:
        return 'Синхрондоштуруу күтүлүүдө';
      case ProgressSyncState.syncing:
        return 'Синхрондошуп жатат';
      case ProgressSyncState.synced:
        return 'Булут менен шайкеш';
      case ProgressSyncState.failed:
        return 'Синхрондоштуруу токтоду';
    }
  }

  String get syncSubtitle {
    switch (_syncState) {
      case ProgressSyncState.localOnly:
        return 'Прогресс ушул түзмөктө сакталат. Кирсеңиз, булутка да жөнөтөбүз.';
      case ProgressSyncState.pending:
        return 'Өзгөртүүлөр локалдык түрдө сакталды жана кезекке коюлду.';
      case ProgressSyncState.syncing:
        return 'Акыркы жыйынтыктар булут сактагычка жөнөтүлүп жатат.';
      case ProgressSyncState.synced:
        if (_lastSyncedAt == null) {
          return 'Прогресс локалдык жана булут сактагычта бирдей.';
        }
        return 'Акыркы синк: ${_formatTime(_lastSyncedAt!)}.';
      case ProgressSyncState.failed:
        return _syncError ??
            'Интернетти текшерип, дайындарды кайра синхрондоп көрүңүз.';
    }
  }

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
    _recalculateTotals();
    _syncState = _remoteUid == null
        ? ProgressSyncState.localOnly
        : ProgressSyncState.pending;
    notifyListeners();
  }

  Future<void> reset() async {
    _progress = UserProgressModel(userId: _remoteUid ?? 'guest');
    _loaded = true;
    _recalculateTotals();
    notifyListeners();
    await _persist();
  }

  void _recalculateTotals() {
    _cachedTotalExposures = _progress.seenByWordId.values.fold(
      0,
      (sum, value) => sum + value,
    );
    _cachedTotalCorrect = _progress.correctByWordId.values.fold(
      0,
      (sum, value) => sum + value,
    );
  }

  void markWordSeen(String wordId) {
    _touchSession();
    final seen = _progress.seenByWordId[wordId] ?? 0;
    _progress.seenByWordId[wordId] = seen + 1;
    _cachedTotalExposures++;
    notifyListeners();
    unawaited(_persist());
  }

  void markWordMastered(String wordId) {
    _touchSession();
    final seen = _progress.seenByWordId[wordId] ?? 0;
    final correct = _progress.correctByWordId[wordId] ?? 0;
    _progress.seenByWordId[wordId] = seen + 1;
    _progress.correctByWordId[wordId] = correct + 1;
    _cachedTotalExposures++;
    _cachedTotalCorrect++;
    notifyListeners();
    unawaited(_persist());
  }

  int get totalWordsReviewed => _progress.seenByWordId.length;
  int get totalWordsMastered => _progress.correctByWordId.length;
  int get totalReviewSessions => _cachedTotalExposures;

  int get accuracyPercent {
    final exposures = _cachedTotalExposures;
    if (exposures == 0) return 0;
    return ((_cachedTotalCorrect / exposures) * 100).round();
  }

  int get streakDays => _progress.streakDays;

  bool get hasActivityToday {
    final last = _progress.lastSessionAt;
    if (last == null) return false;
    final today = DateUtils.dateOnly(DateTime.now());
    return DateUtils.isSameDay(today, DateUtils.dateOnly(last));
  }

  int masteredWordsForCategory(List<WordModel> words) {
    if (words.isEmpty) return 0;
    return words
        .where((word) => _progress.correctByWordId.containsKey(word.id))
        .length;
  }

  int seenWordsForCategory(List<WordModel> words) {
    if (words.isEmpty) return 0;
    return words
        .where((word) => _progress.seenByWordId.containsKey(word.id))
        .length;
  }

  int reviewDueForCategory(List<WordModel> words) {
    if (words.isEmpty) return 0;
    return words.where((word) {
      final seen = _progress.seenByWordId[word.id] ?? 0;
      final correct = _progress.correctByWordId[word.id] ?? 0;
      return seen > correct;
    }).length;
  }

  double completionForCategory(List<WordModel> words) {
    if (words.isEmpty) return 0;
    final mastered = words
        .where((word) => _progress.correctByWordId.containsKey(word.id))
        .length;
    return (mastered / words.length).clamp(0, 1);
  }

  double exposureForCategory(List<WordModel> words) {
    if (words.isEmpty) return 0;
    final seen = words
        .where((word) => _progress.seenByWordId.containsKey(word.id))
        .length;
    return (seen / words.length).clamp(0, 1);
  }

  String get level {
    final mastered = totalWordsMastered;
    if (mastered >= 30) return 'Алдыңкы деңгээл';
    if (mastered >= 15) return 'Орто деңгээл';
    return 'Башталгыч';
  }

  Future<void> retrySync() async {
    if (_remoteUid == null) return;
    _setSyncState(ProgressSyncState.pending, clearError: true);
    notifyListeners();
    await _enqueueSync();
  }

  Future<void> _persist() async {
    await _saveLocal();
    if (_remoteUid == null) {
      _setSyncState(ProgressSyncState.localOnly, clearError: true);
      notifyListeners();
      return;
    }
    _setSyncState(ProgressSyncState.pending, clearError: true);
    notifyListeners();
    await _enqueueSync();
  }

  Future<void> _saveLocal() async {
    final payload = jsonEncode(_progress.toJson());
    await _storage.setString(_storageKey, payload);
  }

  Future<void> _handleAuthChange(String? uid) async {
    _remoteUid = uid;
    if (!_loaded) {
      await load();
    }

    if (uid == null) {
      _progress = _progress.copyWith(userId: 'guest');
      await _saveLocal();
      _setSyncState(ProgressSyncState.localOnly, clearError: true);
      notifyListeners();
      return;
    }

    try {
      final remote = await _firebase.fetchUserProgress(uid);
      if (remote != null) {
        _progress = remote;
        _recalculateTotals();
        await _saveLocal();
        _lastSyncedAt = DateTime.now();
        _setSyncState(ProgressSyncState.synced, clearError: true);
        notifyListeners();
        return;
      }
    } catch (error) {
      _setSyncState(ProgressSyncState.failed, error: _describeSyncError(error));
      notifyListeners();
      return;
    }

    _progress = _progress.copyWith(userId: uid);
    _recalculateTotals();
    notifyListeners();
    await _persist();
  }

  Future<void> _enqueueSync() async {
    final uid = _remoteUid;
    if (uid == null) return;

    _syncQueued = true;
    if (_syncInFlight) return;

    _syncInFlight = true;
    while (_syncQueued && _remoteUid != null) {
      _syncQueued = false;
      final currentUid = _remoteUid;
      if (currentUid == null) break;

      _setSyncState(ProgressSyncState.syncing, clearError: true);
      notifyListeners();

      final snapshot = _progress.copyWith(userId: currentUid);
      final totalMastered = snapshot.correctByWordId.length;
      final totalSessions = snapshot.seenByWordId.values.fold(
        0,
        (sum, value) => sum + value,
      );
      final totalCorrect = snapshot.correctByWordId.values.fold(
        0,
        (sum, value) => sum + value,
      );
      final accuracy = totalSessions == 0
          ? 0
          : ((totalCorrect / totalSessions) * 100).round();

      try {
        await _firebase.saveUserProgress(snapshot);
        await _firebase.updateUserStats(
          uid: currentUid,
          totalMastered: totalMastered,
          totalSessions: totalSessions,
          accuracy: accuracy,
        );
        _lastSyncedAt = DateTime.now();
        _setSyncState(ProgressSyncState.synced, clearError: true);
        notifyListeners();
      } catch (error) {
        _setSyncState(
          ProgressSyncState.failed,
          error: _describeSyncError(error),
        );
        notifyListeners();
        break;
      }
    }
    _syncInFlight = false;
  }

  void _touchSession() {
    final today = DateUtils.dateOnly(DateTime.now());
    final last = _progress.lastSessionAt == null
        ? null
        : DateUtils.dateOnly(_progress.lastSessionAt!);

    var streak = _progress.streakDays;
    if (last == null) {
      streak = 1;
    } else {
      final diff = today.difference(last).inDays;
      if (diff == 1) {
        streak = _progress.streakDays + 1;
      } else if (diff > 1) {
        streak = 1;
      }
    }

    _progress = _progress.copyWith(streakDays: streak, lastSessionAt: today);
  }

  void _setSyncState(
    ProgressSyncState state, {
    String? error,
    bool clearError = false,
  }) {
    _syncState = state;
    if (clearError) {
      _syncError = null;
    } else if (error != null) {
      _syncError = error;
    }
  }

  String _describeSyncError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('unavailable') ||
        message.contains('timeout')) {
      return 'Интернет жок же Firebase жеткиликсиз. Кайра аракет кылыңыз.';
    }
    return 'Булутка жөнөтүү ишке ашкан жок. Кийинчерээк кайра аракет кылыңыз.';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
