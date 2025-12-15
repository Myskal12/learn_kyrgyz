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

## Project Structure
- `lib/app` — app setup and routing
- `lib/features/home` — landing page with hero, stats, categories, shortcuts
- `lib/features/categories` — grid of topics and flashcard entry points
- `lib/features/profile` — profile, leaderboard, progress/state providers
- `lib/features/extras` — achievements, quick quiz, study plan, resources

## Troubleshooting
- If Google Sign-In fails on Android, ensure SHA-1/SHA-256 are registered and `com.google.android.gms` is allowed in `AndroidManifest`.
- When testing layout on small screens, use `flutter run -d` with low-res emulators; cards and buttons wrap instead of overflowing.
