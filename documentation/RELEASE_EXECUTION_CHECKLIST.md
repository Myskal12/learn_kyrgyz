# Release Execution Checklist

This checklist is ordered by execution priority and reflects the current repository state.

## Phase 0: Baseline verification

- [x] flutter analyze passes
- [x] flutter test passes
- [x] flutter build apk --release passes
- [x] release preflight verifier added: `dart run tools/release/verify_release_readiness.dart`

## Phase 1: Technical release hardening

### 1. Android signing and app ID configuration

- [x] Add release signing support via android/key.properties
- [x] Add android/key.properties.example template
- [x] Fail release builds when key.properties is absent
- [x] Make applicationId configurable via Gradle property APP_ID
- [x] Fail release builds when APP_ID is still `com.example.*`
- [x] Fail release builds when `APP_ID` does not match `android/app/google-services.json`

How to finalize:

1. Copy android/key.properties.example to android/key.properties
2. Fill real keystore values
3. Download a Firebase Android config whose `package_name` matches the final app id
4. Verify locally:
   - dart run tools/release/verify_release_readiness.dart
5. Build with final app ID:
   - ./gradlew assembleRelease -PAPP_ID=com.yourcompany.learnkyrgyz
   - or `flutter build apk --release --dart-define=IGNORED` after exporting `ORG_GRADLE_PROJECT_APP_ID=com.yourcompany.learnkyrgyz`

### 2. iOS bundle ID configuration

- [x] Move bundle ID to xcconfig variable APP_BUNDLE_ID
- [x] Wire target PRODUCT_BUNDLE_IDENTIFIER to $(APP_BUNDLE_ID)
- [x] Fail iOS Release/Profile builds when APP_BUNDLE_ID is still `com.example.*`
- [x] Fail iOS Release/Profile builds when `ios/Runner/GoogleService-Info.plist` is missing

How to finalize:

1. Set APP_BUNDLE_ID in:
   - ios/Flutter/Debug.xcconfig
   - ios/Flutter/Release.xcconfig
2. Regenerate Firebase iOS config for final bundle ID
3. Add ios/Runner/GoogleService-Info.plist
4. Regenerate `lib/firebase_options.dart` for the final Apple bundle ID
5. Verify locally:
   - dart run tools/release/verify_release_readiness.dart

### 3. Demo-account removal from user flows

- [x] Remove demo login/register actions from onboarding, login, register
- [x] Remove hardcoded demo credentials class from source

## Phase 2: Content and data pipeline

### 1. Dataset quality gate

- [x] Add tools/firestore/validate_dataset.js
- [x] Add schema/consistency checks before generation/import

Run:

- node tools/firestore/validate_dataset.js --min 500

Current status:

- [x] Full dataset present (words.json contains 500 entries)

### 2. Collection generation and import safety

- [x] Strengthen tools/firestore/generate_collections.js validation
- [x] Add preflight consistency checks to tools/firestore/upload.js
- [x] Update tools/firestore/README.md with ordered workflow

Run after full dataset is ready:

1. node tools/firestore/validate_dataset.js --min 500
2. node tools/firestore/generate_collections.js
3. node tools/firestore/upload.js

Current status:

- [x] words/sentences/quiz generated locally (500/500/500)
- [x] firestore tooling dependencies installed (`firebase-admin`, `xlsx`)
- [ ] Firebase Admin credentials configured for uploader (`serviceAccountKey.json` or `FIREBASE_SERVICE_ACCOUNT_PATH` or `FIREBASE_SERVICE_ACCOUNT_JSON` or ADC)
- [ ] words/sentences/quiz uploaded to production Firebase

Blocker details:

- `node tools/firestore/upload.js` now supports file/env/ADC auth, but current environment is not configured for a target project (`Unable to detect a Project Id`).
- Configure one credential option and set `FIREBASE_PROJECT_ID` (or `GOOGLE_CLOUD_PROJECT`) if project ID is not auto-detected.

## Phase 3: Product completeness and release gate

- [ ] Fill production Firestore data for words/sentences/quiz
- [ ] Verify sentence-builder has no empty states for core categories
- [ ] Verify quiz has no empty states for core categories
- [x] Configure Firestore security rules in repository
- [ ] Add iOS Firebase plist and verify iOS auth flows
- [ ] Run full manual smoke test on at least 2 Android devices
- [ ] Run final release smoke test and publish artifacts

## Final done criteria

Project is 100% release-ready only when all unchecked items above are completed.
