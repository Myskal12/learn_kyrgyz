import 'package:flutter_test/flutter_test.dart';
import 'package:learn_kyrgyz/app/providers/learning_direction_provider.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';
import 'package:learn_kyrgyz/core/utils/learning_direction.dart';

class FakeLocalStorageService implements LocalStorageService {
  FakeLocalStorageService([Map<String, String>? initialValues])
    : values = {...?initialValues};

  final Map<String, String> values;

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  group('LearningDirectionNotifier', () {
    test('loads the persisted direction', () async {
      final storage = FakeLocalStorageService({
        'learning_direction': 'ky_to_en',
      });
      final notifier = LearningDirectionNotifier(storage);

      await notifier.load();

      expect(notifier.state, LearningDirection.kyToEn);
    });

    test('setDirection persists the selected direction', () async {
      final storage = FakeLocalStorageService();
      final notifier = LearningDirectionNotifier(storage);

      await notifier.setDirection(LearningDirection.kyToEn);

      expect(notifier.state, LearningDirection.kyToEn);
      expect(storage.values['learning_direction'], 'ky_to_en');
    });

    test('toggleDirection flips and persists the direction', () async {
      final storage = FakeLocalStorageService();
      final notifier = LearningDirectionNotifier(storage);

      await notifier.toggleDirection();

      expect(notifier.state, LearningDirection.kyToEn);
      expect(storage.values['learning_direction'], 'ky_to_en');
    });
  });
}
