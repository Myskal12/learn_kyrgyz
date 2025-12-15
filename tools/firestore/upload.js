const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const serviceAccountPath = path.resolve(__dirname, 'serviceAccountKey.json');
if (!fs.existsSync(serviceAccountPath)) {
  throw new Error('serviceAccountKey.json missing. Download it from Firebase Console.');
}

admin.initializeApp({
  credential: admin.credential.cert(require(serviceAccountPath)),
});

const db = admin.firestore();

const fileMap = [
  { file: 'words.json', collection: 'words' },
  { file: 'sentences.json', collection: 'sentences' },
  { file: 'quiz.json', collection: 'quiz' },
];

async function uploadCollection(target) {
  const fullPath = path.resolve(__dirname, target.file);
  if (!fs.existsSync(fullPath)) {
    console.warn(`Skip ${target.file} – file not found.`);
    return;
  }
  const data = JSON.parse(fs.readFileSync(fullPath, 'utf8'));
  if (!Array.isArray(data) || data.length === 0) {
    console.warn(`Skip ${target.file} – no data.`);
    return;
  }
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
  for (const entry of fileMap) {
    // eslint-disable-next-line no-await-in-loop
    await uploadCollection(entry);
  }
  process.exit(0);
})();
