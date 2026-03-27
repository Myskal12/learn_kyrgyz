# Technology Stack Documentation

**Project:** Learn Kyrgyz

---

## Technical Goals

Build for Android and iOS only (mobile launch). Offline-first learning, secure data, scalable backend, high development velocity.

---

## Selected Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| Client | Flutter (Dart) | Android and iOS mobile app |
| State | Riverpod | Testable state orchestration |
| Architecture | Feature-first + clean layers | Modular growth |
| Backend | Firebase | Auth, data, analytics, crash monitoring |
| Database | Cloud Firestore | Real-time sync, document storage |
| Auth | Firebase Auth | Email, Google, Anonymous |
| Local | SharedPreferences + Hive/Isar | Offline cache, settings |
| CI/CD | GitHub Actions | Lint, test, build, release |

---

## Rationale

**Flutter:** Single codebase for Android and iOS, strong performance.

**Riverpod:** Separation of UI and logic, dependency injection, scales with features.

**Firebase:** Managed services, integrated auth/data/analytics, fits small team.

**Firestore:** Flexible schema, user-scoped documents, built-in sync.

---

## Alternatives Considered

Bloc/Provider → Riverpod; Supabase → Firebase; SQLite → Hive/Isar.

---

## Quality & Operations

- Static analysis, unit/widget/integration tests, 60–80% coverage target
- CI: validate → build → release → post-deploy monitoring
- Cost optimization: caching, batched writes, query tuning

---

**Recommendation:** Proceed with Flutter + Riverpod + Firebase as production baseline.
