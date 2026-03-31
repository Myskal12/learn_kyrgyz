# Architecture

Обновлено: 2026-04-01

## 1. Общая схема

Приложение построено как Flutter client-first проект с Riverpod для DI и state wiring, Firebase как remote backend и локальными persistence-слоями для offline-friendly работы.

Текущая архитектурная формула:

- presentation -> screens and shared widgets
- state -> providers / notifiers
- data access -> repositories
- platform / remote / local -> services

## 2. Основной стек

- Flutter / Dart
- flutter_riverpod
- go_router
- Firebase Auth
- Cloud Firestore
- SharedPreferences

Важно:
полноценная локальная БД еще не внедрена. Сейчас offline foundation построен поверх `SharedPreferences` и dedicated cache services.

## 3. Ключевые директории

- `lib/app`
  app bootstrap, router, global providers

- `lib/core`
  shared services, utilities, session helpers

- `lib/data/models`
  app models: words, categories, quiz questions, progress, profile

- `lib/features`
  feature-first модули: auth, home, categories, learning, quiz, progress, profile, extras

- `lib/shared/widgets`
  reusable UI blocks, shell, cards, buttons, layout helpers

## 4. Routing и shell

Навигация собирается через `GoRouter` в `lib/app/router.dart`.

Основные свойства текущего navigation layer:

- единый shell для основных экранов
- secondary flows на тех же shared UI patterns
- query-param support для review entry points в flashcards

## 5. Provider graph

### App-level providers

В `lib/app/providers/app_providers.dart` находятся базовые зависимости:

- `sharedPreferencesProvider`
- `firebaseServiceProvider`
- `localStorageServiceProvider`
- `analyticsServiceProvider`
- `offlineCatalogCacheServiceProvider`
- repository providers

### User/session related providers

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

## 6. Data flow

### 6.1 Startup

1. App initializes Firebase and SharedPreferences.
2. Riverpod wires base services and repositories.
3. Onboarding / auth / theme / direction providers hydrate local state.
4. Home and other screens read feature providers on demand.

### 6.2 Content loading

Категории, слова, предложения и quiz data проходят через repository layer.

Типовой путь:

1. screen -> provider
2. provider -> repository
3. repository -> offline cache read
4. repository -> Firebase fetch attempt
5. remote success -> cache refresh
6. fallback -> cached or seeded content

### 6.3 Progress

`ProgressProvider` - центральная точка для:

- streak
- attempts
- review due
- weak words
- mastered words
- sync state
- next milestone helpers

Per-word progress хранится через `WordProgressRecord`, а не только через простые counters.

### 6.4 Learning cycle

Flashcards, quiz и sentence builder обновляют progress через `recordWordAttempt`.

Сейчас это обеспечивает:

- unified attempt tracking
- review due calculation
- mastery progression foundation
- session analytics events

### 6.5 Sync

Remote sync сейчас строится вокруг `ProgressProvider` и `FirebaseService`.

Текущие состояния:

- local only
- pending
- syncing
- synced
- failed

Важно:
sync foundation есть, но полноценная conflict resolution и queue backed by local DB еще не завершены.

## 7. Offline-first foundation

Текущее offline-решение состоит из двух слоев:

1. `LocalStorageService`
   хранение lightweight state и serialized payloads

2. `OfflineCatalogCacheService`
   кэширует:
   - categories
   - words by category
   - sentences by category
   - quiz questions by category and direction

Это уже делает приложение заметно устойчивее без сети, но это еще не "full offline-first architecture" в смысле локальной БД и полноценной sync queue.

## 8. Analytics

В проекте есть локальный analytics layer:

- `AnalyticsService`
- `LocalAnalyticsService`

Сейчас логируются ключевые учебные события:

- flashcards started / completed
- quiz started / completed
- sentence builder started / completed

Пока это локальное наблюдение и debugging/quality layer. Отправка в remote analytics еще не подключена.

## 9. Текущие архитектурные плюсы

- feature-first структура понятна и масштабируема
- providers и repositories уже разведены достаточно чисто
- UX-изменения последних этапов внедрялись без полного архитектурного слома
- offline и analytics foundation уже встроены в app-level graph

## 10. Текущие ограничения

- нет полноценной local DB
- FirebaseService все еще слишком крупный и многофункциональный
- часть sync-сценариев требует дальнейшего hardening
- integration-test layer пока не покрывает end-to-end learning cycle

## 11. Следующий архитектурный приоритет

1. local DB for content and sync queue
2. safer guest/cloud merge strategy
3. smaller service boundaries around Firebase-related responsibilities
4. integration-test coverage for full learning flow
