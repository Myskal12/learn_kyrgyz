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

## 4) Bulk upload (recommended)

Use the helper scripts in `tools/firestore` to generate and upload large datasets:

- `tools/firestore/README.md`
- `tools/firestore/generate_collections.js`
- `tools/firestore/upload.js`

## 5) Troubleshooting

- Empty UI: confirm collection names match exactly (`words`, `sentences`, `quiz`).
- Google Sign-In fails on Android: ensure SHA-1/SHA-256 are added in Firebase Console and the device has Google Play Services.
- Permission denied: relax Firestore rules for development (at least allow reads for your content collections) and tighten for production.
