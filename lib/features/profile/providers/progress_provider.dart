import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../data/models/word_model.dart';

enum ProgressSyncState { localOnly, pending, syncing, synced, failed }

class DailyActivitySnapshot {
  const DailyActivitySnapshot({
    required this.date,
    required this.seconds,
    required this.interactions,
  });

  final DateTime date;
  final int seconds;
  final int interactions;

  bool get isActive => seconds > 0 || interactions > 0;
}

class DailyQuestSnapshot {
  const DailyQuestSnapshot({
    required this.id,
    required this.title,
    required this.description,
    required this.current,
    required this.target,
    required this.rewardXp,
    required this.route,
    required this.displayCurrent,
    required this.displayTarget,
    required this.claimed,
  });

  final String id;
  final String title;
  final String description;
  final int current;
  final int target;
  final int rewardXp;
  final String route;
  final String displayCurrent;
  final String displayTarget;
  final bool claimed;

  bool get isCompleted => current >= target;

  double get progress => target <= 0 ? 1 : (current / target).clamp(0, 1);

  String titleOf(BuildContext context) {
    switch (id) {
      case 'time_bloom':
        return context.tr(
          ky: 'Темпти ач',
          en: 'Unlock the pace',
          ru: 'Открой темп',
        );
      case 'steady_hands':
        return context.tr(ky: '12 аракет', en: '12 actions', ru: '12 действий');
      case 'sharp_focus':
        return context.tr(
          ky: 'Так жооп сериясы',
          en: 'Correct-answer streak',
          ru: 'Серия точных ответов',
        );
      default:
        return title;
    }
  }

  String descriptionOf(BuildContext context) {
    switch (id) {
      case 'time_bloom':
        return context.tr(
          ky: 'Бүгүн 10 мүнөт практика жаса.',
          en: 'Practice for 10 minutes today.',
          ru: 'Позанимайтесь сегодня 10 минут.',
        );
      case 'steady_hands':
        return context.tr(
          ky: 'Бүгүн 12 жооп же аракет топто.',
          en: 'Complete 12 answers or actions today.',
          ru: 'Сделайте сегодня 12 ответов или действий.',
        );
      case 'sharp_focus':
        return context.tr(
          ky: 'Бүгүн 8 туура жооп ал.',
          en: 'Get 8 correct answers today.',
          ru: 'Дайте сегодня 8 правильных ответов.',
        );
      default:
        return description;
    }
  }

  String progressLabelOf(BuildContext context) => isCompleted
      ? context.tr(ky: 'Аткарылды', en: 'Completed', ru: 'Выполнено')
      : '$displayCurrent / $displayTarget';
}

class WeeklyChallengeSnapshot {
  const WeeklyChallengeSnapshot({
    required this.title,
    required this.description,
    required this.activeDays,
    required this.targetActiveDays,
    required this.weeklyXp,
    required this.targetXp,
    required this.route,
  });

  final String title;
  final String description;
  final int activeDays;
  final int targetActiveDays;
  final int weeklyXp;
  final int targetXp;
  final String route;

  bool get isCompleted =>
      activeDays >= targetActiveDays && weeklyXp >= targetXp;

  double get activeDaysProgress =>
      targetActiveDays <= 0 ? 1 : (activeDays / targetActiveDays).clamp(0, 1);

  double get xpProgress =>
      targetXp <= 0 ? 1 : (weeklyXp / targetXp).clamp(0, 1);

  double get progress => ((activeDaysProgress + xpProgress) / 2).clamp(0, 1);

  String titleOf(BuildContext context) => context.tr(
    ky: 'Апталык толкун',
    en: 'Weekly wave',
    ru: 'Недельная волна',
  );

  String descriptionOf(BuildContext context) => context.tr(
    ky: '5 актив күн жана 180 XP менен жуманы жап.',
    en: 'Close the week with 5 active days and 180 XP.',
    ru: 'Закройте неделю с 5 активными днями и 180 XP.',
  );

