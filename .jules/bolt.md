## 2025-02-18 - Avoid repeated List.unmodifiable allocations
**Learning:** In Dart/Flutter, `List.unmodifiable` creates a new shallow copy of the list (O(N)). Using it in a getter that is accessed frequently (e.g., inside a `ListView.builder` or state selector) causes significant memory churn and CPU usage, as it allocates a new list on every access.
**Action:** Memoize the immutable list wrapper. Store the `List.unmodifiable` result in a cache and return the cached instance. Invalidate the cache whenever the underlying mutable data source changes.
