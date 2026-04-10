# Firebase Guide (Learn Kyrgyz)

This app uses Firebase for authentication, vocabulary content, quizzes, and synced progress:

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `google_sign_in`

The Firestore schema below matches the JSON formats used in `tools/firestore` (words / sentences / quiz).

## 1) FlutterFire setup

1. Generate `lib/firebase_options.dart`:
   - `flutterfire configure --project <your-project-id>`
2. Android:
   - Keep `android/app/google-services.json` in place.
   - Register SHA-1/SHA-256 in Firebase Console (Project settings → Android app) for Google Sign-In.
3. iOS:
   - Add `ios/Runner/GoogleService-Info.plist` and run `pod install` after dependency changes.

## 1.1) Google Sign-In fix for the current repo

Current identifiers in this project:

- Android package: `com.example.learn_kyrgyz`
- iOS bundle: `com.example.learnKyrgyz`

Current local diagnosis:

- `android/app/google-services.json` must include an Android OAuth client with `client_type: 1`
- if this entry is missing, Google Sign-In on Android will fail even if provider is enabled
- `ios/Runner/GoogleService-Info.plist` is missing from the repo

This usually means Google Sign-In was enabled partially, but the Android SHA fingerprints were not added in Firebase Console or a fresh config file was not downloaded afterwards.

### Android

Use the Firebase Console path:

1. **Project settings**
2. **General** tab
3. In **Your apps**, open the Android app `com.example.learn_kyrgyz`

Important:
the screenshot with **Cloud Messaging** is not the right page for Google Sign-In setup.

Add these debug fingerprints for local development:

- SHA-1: `8E:C4:63:65:CB:F2:99:4C:F8:45:14:BF:D5:8F:19:66:92:C1:E7:2F`
- SHA-256: `34:22:53:0A:8E:D0:9A:A7:9E:F1:B2:A3:F1:E8:92:F8:9A:6A:54:BC:40:A3:0C:AB:7C:6E:DB:E1:10:DC:3B:B8`

Then:

1. Go to **Authentication** → **Sign-in method**
2. Enable **Google**
3. Save
4. Return to **Project settings** → **General**
5. Download a fresh `google-services.json`
6. Replace `android/app/google-services.json`

Validation:

- the refreshed `google-services.json` should now include an `oauth_client` entry with `client_type: 1`
- if it still contains only `client_type: 3`, Android Google Sign-In is still not fully configured

### iOS

1. In Firebase Console, open the iOS app `com.example.learnKyrgyz`
2. Download `GoogleService-Info.plist`
3. Put it into `ios/Runner/GoogleService-Info.plist`
4. Keep the bundle id equal to `com.example.learnKyrgyz`
5. Rebuild the iOS app

Notes:

- this repo already has a URL scheme entry in `ios/Runner/Info.plist`
- the plist file itself is still required for native iOS Google Sign-In

### After replacing Firebase config files

