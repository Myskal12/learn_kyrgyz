const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const DEFAULT_SOURCE = 'words.json';
const DEFAULT_MAX_PER_CATEGORY = 10;
const DEFAULT_FAKE_USERS = 24;

const OUTPUT_WORDS = path.resolve(__dirname, 'words.demo.json');
const OUTPUT_SENTENCES = path.resolve(__dirname, 'sentences.demo.json');
const OUTPUT_QUIZ = path.resolve(__dirname, 'quiz.demo.json');
const OUTPUT_USERS = path.resolve(__dirname, 'users.demo.json');

const CATEGORY_ORDER = [
    'basic',
    'family',
    'food',
    'nature',
    'animals',
    'travel',
    'education',
    'time',
    'place',
    'emotion',
    'clothes',
    'transport',
    'color',
    'number',
    'technology',
    'sport',
    'verbs',
    'adjectives',
    'health',
    'work',
    'weather',
];

const AVATAR_POOL = [
    'assets/images/photo_1_2026-04-10_18-59-53.jpg',
    'assets/images/photo_2_2026-04-10_18-59-53.jpg',
    'assets/images/photo_3_2026-04-10_18-59-53.jpg',
    'assets/images/photo_4_2026-04-10_18-59-53.jpg',
];

const NAME_POOL = [
    'Aruzhan',
    'Bekzat',
    'Nurai',
    'Tilek',
    'Aigerim',
    'Emir',
    'Saniya',
    'Nursultan',
    'Amina',
    'Askar',
    'Elmira',
    'Rinat',
    'Aibek',
    'Dana',
    'Meder',
    'Samat',
    'Mira',
    'Timur',
    'Nurgul',
    'Azamat',
    'Kamila',
    'Arsen',
    'Madina',
    'Adilet',
    'Ayal',
    'Kairat',
    'Sezim',
    'Ruslan',
    'Aliya',
    'Mirlan',
];

function getArgValue(name) {
    const index = process.argv.indexOf(name);
    if (index >= 0 && process.argv[index + 1]) {
        return process.argv[index + 1];
    }

    const match = process.argv.find((item) => item.startsWith(`${name}=`));
    if (!match) return null;
    const [, value] = match.split('=');
    return value ?? null;
}

function parsePositiveInteger(raw, fallback, label) {
    if (raw == null || raw === '') return fallback;
    const parsed = Number.parseInt(raw, 10);
    if (!Number.isInteger(parsed) || parsed < 1) {
        throw new Error(`Invalid ${label}: ${raw}`);
    }
    return parsed;
}

function loadWords(sourceFile) {
    const filePath = path.isAbsolute(sourceFile)
        ? sourceFile
        : path.resolve(__dirname, sourceFile);

    if (!fs.existsSync(filePath)) {
        throw new Error(`Source file not found: ${filePath}`);
    }

    const raw = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    if (!Array.isArray(raw)) {
        throw new Error('Source dataset must be a JSON array.');
    }

    const normalized = [];
    for (let i = 0; i < raw.length; i += 1) {
        const item = raw[i];
        if (typeof item !== 'object' || item == null || Array.isArray(item)) {
            continue;
        }

        const id = String(item.id ?? '').trim();
        const en = String(item.en ?? '').trim();
        const ky = String(item.ky ?? '').trim();
        const category = String(item.category ?? '').trim().toLowerCase();
        const levelRaw = Number.parseInt(String(item.level ?? '1'), 10);
        const level = Number.isInteger(levelRaw) && levelRaw > 0 ? levelRaw : 1;

        if (!id || !en || !ky || !category) {
            continue;
        }

        if (!isUsableTranslation(en, ky)) {
            continue;
        }

        normalized.push({
            id,
            en,
            ky,
            level,
            category,
            transcription_en: stringOrUndefined(item.transcription_en),
            transcription_ky: stringOrUndefined(item.transcription_ky),
        });
    }

    return dedupeById(normalized);
}

function stringOrUndefined(value) {
    const text = String(value ?? '').trim();
    return text ? text : undefined;
}

function isUsableTranslation(en, ky) {
    const enLower = en.toLowerCase();
    const kyLower = ky.toLowerCase();
    if (!kyLower) return false;
    if (kyLower === 'todo_translation') return false;
    if (kyLower === enLower) return false;
    return true;
}

function dedupeById(words) {
    const used = new Set();
    const result = [];
    for (const word of words) {
        if (used.has(word.id)) continue;
        used.add(word.id);
        result.push(word);
    }
    return result;
}

function categorySortKey(category) {
    const known = CATEGORY_ORDER.indexOf(category);
    return known === -1 ? 10_000 : known;
}

