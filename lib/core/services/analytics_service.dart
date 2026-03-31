import 'dart:convert';

import 'local_storage_service.dart';

abstract class AnalyticsService {
  Future<void> track(String name, {Map<String, Object?> properties = const {}});

  Future<List<AnalyticsEvent>> readRecentEvents();
}

class LocalAnalyticsService implements AnalyticsService {
  LocalAnalyticsService(this._storage);

  static const _storageKey = 'analytics_events';
  static const _maxEvents = 100;

  final LocalStorageService _storage;

  @override
  Future<void> track(
    String name, {
    Map<String, Object?> properties = const {},
  }) async {
    final events = List<AnalyticsEvent>.of(await readRecentEvents());
    events.add(
      AnalyticsEvent(
        name: name,
        timestamp: DateTime.now(),
        properties: _normalize(properties),
      ),
    );
    final trimmed = events.length > _maxEvents
        ? events.sublist(events.length - _maxEvents)
        : events;
    await _storage.setString(
      _storageKey,
      jsonEncode(trimmed.map((event) => event.toJson()).toList()),
    );
  }

  @override
  Future<List<AnalyticsEvent>> readRecentEvents() async {
    final raw = await _storage.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) =>
                AnalyticsEvent.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Map<String, dynamic> _normalize(Map<String, Object?> properties) {
    final normalized = <String, dynamic>{};
    properties.forEach((key, value) {
      if (value == null || value is String || value is num || value is bool) {
        normalized[key] = value;
      } else {
        normalized[key] = value.toString();
      }
    });
    return normalized;
  }
}

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<List<AnalyticsEvent>> readRecentEvents() async => const [];

  @override
  Future<void> track(
    String name, {
    Map<String, Object?> properties = const {},
  }) async {}
}

class AnalyticsEvent {
  const AnalyticsEvent({
    required this.name,
    required this.timestamp,
    required this.properties,
  });

  final String name;
  final DateTime timestamp;
  final Map<String, dynamic> properties;

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      name: (json['name'] ?? '').toString(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] as num?)?.toInt() ?? 0,
      ),
      properties: Map<String, dynamic>.from(
        json['properties'] as Map? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'properties': properties,
  };
}
