# Architecture

## 1. Overview

The app is built as a Flutter client-first project with Riverpod for dependency injection and state wiring, Firebase as the remote backend, and local persistence layers for offline-friendly behavior.

Current architecture formula:

- presentation -> screens and shared widgets
- state -> providers and notifiers
- data access -> repositories
- platform and backend integration -> services

## 2. Core Stack

- Flutter / Dart
- flutter_riverpod
- go_router
- Firebase Auth
- Cloud Firestore
- SharedPreferences

Important note:
A full local database is not implemented yet. The current offline foundation is based on SharedPreferences and dedicated cache services.

## 3. Key Directories

- lib/app
  app bootstrap, router, app-level providers

- lib/core
  shared services, utilities, session helpers

- lib/data/models
  core models: words, categories, quiz questions, progress, profile

- lib/features
  feature-first modules: auth, home, categories, learning, quiz, progress, profile, extras

- lib/shared/widgets
  reusable UI blocks, shell, cards, buttons, layout helpers

## 4. Routing and Shell

Navigation is composed with GoRouter in lib/app/router.dart.

Current navigation characteristics:

- unified shell for primary screens
- secondary flows built on the same shared UI patterns
- query parameter support for review entry points in flashcards

## 5. Provider Graph

### App-level providers

Base dependencies are wired in lib/app/providers/app_providers.dart:

- sharedPreferencesProvider
- firebaseServiceProvider
- localStorageServiceProvider
- analyticsServiceProvider
- offlineCatalogCacheServiceProvider
- repository providers

### User and session providers

- authProvider
- onboardingProvider
- learningDirectionProvider
- themeModeProvider
- learningSessionProvider

### Feature providers

- categoriesProvider
- progressProvider
- userProfileProvider
- leaderboardProvider
- flashcardProvider
- quizProvider
- sentenceBuilderProvider

## 6. Data Flow

### 6.1 Startup

1. The app initializes Firebase and SharedPreferences.
2. Riverpod wires base services and repositories.
3. Onboarding, auth, theme, and direction providers hydrate local state.
4. Home and other screens consume feature providers on demand.

### 6.2 Content loading

Categories, words, sentences, and quiz data flow through repositories.

Typical path:

1. screen -> provider
2. provider -> repository
3. repository -> offline cache read
4. repository -> Firebase fetch attempt
5. remote success -> cache refresh
6. fallback -> cached or seeded content

### 6.3 Progress

ProgressProvider is the central point for:

- streak
- attempts
- review due
- weak words
- mastered words
- sync state
- next milestone helpers

Per-word progress is stored with WordProgressRecord instead of simple aggregate counters.

### 6.4 Learning cycle

Flashcards, quiz, and sentence builder update progress through recordWordAttempt.

This currently provides:

- unified attempt tracking
- review-due calculation
- mastery progression foundation
- session analytics events

### 6.5 Sync

Remote sync is currently centered around ProgressProvider and FirebaseService.

Current sync states:

- local only
- pending
- syncing
- synced
- failed

Important note:
Sync foundation is in place, but full conflict resolution and a queue backed by a local database are not complete yet.

## 7. Offline-first Foundation

Current offline behavior is implemented with two layers:

1. LocalStorageService
   stores lightweight state and serialized payloads

2. OfflineCatalogCacheService
   caches:
   - categories
   - words by category
   - sentences by category
   - quiz questions by category and direction

This already improves resiliency without network access, but it is not yet a full offline-first architecture with local DB + durable sync queue.

## 8. Analytics

The project includes a local analytics layer:

- AnalyticsService
- LocalAnalyticsService

Tracked learning events include:

- flashcards started / completed
- quiz started / completed
- sentence builder started / completed

At this stage analytics are local for quality/debug visibility; remote analytics export is not connected.

## 9. Current Architecture Strengths

- Feature-first structure is clear and scalable.
- Providers and repositories are separated with reasonable boundaries.
- Recent UX changes were integrated without major architectural breakage.
- Offline and analytics foundations are already part of the app-level dependency graph.

## 10. Current Limitations

- No full local database.
- FirebaseService is still too broad in responsibility.
- Some sync scenarios still need hardening.
- Integration test coverage does not yet include a full end-to-end learning cycle.

## 11. Next Architecture Priorities

1. Add local DB support for content and sync queue.
2. Implement safer guest/cloud merge strategy.
3. Split Firebase responsibilities into smaller services.
4. Add integration test coverage for the full learning flow.