  String statusLabelOf(BuildContext context) => isCompleted
      ? context.tr(ky: 'Жабылды', en: 'Completed', ru: 'Закрыто')
      : context.tr(ky: 'Жумада', en: 'This week', ru: 'На неделе');
}

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

  String syncTitleOf(BuildContext context) {
    switch (_syncState) {
      case ProgressSyncState.localOnly:
        return context.tr(ky: 'Түзмөктө', en: 'On device', ru: 'На устройстве');
      case ProgressSyncState.pending:
        return context.tr(ky: 'Кезекте', en: 'Queued', ru: 'В очереди');
      case ProgressSyncState.syncing:
        return context.tr(
          ky: 'Жөнөтүлүүдө',
          en: 'Syncing',
          ru: 'Синхронизация',
        );
      case ProgressSyncState.synced:
        return context.tr(ky: 'Аккаунтта', en: 'In account', ru: 'В аккаунте');
      case ProgressSyncState.failed:
        return context.tr(
          ky: 'Жеткирилген жок',
          en: 'Not delivered',
          ru: 'Не доставлено',
        );
    }
  }

  String syncSubtitleOf(BuildContext context) {
    switch (_syncState) {
      case ProgressSyncState.localOnly:
        return context.tr(
          ky: 'Маалымат ушул түзмөктө сакталат.',
          en: 'Data is stored on this device.',
          ru: 'Данные хранятся на этом устройстве.',
        );
      case ProgressSyncState.pending:
        return context.tr(
          ky: 'Өзгөрүү сакталды.',
          en: 'Changes were saved.',
          ru: 'Изменения сохранены.',
        );
      case ProgressSyncState.syncing:
        return context.tr(
          ky: 'Аккаунтка көчүрмө кетип жатат.',
          en: 'A copy is being sent to your account.',
          ru: 'Копия отправляется в аккаунт.',
        );
      case ProgressSyncState.synced:
        if (_lastSyncedAt == null) {
          return context.tr(
            ky: 'Түзмөк жана аккаунт даяр.',
            en: 'Device and account are in sync.',
            ru: 'Устройство и аккаунт синхронизированы.',
          );
        }
        return context.tr(
          ky: 'Акыркы көчүрмө: ${_formatTime(_lastSyncedAt!)}.',
          en: 'Last sync: ${_formatTime(_lastSyncedAt!)}.',
          ru: 'Последняя синхронизация: ${_formatTime(_lastSyncedAt!)}.',
        );
      case ProgressSyncState.failed:
        return _syncError ??
            context.tr(
              ky: 'Кийин кайра аракет кылыңыз.',
              en: 'Please try again later.',
              ru: 'Попробуйте позже.',
            );
    }
  }

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
    final now = DateTime.now();
    _touchSession(now: now, trackInteraction: true);
    final seen = _progress.seenByWordId[wordId] ?? 0;
    _progress.seenByWordId[wordId] = seen + 1;
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
      final key = _dateKey(now);
      final dailyCorrect = Map<String, int>.from(
        _progress.dailyCorrectCountByDate,
      );
      dailyCorrect[key] = (dailyCorrect[key] ?? 0) + 1;
      _progress = _progress.copyWith(
        dailyCorrectCountByDate: _trimDailyMap(dailyCorrect),
      );
    }
    _awardXp(_xpForAttempt(isCorrect), when: now);
    _applyDailyQuestRewards(now);
    notifyListeners();
    unawaited(_persist());
  }

  void recordLearningDuration(Duration duration, {DateTime? endedAt}) {
    var seconds = duration.inSeconds;
    if (seconds <= 0 && duration.inMilliseconds > 0) {
      seconds = 1;
    }
    if (seconds <= 0) return;

    final moment = endedAt ?? DateTime.now();
    _touchSession(now: moment, trackInteraction: false);
    final key = _dateKey(moment);
    final dailySeconds = Map<String, int>.from(
      _progress.dailyLearningSecondsByDate,
    );
    dailySeconds[key] = (dailySeconds[key] ?? 0) + seconds;
    _progress = _progress.copyWith(
      totalLearningSeconds: _progress.totalLearningSeconds + seconds,
      dailyLearningSecondsByDate: _trimDailyMap(dailySeconds),
    );
    _awardXp(_xpForLearningDuration(seconds), when: moment);
    _applyDailyQuestRewards(moment);
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

  String nextMilestoneLabelOf(BuildContext context) {
    final target = nextMilestoneTarget;
    if (target == null) {
      return context.tr(
        ky: 'Ачык практика этабы',
        en: 'Open practice stage',
        ru: 'Этап свободной практики',
      );
    }
    return context.tr(
      ky: '$target сөз',
      en: '$target words',
      ru: '$target слов',
    );
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
  int get totalLearningSeconds => _progress.totalLearningSeconds;
  Duration get totalLearningDuration =>
      Duration(seconds: _progress.totalLearningSeconds);
  int get totalXp => _progress.totalXp;

  int get journeyLevel {
    var level = 1;
    while (totalXp >= _xpRequiredForLevel(level + 1)) {
      level++;
    }
    return level;
  }

  String journeyRankOf(BuildContext context) =>
      localizedJourneyRank(context, journeyLevel);

  String get journeyRank {
    final level = journeyLevel;
    if (level >= 8) return 'Тоо чебери';
    if (level >= 6) return 'Ритм устаты';
    if (level >= 4) return 'Туруктуу саякатчы';
    if (level >= 2) return 'Өсүп жаткан тилчи';
    return 'Алгачкы от';
  }

  int get xpIntoCurrentLevel => totalXp - _xpRequiredForLevel(journeyLevel);

  int get xpToNextLevel => _xpRequiredForLevel(journeyLevel + 1) - totalXp;

  double get journeyLevelProgress {
    final currentStart = _xpRequiredForLevel(journeyLevel);
    final nextStart = _xpRequiredForLevel(journeyLevel + 1);
    final span = nextStart - currentStart;
    if (span <= 0) return 1;
    return ((totalXp - currentStart) / span).clamp(0, 1);
  }

  bool get hasActivityToday {
    final last = _progress.lastSessionAt;
    if (last == null) return false;
    final today = DateUtils.dateOnly(DateTime.now());
    return DateUtils.isSameDay(today, DateUtils.dateOnly(last));
  }

  List<DailyActivitySnapshot> activityForLastDays([int days = 7]) {
    final today = DateUtils.dateOnly(DateTime.now());
    return List.generate(days, (index) {
      final date = today.subtract(Duration(days: days - index - 1));
      final key = _dateKey(date);
      return DailyActivitySnapshot(
        date: date,
        seconds: _progress.dailyLearningSecondsByDate[key] ?? 0,
        interactions: _progress.dailyActivityCountByDate[key] ?? 0,
      );
    });
  }

  List<DailyActivitySnapshot> get recentWeekActivity => activityForLastDays(7);

  int get activeDaysThisWeek =>
      recentWeekActivity.where((day) => day.isActive).length;

  int get todayInteractionCount =>
      _progress.dailyActivityCountByDate[_dateKey(DateTime.now())] ?? 0;

  int get todayCorrectAnswers =>
      _progress.dailyCorrectCountByDate[_dateKey(DateTime.now())] ?? 0;

  int get todayLearningSeconds =>
      _progress.dailyLearningSecondsByDate[_dateKey(DateTime.now())] ?? 0;

  int get todayXp => _progress.dailyXpByDate[_dateKey(DateTime.now())] ?? 0;

  int get weeklyXp => recentWeekActivity.fold<int>(0, (sum, day) {
    final key = _dateKey(day.date);
    return sum + (_progress.dailyXpByDate[key] ?? 0);
  });

  List<DailyQuestSnapshot> get dailyQuests {
    final todayKey = _dateKey(DateTime.now());
    final claimed = _progress.claimedDailyQuestKeys.toSet();
    return [
      DailyQuestSnapshot(
        id: 'time_bloom',
        title: 'Темпти ач',
        description: 'Бүгүн 10 мүнөт практика жаса.',
        current: todayLearningSeconds,
        target: 10 * 60,
        rewardXp: 40,
        route: '/practice',
        displayCurrent: _formatMinutes(todayLearningSeconds),
        displayTarget: '10 мүн',
        claimed: claimed.contains(_questKey(todayKey, 'time_bloom')),
      ),
      DailyQuestSnapshot(
        id: 'steady_hands',
        title: '12 аракет',
        description: 'Бүгүн 12 жооп же аракет топто.',
        current: todayInteractionCount,
        target: 12,
        rewardXp: 30,
        route: '/practice',
        displayCurrent: '$todayInteractionCount',
        displayTarget: '12',
        claimed: claimed.contains(_questKey(todayKey, 'steady_hands')),
      ),
      DailyQuestSnapshot(
        id: 'sharp_focus',
        title: 'Так жооп сериясы',
        description: 'Бүгүн 8 туура жооп ал.',
        current: todayCorrectAnswers,
        target: 8,
        rewardXp: 35,
        route: '/practice',
        displayCurrent: '$todayCorrectAnswers',
        displayTarget: '8',
        claimed: claimed.contains(_questKey(todayKey, 'sharp_focus')),
      ),
    ];
  }

  int get completedDailyQuestsCount =>
      dailyQuests.where((quest) => quest.claimed).length;

  WeeklyChallengeSnapshot get weeklyChallenge => WeeklyChallengeSnapshot(
    title: 'Апталык толкун',
    description: '5 актив күн жана 180 XP менен жуманы жап.',
    activeDays: activeDaysThisWeek,
    targetActiveDays: 5,
    weeklyXp: weeklyXp,
    targetXp: 180,
    route: '/practice',
  );

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

  String levelOf(BuildContext context) {
    final mastered = totalWordsMastered;
    if (mastered >= 30) {
      return context.tr(
        ky: 'Алдыңкы деңгээл',
        en: 'Advanced level',
        ru: 'Продвинутый уровень',
      );
    }
    if (mastered >= 15) {
      return context.tr(
        ky: 'Орто деңгээл',
        en: 'Intermediate level',
        ru: 'Средний уровень',
      );
    }
    return context.tr(ky: 'Башталгыч', en: 'Beginner', ru: 'Начальный уровень');
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
        _progress = _normalizeGamification(_migrateLegacyWordProgress(remote));
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
          totalXp: snapshot.totalXp,
          streakDays: snapshot.streakDays,
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

  void _touchSession({DateTime? now, required bool trackInteraction}) {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
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

    final activityByDate = Map<String, int>.from(
      _progress.dailyActivityCountByDate,
    );
    if (trackInteraction) {
      final key = _dateKey(today);
      activityByDate[key] = (activityByDate[key] ?? 0) + 1;
    }

    _progress = _progress.copyWith(
      streakDays: streak,
      lastSessionAt: today,
      dailyActivityCountByDate: _trimDailyMap(activityByDate),
    );
  }

  void _awardXp(int amount, {required DateTime when}) {
    if (amount <= 0) return;
    final key = _dateKey(when);
    final dailyXp = Map<String, int>.from(_progress.dailyXpByDate);
    dailyXp[key] = (dailyXp[key] ?? 0) + amount;
    _progress = _progress.copyWith(
      totalXp: _progress.totalXp + amount,
      dailyXpByDate: _trimDailyMap(dailyXp),
    );
  }

  void _applyDailyQuestRewards(DateTime when) {
    final todayKey = _dateKey(when);
    final claimed = List<String>.from(_progress.claimedDailyQuestKeys);
    var bonusXp = 0;

    for (final quest in dailyQuests) {
      final key = _questKey(todayKey, quest.id);
      if (quest.isCompleted && !claimed.contains(key)) {
        claimed.add(key);
        bonusXp += quest.rewardXp;
      }
    }

    if (bonusXp <= 0) return;
    final dailyXp = Map<String, int>.from(_progress.dailyXpByDate);
    dailyXp[todayKey] = (dailyXp[todayKey] ?? 0) + bonusXp;
    _progress = _progress.copyWith(
      totalXp: _progress.totalXp + bonusXp,
      dailyXpByDate: _trimDailyMap(dailyXp),
      claimedDailyQuestKeys: _trimClaimedQuestKeys(claimed),
    );
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
    _progress = loaded != null
        ? _normalizeGamification(
            _migrateLegacyWordProgress(loaded.copyWith(userId: uid ?? 'guest')),
          )
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
        progress.dailyActivityCountByDate.isNotEmpty ||
        progress.dailyCorrectCountByDate.isNotEmpty ||
        progress.dailyLearningSecondsByDate.isNotEmpty ||
        progress.dailyXpByDate.isNotEmpty ||
        progress.claimedDailyQuestKeys.isNotEmpty ||
        progress.totalLearningSeconds > 0 ||
        progress.totalXp > 0 ||
        progress.streakDays > 0 ||
        progress.lastSessionAt != null;
  }

  UserProgressModel _normalizeGamification(UserProgressModel progress) {
    final normalized = progress.copyWith(
      dailyActivityCountByDate: _trimDailyMap(
        Map<String, int>.from(progress.dailyActivityCountByDate),
      ),
      dailyCorrectCountByDate: _trimDailyMap(
        Map<String, int>.from(progress.dailyCorrectCountByDate),
      ),
      dailyLearningSecondsByDate: _trimDailyMap(
        Map<String, int>.from(progress.dailyLearningSecondsByDate),
      ),
      dailyXpByDate: _trimDailyMap(
        Map<String, int>.from(progress.dailyXpByDate),
      ),
      claimedDailyQuestKeys: _trimClaimedQuestKeys(
        List<String>.from(progress.claimedDailyQuestKeys),
      ),
    );

    if (normalized.totalXp > 0) {
      return normalized;
    }

    final records = normalized.wordProgressById.values;
    final attemptCount = records.isNotEmpty
        ? records.fold<int>(0, (sum, value) => sum + value.attemptCount)
        : normalized.seenByWordId.values.fold<int>(
            0,
            (sum, value) => sum + value,
          );
    final successCount = records.isNotEmpty
        ? records.fold<int>(0, (sum, value) => sum + value.successCount)
        : normalized.correctByWordId.values.fold<int>(
            0,
            (sum, value) => sum + value,
          );
    final failureCount = (attemptCount - successCount).clamp(0, attemptCount);

    if (attemptCount == 0 && normalized.totalLearningSeconds <= 0) {
      return normalized;
    }

    final estimatedXp =
        (successCount * _xpForAttempt(true)) +
        (failureCount * _xpForAttempt(false)) +
        _xpForLearningDuration(normalized.totalLearningSeconds);
    return normalized.copyWith(totalXp: estimatedXp);
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Map<String, int> _trimDailyMap(
    Map<String, int> values, {
    int keepDays = 120,
  }) {
    if (values.length <= keepDays) {
      return values;
    }
    final keys = values.keys.toList()..sort();
    final trimmed = <String, int>{};
    for (final key in keys.skip(keys.length - keepDays)) {
      trimmed[key] = values[key] ?? 0;
    }
    return trimmed;
  }

  List<String> _trimClaimedQuestKeys(
    List<String> values, {
    int keepItems = 90,
  }) {
    if (values.length <= keepItems) {
      return values;
    }
    final sorted = List<String>.from(values)..sort();
    return sorted.skip(sorted.length - keepItems).toList();
  }

  int _xpRequiredForLevel(int level) {
    if (level <= 1) return 0;
    var total = 0;
    for (var current = 1; current < level; current++) {
      total += 80 + ((current - 1) * 35);
    }
    return total;
  }

  int _xpForAttempt(bool isCorrect) => isCorrect ? 12 : 5;

  int _xpForLearningDuration(int seconds) {
    if (seconds < 60) return 0;
    final minutes = (seconds / 60).floor();
    return (minutes * 3).clamp(0, 1800);
  }

  String _questKey(String dateKey, String questId) => '$dateKey:$questId';

  String _formatMinutes(int totalSeconds) {
    if (totalSeconds <= 0) return '0 мүн';
    final minutes = (totalSeconds / 60).ceil();
    return '$minutes мүн';
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

String localizedJourneyRank(BuildContext context, int level) {
  if (level >= 8) {
    return context.tr(
      ky: 'Тоо чебери',
      en: 'Peak master',
      ru: 'Мастер вершины',
    );
  }
  if (level >= 6) {
    return context.tr(
      ky: 'Ритм устаты',
      en: 'Rhythm master',
      ru: 'Мастер ритма',
    );
  }
  if (level >= 4) {
    return context.tr(
      ky: 'Туруктуу саякатчы',
      en: 'Steady traveler',
      ru: 'Уверенный путешественник',
    );
  }
  if (level >= 2) {
    return context.tr(
      ky: 'Өсүп жаткан тилчи',
      en: 'Growing learner',
      ru: 'Растущий ученик',
    );
  }
  return context.tr(ky: 'Алгачкы от', en: 'First spark', ru: 'Первый огонь');
}