function buildDemoWords(words, maxPerCategory) {
    const groups = new Map();
    for (const word of words) {
        const list = groups.get(word.category) ?? [];
        list.push(word);
        groups.set(word.category, list);
    }

    const categories = Array.from(groups.keys()).sort((a, b) => {
        const keyCompare = categorySortKey(a) - categorySortKey(b);
        if (keyCompare !== 0) return keyCompare;
        return a.localeCompare(b);
    });

    const selected = [];
    for (const category of categories) {
        const list = groups.get(category);
        list.sort((a, b) => {
            const levelCompare = a.level - b.level;
            if (levelCompare !== 0) return levelCompare;
            return a.id.localeCompare(b.id);
        });

        selected.push(...list.slice(0, maxPerCategory));
    }

    selected.sort((a, b) => {
        const categoryCompare = categorySortKey(a.category) - categorySortKey(b.category);
        if (categoryCompare !== 0) return categoryCompare;
        const fallbackCategoryCompare = a.category.localeCompare(b.category);
        if (fallbackCategoryCompare !== 0) return fallbackCategoryCompare;
        const levelCompare = a.level - b.level;
        if (levelCompare !== 0) return levelCompare;
        return a.id.localeCompare(b.id);
    });

    return selected;
}

function buildSentences(words) {
    return words.map((word) => ({
        id: `sent_${word.id}`,
        en: `This is ${word.en}`,
        ky: `Бул ${word.ky}`,
        highlight: word.en,
        word_en: word.en,
        word_ky: word.ky,
        wordId: word.id,
        level: word.level,
        category: word.category,
    }));
}

function pickWrongOptions(word, sameCategoryWords, allWords) {
    const options = new Set();

    const categoryPool = sameCategoryWords
        .map((item) => item.ky)
        .filter((value) => value !== word.ky);
    shuffleInPlace(categoryPool);

    for (const candidate of categoryPool) {
        if (options.size >= 3) break;
        options.add(candidate);
    }

    if (options.size < 3) {
        const globalPool = allWords
            .map((item) => item.ky)
            .filter((value) => value !== word.ky);
        shuffleInPlace(globalPool);
        for (const candidate of globalPool) {
            if (options.size >= 3) break;
            options.add(candidate);
        }
    }

    while (options.size < 3) {
        options.add(word.ky);
    }

    return Array.from(options).slice(0, 3);
}

function buildQuiz(words) {
    const byCategory = new Map();
    for (const word of words) {
        const list = byCategory.get(word.category) ?? [];
        list.push(word);
        byCategory.set(word.category, list);
    }

    return words.map((word) => {
        const sameCategoryWords = byCategory.get(word.category) ?? [];
        const wrong = pickWrongOptions(word, sameCategoryWords, words);
        const options = [word.ky, ...wrong];
        shuffleInPlace(options);

        return {
            id: `quiz_${word.id}`,
            type: 'choose_translation',
            question: word.en,
            correct: word.ky,
            options,
            level: word.level,
            category: word.category,
            wordId: word.id,
        };
    });
}

function buildFakeUsers(count) {
    const users = [];
    for (let i = 0; i < count; i += 1) {
        const rankFactor = count - i;
        const totalXp = 450 + (rankFactor * 95) + randomInt(0, 90);
        const totalMastered = Math.max(12, Math.floor(totalXp / 30) + randomInt(-5, 8));
        const totalSessions = Math.max(10, Math.floor(totalMastered * 1.4) + randomInt(0, 24));
        const accuracy = Math.min(99, Math.max(62, 68 + Math.floor(rankFactor / 2) + randomInt(-8, 10)));
        const streakDays = Math.max(1, Math.floor(rankFactor / 2) + randomInt(0, 8));

        const avatar = AVATAR_POOL[i % AVATAR_POOL.length];

        users.push({
            id: `demo_user_${String(i + 1).padStart(3, '0')}`,
            nickname: `${NAME_POOL[i % NAME_POOL.length]} ${i + 1}`,
            avatar,
            avatarProfile: {
                type: 'preset_asset',
                value: avatar,
            },
            totalMastered,
            totalSessions,
            accuracy,
            totalXp,
            streakDays,
            isDemo: true,
        });
    }

    users.sort((a, b) => b.totalXp - a.totalXp);
    return users;
}

function randomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function shuffleInPlace(items) {
    for (let i = items.length - 1; i > 0; i -= 1) {
        const j = Math.floor(Math.random() * (i + 1));
        [items[i], items[j]] = [items[j], items[i]];
    }
}

