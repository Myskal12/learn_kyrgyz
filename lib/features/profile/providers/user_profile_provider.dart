import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

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

  UserProfileModel _profile = const UserProfileModel(
    id: 'guest',
    nickname: 'Конок',
    avatar: '🙂',
    totalMastered: 0,
    totalSessions: 0,
    accuracy: 0,
  );

  bool _isGuest = true;
  bool _loading = false;

  bool get isGuest => _isGuest;
  bool get isLoading => _loading;
  UserProfileModel get profile => _profile;

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
      _profile = remote;
      notifyListeners();
      await _persistProfile();
    }
  }

  Future<void> _handleUserChange(String? uid) async {
    if (uid == null) {
      _isGuest = true;
      _loading = false;
      _profile = const UserProfileModel(
        id: 'guest',
        nickname: 'Конок',
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
    notifyListeners();

    final cached = await _readCache(uid);
    if (cached != null) {
      _profile = cached;
      _loading = false;
      notifyListeners();
    }

    final remote = await _firebase.fetchUserProfile(uid);
    if (remote != null) {
      _profile = remote;
      await _persistProfile();
    } else if (cached == null) {
      _profile = UserProfileModel(
        id: uid,
        nickname: 'Колдонуучу',
        avatar: '🙂',
        totalMastered: 0,
        totalSessions: 0,
        accuracy: 0,
      );
      await _firebase.updateUserProfile(
        uid: uid,
        nickname: _profile.nickname,
        avatar: _profile.avatar,
      );
      await _persistProfile();
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

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
