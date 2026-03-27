# Security Check

## Learn Kyrgyz

Дата проверки: 2026-03-28

## Что было проверено

- наличие приватных ключей, service-account файлов и `.env`
- клиентские Firebase-конфиги
- editor-specific и локальные machine-specific файлы
- базовые git-риски перед публикацией

## Итог

Критичных секретов в рабочем дереве не найдено.

Что найдено:
- в репозитории есть клиентские Firebase-конфиги:
  - `android/app/google-services.json`
  - `lib/firebase_options.dart`
- это не серверные секреты и для мобильного клиента обычно коммитятся в репозиторий
- в проекте есть tooling, ожидающий локальный service account файл:
  - `tools/firestore/upload.js`
- сам `serviceAccountKey.json` в репозитории не найден

## Что было сделано

1. Усилен `.gitignore`
   Добавлены игнорируемые паттерны для:
   - `.vscode/`
   - `.env*`
   - `android/local.properties`
   - `android/key.properties`
   - `serviceAccountKey.json`
   - `*.jks`, `*.keystore`, `*.pem`, `*.key`, `*.p12`
   - `node_modules`
   - debug logs Firebase

2. Убраны editor-specific риски
   `.vscode/settings.json` больше не должен храниться в git.

## Замечания по безопасности

1. Firebase client config не равен секрету
   `apiKey` из Firebase web/mobile config не считается полноценным секретом. Защита должна строиться не на скрытии этого ключа, а на:
   - Firebase Auth
   - Firestore Security Rules
   - Storage Rules
   - API restrictions в Google Cloud при необходимости

2. В репозитории не видно versioned security rules
   В дереве найден `firebase.json`, но отдельные `firestore.rules` / `storage.rules` не найдены.
   Рекомендуется добавить их в репозиторий и поддерживать как часть инфраструктуры.

3. Service account ключи нельзя коммитить
   Для `tools/firestore/upload.js` service account должен оставаться только локальным файлом вне git.

## Рекомендуемые следующие шаги

1. Добавить в репозиторий `firestore.rules`
2. Добавить в репозиторий `storage.rules`
3. Проверить правила Firestore на:
   - доступ только к собственному профилю
   - доступ только к собственному прогрессу
   - запрет на массовое чтение/запись без нужной авторизации
4. Ограничить Google API key по платформам, если это ещё не сделано в Google Cloud Console
5. Не хранить админские ключи и service-account JSON в рабочем дереве проекта
