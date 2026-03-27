# Technology Stack Documentation

## Project
Learn Kyrgyz - Technical stack decisions, trade-offs, and implementation standards

## Document Control
- Version: 1.0
- Date: 2026-03-19
- Status: Recommended baseline stack

## 1. Technical Goals
- Build once, deploy to Android, iOS, Web, and Desktop
- Keep UI performance high on low to mid-range devices
- Provide offline-first learning and reliable sync
- Maintain secure user data handling and scalable backend operations
- Keep development velocity high for a small team

## 2. Selected Stack Summary

| Layer | Selected Technology | Purpose |
|---|---|---|
| Client Framework | Flutter (Dart) | Cross-platform UI and business logic |
| State Management | Riverpod | Predictable, testable state orchestration |
| Architecture | Feature-first + clean layers | Maintainability and modular growth |
| Backend Platform | Firebase | Auth, data, analytics, crash monitoring |
| Cloud Database | Cloud Firestore | Real-time sync and scalable document storage |
| Authentication | Firebase Auth (Email/Google/Anonymous) | Secure user identity and session management |
| Local Storage | SharedPreferences + local DB (Hive or Isar) | Offline cache and user/device settings |
| Networking/SDK | Firebase Flutter SDKs | Platform-integrated cloud access |
| Observability | Firebase Analytics + Crashlytics | Product insights and runtime diagnostics |
| CI/CD | GitHub Actions (recommended) | Automated lint, tests, build, and release gates |

## 3. Why This Stack

### Flutter (Dart)
- Single codebase for six platforms
- Strong performance and mature ecosystem
- Fast UI iteration and consistent design system control

### Riverpod
- Good separation between UI and business logic
- Safer dependency injection patterns
- Scales well as features and modules increase

### Firebase
- Managed services reduce operational overhead
- Native support for auth, data, analytics, and crash reports
- Strong fit for small team and fast delivery timeline

### Firestore
- Flexible schema for evolving content and progress models
- Works well with user-scoped documents
- Built-in sync capabilities suited for mobile workloads

## 4. Alternatives Considered

| Component | Alternatives | Decision Rationale |
|---|---|---|
| State Management | Bloc, Provider | Riverpod selected for simpler testable provider graph |
| Backend | Supabase, custom API | Firebase selected for team speed and integrated services |
| Local DB | SQLite, ObjectBox | Hive/Isar preferred for simpler local object workflows |
| Analytics | Mixpanel, Amplitude | Firebase Analytics preferred for tighter platform integration |

## 5. Detailed Layer Mapping

### 5.1 Presentation Layer
- Flutter widgets and routing
- Material 3 theming
- Responsive UI adaptations for phone/tablet/desktop

### 5.2 Application Layer
- Riverpod providers for session state, content state, learning flow state
- Controllers/use-cases orchestrate interactions across repositories

### 5.3 Domain Layer
- Entities: User, Word, Category, Progress, Achievement
- Use-cases: StartSession, SubmitAnswer, UpdateProgress, EvaluateAchievements

### 5.4 Data Layer
- Repository interfaces for auth, content, progress, profile
- Remote adapters for Firebase
- Local adapters for cache and settings

### 5.5 Infrastructure Layer
- Crashlytics, analytics events, notification integrations
- Environment config and feature flag handling

## 6. Security and Compliance Stack
- Transport security through TLS
- Firebase security rules for least privilege
- Authentication token lifecycle managed by SDK
- Sensitive config via secure environment handling
- PII minimization in logs and analytics payloads
- Account deletion path for privacy requirements

## 7. Offline and Sync Strategy
- Local-first reads for key content and latest user progress snapshot
- Queue unsynced events while offline
- Sync on reconnect with retry/backoff
- Conflict handling:
  - counters and attempts merged additively
  - settings and profile use last-write-wins by timestamp

## 8. Quality Engineering Tooling
- Static analysis: flutter analyze
- Formatting: dart format
- Unit tests: flutter test
- Widget tests for critical screens
- Integration tests for auth and learning flows
- Recommended coverage threshold: >= 60% short-term, >= 80% long-term

## 9. CI/CD Blueprint
Pipeline stages:
1. Validate
- Dependency restore
- Static analysis and formatting checks
- Unit/widget test suite

2. Build
- Android and iOS build jobs
- Web and desktop build jobs (as required)

3. Release
- Staged deployment workflow
- Environment-based configuration injection

4. Post-Deploy
- Smoke checks
- Crash and error-rate monitoring

## 10. Cost and Operations Considerations
- Cost drivers:
  - Firestore reads/writes
  - Auth MAU scale
  - Notification volume
- Optimization levers:
  - aggressive client caching
  - batched progress writes
  - index and query tuning
- Operational dashboards:
  - daily active users
  - sync failures
  - crash-free session rate
  - top latency and error paths

## 11. Implementation Conventions
- Feature-first folder structure
- Repository pattern for data source abstraction
- DTO-to-domain mapping isolation
- Consistent naming for providers and state objects
- Clear error models and user-facing fallback messages

## 12. Technical Risks and Mitigations
- Risk: Firestore cost growth
  - Mitigation: cache-first strategy and write batching
- Risk: Offline sync complexity
  - Mitigation: deterministic queue processing and telemetry
- Risk: Platform-specific auth edge cases
  - Mitigation: device matrix testing and staged rollout
- Risk: Regressions under rapid feature growth
  - Mitigation: mandatory CI gates and architecture review checkpoints

## 13. Recommended Next Steps
1. Finalize local database choice (Hive or Isar) after benchmark
2. Lock CI pipeline with minimum quality gates
3. Define production-ready Firestore rules and load test scripts
4. Create architecture decision records for major stack choices

## 14. Final Recommendation
Proceed with Flutter + Riverpod + Firebase as the production baseline. This stack best matches the project's timeline, team size, platform coverage needs, and offline-capable learning experience requirements while keeping operations manageable.
