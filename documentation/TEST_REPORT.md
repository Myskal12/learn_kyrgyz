# Test Report

## 1. Scope

I use this report to describe the current validation baseline after the UX, offline foundation, learning flow, and stabilization work already merged into the project.

## 2. Main Verification Commands

```bash
flutter analyze
flutter test
git diff --check
```

## 3. Current Coverage

### Provider and logic tests

I currently cover:

- learning direction persistence
- progress provider milestone and review logic
- flashcard provider reveal and review behavior
- quiz provider session analytics lifecycle
- sentence builder provider session analytics lifecycle

### Repository and service tests

I currently cover:

- offline catalog cache service
- words repository
- quiz repository
- local analytics service

### Widget and UX smoke tests

I currently cover:

- auth CTA visibility on short screens
- adaptive mobile shell stability
- learning direction control behavior
- study plan roadmap rendering

## 4. Current Result

In my latest full validation run:

- `flutter analyze` passed
- `flutter test` passed
- `git diff --check` passed

## 5. Remaining Gaps

- full integration tests for the complete study cycle
- guest and cloud merge edge cases under sync pressure
- golden tests for the main mobile screens
- broader manual device checks on more form factors

## 6. Next Testing Step

I want the next testing step to include:

1. integration flow:
   onboarding -> home -> flashcards -> quiz -> sentence builder -> progress
2. offline and online transition checks
3. golden tests for:
   - home
   - practice
   - categories
   - flashcards
   - progress
