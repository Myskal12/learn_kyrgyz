import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';
import '../utils/learning_direction.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._storage);

  static const _themeKey = 'theme_mode';
  static const _directionKey = 'learning_direction';

  final LocalStorageService _storage;

  bool _loaded = false;
  bool _isDark = false;
  LearningDirection _direction = LearningDirection.enToKy;

  bool get isLoaded => _loaded;
  bool get isDark => _isDark;
  LearningDirection get direction => _direction;

  Future<void> load() async {
    if (_loaded) return;
    final rawTheme = await _storage.getString(_themeKey);
    _isDark = rawTheme == 'dark';
    final rawDirection = await _storage.getString(_directionKey);
    _direction = LearningDirectionX.fromStorage(rawDirection);
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    await _storage.setString(_themeKey, _isDark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    if (_isDark == isDark) return;
    _isDark = isDark;
    await _storage.setString(_themeKey, _isDark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> toggleDirection() async {
    _direction = _direction == LearningDirection.enToKy
        ? LearningDirection.kyToEn
        : LearningDirection.enToKy;
    await _storage.setString(_directionKey, _direction.storageValue);
    notifyListeners();
  }

  Future<void> setDirection(LearningDirection direction) async {
    if (_direction == direction) return;
    _direction = direction;
    await _storage.setString(_directionKey, _direction.storageValue);
    notifyListeners();
  }
}
