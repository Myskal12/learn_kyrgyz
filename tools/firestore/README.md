# Firestore bulk data

This folder contains helper scripts to prepare and upload the 500 words / sentences / quiz documents described in the requirements.

## Files

- `words.json` – master list of words (English ↔ Kyrgyz, level, category). Supply 500 entries here.
- `generate_collections.js` – generates `sentences.json` and `quiz.json` from `words.json`.
- `upload.js` – pushes `words.json`, `sentences.json` and `quiz.json` to Firestore using a service account.
- `words.sample.json` – short example showing the expected structure (replace with your full data set).

## Workflow

1. Copy your Firebase service account file into this folder and name it `serviceAccountKey.json`.
2. Replace `words.json` with your own 500-entry data (or start from `words.sample.json`).
3. Install dependencies:
   ```bash
   cd tools/firestore
   npm init -y
   npm install firebase-admin
   ```
4. Generate the linked collections:
   ```bash
   node generate_collections.js
   ```
   This produces `sentences.json` and `quiz.json` with the same document count as `words.json`.
5. Upload everything to Firestore:
   ```bash
   node upload.js
   ```

Both scripts are idempotent: rerunning them overwrites the same documents by document ID. Use a staging project if you want to inspect the generated content first.
