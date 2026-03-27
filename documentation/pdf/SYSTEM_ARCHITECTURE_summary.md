# System Architecture

**Project:** Learn Kyrgyz

---

## Overview

Mobile-only Flutter app (Android, iOS) with Firebase backend. Supports guest and authenticated modes with data sync when online.

**External Services:** Firebase Auth, Cloud Firestore, Cloud Functions, Firebase Analytics, Crashlytics, FCM.

---

## Architectural Layers

| Layer | Components | Responsibility |
|-------|-------------|----------------|
| **Presentation** | Flutter screens, widgets | UI, navigation, responsive layout |
| **Application** | Riverpod providers | State management, use-case coordination |
| **Domain** | Entities, use-cases | Business rules, scoring, streaks, achievements |
| **Data** | Repositories | Local cache, remote sync orchestration |
| **Infrastructure** | Firebase adapters | SDK integration, telemetry, platform services |

---

## Deployment View

**Client Artifacts:** Android APK/AAB, iOS IPA (mobile only).

**CI/CD:** PR validation (lint, tests, static analysis) → Build per platform → Release → Post-deploy monitoring.

**Environments:** dev, staging, production.

---

## Non-Functional Mapping

| Area | Target |
|------|--------|
| Performance | Cold start < 3s, screen load < 1s, API < 500ms |
| Scalability | Horizontal via Firebase, user-scoped partitioning |
| Availability | Provider SLA, graceful offline mode |
| Reliability | Idempotent sync, crash monitoring |
