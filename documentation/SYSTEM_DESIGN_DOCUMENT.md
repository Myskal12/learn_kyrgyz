# System Design Document (SDD)

## Project
Learn Kyrgyz - Cross-platform language learning application

## Document Control
- Version: 1.0
- Date: 2026-03-19
- Status: Draft for implementation
- Owner: Product and Engineering Team

## 1. Purpose and Scope
This System Design Document defines the target architecture for Learn Kyrgyz. It describes system components, data flow, external interfaces, non-functional requirements, and operational design decisions needed to deliver a secure, scalable, offline-capable language learning platform.

### In Scope
- Mobile-first app architecture (Android, iOS), plus Web and Desktop support
- Authentication and user profile management
- Content delivery (categories, words, examples, pronunciation metadata)
- Learning modules (flashcards, quizzes, sentence practice)
- Progress tracking, streaks, achievements, and leaderboard
- Offline-first synchronization and conflict handling
- Monitoring, security, and release architecture

### Out of Scope
- Marketing website architecture
- Advanced AI tutoring features
- Third-party marketplace integrations

## 2. System Context
Learn Kyrgyz is a client-heavy application built with Flutter. Firebase provides authentication, cloud datastore, and analytics/monitoring integrations. The app supports anonymous and authenticated modes, with data synchronization when connectivity is available.

### Actors
- Learner (guest or signed-in)
- Content editor/admin (future phase)
- System operator/engineer

### External Services
- Firebase Authentication
- Cloud Firestore
- Cloud Functions (optional backend rules/events)
- Firebase Analytics and Crashlytics
- Push notification service (Firebase Cloud Messaging)

## 3. High-Level Architecture
The architecture follows clean modular boundaries:

1. Presentation Layer
- Flutter screens and widgets
- Navigation and responsive UI orchestration

2. Application Layer
- State management providers
- Use-case coordinators for user actions

3. Domain Layer
- Core business entities and use-cases
- Rules for scoring, streak calculation, and achievement unlocks

4. Data Layer
- Repository interfaces and implementations
- Local cache and remote data source orchestration

5. Infrastructure Layer
- Firebase SDK adapters
- Telemetry, logging, and platform services

## 4. Major Components

### 4.1 Authentication Module
Responsibilities:
- Email/password registration and sign-in
- Google sign-in
- Guest session support
- Session refresh and account lifecycle

Interfaces:
- AuthRepository
- UserSessionProvider

### 4.2 Content Module
Responsibilities:
- Fetch and cache categories and vocabulary
- Provide fallback seed content for offline use
- Support difficulty and category-based filtering

Interfaces:
- ContentRepository
- CategoryService
- WordService

### 4.3 Learning Module
Responsibilities:
- Flashcard flow with known/unknown feedback
- Quiz generation and scoring
- Sentence practice sessions
- Pronunciation trigger metadata and controls

Interfaces:
- LearningSessionService
- QuizEngine

### 4.4 Progress and Gamification Module
Responsibilities:
- Track attempts, accuracy, words learned, and daily streak
- Unlock achievements based on milestones
- Build global leaderboard entries and profile stats

Interfaces:
- ProgressRepository
- AchievementEngine
- LeaderboardService

### 4.5 Profile and Settings Module
Responsibilities:
- Profile edit (nickname/avatar)
- Theme and language preferences
- Notification preferences

Interfaces:
- ProfileRepository
- SettingsRepository

## 5. Data Model (Conceptual)

### Core Entities
- User: id, authType, email, displayName, avatarUrl, createdAt
- Category: id, title, description, imageUrl, level
- Word: id, categoryId, kyrgyzText, translatedText, transcription, example, pronunciationRef
- LearningSession: id, userId, mode, startedAt, completedAt, score
- UserProgress: userId, wordsLearned, totalAttempts, correctAttempts, accuracy, streakCount, lastActiveDate
- Achievement: id, title, description, threshold, icon
- UserAchievement: userId, achievementId, unlockedAt
- LeaderboardEntry: userId, period, points, rank, updatedAt

### Derived Metrics
- Accuracy = correctAttempts / totalAttempts * 100
- Streak increments when a daily learning goal is met

## 6. Data Flow

### 6.1 Onboarding and Authentication
1. User opens app
2. Client checks existing session token
3. If no valid session, user chooses guest/email/google
4. Auth result returns user identity and access context
5. User profile is loaded or initialized

### 6.2 Study Session (Flashcard/Quiz)
1. User selects category
2. Client loads cached content first
3. If online, client refreshes content from cloud
4. User interactions produce learning events
5. Session summary updates local progress
6. Sync worker pushes updates to cloud when online

### 6.3 Achievement and Leaderboard Update
1. Progress update triggers achievement evaluation
2. Newly unlocked achievements are stored and surfaced
3. Leaderboard score is recomputed
4. Ranking data is refreshed in UI

## 7. Offline-First Strategy
- Local-first reads for categories, words, and in-progress state
- Event queue for unsynced progress updates
- Retry policy with exponential backoff
- Conflict strategy:
  - Progress counters: merge by additive update and max(lastActiveDate)
  - Profile settings: latest-write-wins with timestamp
- User feedback states: syncing, synced, retry pending

## 8. Security Design
- TLS for all in-transit communication
- Encrypted storage handled by platform and Firebase defaults
- Least-privilege Firestore security rules by user scope
- Input validation at client boundary
- PII minimization in analytics events
- Account deletion workflow with data cleanup

## 9. Non-Functional Requirements Mapping

### Performance
- App cold start target < 3 seconds
- Screen transition and data load target < 1 second (cached path)
- API response target < 500ms (normal network)

### Scalability
- Horizontal cloud scalability via managed Firebase services
- Data model designed for user and progress partitioning

### Availability
- Cloud availability target aligned with provider SLA
- Graceful offline mode during network outages

### Reliability
- Idempotent progress sync events
- Crash monitoring and alerting for top failures

## 10. Observability and Operations
- Crashlytics for runtime crashes
- Analytics events for funnel and retention metrics
- Structured logs for sync failures and auth failures
- Alert thresholds for crash-free sessions, auth error spikes, and sync backlog

## 11. Deployment View
- Client artifacts: Android APK/AAB, iOS IPA, Web bundle, Desktop binaries
- CI/CD:
  - Pull request validation (lint, tests, static analysis)
  - Build and release pipelines per platform
- Environments: dev, staging, production

## 12. Key Risks and Mitigations
- Risk: Cloud cost growth at high usage
  - Mitigation: cache-first reads, batched writes, usage dashboards
- Risk: Inconsistent sync in low-connectivity regions
  - Mitigation: robust queue/retry and explicit sync status UI
- Risk: Content quality gaps
  - Mitigation: native-speaker review workflow and curation pipeline
- Risk: Security/privacy incidents
  - Mitigation: periodic rule audits and penetration testing

## 13. Acceptance Criteria
- Architecture supports all must-have features
- Offline learning works for cached content and deferred progress sync
- Security rules enforce user data isolation
- Observability captures major error classes and user funnels
- System can be operated with clear runbooks and release process

## 14. Open Decisions
- Final local database technology selection (Hive vs Isar)
- Cloud Functions usage boundary for leaderboard aggregation
- Final push-notification campaign strategy

## 15. Appendix: Suggested Interface Contracts
- AuthRepository: signInEmail, signInGoogle, continueAsGuest, signOut, deleteAccount
- ContentRepository: getCategories, getWordsByCategory, refreshContent
- ProgressRepository: recordAttempt, getProgress, syncPending
- LeaderboardService: getLeaderboard, refreshRank
- SettingsRepository: getSettings, updateSettings
