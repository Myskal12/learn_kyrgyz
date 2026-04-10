const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

function isServiceAccountLike(value) {
  return (
    value &&
    typeof value === 'object' &&
    typeof value.client_email === 'string' &&
    typeof value.private_key === 'string'
  );
}

function readServiceAccountFromFile(filePath, sourceLabel) {
  if (!filePath) {
    return null;
  }

  const absolutePath = path.isAbsolute(filePath)
    ? filePath
    : path.resolve(__dirname, filePath);

  if (!fs.existsSync(absolutePath)) {
    throw new Error(`${sourceLabel} points to a missing file: ${absolutePath}`);
  }

  let parsed;
  try {
    parsed = JSON.parse(fs.readFileSync(absolutePath, 'utf8'));
  } catch (error) {
    throw new Error(
      `${sourceLabel} must be a valid JSON file. ${error.message}`,
    );
  }

  if (!isServiceAccountLike(parsed)) {
    throw new Error(
      `${sourceLabel} is not a Firebase Admin service account JSON (missing client_email/private_key).`,
    );
  }

  return {
    credential: admin.credential.cert(parsed),
    source: `${sourceLabel} (${absolutePath})`,
    projectId: parsed.project_id,
  };
}

function readServiceAccountFromEnvJson() {
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (!raw) {
    return null;
  }

  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch (error) {
    throw new Error(
      `FIREBASE_SERVICE_ACCOUNT_JSON must contain valid JSON. ${error.message}`,
    );
  }

  if (!isServiceAccountLike(parsed)) {
    throw new Error(
      'FIREBASE_SERVICE_ACCOUNT_JSON is missing client_email/private_key.',
    );
  }

  return {
    credential: admin.credential.cert(parsed),
    source: 'FIREBASE_SERVICE_ACCOUNT_JSON',
    projectId: parsed.project_id,
  };
}

function resolveFirebaseAuthConfig() {
  const fromEnvJson = readServiceAccountFromEnvJson();
  if (fromEnvJson) {
    return fromEnvJson;
  }

  const fromEnvPath = readServiceAccountFromFile(
    process.env.FIREBASE_SERVICE_ACCOUNT_PATH,
    'FIREBASE_SERVICE_ACCOUNT_PATH',
  );
  if (fromEnvPath) {
    return fromEnvPath;
  }

  const fromGoogleCredentials = readServiceAccountFromFile(
    process.env.GOOGLE_APPLICATION_CREDENTIALS,
    'GOOGLE_APPLICATION_CREDENTIALS',
  );
  if (fromGoogleCredentials) {
    return fromGoogleCredentials;
  }

  const localServiceAccountPath = path.resolve(__dirname, 'serviceAccountKey.json');
  if (fs.existsSync(localServiceAccountPath)) {
    return readServiceAccountFromFile(localServiceAccountPath, 'serviceAccountKey.json');
  }

  return {
    credential: admin.credential.applicationDefault(),
    source: 'Application Default Credentials (ADC)',
    projectId:
      process.env.FIREBASE_PROJECT_ID ||
      process.env.GOOGLE_CLOUD_PROJECT ||
      process.env.GCLOUD_PROJECT,
  };
}

const firebaseAuthConfig = resolveFirebaseAuthConfig();
const appOptions = {
  credential: firebaseAuthConfig.credential,
};

if (firebaseAuthConfig.projectId) {
  appOptions.projectId = firebaseAuthConfig.projectId;
}

admin.initializeApp(appOptions);
console.log(`Firebase auth source: ${firebaseAuthConfig.source}`);

const db = admin.firestore();

const fileMap = [
  { file: 'words.json', collection: 'words' },
  { file: 'sentences.json', collection: 'sentences' },
  { file: 'quiz.json', collection: 'quiz' },
  { file: 'app_config.json', collection: 'app_config' },
];

function loadJsonArray(fileName) {
  const fullPath = path.resolve(__dirname, fileName);
  if (!fs.existsSync(fullPath)) {
    console.warn(`Skip ${fileName} - file not found.`);
    return null;
  }

  const payload = JSON.parse(fs.readFileSync(fullPath, 'utf8'));
  if (!Array.isArray(payload) || payload.length === 0) {
    console.warn(`Skip ${fileName} - no data.`);
    return null;
  }

  return payload;
}

async function uploadCollection(target, data) {
  console.log(`Uploading ${data.length} docs to ${target.collection}...`);
  let batch = db.batch();
  let batchCount = 0;
  for (let i = 0; i < data.length; i += 1) {
    const docId = data[i].id ?? undefined;
    const ref = docId
      ? db.collection(target.collection).doc(docId)
      : db.collection(target.collection).doc();
    batch.set(ref, data[i], { merge: true });
    batchCount += 1;
    if (batchCount === 450) {
      await batch.commit();
      batch = db.batch();
      batchCount = 0;
    }
  }
  if (batchCount > 0) {
    await batch.commit();
  }
  console.log(`Done: ${target.collection}`);
}

(async () => {
  try {
    const payloads = new Map();
    for (const entry of fileMap) {
      const payload = loadJsonArray(entry.file);
      if (payload) {
        payloads.set(entry.collection, payload);
      }
    }

    const words = payloads.get('words');
    const sentences = payloads.get('sentences');
    const quiz = payloads.get('quiz');

    if (words && sentences && words.length !== sentences.length) {
      throw new Error(
        `words (${words.length}) and sentences (${sentences.length}) counts do not match.`,
      );
    }

    if (words && quiz && words.length !== quiz.length) {
      throw new Error(
        `words (${words.length}) and quiz (${quiz.length}) counts do not match.`,
      );
    }

    for (const entry of fileMap) {
      const payload = payloads.get(entry.collection);
      if (!payload) continue;
      // eslint-disable-next-line no-await-in-loop
      await uploadCollection(entry, payload);
    }
    process.exit(0);
  } catch (error) {
    console.error(`Upload failed: ${error.message}`);
    if (/unable to detect a project id/i.test(error.message)) {
      console.error(
        'If you are using ADC, set FIREBASE_PROJECT_ID (or GOOGLE_CLOUD_PROJECT) to your Firebase project id.',
      );
    }
    console.error(
      'Provide Firebase Admin credentials via one of: serviceAccountKey.json, FIREBASE_SERVICE_ACCOUNT_PATH, FIREBASE_SERVICE_ACCOUNT_JSON, or ADC (GOOGLE_APPLICATION_CREDENTIALS / gcloud auth application-default login).',
    );
    process.exit(1);
  }
})();
