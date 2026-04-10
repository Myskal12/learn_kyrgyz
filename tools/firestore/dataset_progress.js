const fs = require('fs');
const path = require('path');

const WORDS_FILE = path.resolve(__dirname, 'words.json');
const TARGETS_FILE = path.resolve(__dirname, 'dataset_targets.json');
const SOURCE_DIR = path.resolve(__dirname, 'words_sources');

function loadJson(filePath, title) {
    if (!fs.existsSync(filePath)) {
        throw new Error(`${title} not found: ${filePath}`);
    }

    const raw = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(raw);
}

function buildCategoryStats(words) {
    const stats = new Map();
    for (const word of words) {
        if (!word || typeof word !== 'object') continue;
        const category = String(word.category ?? 'uncategorized').trim().toLowerCase();
        if (!stats.has(category)) {
            stats.set(category, 0);
        }
        stats.set(category, stats.get(category) + 1);
    }
    return stats;
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
    const status =
        typeof word?.status === 'string' ? word.status.trim().toLowerCase() : '';
    if (status === 'draft') {
        return false;
    }

    if (Object.prototype.hasOwnProperty.call(word ?? {}, 'ready')) {
        return parseBool(word.ready, true);
    }

    return true;
}

function readSourceStats() {
    if (!fs.existsSync(SOURCE_DIR)) {
        return { files: 0, total: 0, ready: 0, drafts: 0 };
    }

    const files = fs
        .readdirSync(SOURCE_DIR)
        .filter((name) => name.toLowerCase().endsWith('.json'));

    let total = 0;
    let ready = 0;
    let drafts = 0;

    for (const fileName of files) {
        const filePath = path.resolve(SOURCE_DIR, fileName);
        const raw = fs.readFileSync(filePath, 'utf8');
        const parsed = JSON.parse(raw);
        if (!Array.isArray(parsed)) {
            continue;
        }

        for (const word of parsed) {
            if (!word || typeof word !== 'object') continue;
            total += 1;
            if (isReady(word)) {
                ready += 1;
            } else {
                drafts += 1;
            }
        }
    }

    return {
        files: files.length,
        total,
        ready,
        drafts,
    };
}

function printProgress(words, targets, sourceStats) {
    const minTotal = Number.isInteger(targets.minTotal) ? targets.minTotal : 500;
    const categoryMinimums = targets.categoryMinimums ?? {};
    const stats = buildCategoryStats(words);

    console.log(`Source shards: ${sourceStats.files}`);
    console.log(`Source entries: ${sourceStats.total}`);
    console.log(`- ready : ${sourceStats.ready}`);
    console.log(`- drafts: ${sourceStats.drafts}`);
    if (sourceStats.drafts > 0) {
        console.log(
            'Draft entries are skipped in words.json until ky is filled and ready=true.',
        );
    }
    console.log('');

    console.log(`Current words: ${words.length}`);
    console.log(`Target words : ${minTotal}`);
    console.log(`Remaining    : ${Math.max(minTotal - words.length, 0)}`);
    console.log('');

    const categories = Object.keys(categoryMinimums).sort((a, b) =>
        a.localeCompare(b),
    );

    if (categories.length > 0) {
        console.log('Category targets:');
        for (const category of categories) {
            const current = stats.get(category) ?? 0;
            const target = categoryMinimums[category];
            const remaining = Math.max(target - current, 0);
            const status = remaining === 0 ? 'ok' : `+${remaining}`;
            console.log(`- ${category}: ${current}/${target} (${status})`);
        }
        console.log('');
    }

    const uncovered = Array.from(stats.entries())
        .filter(([category]) => !(category in categoryMinimums))
        .sort((a, b) => a[0].localeCompare(b[0]));

    if (uncovered.length > 0) {
        console.log('Categories without explicit target:');
        for (const [category, count] of uncovered) {
            console.log(`- ${category}: ${count}`);
        }
    }
}

function main() {
    const words = loadJson(WORDS_FILE, 'words.json');
    if (!Array.isArray(words)) {
        throw new Error('words.json must contain an array.');
    }

    const targets = loadJson(TARGETS_FILE, 'dataset_targets.json');
    const sourceStats = readSourceStats();
    printProgress(words, targets, sourceStats);
}

main();
