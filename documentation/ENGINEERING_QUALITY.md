# Engineering Quality

## 1. Purpose

This file describes the current engineering quality rules for the project:

- how code is validated
- what is considered a quality gate
- what tests already exist
- where real technical risks still remain

## 2. Required Commands Before Finishing Work

```bash
dart format .
flutter analyze
flutter test
git diff --check
```

If changes affect only part of the codebase, formatting can be scoped to modified files, but flutter analyze, flutter test, and git diff --check remain mandatory.

## 3. Existing Test Coverage

### Unit / provider / repository

Current test coverage includes:

- learning direction persistence
- progress provider logic
- flashcard provider behavior
- words repository
- quiz repository
- offline catalog cache
- analytics service

### Widget / UX smoke tests

Current smoke coverage includes:

- primary CTA visibility on short screens
- adaptive mobile shell behavior across widths and text scales
- learning direction control

## 4. Stage-6 Stabilization Additions

The latest stabilization stage added:

- local analytics events for learning sessions
- lifecycle tests for learning sessions
- git diff --check as a mandatory hygiene gate
- whitespace and formatting cleanup

## 5. Current Quality Gates

A change is acceptable only when:

1. Code remains readable without redundant comments and duplicated logic.
2. No new analyzer warnings are introduced.
3. Existing tests stay green.
4. New non-trivial behavior has test coverage.
5. No obvious mobile UX regression is introduced.
6. git diff --check passes without whitespace or merge-noise errors.

## 6. Security and Operational Notes

### Important baseline

- Firebase client config in a mobile app is not a secret by itself.
- Security must be enforced through auth, Firestore rules, and server-side limits.
- Service-account keys must never be committed.

### Work still recommended

- Maintain versioned Firestore rules in the repository.
- Run a dedicated Firebase security posture review before production.
- Complete platform-by-platform Google Sign-In configuration review.

## 7. Current Technical Risks

### High

- guest/cloud sync and merge flows still need additional hardening
- remote analytics pipeline is not connected yet

### Medium

- no full local database yet
- FirebaseService remains too broad in responsibility
- no end-to-end integration tests for the complete learning loop

### Low

- documentation and tooling are now cleaner, but update discipline must be maintained

## 8. Recommended Next Quality Backlog

1. Add integration tests for this flow:
   onboarding -> home -> flashcards -> quiz -> sentence builder -> progress

2. Add smoke tests for sync/offline transitions.

3. Add golden tests for key mobile screens.

4. Split Firebase responsibilities into narrower services.

5. Prepare a local DB migration plan.

## 9. Release Verification List

Before release, verify:

- flutter analyze
- flutter test
- manual mobile smoke pass
- auth scenarios: guest, email, Google
- offline open and continue behavior
- progress sync and conflict edge cases
- no fake CTA and no broken links

## 10. Quality Maintenance Rule

If new code requires long explanations to understand, boundaries are likely wrong or logic is overloaded.

Project preference:

- less magic
- explicit dependencies through providers
- short, testable services
- honest empty/error/offline states
