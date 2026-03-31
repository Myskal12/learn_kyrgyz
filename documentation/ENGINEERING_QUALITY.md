# Engineering Quality

## 1. Purpose

I use this document to describe how I validate the project in its current state. I do not use it to describe an ideal future version that does not exist yet.

## 2. Commands I Run Before I Finish Work

```bash
dart format .
flutter analyze
flutter test
git diff --check
```

If I only touch a small set of files, I may format only those files, but I still treat `flutter analyze`, `flutter test`, and `git diff --check` as the minimum quality gate.

## 3. What Is Already Tested

### Logic and provider coverage

I already have tests for:

- learning direction persistence
- progress provider logic
- flashcard provider behavior
- words repository
- quiz repository
- offline catalog cache
- analytics service

### Widget and UX smoke coverage

I also check:

- primary CTA visibility on short screens
- adaptive mobile shell behavior on several widths and text scales
- learning direction control behavior
- study plan roadmap rendering

## 4. What Stage 6 Added

In the stabilization stage I added:

- local study analytics
- lifecycle tests for learning sessions
- `git diff --check` as a mandatory hygiene check
- cleanup of whitespace and formatting issues

## 5. Quality Gates

I consider a change acceptable when:

1. the code stays readable without redundant comments
2. analyzer warnings do not increase
3. the existing test suite stays green
4. new non-trivial behavior has a test
5. I do not introduce an obvious mobile UX regression
6. `git diff --check` stays clean

## 6. Security And Operational Notes

### Important baseline

- Firebase client configuration in a mobile app is not a secret by itself.
- Real protection depends on authentication, Firestore rules, and backend-side limits.
- Service account keys should never be committed.

### Work I still want to finish

- versioned Firestore rules in the repository
- a dedicated Firebase security review before production release
- a full Google Sign-In configuration review by platform

## 7. Current Technical Risks

### High

- guest and cloud sync still need more hardening
- remote analytics are not connected yet

### Medium

- there is no full local database
- `FirebaseService` is still too broad
- there are no end-to-end integration tests for the full learning cycle

### Low

- the documentation set is cleaner now, but I still need to keep it disciplined and current

## 8. Next Quality Backlog

1. add integration coverage for:
   onboarding -> home -> flashcards -> quiz -> sentence builder -> progress
2. add offline and sync transition smoke tests
3. add golden tests for the key mobile screens
4. split Firebase responsibilities into narrower services
5. prepare a local database migration plan

## 9. Release Checklist

Before I publish a release, I check:

- `flutter analyze`
- `flutter test`
- a manual mobile smoke pass
- guest, email, and Google auth flows
- offline open and continue behavior
- progress sync and conflict edge cases
- broken links or broken CTAs

## 10. Quality Rule

If a new code path needs a long explanation to be understandable, I treat that as a sign that the boundary or structure still needs work.

I prefer:

- less magic
- explicit dependencies through providers
- short and testable services
- honest empty, error, and offline states
