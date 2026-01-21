import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/learning_direction.dart';
import '../../core/services/local_storage_service.dart';
import 'app_providers.dart';

const _directionKey = 'learning_direction';

final learningDirectionProvider =
    StateNotifierProvider<LearningDirectionNotifier, LearningDirection>(
  (ref) {
    final storage = ref.read(localStorageServiceProvider);
    final notifier = LearningDirectionNotifier(storage);
    unawaited(notifier.load());
    return notifier;
  },
);

class LearningDirectionNotifier extends StateNotifier<LearningDirection> {
  LearningDirectionNotifier(this._storage) : super(LearningDirection.enToKy);

  final LocalStorageService _storage;

  Future<void> load() async {
    final rawDirection = await _storage.getString(_directionKey);
    state = LearningDirectionX.fromStorage(rawDirection);
  }

  Future<void> toggleDirection() async {
    final next = state == LearningDirection.enToKy
        ? LearningDirection.kyToEn
        : LearningDirection.enToKy;
    await setDirection(next);
  }

  Future<void> setDirection(LearningDirection direction) async {
    if (state == direction) return;
    state = direction;
    await _storage.setString(_directionKey, direction.storageValue);
  }
}
