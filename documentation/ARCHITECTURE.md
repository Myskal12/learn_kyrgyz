# Architecture

## 1. High-Level Structure

I built the app as a Flutter client-first project. I use Riverpod for dependency injection and state wiring, Firebase as the remote backend, and local persistence for offline-friendly behavior.

The current structure is:

- presentation -> screens and shared widgets
- state -> providers and notifiers
- data access -> repositories
- remote and local integration -> services

## 2. Core Stack

I currently use:

- Flutter and Dart
- flutter_riverpod
- go_router
- Firebase Auth
- Cloud Firestore
- SharedPreferences

I have not added a full local database yet. The offline layer still depends on serialized local storage and cache services.

## 3. Directory Layout

- `lib/app`
  I keep app bootstrap, routing, and global providers here.

- `lib/core`
  I keep shared services, utilities, and session helpers here.

- `lib/data/models`
  I keep application models here, including words, categories, quizzes, progress, and profile data.

- `lib/features`
  I organize feature modules here: auth, home, categories, learning, quiz, progress, profile, and extras.

- `lib/shared/widgets`
  I keep reusable UI building blocks here.

## 4. Routing And Shell

I use `GoRouter` in `lib/app/router.dart`.

The current routing layer supports:

- a shared shell for the main screens
- separate secondary flows on the same design patterns
- query parameter support for review mode in flashcards

## 5. Provider Graph

### App-level providers

In `lib/app/providers/app_providers.dart` I register the base dependencies:

- `sharedPreferencesProvider`
- `firebaseServiceProvider`
- `localStorageServiceProvider`
- `analyticsServiceProvider`
- `offlineCatalogCacheServiceProvider`
- repository providers

### User and session providers

- `authProvider`
- `onboardingProvider`
- `learningDirectionProvider`
- `themeModeProvider`
- `learningSessionProvider`

### Feature providers

- `categoriesProvider`
- `progressProvider`
- `userProfileProvider`
- `leaderboardProvider`
- `flashcardProvider`
- `quizProvider`
- `sentenceBuilderProvider`

## 6. Data Flow

### Startup

1. I initialize Firebase and SharedPreferences.
2. Riverpod wires the services and repositories.
3. Onboarding, auth, theme, and direction providers hydrate local state.
4. Screens load feature providers when needed.

### Content loading

Categories, words, sentences, and quiz content go through the repository layer.

The typical flow is:

1. screen -> provider
2. provider -> repository
3. repository -> local cache read
4. repository -> Firebase fetch attempt
5. remote success -> cache refresh
6. fallback -> cached or seeded content

### Progress

`ProgressProvider` is the central place for:

- streak
- attempts
- review due
- weak words
- mastered words
- sync state
- milestone helpers

I no longer rely only on simple counters. I store per-word progress through `WordProgressRecord`.

### Learning cycle

Flashcards, quiz, and sentence builder all update progress through `recordWordAttempt`.

That gives me:

- shared attempt tracking
- review due calculation
- mastery progression groundwork
- session analytics events

### Sync

Remote sync is currently handled through `ProgressProvider` and `FirebaseService`.

The sync states are:

- local only
- pending
- syncing
- synced
- failed

I already have the foundation, but I still need stronger conflict handling and a queue backed by a real local database.

## 7. Offline Foundation

My current offline layer has two main parts.

### `LocalStorageService`

I use it for lightweight state and serialized payloads.

### `OfflineCatalogCacheService`

I use it to cache:

- categories
- words by category
- sentences by category
- quiz questions by category and direction

This makes the app much more stable without a network connection, but it is not yet a full offline-first architecture.

## 8. Analytics

I added a local analytics layer through:

- `AnalyticsService`
- `LocalAnalyticsService`

I currently log:

- flashcards started and completed
- quiz started and completed
- sentence builder started and completed

This layer is local right now. I have not connected remote analytics yet.

## 9. Strengths

- I already have a clear feature-first structure.
- Providers and repositories are separated well enough for continued growth.
- Recent UX changes fit into the architecture without a full rewrite.
- Offline and analytics foundations are already part of the app graph.

## 10. Current Limits

- no full local database yet
- `FirebaseService` is still too broad
- sync scenarios still need more hardening
- integration tests do not cover the full learning flow yet

## 11. Next Architecture Priorities

1. add a local database for content and sync queue
2. make guest and cloud merge safer
3. split Firebase responsibilities into smaller services
4. add integration coverage for the full learning cycle
