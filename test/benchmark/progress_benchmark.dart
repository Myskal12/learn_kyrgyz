import 'dart:math';

void main() {
  // Setup data
  final int itemCount = 10000;
  final Map<String, int> seenByWordId = {};
  final Map<String, int> correctByWordId = {};

  for (int i = 0; i < itemCount; i++) {
    seenByWordId['word_$i'] = 1 + (i % 5);
    if (i % 2 == 0) {
      correctByWordId['word_$i'] = 1;
    }
  }

  // Baseline function (current implementation)
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

  // Optimized function (simulated)
  int _cachedTotalExposures = 0;
  int _cachedTotalMastered = 0;

  // Initialize cached values
  _cachedTotalExposures = seenByWordId.values.fold(0, (p, v) => p + v);
  _cachedTotalMastered = correctByWordId.values.fold(0, (p, v) => p + v);

  int getAccuracyPercentOptimized() {
    if (_cachedTotalExposures == 0) return 0;
    return ((_cachedTotalMastered / _cachedTotalExposures) * 100).round();
  }

  // Benchmark Baseline
  final stopwatch = Stopwatch()..start();
  final iterations = 5000;

  int dummy = 0;
  for (int i = 0; i < iterations; i++) {
    dummy += getAccuracyPercent();
  }
  stopwatch.stop();
  final baselineTime = stopwatch.elapsedMilliseconds;

  print('Baseline (O(N)):');
  print('  Time for $iterations calls: ${baselineTime} ms');
  print('  Average per call: ${baselineTime / iterations} ms');

  // Benchmark Optimized
  stopwatch.reset();
  stopwatch.start();

  dummy = 0;
  for (int i = 0; i < iterations; i++) {
    dummy += getAccuracyPercentOptimized();
  }
  stopwatch.stop();
  final optimizedTime = stopwatch.elapsedMilliseconds;

  print('Optimized (O(1)):');
  print('  Time for $iterations calls: ${optimizedTime} ms');
  print('  Average per call: ${optimizedTime / iterations} ms');

  print('Speedup: ${(baselineTime / optimizedTime).toStringAsFixed(2)}x');
}
