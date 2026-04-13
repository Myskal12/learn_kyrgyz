import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/local_storage_service.dart';
import 'app_providers.dart';

const _themeKey = 'theme_mode';

final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  final storage = ref.read(localStorageServiceProvider);
  final notifier = ThemeNotifier(storage);
  unawaited(notifier.load());
  return notifier;
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._storage) : super(ThemeMode.light);

  final LocalStorageService _storage;

  Future<void> load() async {
    final rawTheme = await _storage.getString(_themeKey);
    state = _themeFromStorage(rawTheme);
  }

  Future<void> toggleTheme() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(next);
  }

  Future<void> setTheme(ThemeMode mode) async {
    final normalized = mode == ThemeMode.dark
        ? ThemeMode.dark
        : ThemeMode.light;
    if (state == normalized) return;
    state = normalized;
    await _storage.setString(_themeKey, _themeToStorage(normalized));
  }

  ThemeMode _themeFromStorage(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
      case 'system':
      default:
        return ThemeMode.light;
    }
  }

  String _themeToStorage(ThemeMode mode) {
    return mode == ThemeMode.dark ? 'dark' : 'light';
  }
}
