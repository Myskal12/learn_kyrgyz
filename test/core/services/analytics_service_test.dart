import 'package:flutter_test/flutter_test.dart';
import 'package:learn_kyrgyz/core/services/analytics_service.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';

class FakeLocalStorageService implements LocalStorageService {
  final Map<String, String> _values = {};

  @override
  Future<String?> getString(String key) async => _values[key];

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }
}

void main() {
  group('LocalAnalyticsService', () {
    test('tracks events and reads them back', () async {
      final storage = FakeLocalStorageService();
      final service = LocalAnalyticsService(storage);

      await service.track(
        'quiz_started',
        properties: {'categoryId': 'basics', 'questionCount': 3},
      );

      final events = await service.readRecentEvents();

      expect(events, hasLength(1));
      expect(events.single.name, 'quiz_started');
      expect(events.single.properties['categoryId'], 'basics');
      expect(events.single.properties['questionCount'], 3);
    });

    test('keeps only the most recent 100 events', () async {
      final storage = FakeLocalStorageService();
      final service = LocalAnalyticsService(storage);

      for (var index = 0; index < 105; index++) {
        await service.track('event_$index');
      }

      final events = await service.readRecentEvents();

      expect(events, hasLength(100));
      expect(events.first.name, 'event_5');
      expect(events.last.name, 'event_104');
    });

    test('returns empty list for malformed storage payload', () async {
      final storage = FakeLocalStorageService();
      await storage.setString('analytics_events', '{broken json');

      final service = LocalAnalyticsService(storage);

      expect(await service.readRecentEvents(), isEmpty);
    });
  });
}
