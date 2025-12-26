# Learn Kyrgyz — 8-Week Progress Report

**Author:** <your name>  
**Period:** Week 1–Week 8  
**Goal:** Build a Duolingo-style Kyrgyz learning app (red + yellow theme) with Firebase content + synced progress.

## 1) Executive summary (what I delivered)
- Cross-platform Flutter app with scalable structure (`lib/app`, `lib/core`, `lib/data`, `lib/features`).
- Navigation with `go_router` and state management with `provider`.
- Firebase integration:
  - Auth: Email/Password + Google
  - Firestore: content collections (`words`, `sentences`, `quiz`) + user data (`users`, `userProgress`)
- Learning experiences:
  - Categories (lesson list) -> Flashcards (TTS + reveal) -> Quiz (submit + results) -> Summary
  - Review loop for mistakes (both flashcards and quiz)
- Responsive UI improvements: larger buttons/tap targets and more comfortable quiz options.
- Bulk tooling to generate and upload large datasets to Firestore (supports 500+ docs easily).

## 2) Tech stack & project structure
**Tech**
- Flutter + Material 3
- `provider` (state management)
- `go_router` (navigation)
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in`
- `shared_preferences` (local persistence)
- `flutter_tts` (Kyrgyz pronunciation)

**Key files**
- Theme + providers: `lib/app/app.dart`
- Routes: `lib/app/router.dart`
- Firebase gateway: `lib/core/services/firebase_service.dart`
- Flashcards: `lib/features/learning/presentation/flashcard_screen.dart`
- Quiz: `lib/features/quiz/presentation/quiz_screen.dart`
- Bulk scripts: `tools/firestore/generate_collections.js`, `tools/firestore/upload.js`
- Firebase documentation: `FIREBASE_GUIDE.md`

## 3) Firebase content formats (how data is stored)
These are the JSON shapes used for the Firestore datasets.

### `quiz` (multiple-choice)
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

### `words` (vocabulary)
```json
{
  "en": "jacket",
  "ky": "куртка",
  "transcription_en": "[jacket]",
  "transcription_ky": "[куртка]",
  "level": 1,
  "category": "clothes"
}
```

### `sentences` (examples)
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

For the full setup checklist and collection expectations, see `FIREBASE_GUIDE.md`.

## 4) Week-by-week progress log

### Week 1 — Project bootstrap & UX direction
**Goals**
- Create the Flutter project and choose a scalable architecture.
- Define UI direction (Duolingo-like feel, Kyrgyz style, red/yellow palette).

**Work completed**
- Initialized Flutter project and prepared a feature-based folder structure.
- Chose `provider` + `go_router` early to avoid rewrites later.
- Created base colors/typography and an initial Material 3 look.

**Deliverables**
- App skeleton + theme foundation (colors, fonts, reusable styles).

**Challenges / fixes**
- Avoided “one-file app” by structuring early (app/core/data/features).

**Next week**
- Implement navigation + build the main tabs/screens.

---

### Week 2 — Navigation + core screens
**Goals**
- Build the main navigation and the first complete user flow.

**Work completed**
- Built Dashboard bottom navigation (Home / Categories / Practice / Profile).
- Implemented route structure for learning flows:
  - `/flashcards/:categoryId`
  - `/quiz/:categoryId`
  - `/login`, `/register`, `/leaderboard`, etc.
- Built first versions of Home + Categories UI with reusable card patterns.

**Deliverables**
- Users can navigate through the app and start learning flows from Categories.

**Challenges / fixes**
- Ensured screens work in both “embedded tab” mode and “full screen” mode.

**Next week**
- Connect Firebase and load content dynamically.

---

### Week 3 — Firebase integration (Auth + Firestore)
**Goals**
- Connect Firebase and establish a clean data layer.

**Work completed**
- Added Firebase initialization and generated platform configs (`firebase_options.dart`).
- Implemented `FirebaseService` as the single place for Auth + Firestore access.
- Added offline fallback data so the UI doesn’t break when Firestore is empty.

**Deliverables**
- App runs with Firebase and can still demo offline with fallback data.

**Challenges / fixes**
- Learned the importance of SHA keys + Google Play Services when testing Google Sign-In on Android.

**Next week**
- Prepare the data model and bulk upload pipeline for large datasets.

---

### Week 4 — Data model + bulk pipeline (500+ docs)
**Goals**
- Make content upload repeatable and scalable (words/sentences/quiz).

**Work completed**
- Standardized the Firestore schema for:
  - `words` (en/ky + level + category)
  - `sentences` (en/ky + highlight + linked word fields)
  - `quiz` (question/correct/options + category)
- Built scripts under `tools/firestore/`:
  - Generate `sentences.json` and `quiz.json` from `words.json`
  - Upload all collections to Firestore using a service account
- Ensured categories can be formed by grouping on the `category` field.

**Deliverables**
- A reliable workflow to upload and refresh thousands of Firestore docs quickly.

**Challenges / fixes**
- Planned for idempotent uploads (rerun scripts safely without duplicates).

**Next week**
- Implement flashcards with good UX + Kyrgyz pronunciation.

---

### Week 5 — Flashcards learning loop + TTS
**Goals**
- Build a comfortable flashcard session (fast, interactive, mobile-friendly).

**Work completed**
- Implemented flashcard flow:
  - reveal translation
  - mark correct/incorrect
  - review mistakes
  - show session summary
- Integrated Kyrgyz TTS so users can hear pronunciation.
- Displayed example text (local fallback or Firestore sentence when available).

**Deliverables**
- Flashcards feel like a real learning tool, not a static list.

**Challenges / fixes**
- Tuned speech rate + language for Kyrgyz TTS to sound natural.

**Next week**
- Build quizzes and match Duolingo-style interaction patterns.

---

### Week 6 — Quiz system + UI comfort improvements
**Goals**
- Create a quiz system that is easy to tap and visually clean.

**Work completed**
- Implemented quiz provider logic (progress, scoring, review mistakes).
- Improved quiz UX:
  - larger, full-width options
  - A/B/C/D option badges
  - better alignment and spacing
- Implemented Duolingo-like flow: **select option -> “Текшерүү” -> “Кийинки”**.
- Added option normalization (dedupe, always include correct, always 4 options).

**Deliverables**
- Quizzes are comfortable on mobile and easier to use than the initial UI.

**Challenges / fixes**
- Fixed small/uncomfortable button sizing and improved responsiveness.

**Next week**
- Sync progress to Firebase and build profile/leaderboard experience.

---

### Week 7 — Progress sync, profile & leaderboard
**Goals**
- Make progress persistent and allow users to keep progress across devices.

**Work completed**
- Implemented progress tracking:
  - seen words
  - mastered words
  - sessions count
  - accuracy percentage
  - daily streak tracking
- Synced progress to Firestore for logged-in users (kept local cache for offline use).
- Built profile screens and leaderboard integration.

**Deliverables**
- Users can log in and keep progress, and see leaderboard stats.

**Challenges / fixes**
- Ensured guest mode works without forcing login.

**Next week**
- Final polish: docs, cleanup, and QA.

---

### Week 8 — Documentation, QA, and final polish
**Goals**
- Improve perceived quality and make the project easy to run for others.

**Work completed**
- Rewrote and cleaned Firebase documentation: `FIREBASE_GUIDE.md`.
- Added global theming for bigger buttons and consistent inputs (improves mobile comfort).
- Fixed data consistency issues (category id alignment, quiz option handling, sentence wiring).
- Ran `flutter analyze` and fixed lints; ensured `flutter test` passes.

**Deliverables**
- Cleaner documentation + improved UX + quality checks passing.

**Challenges / fixes**
- Fixed encoding/formatting issues and removed broken text in docs where needed.

## 5) Next steps (roadmap)
- Duolingo-style lesson path UI (map progression) + clearer level gating.
- Sentence-focused exercises (missing word, reorder words) using the `sentences` dataset.
- “Hearts” system, daily goals, and streak rewards.
- Firestore pagination/caching for large datasets to reduce reads and improve startup speed.

