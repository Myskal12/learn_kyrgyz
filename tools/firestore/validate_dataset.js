const fs = require('fs');
const path = require('path');

const WORDS_FILE = path.resolve(__dirname, 'words.json');

function parseMinWordsArg() {
    const args = process.argv.slice(2);
    for (let i = 0; i < args.length; i += 1) {
        const arg = args[i];
        if (arg === '--min' && args[i + 1]) {
            return Number.parseInt(args[i + 1], 10);
        }
        if (arg.startsWith('--min=')) {
            return Number.parseInt(arg.split('=')[1], 10);
        }
    }
    return 500;
}

function isNonEmptyString(value) {
    return typeof value === 'string' && value.trim().length > 0;
}

function loadWords() {
    if (!fs.existsSync(WORDS_FILE)) {
        throw new Error(`words.json not found in ${__dirname}`);
    }

    const raw = fs.readFileSync(WORDS_FILE, 'utf8');
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) {
        throw new Error('words.json must contain a JSON array.');
    }

    return parsed;
}

function validateWords(words, minWords) {
    const errors = [];
    const warnings = [];
    const seenIds = new Set();
    const seenEnglish = new Set();
    const categoryStats = new Map();

    if (words.length < minWords) {
        errors.push(
            `Expected at least ${minWords} entries, but got ${words.length}.`,
        );
    }

    words.forEach((word, index) => {
        const label = `index ${index}`;

        if (typeof word !== 'object' || word === null || Array.isArray(word)) {
            errors.push(`${label}: item must be an object.`);
            return;
        }

        const id = word.id;
        const en = word.en;
        const ky = word.ky;
        const level = word.level;
        const category = word.category;

        if (!isNonEmptyString(id)) {
            errors.push(`${label}: field id is required.`);
        } else {
            const normalizedId = id.trim();
            if (!/^[a-z0-9_-]+$/i.test(normalizedId)) {
                warnings.push(`${label}: id "${normalizedId}" should use slug format.`);
            }
            if (seenIds.has(normalizedId)) {
                errors.push(`${label}: duplicate id "${normalizedId}".`);
            }
            seenIds.add(normalizedId);
        }

        if (!isNonEmptyString(en)) {
            errors.push(`${label}: field en is required.`);
        } else {
            const normalizedEn = en.trim().toLowerCase();
            if (seenEnglish.has(normalizedEn)) {
                warnings.push(`${label}: duplicate English word "${en.trim()}".`);
            }
            seenEnglish.add(normalizedEn);
        }

        if (!isNonEmptyString(ky)) {
            errors.push(`${label}: field ky is required.`);
        }

        if (!Number.isInteger(level) || level < 1) {
            errors.push(`${label}: field level must be an integer >= 1.`);
        }

        if (!isNonEmptyString(category)) {
            errors.push(`${label}: field category is required.`);
        } else {
            const normalizedCategory = category.trim();
            const current = categoryStats.get(normalizedCategory) ?? 0;
            categoryStats.set(normalizedCategory, current + 1);
            if (!/^[a-z0-9_-]+$/i.test(normalizedCategory)) {
                warnings.push(
                    `${label}: category "${normalizedCategory}" should use slug format.`,
                );
            }
        }

        if (
            Object.prototype.hasOwnProperty.call(word, 'transcription_en') &&
            word.transcription_en != null &&
            typeof word.transcription_en !== 'string'
        ) {
            errors.push(`${label}: transcription_en must be a string when present.`);
        }

        if (
            Object.prototype.hasOwnProperty.call(word, 'transcription_ky') &&
            word.transcription_ky != null &&
            typeof word.transcription_ky !== 'string'
        ) {
            errors.push(`${label}: transcription_ky must be a string when present.`);
        }
    });

    return { errors, warnings, categoryStats };
}

function printSummary(words, categoryStats, warnings) {
    console.log(`Words entries: ${words.length}`);
    console.log(`Unique categories: ${categoryStats.size}`);
    console.log('Category distribution:');

    const sorted = Array.from(categoryStats.entries()).sort((a, b) =>
        a[0].localeCompare(b[0]),
    );
    for (const [category, count] of sorted) {
        console.log(`- ${category}: ${count}`);
    }

    if (warnings.length > 0) {
        console.log('\nWarnings:');
        warnings.forEach((warning) => console.log(`- ${warning}`));
    }
}

function main() {
    const minWords = parseMinWordsArg();
    if (!Number.isInteger(minWords) || minWords < 1) {
        throw new Error('Invalid --min value. Use a positive integer.');
    }

    const words = loadWords();
    const { errors, warnings, categoryStats } = validateWords(words, minWords);

    if (errors.length > 0) {
        console.error('Dataset validation failed:');
        errors.forEach((error) => console.error(`- ${error}`));
        process.exit(1);
    }

    printSummary(words, categoryStats, warnings);
    console.log('\nValidation succeeded. Dataset is ready for generation/import.');
}

main();
