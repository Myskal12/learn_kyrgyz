# Static Parts Implementation Plan

## 1) Identified static parts

### A. Learning content and fallback data

- Static vocabulary seed is hardcoded in service code:
  - lib/core/services/firebase_service.dart (seed words map)
- Static fallback categories are hardcoded:
  - lib/core/services/firebase_service.dart (fallback categories list)
- Firestore source dataset in repo is not production-sized:
  - tools/firestore/words.json (currently 10 entries)

Impact:

- Product quality depends on code-level content instead of managed data.
- Empty states appear if Firestore does not contain enough records.

### B. Static study plan roadmap

- Regional roadmap sections are hardcoded:
  - lib/features/extras/presentation/study_plan_screen.dart (_buildSections)

Impact:

- Product team cannot change roadmap text, thresholds, or steps without code deploy.

### C. Static achievements configuration

- Trophy list and unlock criteria are hardcoded:
  - lib/features/extras/presentation/achievements_screen.dart (final trophies list)

Impact:

- No dynamic rollout of new achievements.
- Hard to localize/iterate without app update.

### D. Static resources list

- Learning links are hardcoded:
  - lib/features/extras/presentation/resources_screen.dart (final resources list)

Impact:

- Broken/outdated links require a new release.

### E. Static progression and gating rules

- Category unlock threshold is static index * 5:
  - lib/features/categories/presentation/categories_screen.dart (unlockThreshold)
- Completion threshold is static mastery >= 0.9:
  - lib/features/categories/presentation/categories_screen.dart
- Milestone targets are hardcoded [5, 15, 30, 50]:
  - lib/features/profile/providers/progress_provider.dart (_milestoneTargets)
- Onboarding daily goals are static choices:
  - lib/features/onboarding/presentation/welcome_screen.dart ([10, 20, 30])
  - lib/features/app/providers/onboarding_provider.dart (_defaultDailyGoal)

Impact:

- Core learning economy cannot be tuned from backend/admin panel.

### F. Static placeholders / unfinished settings features

- Notifications marked as not connected yet:
  - lib/features/profile/presentation/profile_settings_screen.dart
- Text size setting marked as coming soon:
  - lib/features/profile/presentation/profile_settings_screen.dart

Impact:

- Settings screen has non-functional sections in release UX.

### G. Static default app identifiers (release config)

- Default Android APP_ID fallback still points to example id:
  - android/app/build.gradle.kts
- Default iOS APP_BUNDLE_ID still points to example id:
  - ios/Flutter/Debug.xcconfig
  - ios/Flutter/Release.xcconfig

Impact:

- High risk of releasing with non-final identifiers if CI parameters are not set.

## 2) Implementation roadmap (from highest business impact to lowest)

## Phase 1: Data source first (must do)

Goal: Remove dependency on hardcoded learning content.

1. Finalize production words dataset (>= 500 entries) in tools/firestore/words.json.
2. Validate with:
   - node tools/firestore/validate_dataset.js --min 500
3. Generate derived collections:
   - node tools/firestore/generate_collections.js
4. Upload to Firestore:
   - node tools/firestore/upload.js
5. Verify in-app:
   - categories loaded from Firestore
   - no empty states in quiz and sentence builder for main categories

Deliverables:

- Production words/sentences/quiz data in Firestore.
- App works without relying on in-code seed as primary path.

## Phase 2: Externalize static product configuration

Goal: Move static business configuration into Firestore config collections.

Create config collections:

1. app_config/onboarding
   - dailyGoalOptions: [10, 20, 30, 45]
   - defaultDailyGoal: 20
2. app_config/progress
   - milestoneTargets: [5, 15, 30, 50, 100]
   - categoryUnlockRule: either explicit thresholds per category or formula config
3. app_config/study_plan
   - sections array with title, significance, grammar, targets, vocabulary, actions
4. app_config/achievements
   - list of achievements with condition type and threshold
5. app_config/resources
   - list of curated links with title, description, url, active flag

Code changes:

- Add typed config models and repository layer.
- Load config at startup with local cache fallback.
- Keep safe built-in defaults only as emergency fallback path.

Deliverables:

- Study plan, achievements, resources, milestones, and onboarding goals are remotely configurable.

## Phase 3: Complete currently static placeholders

Goal: Remove "coming soon" behavior in user-visible settings.

1. Notifications:
   - integrate Firebase Cloud Messaging
   - add enable/disable toggle and local schedule settings
   - persist token/user preferences in Firestore user profile
2. Text size:
   - add app-wide text scale setting
   - persist in local storage and user profile
   - apply to typography system globally

Deliverables:

- Settings sections become functional.

## Phase 4: Release hardening and guardrails

Goal: Prevent static fallback defaults from leaking into production build.

1. CI checks:
   - fail build if APP_ID is still com.example.learn_kyrgyz
   - fail build if APP_BUNDLE_ID is still com.example.learnKyrgyz
2. Add release checklist gate in CI:
   - dataset validation passed
   - analyze/test passed
   - release build passed
3. Add startup diagnostics log for active config source (remote/cache/fallback)

Deliverables:

- Safer release process with lower regression risk.

## 3) Suggested sprint split

Sprint 1 (backend content):

- Complete Phase 1
- Start config schemas from Phase 2

Sprint 2 (data-driven app):

- Complete Phase 2 integration in app screens/providers

Sprint 3 (feature completion + release):

- Complete Phase 3 and Phase 4

## 4) Definition of done for static-to-dynamic migration

- Core learning flow does not depend on hardcoded content for normal operation.
- Study plan, achievements, resources, milestones, and onboarding goals are editable in Firestore config.
- No user-facing "coming soon" placeholders in release settings.
- CI blocks release when placeholder identifiers or insufficient dataset are detected.
