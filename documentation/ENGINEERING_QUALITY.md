# Engineering Quality

Обновлено: 2026-04-01

## 1. Цель этого документа

Этот файл фиксирует не "идеальное будущее", а текущие инженерные правила проекта:

- как проверять код
- что считается quality gate
- какие тесты уже есть
- где остаются реальные технические риски

## 2. Обязательные команды перед завершением работы

```bash
dart format .
flutter analyze
flutter test
git diff --check
```

Если правки касаются только части файлов, допускается форматировать только измененные файлы, но `flutter analyze`, `flutter test` и `git diff --check` остаются обязательными.

## 3. Что уже покрыто тестами

### Unit / provider / repository

В проекте уже есть тесты для:

- learning direction persistence
- progress provider logic
- flashcard provider behavior
- words repository
- quiz repository
- offline catalog cache
- analytics service

### Widget / UX smoke tests

Есть проверки для:

- visibility primary CTA на коротких экранах
- adaptive mobile shell на нескольких ширинах и text scale
- learning direction control

## 4. Что проверяет этап 6

Финальный этап стабилизации добавил:

- локальную аналитику учебных событий
- тесты на lifecycle учебных сессий
- `git diff --check` как обязательную hygiene-проверку
- cleanup whitespace / formatting issues

## 5. Текущие quality gates

Изменение считается приемлемым, если:

1. код читается без лишних комментариев и без дублирующей логики
2. нет новых analyzer warnings
3. существующие тесты проходят
4. для нового сложного поведения есть тест
5. нет obvious UX regression на мобильном экране
6. `git diff --check` не падает на whitespace / merge мусоре

## 6. Security и operational notes

### Что важно понимать

- Firebase client config в мобильном приложении не является полноценным секретом.
- Безопасность должна строиться на auth, Firestore rules и server-side ограничениях.
- Service-account ключи не должны лежать в репозитории.

### Что в проекте еще желательно довести

- versioned Firestore rules в репозитории
- отдельный review Firebase security posture перед production release
- ревизия Google Sign-In конфигурации по платформам

## 7. Реальные технические риски на сегодня

### High

- sync и merge guest/cloud still need additional hardening
- remote analytics пока не подключены

### Medium

- нет полноценной local DB
- `FirebaseService` остается слишком широким по ответственности
- нет end-to-end integration tests для полного учебного цикла

### Low

- часть документации и tooling раньше была разрозненной; теперь это очищено, но нужно поддерживать дисциплину обновления

## 8. Рекомендованный следующий quality backlog

1. добавить integration tests для сценария:
   onboarding -> home -> flashcards -> quiz -> sentence builder -> progress

2. добавить smoke tests для sync/offline transitions

3. ввести golden tests для ключевых mobile screens

4. вынести Firebase responsibilities в более узкие services

5. подготовить local DB migration plan

## 9. Release checklist

Перед релизом проверить:

- `flutter analyze`
- `flutter test`
- ручной smoke pass на mobile
- auth scenarios: guest, email, Google
- offline open and continue behavior
- progress sync and conflict edge cases
- no fake CTA or broken external links

## 10. Правило поддержки качества

Если новый код требует длинного пояснения, значит архитектурная граница выбрана плохо или логика перегружена.

Предпочтение проекта:

- меньше магии
- явные зависимости через providers
- короткие и тестируемые сервисы
- честные empty/error/offline states
