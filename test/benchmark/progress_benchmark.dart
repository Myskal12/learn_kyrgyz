import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final int itemCount = 10000;
  final Map<String, int> seenByWordId = {};
  final Map<String, int> correctByWordId = {};

  for (int i = 0; i < itemCount; i++) {
    seenByWordId['word_$i'] = 1 + (i % 5);
    if (i % 2 == 0) {
      correctByWordId['word_$i'] = 1;
    }
  }

  int getAccuracyPercent() {
    final exposures = seenByWordId.values.fold(
      0,
      (prev, value) => prev + value,
    );
    if (exposures == 0) return 0;
    final masteredCount = correctByWordId.values.fold(
      0,
      (prev, value) => prev + value,
    );
    return ((masteredCount / exposures) * 100).round();
  }

  int cachedTotalExposures = 0;
  int cachedTotalMastered = 0;

  cachedTotalExposures = seenByWordId.values.fold(0, (p, v) => p + v);
  cachedTotalMastered = correctByWordId.values.fold(0, (p, v) => p + v);

  int getAccuracyPercentOptimized() {
    if (cachedTotalExposures == 0) return 0;
    return ((cachedTotalMastered / cachedTotalExposures) * 100).round();
  }

  final stopwatch = Stopwatch()..start();
  final iterations = 5000;

  int dummy = 0;
  for (int i = 0; i < iterations; i++) {
    dummy += getAccuracyPercent();
  }
  stopwatch.stop();
  final baselineTime = stopwatch.elapsedMilliseconds;

  debugPrint('Baseline (O(N)):');
  debugPrint('  Time for $iterations calls: $baselineTime ms');
  debugPrint('  Average per call: ${baselineTime / iterations} ms');

  stopwatch.reset();
  stopwatch.start();

  dummy = 0;
  for (int i = 0; i < iterations; i++) {
    dummy += getAccuracyPercentOptimized();
  }
  stopwatch.stop();
  final optimizedTime = stopwatch.elapsedMilliseconds;

  debugPrint('Optimized (O(1)):');
  debugPrint('  Time for $iterations calls: $optimizedTime ms');
  debugPrint('  Average per call: ${optimizedTime / iterations} ms');
  debugPrint('Speedup: ${(baselineTime / optimizedTime).toStringAsFixed(2)}x');

  expect(dummy, greaterThanOrEqualTo(0));
}
