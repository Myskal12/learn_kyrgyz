import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_language.dart';
import '../../core/services/local_storage_service.dart';
import 'app_providers.dart';

const _languageKey = 'app_language';

final appLanguageProvider =
    StateNotifierProvider<AppLanguageNotifier, AppLanguage>((ref) {
      final storage = ref.read(localStorageServiceProvider);
      final notifier = AppLanguageNotifier(storage);
      unawaited(notifier.load());
      return notifier;
    });

class AppLanguageNotifier extends StateNotifier<AppLanguage> {
  AppLanguageNotifier(this._storage) : super(AppLanguage.kyrgyz);

  final LocalStorageService _storage;

  Future<void> load() async {
    final raw = await _storage.getString(_languageKey);
    state = AppLanguage.fromCode(raw);
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (state == language) return;
    state = language;
    await _storage.setString(_languageKey, language.code);
  }
}
