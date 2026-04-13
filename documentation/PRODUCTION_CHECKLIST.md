# Production Checklist

This file defines the minimum actions required to move the current project from a working MVP to a production-ready release.

## 1. Auth and Firebase

- Enable Google and Email/Password in Firebase Authentication.
- Add SHA-1 and SHA-256 for the final Android app ID.
- Download a fresh android/app/google-services.json for the final Android package.
- Add ios/Runner/GoogleService-Info.plist for the final iOS bundle ID.
- Verify sign-in flows: guest, email login, email signup, password reset, Google login.
- Verify logout and re-login without session loss.

## 2. Firestore and Data

- Populate words, sentences, and quiz with production data, not fallback-only datasets.
- Verify each sentence record is linked to a word via wordId.
- Verify category consistency across words, sentences, and quiz.
- Keep production Firestore rules versioned in the repository.
- Manually validate leaderboard, profile, and synced progress with real accounts.

## 3. Offline and Sync

- Harden guest/cloud merge strategy.
- Introduce full local DB support beyond SharedPreferences.
- Add a sync queue and stronger conflict handling.
- Validate offline -> online transitions without data loss.

## 4. Learning Product

- Close the sentence-builder dependency gap when sentences are missing from Firestore/cache.
- Improve error feedback in quiz and sentence builder.
- Make category progression transparent and verifiable.
- Decide whether study plan remains static or becomes data-driven.
- Complete a full content review: translations, spelling, transcriptions, examples.

## 5. Quality

- Add integration test for full flow: onboarding -> home -> flashcards -> quiz -> sentence builder -> progress.
- Add smoke tests for offline/online sync transitions.
- Add golden tests for key screens.
- Run manual Android QA on at least two devices or emulators.
- Run manual iOS QA if iOS is in release scope.

## 6. Release Readiness

- Replace all com.example.* identifiers with final package/bundle IDs.
- Configure Android release signing with real keystore values.
- Keep fail-fast release checks for missing keystore/plist and example IDs.
- Update app title, descriptions, and store metadata.
- Verify privacy and data-safety requirements for Play Store and App Store.
- Configure Crashlytics and production analytics.
- Build and verify release artifacts, not only debug builds.

## 7. Definition of Done

The project is considered production-ready only when:

- Auth scenarios are stable on target platforms.
- Backend and security rules are part of source control and release process.
- The full learning loop works end-to-end with no empty-state blockers.
- Offline/sync does not lose user progress.
- Release builds pass automated checks and manual smoke validation.
