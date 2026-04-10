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

  static const _legacyStorageKey = 'user_progress';
  static const _milestoneTargets = <int>[5, 15, 30, 50];

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
        return 'Түзмөктө';
      case ProgressSyncState.pending:
        return 'Кезекте';
      case ProgressSyncState.syncing:
        return 'Жөнөтүлүүдө';
      case ProgressSyncState.synced:
        return 'Аккаунтта';
      case ProgressSyncState.failed:
        return 'Жеткирилген жок';
    }
  }

  String get syncSubtitle {
    switch (_syncState) {
      case ProgressSyncState.localOnly:
        return 'Маалымат ушул түзмөктө сакталат.';
      case ProgressSyncState.pending:
        return 'Өзгөрүү сакталды.';
      case ProgressSyncState.syncing:
        return 'Аккаунтка көчүрмө кетип жатат.';
      case ProgressSyncState.synced:
        if (_lastSyncedAt == null) {
          return 'Түзмөк жана аккаунт даяр.';
        }
        return 'Акыркы көчүрмө: ${_formatTime(_lastSyncedAt!)}.';
      case ProgressSyncState.failed:
        return _syncError ?? 'Кийин кайра аракет кылыңыз.';
    }
  }

  Future<void> load() async {
    if (_loaded) return;
    await _loadLocalProgress(_remoteUid);
    _loaded = true;
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
    if (_progress.wordProgressById.isNotEmpty) {
      _cachedTotalExposures = _progress.wordProgressById.values.fold(
        0,
        (sum, value) => sum + value.attemptCount,
      );
      _cachedTotalCorrect = _progress.wordProgressById.values.fold(
        0,
        (sum, value) => sum + value.successCount,
      );
      return;
    }
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
    recordWordAttempt(wordId, isCorrect: false);
  }

  void markWordMastered(String wordId) {
    recordWordAttempt(wordId, isCorrect: true);
  }

  void recordWordAttempt(String wordId, {required bool isCorrect}) {
    _touchSession();
    final seen = _progress.seenByWordId[wordId] ?? 0;
    _progress.seenByWordId[wordId] = seen + 1;
    final now = DateTime.now();
    final current = _progress.wordProgressById[wordId] ?? WordProgressRecord();
    _progress.wordProgressById[wordId] = _nextWordProgressState(
      current,
      attemptedAt: now,
      isCorrect: isCorrect,
    );
    _cachedTotalExposures++;
    if (isCorrect) {
      final correct = _progress.correctByWordId[wordId] ?? 0;
      _progress.correctByWordId[wordId] = correct + 1;
      _cachedTotalCorrect++;
    }
    notifyListeners();
    unawaited(_persist());
  }

  int get totalWordsReviewed => _progress.wordProgressById.isNotEmpty
      ? _progress.wordProgressById.values
            .where((record) => record.attemptCount > 0)
            .length
      : _progress.seenByWordId.length;
  int get totalWordsMastered => _progress.correctByWordId.length;
  int get totalReviewSessions => _cachedTotalExposures;
  int get weakWordsCount => _progress.wordProgressById.values
      .where(
        (record) =>
            record.learningState == WordLearningState.weak ||
            record.learningState == WordLearningState.reviewDue,
      )
      .length;
  int get reviewDueWordsCount =>
      _progress.wordProgressById.values.where(_isWordReviewDue).length;
  bool get hasReviewFocus => reviewDueWordsCount > 0 || weakWordsCount > 0;

  int? get nextMilestoneTarget {
    for (final target in _milestoneTargets) {
      if (totalWordsMastered < target) return target;
    }
    return null;
  }

  int get previousMilestoneTarget {
    var previous = 0;
    for (final target in _milestoneTargets) {
      if (totalWordsMastered < target) {
        return previous;
      }
      previous = target;
    }
    return _milestoneTargets.last;
  }

  int get wordsToNextMilestone {
    final target = nextMilestoneTarget;
    if (target == null) return 0;
    return (target - totalWordsMastered).clamp(0, target);
  }

  double get nextMilestoneProgress {
    final target = nextMilestoneTarget;
    if (target == null) return 1;
    final previous = previousMilestoneTarget;
    final span = target - previous;
    if (span <= 0) return 1;
    return ((totalWordsMastered - previous) / span).clamp(0, 1);
  }

  String get nextMilestoneLabel {
    final target = nextMilestoneTarget;
    if (target == null) return 'Ачык практика этабы';
    return '$target сөз';
  }

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
      final record = _progress.wordProgressById[word.id];
      if (record != null) {
        return _isWordReviewDue(record);
      }
      final seen = _progress.seenByWordId[word.id] ?? 0;
      final correct = _progress.correctByWordId[word.id] ?? 0;
      return seen > correct;
    }).length;
  }

  List<WordModel> reviewDueWords(List<WordModel> words) {
    if (words.isEmpty) return const [];
    return words.where((word) {
      final record = _progress.wordProgressById[word.id];
      if (record != null) {
        return _isWordReviewDue(record);
      }
      final seen = _progress.seenByWordId[word.id] ?? 0;
      final correct = _progress.correctByWordId[word.id] ?? 0;
      return seen > correct;
    }).toList();
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
    await _storage.setString(_storageKeyFor(_remoteUid), payload);
  }

  Future<void> _handleAuthChange(String? uid) async {
    _remoteUid = uid;
    final hadLocalProgress = await _loadLocalProgress(uid);
    _loaded = true;
    _lastSyncedAt = null;

    if (uid == null) {
      _setSyncState(ProgressSyncState.localOnly, clearError: true);
      notifyListeners();
      return;
    }

    try {
      final remote = await _firebase.fetchUserProgress(uid);
      if (remote != null) {
        _progress = _migrateLegacyWordProgress(remote);
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

    if (hadLocalProgress && _hasMeaningfulProgress(_progress)) {
      _setSyncState(ProgressSyncState.pending, clearError: true);
      notifyListeners();
      await _enqueueSync();
      return;
    }

    _progress = UserProgressModel(userId: uid);
    _recalculateTotals();
    await _saveLocal();
    _setSyncState(ProgressSyncState.synced, clearError: true);
    notifyListeners();
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

  WordProgressRecord? progressForWord(String wordId) {
    return _progress.wordProgressById[wordId];
  }

  WordLearningState learningStateForWord(String wordId) {
    return progressForWord(wordId)?.learningState ?? WordLearningState.newWord;
  }

  UserProgressModel _migrateLegacyWordProgress(UserProgressModel progress) {
    if (progress.wordProgressById.isNotEmpty) {
      return progress;
    }

    final migrated = <String, WordProgressRecord>{};
    final allWordIds = <String>{
      ...progress.seenByWordId.keys,
      ...progress.correctByWordId.keys,
    };
    for (final wordId in allWordIds) {
      final attempts = progress.seenByWordId[wordId] ?? 0;
      final successes = progress.correctByWordId[wordId] ?? 0;
      final failures = (attempts - successes).clamp(0, attempts);
      final learningState = _deriveLearningState(
        attemptCount: attempts,
        successCount: successes,
        failureCount: failures,
      );
      migrated[wordId] = WordProgressRecord(
        attemptCount: attempts,
        successCount: successes,
        failureCount: failures,
        lastAttemptAt: progress.lastSessionAt,
        lastCorrectAt: successes > 0 ? progress.lastSessionAt : null,
        nextReviewAt: failures > 0 ? DateTime.now() : null,
        learningState: learningState,
      );
    }
    return progress.copyWith(wordProgressById: migrated);
  }

  WordProgressRecord _nextWordProgressState(
    WordProgressRecord current, {
    required DateTime attemptedAt,
    required bool isCorrect,
  }) {
    final attempts = current.attemptCount + 1;
    final successes = current.successCount + (isCorrect ? 1 : 0);
    final failures = current.failureCount + (isCorrect ? 0 : 1);
    final learningState = _deriveLearningState(
      attemptCount: attempts,
      successCount: successes,
      failureCount: failures,
    );
    return WordProgressRecord(
      attemptCount: attempts,
      successCount: successes,
      failureCount: failures,
      lastAttemptAt: attemptedAt,
      lastCorrectAt: isCorrect ? attemptedAt : current.lastCorrectAt,
      nextReviewAt: _nextReviewAt(
        attemptedAt: attemptedAt,
        attemptCount: attempts,
        successCount: successes,
        failureCount: failures,
        isCorrect: isCorrect,
      ),
      learningState: learningState,
    );
  }

  WordLearningState _deriveLearningState({
    required int attemptCount,
    required int successCount,
    required int failureCount,
  }) {
    if (attemptCount == 0) return WordLearningState.newWord;
    if (failureCount >= successCount && failureCount > 0) {
      return failureCount >= 2
          ? WordLearningState.weak
          : WordLearningState.reviewDue;
    }
    if (successCount >= 3 && failureCount == 0) {
      return WordLearningState.mastered;
    }
    if (successCount >= 2) {
      return WordLearningState.strong;
    }
    return WordLearningState.learning;
  }

  DateTime? _nextReviewAt({
    required DateTime attemptedAt,
    required int attemptCount,
    required int successCount,
    required int failureCount,
    required bool isCorrect,
  }) {
    if (!isCorrect) {
      return attemptedAt;
    }
    if (successCount >= 3 && failureCount == 0) {
      return attemptedAt.add(const Duration(days: 7));
    }
    if (successCount >= 2) {
      return attemptedAt.add(const Duration(days: 3));
    }
    if (attemptCount == 1) {
      return attemptedAt.add(const Duration(hours: 12));
    }
    return attemptedAt.add(const Duration(days: 1));
  }

  bool _isWordReviewDue(WordProgressRecord record) {
    if (record.learningState == WordLearningState.weak ||
        record.learningState == WordLearningState.reviewDue) {
      return true;
    }
    final nextReviewAt = record.nextReviewAt;
    if (nextReviewAt == null) return false;
    return !nextReviewAt.isAfter(DateTime.now());
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
    return 'Аккаунтка жөнөтүү ишке ашкан жок.';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<bool> _loadLocalProgress(String? uid) async {
    final loaded = await _readStoredProgress(uid);
    _progress =
        loaded != null
            ? _migrateLegacyWordProgress(loaded.copyWith(userId: uid ?? 'guest'))
            : UserProgressModel(userId: uid ?? 'guest');
    _recalculateTotals();
    return loaded != null;
  }

  Future<UserProgressModel?> _readStoredProgress(String? uid) async {
    final scopedRaw = await _storage.getString(_storageKeyFor(uid));
    final scoped = _parseProgress(scopedRaw);
    if (scoped != null) {
      return scoped;
    }

    final legacyRaw = await _storage.getString(_legacyStorageKey);
    final legacy = _parseProgress(legacyRaw);
    if (legacy == null) {
      return null;
    }

    final expectedUserId = uid ?? 'guest';
    if (legacy.userId != expectedUserId) {
      return null;
    }

    await _storage.setString(
      _storageKeyFor(uid),
      jsonEncode(legacy.copyWith(userId: expectedUserId).toJson()),
    );
    return legacy;
  }

  UserProgressModel? _parseProgress(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return UserProgressModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  String _storageKeyFor(String? uid) => 'user_progress_${uid ?? 'guest'}';

  bool _hasMeaningfulProgress(UserProgressModel progress) {
    return progress.wordProgressById.isNotEmpty ||
        progress.seenByWordId.isNotEmpty ||
        progress.correctByWordId.isNotEmpty ||
        progress.streakDays > 0 ||
        progress.lastSessionAt != null;
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
