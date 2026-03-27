# Learn Kyrgyz - System Design

**Version:** 1.0 | **Date:** 2026-03-19 | **Status:** Draft for implementation

---

## Purpose

Defines target architecture for a secure, scalable, offline-capable language learning platform.

**In Scope:** Mobile-first app, auth, content delivery, learning modules, progress/gamification, offline sync, monitoring.

**Out of Scope:** Marketing site, AI tutoring, third-party integrations.

---

## Architecture

**Client-heavy Flutter app** with Firebase backend. Supports guest and authenticated modes.

**Layers:**
1. **Presentation** — Flutter screens, navigation, responsive UI
2. **Application** — Riverpod providers, use-case coordinators
3. **Domain** — Entities, scoring, streaks, achievements
4. **Data** — Repositories, local cache, remote sync
5. **Infrastructure** — Firebase adapters, telemetry

---

## Major Modules

| Module | Responsibilities |
|--------|------------------|
| **Auth** | Email/Google/guest sign-in, session lifecycle |
| **Content** | Categories, vocabulary, offline seed data |
| **Learning** | Flashcards, quizzes, sentence practice, TTS |
| **Progress** | Attempts, accuracy, streaks, achievements, leaderboard |
| **Profile** | Nickname, avatar, theme, language, notifications |

---

## Data Flow

**Study Session:** User selects category → load cached content → refresh if online → learning events → local progress → sync to cloud when online.

**Offline:** Local-first reads, event queue for unsynced updates, retry with backoff. Conflict: progress merged additively; profile last-write-wins.

---

## Security & Operations

TLS in transit, encrypted storage, Firestore least-privilege rules. Crashlytics and Analytics for monitoring. Alert on crash spikes and sync failures.