Run:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run
```

## 2) Enable Firebase products

- Authentication → Sign-in method: enable **Email/Password** and **Google**
- Firestore Database: create a database in **Native mode**

## 3) Firestore collections

### `words` (vocabulary)

Recommended: use a stable document id (e.g., `water`, `hello`) so the app can track progress per word.

Fields:

- `en` (string, required) — English word
- `ky` (string, required) — Kyrgyz translation
- `transcription_en` (string, optional)
- `transcription_ky` (string, optional)
- `level` (number, optional, default 1)
- `category` (string, required) — used to group words into lessons

Example:

```json
{
  "id": "water",
  "en": "water",
  "ky": "суу",
  "transcription_en": "[ˈwɔːtər]",
  "transcription_ky": "[суу]",
  "level": 1,
  "category": "basic"
}
```

### `sentences` (example sentences)

Fields:

- `en` (string, required)
- `ky` (string, required)
- `highlight` (string, optional) — the highlighted word/phrase (for UI emphasis)
- `word_en` (string, optional) — linked vocabulary item (English)
- `word_ky` (string, optional) — linked vocabulary item (Kyrgyz)
- `wordId` (string, optional) — linked vocabulary document id (recommended)
- `level` (number, optional, default 1)
- `category` (string, required)

Example:

```json
{
  "en": "This is water",
  "ky": "Бул суу",
  "highlight": "water",
  "word_en": "water",
  "word_ky": "суу",
  "level": 1,
  "category": "basic"
}
```

### `quiz` (multiple-choice quizzes)

Fields:

- `type` (string, required) — currently the app supports `choose_translation`
- `question` (string, required) — prompt (usually English)
- `correct` (string, required) — correct answer (usually Kyrgyz)
- `options` (array of strings, required) — must include `correct`
- `level` (number, optional, default 1)
- `category` (string, required)
- `wordId` (string, optional) — linked vocabulary document id (recommended)

Example:

```json
{
  "type": "choose_translation",
  "question": "water",
  "correct": "суу",
  "options": ["суу", "жетимиш", "же", "эртең"],
  "level": 1,
  "category": "basic"
}
```

### `users` (profile + leaderboard)

Document id: `users/<uid>`

- `nickname` (string, optional)
- `avatar` (string, optional)
- `totalMastered` (number, optional)
- `totalSessions` (number, optional)
- `accuracy` (number, optional)

### `userProgress` (synced progress)

Document id: `userProgress/<uid>`

- `correctByWordId` (map<string, number>)
- `seenByWordId` (map<string, number>)
- `streakDays` (number)
- `lastSessionAt` (timestamp)
- `updatedAt` (timestamp)

### `app_config/onboarding` (dynamic onboarding goals)

Document id: `app_config/onboarding`

- `dailyGoalOptions` (array<number>, required) — e.g. `[10, 20, 30, 45]`
- `defaultDailyGoal` (number, required) — must be one of `dailyGoalOptions`

Example:

```json
{
  "dailyGoalOptions": [10, 20, 30],
  "defaultDailyGoal": 20
}
```

### `app_config/achievements` (dynamic achievements)

Document id: `app_config/achievements`

- `items` (array<object>, required)

Each item fields:

- `id` (string, required)
- `title` (string, required)
- `description` (string, required)
- `metric` (string, required): `total_words_mastered` | `accuracy_percent`
- `target` (number, required)
- `order` (number, optional)
- `active` (bool, optional, default `true`)

Example:

```json
{
  "items": [
    {
      "id": "first_star",
      "title": "Алгачкы жылдыз",
      "description": "5 сөздү жаттадыңыз.",
      "metric": "total_words_mastered",
      "target": 5,
      "order": 10,
      "active": true
    },
    {
      "id": "accurate_answers",
      "title": "Так жооптор",
      "description": "Тактык 80% же андан жогору.",
      "metric": "accuracy_percent",
      "target": 80,
      "order": 20,
      "active": true
    }
  ]
}
```

### `app_config/resources` (dynamic external resources)

Document id: `app_config/resources`

- `items` (array<object>, required)

Each item fields:

- `id` (string, required)
- `title` (string, required)
- `description` (string, required)
- `url` (string, required)
- `order` (number, optional)
- `active` (bool, optional, default `true`)

Example:

```json
{
  "items": [
    {
      "id": "glosbe_dictionary",
      "title": "Онлайн сөздүк",
      "description": "Glosbe аркылуу англисче-кыргызча жана кыргызча-англисче издеңиз.",
      "url": "https://en.glosbe.com/en/ky",
      "order": 10,
      "active": true
    }
  ]
}
```

## 4) Bulk upload (recommended)

Use the helper scripts in `tools/firestore` to generate and upload large datasets:

- `tools/firestore/README.md`
- `tools/firestore/generate_collections.js`
- `tools/firestore/upload.js`

## 5) Troubleshooting

- Empty UI: confirm collection names match exactly (`words`, `sentences`, `quiz`).
- Google Sign-In fails on Android: ensure SHA-1/SHA-256 are added in Firebase Console and the device has Google Play Services.
- If `android/app/google-services.json` has an empty `oauth_client` array, enabling Google provider alone is not enough. Add the Android app SHA fingerprints in Firebase Project Settings, download a fresh `google-services.json`, and rebuild the app.
- Permission denied: relax Firestore rules for development (at least allow reads for your content collections) and tighten for production.
