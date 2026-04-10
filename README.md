# Learn Kyrgyz

Mobile flashcards and quizzes to practice Kyrgyz vocabulary with synced progress, streaks, and a global leaderboard.

## Features
- Category-based flashcards with quick quizzes and fallback offline seed data.
- Progress sync (email/Google), accuracy tracking, daily streak counter, and leaderboard.
- Profile editing (nickname/avatar) plus a refreshed profile layout with stats preview.
- Extra learning tools: quick quiz, study plan, achievements, and resource links.
- Material 3 UI, Kyrgyz copy, Manrope typography, and responsive cards to avoid overflows.

## Getting Started
1. Install Flutter (3.22+) and run `flutter pub get`.
2. Launch on a device or emulator: `flutter run`.
3. Sign in with email, Google, or continue as guest and start from the Home screen.
4. Want real data? Follow [FIREBASE_GUIDE.md](FIREBASE_GUIDE.md) to seed Firestore, enable Auth providers, and add SHA keys for Google Sign-In.

## Firebase Setup (quick)
- Enable **Email/Password** and **Google** in Firebase Console → Authentication.
- Firestore: `categories` and `words` collections (words include `categoryId`), `users` for leaderboard/profile, `userProgress` for synced stats.
- Keep the generated `lib/firebase_options.dart` in source control; Android also needs `android/app/google-services.json`.

## Release Setup (quick)
- Copy `android/key.properties.example` to `android/key.properties` and fill real signing values.
- Release Android builds now fail fast unless you pass a final Android app id via Gradle property `APP_ID`.
- Set final iOS bundle id through `APP_BUNDLE_ID` in `ios/Flutter/Debug.xcconfig` and `ios/Flutter/Release.xcconfig`.
- Run `dart run tools/release/verify_release_readiness.dart` before cutting release artifacts.
- Follow the step-by-step release runbook in [documentation/RELEASE_EXECUTION_CHECKLIST.md](documentation/RELEASE_EXECUTION_CHECKLIST.md).

## Project Structure
- `lib/app` — app setup and routing
- `lib/features/home` — landing page with hero, stats, categories, shortcuts
- `lib/features/categories` — grid of topics and flashcard entry points
- `lib/features/profile` — profile, leaderboard, progress/state providers
- `lib/features/extras` — achievements, quick quiz, study plan, resources

## Documentation
- Current project docs live in [documentation/README.md](documentation/README.md)
- Product and UX notes: [documentation/PRODUCT_AND_UX.md](documentation/PRODUCT_AND_UX.md)
- Architecture notes: [documentation/ARCHITECTURE.md](documentation/ARCHITECTURE.md)
- Quality and testing notes: [documentation/ENGINEERING_QUALITY.md](documentation/ENGINEERING_QUALITY.md)
- User guide: [documentation/USER_GUIDE.md](documentation/USER_GUIDE.md)
- Test report: [documentation/TEST_REPORT.md](documentation/TEST_REPORT.md)
- Release execution runbook: [documentation/RELEASE_EXECUTION_CHECKLIST.md](documentation/RELEASE_EXECUTION_CHECKLIST.md)

## Troubleshooting
- If Google Sign-In fails on Android, ensure SHA-1/SHA-256 are registered and `com.google.android.gms` is allowed in `AndroidManifest`.
- When testing layout on small screens, use `flutter run -d` with low-res emulators; cards and buttons wrap instead of overflowing.
