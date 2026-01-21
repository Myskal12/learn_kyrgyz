import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LegacyLocalStorageService {
  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}

class OptimizedLocalStorageService {
  final SharedPreferences _prefs;
  OptimizedLocalStorageService(this._prefs);

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }
}

void main() {
  test('Benchmark LocalStorageService', () async {
    SharedPreferences.setMockInitialValues({});

    final legacyService = LegacyLocalStorageService();
    final prefs = await SharedPreferences.getInstance();
    final optimizedService = OptimizedLocalStorageService(prefs);

    const int iterations = 10000;

    // Benchmark Legacy
    final stopwatchLegacy = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      await legacyService.setString('key_$i', 'value_$i');
      await legacyService.getString('key_$i');
    }
    stopwatchLegacy.stop();
    print('Legacy LocalStorageService time: ${stopwatchLegacy.elapsedMilliseconds}ms');

    // Benchmark Optimized
    final stopwatchOptimized = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      await optimizedService.setString('key_$i', 'value_$i');
      await optimizedService.getString('key_$i');
    }
    stopwatchOptimized.stop();
    print('Optimized LocalStorageService time: ${stopwatchOptimized.elapsedMilliseconds}ms');

    final improvement = stopwatchLegacy.elapsedMilliseconds - stopwatchOptimized.elapsedMilliseconds;
    final percent = (improvement / stopwatchLegacy.elapsedMilliseconds) * 100;

    print('Improvement: ${improvement}ms (${percent.toStringAsFixed(2)}%)');
  });
}
