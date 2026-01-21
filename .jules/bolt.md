# Performance Journal

## WordsRepository Optimization
- **Date**: 2024-05-22
- **Change**: Replaced linear search in `WordsRepository.findById` with a `Map<String, WordModel>` lookup.
- **Rationale**: `findById` was iterating over `allWords` (O(N)). `allWords` itself is a computed property in `FirebaseService` that creates a new unmodifiable list on every access (O(N) allocation + copy). Total cost was O(N) time and O(N) garbage.
- **Optimization**: Introduced `_idMap` cache in `WordsRepository`, populated at construction and updated on fetch. Lookup is now O(1).
- **Impact**: Removes significant overhead for word lookup, crucial for quiz resolution and other frequent lookups.