function summarizeByCategory(words) {
    const counts = new Map();
    for (const word of words) {
        counts.set(word.category, (counts.get(word.category) ?? 0) + 1);
    }
    return Array.from(counts.entries()).sort((a, b) => a[0].localeCompare(b[0]));
}

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
        throw new Error(`${sourceLabel} must be a valid JSON file. ${error.message}`);
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
        throw new Error(`FIREBASE_SERVICE_ACCOUNT_JSON must contain valid JSON. ${error.message}`);
    }

    if (!isServiceAccountLike(parsed)) {
        throw new Error('FIREBASE_SERVICE_ACCOUNT_JSON is missing client_email/private_key.');
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

async function clearCollection(db, collectionName, pageSize = 400) {
    let totalDeleted = 0;
    while (true) {
        const snapshot = await db.collection(collectionName).limit(pageSize).get();
        if (snapshot.empty) {
            return totalDeleted;
        }

        const batch = db.batch();
        snapshot.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
        totalDeleted += snapshot.size;

        if (snapshot.size < pageSize) {
            return totalDeleted;
        }
    }
}

async function uploadDocs(db, collectionName, docs, addUserTimestamps = false) {
    let batch = db.batch();
    let pending = 0;
    let written = 0;

    for (const doc of docs) {
        const docId = String(doc.id ?? '').trim();
        if (!docId) {
            throw new Error(`Document without id in ${collectionName}`);
        }

        const payload = { ...doc };
        if (addUserTimestamps) {
            payload.updatedAt = admin.firestore.FieldValue.serverTimestamp();
            payload.createdAt = admin.firestore.FieldValue.serverTimestamp();
        }

        const ref = db.collection(collectionName).doc(docId);
        batch.set(ref, payload, { merge: false });
        pending += 1;
        written += 1;

        if (pending >= 400) {
            await batch.commit();
            batch = db.batch();
            pending = 0;
        }
    }

    if (pending > 0) {
        await batch.commit();
    }

    return written;
}

async function main() {
    const source = getArgValue('--source') ?? DEFAULT_SOURCE;
    const maxPerCategory = parsePositiveInteger(
        getArgValue('--max-per-category'),
        DEFAULT_MAX_PER_CATEGORY,
        '--max-per-category',
    );
    const fakeUsersCount = parsePositiveInteger(
        getArgValue('--fake-users'),
        DEFAULT_FAKE_USERS,
        '--fake-users',
    );

    const dryRun = process.argv.includes('--dry-run');
    const keepAppConfig = process.argv.includes('--keep-app-config');

    const sourceWords = loadWords(source);
    const demoWords = buildDemoWords(sourceWords, maxPerCategory);

    if (demoWords.length < 4) {
        throw new Error(
            `Demo dataset is too small (${demoWords.length} words). Need at least 4 valid words.`,
        );
    }

    const demoSentences = buildSentences(demoWords);
    const demoQuiz = buildQuiz(demoWords);
    const fakeUsers = buildFakeUsers(fakeUsersCount);

    fs.writeFileSync(OUTPUT_WORDS, JSON.stringify(demoWords, null, 2), 'utf8');
    fs.writeFileSync(OUTPUT_SENTENCES, JSON.stringify(demoSentences, null, 2), 'utf8');
    fs.writeFileSync(OUTPUT_QUIZ, JSON.stringify(demoQuiz, null, 2), 'utf8');
    fs.writeFileSync(OUTPUT_USERS, JSON.stringify(fakeUsers, null, 2), 'utf8');

    console.log(`Prepared demo files:`);
    console.log(`- ${OUTPUT_WORDS}`);
    console.log(`- ${OUTPUT_SENTENCES}`);
    console.log(`- ${OUTPUT_QUIZ}`);
    console.log(`- ${OUTPUT_USERS}`);
    console.log(`Words: ${demoWords.length}`);
    console.log(`Sentences: ${demoSentences.length}`);
    console.log(`Quiz: ${demoQuiz.length}`);
    console.log(`Fake users: ${fakeUsers.length}`);
    console.log('Category distribution:');
    for (const [category, count] of summarizeByCategory(demoWords)) {
        console.log(`- ${category}: ${count}`);
    }

    if (dryRun) {
        console.log('Dry run enabled. Skipping Firestore reset/upload.');
        return;
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
    const collectionsToClear = keepAppConfig
        ? ['userProgress', 'users', 'quiz', 'sentences', 'words']
        : ['userProgress', 'users', 'quiz', 'sentences', 'words', 'app_config'];

    for (const name of collectionsToClear) {
        // eslint-disable-next-line no-await-in-loop
        const removed = await clearCollection(db, name);
        console.log(`Cleared ${name}: ${removed} docs`);
    }

    const wordsWritten = await uploadDocs(db, 'words', demoWords);
    const sentencesWritten = await uploadDocs(db, 'sentences', demoSentences);
    const quizWritten = await uploadDocs(db, 'quiz', demoQuiz);
    const usersWritten = await uploadDocs(db, 'users', fakeUsers, true);

    console.log('Upload completed:');
    console.log(`- words: ${wordsWritten}`);
    console.log(`- sentences: ${sentencesWritten}`);
    console.log(`- quiz: ${quizWritten}`);
    console.log(`- users: ${usersWritten}`);
}

main().catch((error) => {
    console.error(`Demo reset/seed failed: ${error.message}`);
    if (/unable to detect a project id/i.test(error.message)) {
        console.error(
            'If you are using ADC, set FIREBASE_PROJECT_ID (or GOOGLE_CLOUD_PROJECT) to your Firebase project id.',
        );
    }
    process.exit(1);
});
