# Test Report

## 1. Purpose

This report documents the current minimum verification scope after UX, offline-first foundation, learning-flow, and stabilization work.

## 2. Core Validation Commands

```bash
flutter analyze
flutter test
git diff --check
```

## 3. Covered Areas

### Provider and logic tests

- learning direction persistence
- progress provider milestone/review logic
- flashcard provider reveal and review-mode behavior
- quiz provider session analytics lifecycle
- sentence builder provider session analytics lifecycle

### Repository and service tests

- offline catalog cache service
- words repository
- quiz repository
- local analytics service

### Widget and UX smoke tests

- auth CTA visibility on short screens
- adaptive mobile shell stability
- learning direction control behavior

## 4. Last Known Full-Run Status

In the latest full run:

- flutter analyze -> passed
- flutter test -> passed
- git diff --check -> passed without whitespace errors

## 5. Remaining Gaps

- full integration tests for the complete learning cycle
- guest/cloud merge edge cases under sync pressure
- golden tests for key mobile screens
- manual device audit for all primary flows on multiple form factors

## 6. Recommended Next Test Stage

1. Add integration test coverage for:
   onboarding -> home -> flashcards -> quiz -> sentence builder -> progress

2. Add offline-to-online transition tests.

3. Add golden tests for:
   - home
   - practice
   - categories
   - flashcards
   - progress
