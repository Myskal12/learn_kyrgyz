# Firebase Integration Guide (Future Work)

The current build intentionally runs **offline** and ships with mocked services.  
When you are ready to reconnect Firebase, follow the steps below.

## 1. Enable packages

1. In `pubspec.yaml`, uncomment the Firebase dependencies ( `firebase_core`, `firebase_auth`, `cloud_firestore` ).
2. Run `flutter pub get`.

## 2. Create Firebase projects

1. Visit [console.firebase.google.com](https://console.firebase.google.com) and create a new project (e.g., `learn-kyrgyz`).
2. Add Android and/or iOS apps:
   - Android: use your package id (e.g., `com.example.learnkyrgyz`). Download the generated `google-services.json` and place it under `android/app/`.
   - iOS: use your bundle id, download `GoogleService-Info.plist` and add it to `ios/Runner/`.

## 3. Configure FlutterFire

1. Install the CLI once: `dart pub global activate flutterfire_cli`.
2. From the project root, run `flutterfire configure` and select the Firebase project + platforms.  
   This command generates `firebase_options.dart` with API keys for each platform.
3. Import and initialize in `lib/main.dart`:

```dart
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(App());
}
```

## 4. Wire services

* **Authentication**  
  - Replace the mock `AuthRepository` methods with calls to `FirebaseAuth.instance.signInWithEmailAndPassword` / `createUserWithEmailAndPassword`.
  - Persist the logged-in user id and feed it to `ProgressProvider` for per-user stats.

* **Firestore data**  
  - Move the mock `FirebaseService` data into Firestore collections (e.g., `categories`, `words`, `progress`).
  - Update `fetchCategories()` and `fetchWordsByCategory()` to read snapshots from Firestore and cache them locally for offline use.

* **User progress**  
  - Instead of storing JSON in `SharedPreferences`, write documents under `users/{uid}/progress`.
  - Keep offline caching with `LocalStorageService` as a fallback or for guest mode.

## 5. Android + iOS build tweaks

* Android:
  - Ensure `android/build.gradle` and `android/app/build.gradle` still apply the `com.google.gms.google-services` plugin (already set in the template).
  - Confirm `minSdkVersion` meets the requirements of the latest Firebase SDKs (usually 21+).

* iOS:
  - Run `pod install` inside the `ios` directory after enabling Firebase packages.

## 6. Testing

* Use `flutterfire configure --project=<project-id>` to target staging/production.
* Run `flutter run` on each platform and monitor the logs for `Firebase`, `Auth`, and `Firestore` errors.
* Consider seeding Firestore with the word/category collections using the Firebase console or automated scripts before launching.

> **Note**: Keep the offline mocks handy. You can wrap Firebase calls in repositories and inject either the mock service or the live service depending on build flavor or a simple toggle.
