# Test Report

Обновлено: 2026-04-01

## 1. Цель

Этот отчет фиксирует текущий минимальный проверочный контур проекта после завершения этапов UX, offline-first foundation, learning-flow и stabilization work.

## 2. Основные команды проверки

```bash
flutter analyze
flutter test
git diff --check
```

## 3. Что покрыто

### Provider / logic tests

- learning direction persistence
- progress provider milestone/review logic
- flashcard provider reveal and review mode behavior
- quiz provider session analytics lifecycle
- sentence builder session analytics lifecycle

### Repository / service tests

- offline catalog cache service
- words repository
- quiz repository
- local analytics service

### Widget / UX smoke tests

- auth CTA visibility on short screens
- adaptive mobile shell stability
- learning direction control behavior

## 4. Последний статус

На последнем полном прогоне:

- `flutter analyze` -> passed
- `flutter test` -> passed
- `git diff --check` -> passed without whitespace errors

## 5. Что еще не закрыто полностью

- full integration tests for complete study cycle
- guest/cloud merge edge cases under sync pressure
- golden tests for key mobile screens
- manual device audit for all main flows on multiple form factors

## 6. Рекомендованный следующий тестовый этап

1. integration test:
   onboarding -> home -> flashcards -> quiz -> sentence builder -> progress

2. offline/online transition tests

3. golden tests for:
   - home
   - practice
   - categories
   - flashcards
   - progress
