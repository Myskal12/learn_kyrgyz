# System Design Document (SDD)

**Project:** Learn Kyrgyz

---

## Purpose and Scope

Defines system components, data flow, interfaces, and design decisions for a secure, scalable, offline-capable language learning platform.

**In Scope:** Mobile app (Android, iOS), auth, content delivery, learning modules, progress/gamification, offline sync, monitoring.  
**Out of Scope:** Marketing site, AI tutoring, third-party integrations.

---

## Major Components

| Module | Responsibilities | Key Interfaces |
|--------|------------------|----------------|
| **Auth** | Email/Google/guest sign-in, session lifecycle | AuthRepository, UserSessionProvider |
| **Content** | Categories, vocabulary, offline seed data | ContentRepository, CategoryService, WordService |
| **Learning** | Flashcards, quizzes, sentence practice, TTS | LearningSessionService, QuizEngine |
| **Progress** | Attempts, accuracy, streaks, achievements, leaderboard | ProgressRepository, AchievementEngine, LeaderboardService |
| **Profile** | Nickname, avatar, theme, language, notifications | ProfileRepository, SettingsRepository |

---

## Data Model (Core Entities)

- **User:** id, authType, email, displayName, avatarUrl
- **Category:** id, title, description, imageUrl, level
- **Word:** id, categoryId, kyrgyzText, translatedText, transcription, example, pronunciationRef
- **UserProgress:** wordsLearned, totalAttempts, correctAttempts, accuracy, streakCount, lastActiveDate
- **Achievement, UserAchievement, LeaderboardEntry**

---

## Data Flow

**Onboarding:** App open → check session → guest/email/Google → auth result → load/init profile.

**Study Session:** Select category → load cache → refresh if online → learning events → local progress → sync to cloud.

**Offline:** Local-first reads, event queue for unsynced updates, retry with backoff. Conflict: progress additive merge; profile last-write-wins.

---

## Security & Acceptance

TLS in transit, encrypted storage, Firestore least-privilege rules. Observability: Crashlytics, Analytics, structured logs.
