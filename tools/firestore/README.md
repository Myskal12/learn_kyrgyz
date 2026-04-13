# Firestore bulk data

This folder contains helper scripts to prepare and upload the 500 words / sentences / quiz documents described in the requirements.

## Files

- `words.json` – master list of words (English ↔ Kyrgyz, level, category). Supply 500 entries here.
- `words_sources/*.json` – editable source shards for collaborative vocabulary curation.
- `build_words_dataset.js` – builds `words.json` from `words_sources/*.json` with dedupe/normalization.
- `create_draft_batch.js` – generates a large draft shard for missing categories (`ready: false`).
- `create_draft_batch_02.js` – generates a second draft shard that matches remaining per-category target gaps.
- `import_words_source.js` – imports `.csv` / `.xlsx` / `.xls` into a new source shard in `words_sources`.
- `export_drafts_for_translation.js` – exports all draft entries to a translator-friendly CSV.
- `apply_translation_updates.js` – applies translated rows back into existing shards by `id`.
- `validate_dataset.js` – validates required schema, uniqueness, and minimum dataset size.
- `generate_collections.js` – generates `sentences.json` and `quiz.json` from `words.json`.
- `upload.js` – pushes `words.json`, `sentences.json`, `quiz.json`, and optional `app_config.json` to Firestore using Firebase Admin credentials (service account file/env JSON/ADC).
- `reset_seed_demo_data.js` – clears Firestore demo collections, builds capped demo data (default: max 10 words per category), generates quiz/sentences, and seeds fake leaderboard users.
- `words.sample.json` – short example showing the expected structure (replace with your full data set).
- `app_config.sample.json` – optional sample for dynamic app config documents (`onboarding`, `achievements`, `resources`).
- `dataset_targets.json` – target totals and per-category minimums for production dataset planning.
- `dataset_progress.js` – reports gap to target (overall and by category).

## Workflow

1. Configure Firebase Admin credentials (pick one):
   - Put a key file at `tools/firestore/serviceAccountKey.json`
   - Set `FIREBASE_SERVICE_ACCOUNT_PATH` to a key JSON path
   - Set `FIREBASE_SERVICE_ACCOUNT_JSON` to the key JSON string
   - Use Application Default Credentials (ADC) via `GOOGLE_APPLICATION_CREDENTIALS` or `gcloud auth application-default login`
   - If project id is not auto-detected (ADC path), also set `FIREBASE_PROJECT_ID` (or `GOOGLE_CLOUD_PROJECT`)
2. Add/edit vocabulary in `words_sources/*.json` (seed data is included in `words_sources/core_from_app.json`).
3. (Optional) Create a large draft batch for missing categories:
   ```bash
   node create_draft_batch.js
   ```
4. (Optional) Create a second draft batch for the remaining category gaps:
   ```bash
   node create_draft_batch_02.js
   ```
   This generates `words_sources/batch_02_target_gap_draft.json`.
5. (Optional) Import translator spreadsheet as source shard:
   ```bash
   node import_words_source.js --input ./incoming_words.csv --default-ready false
   ```
   Excel import example:
   ```bash
   node import_words_source.js --input ./incoming_words.xlsx --sheet Sheet1 --default-ready false
   ```
   Supported columns: `id` (optional), `en`, `ky`, `category`, `level` (optional), `ready` (optional), `transcription_en` (optional), `transcription_ky` (optional), `notes` (optional).
6. (Optional) Translation cycle for existing drafts:
   - Export drafts for translators:
     ```bash
     node export_drafts_for_translation.js
     ```
     Default output: `tools/firestore/translation/drafts_for_translation.csv`
   - After translators fill `ky` (and optionally `ready`), apply updates:
     ```bash
     node apply_translation_updates.js --input ./tools/firestore/translation/drafts_for_translation.csv
     ```
     Excel input is also supported (`.xlsx` / `.xls`) with optional `--sheet`.
7. Build `words.json` from source shards:
   ```bash
   node build_words_dataset.js
   ```
8. Track dataset gap against the target plan:
   ```bash
   node dataset_progress.js
   ```
9. Validate dataset quality and size before generation:
   ```bash
   node validate_dataset.js --min 500
   ```
   Validation checks:
   - required fields (`id`, `en`, `ky`, `level`, `category`)
   - unique ids
   - category distribution and duplicate warnings
10. Install dependencies:
   ```bash
   cd tools/firestore
   npm init -y
   npm install firebase-admin xlsx
   ```
11. Generate the linked collections:
   ```bash
   node generate_collections.js
   ```
   This produces `sentences.json` and `quiz.json` with the same document count as `words.json`.
12. (Optional) Enable dynamic app configuration:
   - Copy `app_config.sample.json` to `app_config.json`.
   - Edit `app_config.json` values for onboarding goals, achievements, and resources.
13. Upload everything to Firestore:
   ```bash
   node upload.js
   ```

   Example with explicit service account path (PowerShell):
   ```powershell
   $env:FIREBASE_SERVICE_ACCOUNT_PATH = "C:\\secrets\\serviceAccountKey.json"
   node upload.js
   ```

If `app_config.json` is present, `upload.js` writes each item to the `app_config` collection using its `id` as the document id.

`upload.js` now validates payload consistency before uploading:

- words/sentences counts must match
- words/quiz counts must match
- empty or missing files are skipped with explicit logs

Both scripts are idempotent: rerunning them overwrites the same documents by document ID. Use a staging project if you want to inspect the generated content first.

## Investor Demo Reset + Seed

Use this workflow when you want a clean Firebase dataset for demos:

1. Preview what will be generated (no Firebase writes):
   ```bash
   npm run demo:seed:dry
   ```
2. Reset Firestore and upload fresh demo data:
   ```bash
   npm run demo:seed
   ```

Defaults:

- max words per category: `10`
- fake leaderboard users: `24`
- fake users use preset image avatars only (no emoji)
- each fake user contains both `avatar` and `avatarProfile` (`{ type, value }`)
- source input: `words.json`
- collections cleared: `userProgress`, `users`, `quiz`, `sentences`, `words`, `app_config`

Optional flags:

```bash
node reset_seed_demo_data.js --max-per-category 10 --fake-users 30 --source words.json
```

Keep existing `app_config` documents:

```bash
node reset_seed_demo_data.js --keep-app-config
```
