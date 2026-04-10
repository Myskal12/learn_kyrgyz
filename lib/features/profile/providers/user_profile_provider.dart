import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../data/models/user_profile_model.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfileProvider(this._firebase, this._storage) {
    _sub = _firebase.userStream.listen(_handleUserChange);
  }

  final FirebaseService _firebase;
  final LocalStorageService _storage;
  StreamSubscription<String?>? _sub;

  static const _cacheKeyPrefix = 'user_profile_';
  static const _guestNickname = 'Конок';
  static const _defaultNickname = 'Колдонуучу';

  UserProfileModel _profile = const UserProfileModel(
    id: 'guest',
    nickname: _guestNickname,
    avatar: '🙂',
    totalMastered: 0,
    totalSessions: 0,
    accuracy: 0,
  );

  bool _isGuest = true;
  bool _loading = false;
  bool _needsProfileSetup = false;
  String? _suggestedNickname;

  bool get isGuest => _isGuest;
  bool get isLoading => _loading;
  bool get needsProfileSetup => _needsProfileSetup;
  UserProfileModel get profile => _profile;
  String? get suggestedNickname {
    final suggested = _suggestedNickname?.trim();
    if (suggested != null && suggested.isNotEmpty) {
      return suggested;
    }
    final nickname = _profile.nickname.trim();
    if (_requiresNicknameSetup(nickname)) {
      return null;
    }
    return nickname;
  }

  Future<void> updateNickname(String value) async {
    final uid = _profile.id;
    if (_isGuest || uid == 'guest') return;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _profile = _profile.copyWith(nickname: trimmed);
    notifyListeners();
    await _persistProfile();
    await _firebase.updateUserProfile(uid: uid, nickname: trimmed);
  }

  Future<void> updateAvatar(String value) async {
    final uid = _profile.id;
    if (_isGuest || uid == 'guest') return;
    _profile = _profile.copyWith(avatar: value);
    notifyListeners();
    await _persistProfile();
    await _firebase.updateUserProfile(uid: uid, avatar: value);
  }

  Future<void> refresh() async {
    if (_isGuest || _profile.id == 'guest') return;
    final remote = await _firebase.fetchUserProfile(_profile.id);
    if (remote != null) {
      final normalized = _preferredNickname(remote.nickname);
      _profile = remote.copyWith(nickname: normalized);
      _needsProfileSetup = _requiresNicknameSetup(normalized);
      if (normalized != remote.nickname) {
        await _firebase.updateUserProfile(uid: _profile.id, nickname: normalized);
      }
      notifyListeners();
      await _persistProfile();
    }
  }

  Future<void> completeProfileSetup(String nickname) async {
    final uid = _firebase.currentUserId;
    final trimmed = nickname.trim();
    if (uid == null || uid.isEmpty || trimmed.isEmpty) return;

    _profile = UserProfileModel(
      id: uid,
      nickname: trimmed,
      avatar: _profile.avatar,
      totalMastered: _profile.totalMastered,
      totalSessions: _profile.totalSessions,
      accuracy: _profile.accuracy,
    );
    _isGuest = false;
    _loading = false;
    _needsProfileSetup = false;
    _suggestedNickname = trimmed;
    notifyListeners();

    await _persistProfile();
    await _firebase.updateUserProfile(
      uid: uid,
      nickname: trimmed,
      avatar: _profile.avatar,
    );
  }

  Future<void> _handleUserChange(String? uid) async {
    if (uid == null) {
      _isGuest = true;
      _loading = false;
      _needsProfileSetup = false;
      _suggestedNickname = null;
      _profile = const UserProfileModel(
        id: 'guest',
        nickname: _guestNickname,
        avatar: '🙂',
        totalMastered: 0,
        totalSessions: 0,
        accuracy: 0,
      );
      notifyListeners();
      return;
    }

    _isGuest = false;
    _loading = true;
    _suggestedNickname = _firebase.currentUserFirstName;
    notifyListeners();

    final cached = await _readCache(uid);
    if (cached != null) {
      _profile = cached.copyWith(
        nickname: _preferredNickname(cached.nickname),
      );
      _needsProfileSetup = _requiresNicknameSetup(_profile.nickname);
      _loading = false;
      notifyListeners();
    }

    final remote = await _firebase.fetchUserProfile(uid);
    if (remote != null) {
      final normalized = _preferredNickname(remote.nickname);
      _profile = remote.copyWith(nickname: normalized);
      _needsProfileSetup = _requiresNicknameSetup(normalized);
      if (normalized != remote.nickname) {
        await _firebase.updateUserProfile(uid: uid, nickname: normalized);
      }
      await _persistProfile();
    } else if (cached == null) {
      final nickname = _preferredNickname(null);
      _profile = UserProfileModel(
        id: uid,
        nickname: nickname,
        avatar: '🙂',
        totalMastered: 0,
        totalSessions: 0,
        accuracy: 0,
      );
      _needsProfileSetup = _requiresNicknameSetup(nickname);
      await _firebase.updateUserProfile(
        uid: uid,
        nickname: _requiresNicknameSetup(nickname) ? null : nickname,
        avatar: _profile.avatar,
      );
      await _persistProfile();
    } else {
      _needsProfileSetup = _requiresNicknameSetup(_profile.nickname);
      if (_profile.nickname != cached.nickname) {
        await _firebase.updateUserProfile(uid: uid, nickname: _profile.nickname);
        await _persistProfile();
      }
    }

    _loading = false;
    notifyListeners();
  }

  Future<UserProfileModel?> _readCache(String uid) async {
    final raw = await _storage.getString('$_cacheKeyPrefix$uid');
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfileModel.fromJson(uid, data);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistProfile() async {
    final uid = _profile.id;
    if (uid.isEmpty || uid == 'guest') return;
    final payload = jsonEncode(_profile.toJson());
    await _storage.setString('$_cacheKeyPrefix$uid', payload);
  }

  String _preferredNickname(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isNotEmpty && !_requiresNicknameSetup(trimmed)) {
      return trimmed;
    }
    final suggested = _suggestedNickname?.trim() ?? '';
    if (suggested.isNotEmpty) {
      return suggested;
    }
    return _defaultNickname;
  }

  bool _requiresNicknameSetup(String nickname) {
    final trimmed = nickname.trim();
    return trimmed.isEmpty || trimmed == _defaultNickname;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final userProfileProvider = ChangeNotifierProvider<UserProfileProvider>((ref) {
  final firebase = ref.read(firebaseServiceProvider);
  final storage = ref.read(localStorageServiceProvider);
  return UserProfileProvider(firebase, storage);
});
