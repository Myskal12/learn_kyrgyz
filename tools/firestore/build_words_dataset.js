const fs = require('fs');
const path = require('path');

const SOURCE_DIR = path.resolve(__dirname, 'words_sources');
const OUTPUT_FILE = path.resolve(__dirname, 'words.json');

function isNonEmptyString(value) {
    return typeof value === 'string' && value.trim().length > 0;
}

function slugify(value) {
    return value
        .toString()
        .trim()
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '_')
        .replace(/^_+|_+$/g, '');
}

function parseBool(value, fallback = true) {
    if (typeof value === 'boolean') return value;
    if (typeof value === 'number') return value !== 0;
    if (typeof value === 'string') {
        const normalized = value.trim().toLowerCase();
        if (['false', '0', 'no', 'n', 'off'].includes(normalized)) {
            return false;
        }
        if (['true', '1', 'yes', 'y', 'on'].includes(normalized)) {
            return true;
        }
    }
    return fallback;
}

function isReady(word) {
    const status = isNonEmptyString(word?.status)
        ? word.status.trim().toLowerCase()
        : null;
    if (status === 'draft') {
        return false;
    }

    if (Object.prototype.hasOwnProperty.call(word, 'ready')) {
        return parseBool(word.ready, true);
    }

    return true;
}

function readSourceFiles() {
    if (!fs.existsSync(SOURCE_DIR)) {
        throw new Error(`Source folder not found: ${SOURCE_DIR}`);
    }

    const files = fs
        .readdirSync(SOURCE_DIR)
        .filter((name) => name.toLowerCase().endsWith('.json'))
        .sort((a, b) => a.localeCompare(b));

    if (files.length === 0) {
        throw new Error(`No source json files found in ${SOURCE_DIR}`);
    }

    return files;
}

function normalizeWord(word, fileName, index, allowMissingKy) {
    const label = `${fileName}[${index}]`;
    if (typeof word !== 'object' || word == null || Array.isArray(word)) {
        throw new Error(`${label} must be an object`);
    }

    if (!isNonEmptyString(word.en)) {
        throw new Error(`${label}.en is required`);
    }
    if (!isNonEmptyString(word.category)) {
        throw new Error(`${label}.category is required`);
    }

    const id = isNonEmptyString(word.id)
        ? word.id.trim()
        : slugify(word.en ?? `word_${index}`);
    if (!isNonEmptyString(id)) {
        throw new Error(`${label}.id is required`);
    }

    const ky = isNonEmptyString(word.ky) ? word.ky.trim() : '';
    if (!allowMissingKy && !isNonEmptyString(ky)) {
        throw new Error(`${label}.ky is required for ready entries`);
    }

    const level = Number.isInteger(word.level) && word.level > 0 ? word.level : 1;

    return {
        id,
        en: word.en.trim(),
        ky,
        transcription_en: isNonEmptyString(word.transcription_en)
            ? word.transcription_en.trim()
            : undefined,
        transcription_ky: isNonEmptyString(word.transcription_ky)
            ? word.transcription_ky.trim()
            : undefined,
        notes: isNonEmptyString(word.notes) ? word.notes.trim() : undefined,
        level,
        category: word.category.trim().toLowerCase(),
        ready: isReady(word),
    };
}

function buildDataset(includeDrafts) {
    const files = readSourceFiles();
    const dataset = [];
    const ids = new Set();
    const summary = {
        sourceEntries: 0,
        readyEntries: 0,
        draftEntries: 0,
        skippedDrafts: 0,
        includedDrafts: 0,
    };

    for (const fileName of files) {
        const filePath = path.resolve(SOURCE_DIR, fileName);
        const raw = fs.readFileSync(filePath, 'utf8');
        const parsed = JSON.parse(raw);
        if (!Array.isArray(parsed)) {
            throw new Error(`${fileName} must contain a JSON array`);
        }

        parsed.forEach((item, index) => {
            const word = normalizeWord(item, fileName, index, true);

            summary.sourceEntries += 1;
            if (word.ready) {
                summary.readyEntries += 1;
            } else {
                summary.draftEntries += 1;
            }

            if (!word.ready && !includeDrafts) {
                summary.skippedDrafts += 1;
                return;
            }

            if (!word.ready) {
                summary.includedDrafts += 1;
            }

            if (!word.ready && !isNonEmptyString(word.ky)) {
                // Keep debug output deterministic even when drafts are included.
                word.ky = 'TODO_TRANSLATION';
            }

            if (ids.has(word.id)) {
                throw new Error(`Duplicate id detected: ${word.id}`);
            }
            ids.add(word.id);
            dataset.push({
                id: word.id,
                en: word.en,
                ky: word.ky,
                transcription_en: word.transcription_en,
                transcription_ky: word.transcription_ky,
                level: word.level,
                category: word.category,
            });
        });
    }

    dataset.sort((a, b) => {
        const categoryCompare = a.category.localeCompare(b.category);
        if (categoryCompare !== 0) return categoryCompare;
        const levelCompare = a.level - b.level;
        if (levelCompare !== 0) return levelCompare;
        return a.id.localeCompare(b.id);
    });

    return { dataset, summary };
}

function categoryStats(words) {
    const map = new Map();
    for (const word of words) {
        map.set(word.category, (map.get(word.category) ?? 0) + 1);
    }
    return Array.from(map.entries()).sort((a, b) => a[0].localeCompare(b[0]));
}

function main() {
    const includeDrafts = process.argv.includes('--include-drafts');
    const { dataset: words, summary } = buildDataset(includeDrafts);
    fs.writeFileSync(OUTPUT_FILE, JSON.stringify(words, null, 2), 'utf8');

    console.log(`Generated ${words.length} entries to ${OUTPUT_FILE}`);
    console.log(
        `Source entries: ${summary.sourceEntries} (ready: ${summary.readyEntries}, drafts: ${summary.draftEntries})`,
    );
    if (!includeDrafts) {
        console.log(`Skipped drafts: ${summary.skippedDrafts}`);
    } else {
        console.log(`Included drafts: ${summary.includedDrafts}`);
    }
    console.log('Category distribution:');
    for (const [category, count] of categoryStats(words)) {
        console.log(`- ${category}: ${count}`);
    }
}

main();
