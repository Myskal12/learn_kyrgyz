const fs = require('fs');
const path = require('path');

const OUTPUT_FILE = path.resolve(
    __dirname,
    'words_sources',
    'batch_02_target_gap_draft.json',
);

const TARGET_COUNTS = {
    adjectives: 10,
    animals: 17,
    basic: 16,
    education: 23,
    emotion: 24,
    family: 19,
    food: 15,
    health: 10,
    nature: 18,
    travel: 20,
    verbs: 10,
    weather: 24,
    work: 10,
};

const WORDS_BY_CATEGORY = {
    adjectives: [
        'red',
        'blue',
        'green',
        'white',
        'black',
        'heavy',
        'light',
        'soft',
        'sharp',
        'sweet',
    ],
    animals: [
        'lion',
        'tiger',
        'leopard',
        'zebra',
        'giraffe',
        'monkey',
        'elephant',
        'swan',
        'pigeon',
        'crow',
        'goose',
        'turkey',
        'lamb',
        'calf',
        'kitten',
        'puppy',
        'squirrel',
    ],
    basic: [
        'afternoon',
        'evening',
        'night',
        'week',
        'month',
        'year',
        'minute',
        'hour',
        'street',
        'house',
        'room',
        'door',
        'window',
        'right',
        'left',
        'center',
    ],
    education: [
        'pen',
        'pencil',
        'eraser',
        'marker',
        'board',
        'desk',
        'chair',
        'library',
        'campus',
        'professor',
        'lecture',
        'seminar',
        'course',
        'chapter',
        'paragraph',
        'grammar',
        'vocabulary',
        'translation',
        'research',
        'lab',
        'calculator',
        'backpack',
        'attendance',
    ],
    emotion: [
        'smile',
        'laughter',
        'tears',
        'friendship',
        'respect',
        'empathy',
        'jealousy',
        'loneliness',
        'excitement',
        'motivation',
        'confidence',
        'gratitude',
        'frustration',
        'relief',
        'disappointment',
        'satisfaction',
        'curiosity',
        'compassion',
        'affection',
        'nervousness',
        'comfort',
        'admiration',
        'enthusiasm',
        'inspiration',
    ],
    family: [
        'nephew',
        'niece',
        'grandson',
        'granddaughter',
        'stepfather',
        'stepmother',
        'brother-in-law',
        'sister-in-law',
        'twins',
        'ancestor',
        'descendant',
        'guardian',
        'baby',
        'toddler',
        'teenager',
        'adult',
        'family tree',
        'household',
        'parenthood',
    ],
    food: [
        'banana',
        'orange',
        'grape',
        'strawberry',
        'honey',
        'yogurt',
        'porridge',
        'pasta',
        'noodles',
        'sausage',
        'salad',
        'sauce',
        'biscuit',
        'cake',
        'juice',
    ],
    health: [
        'allergy',
        'infection',
        'injury',
        'recovery',
        'therapy',
        'diagnosis',
        'treatment',
        'appointment',
        'ambulance',
        'first aid',
    ],
    nature: [
        'desert',
        'ocean',
        'island',
        'waterfall',
        'meadow',
        'cave',
        'cliff',
        'volcano',
        'sand',
        'soil',
        'leaf',
        'branch',
        'root',
        'seed',
        'moon',
        'star',
        'sunlight',
        'shadow',
    ],
    travel: [
        'taxi',
        'subway',
        'tram',
        'bicycle',
        'motorcycle',
        'ship',
        'flight',
        'departure',
        'arrival',
        'checkpoint',
        'customs',
        'guidebook',
        'sightseeing',
        'souvenir',
        'journey',
        'trip',
        'adventure',
        'camp',
        'hostel',
        'rental car',
    ],
    verbs: [
        'to become',
        'to begin',
        'to finish',
        'to choose',
        'to carry',
        'to build',
        'to prepare',
        'to travel',
        'to return',
        'to celebrate',
    ],
    weather: [
        'drizzle',
        'thunder',
        'lightning',
        'breeze',
        'blizzard',
        'hail',
        'heatwave',
        'cold front',
        'pressure',
        'climate',
        'forecasting',
        'sunny',
        'cloudy',
        'rainy',
        'snowy',
        'stormy',
        'chilly',
        'freezing',
        'mild',
        'wet',
        'dry',
        'monsoon',
        'drought',
        'rainbow',
    ],
    work: [
        'interview',
        'contract',
        'colleague',
        'department',
        'budget',
        'strategy',
        'customer',
        'invoice',
        'presentation',
        'overtime',
    ],
};

function slugify(value) {
    return value
        .toString()
        .trim()
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '_')
        .replace(/^_+|_+$/g, '');
}

function pickWords(category, requiredCount) {
    const source = WORDS_BY_CATEGORY[category] ?? [];
    const words = [];
    const seen = new Set();

    for (const item of source) {
        const normalized = String(item).trim();
        if (!normalized) continue;
        const key = normalized.toLowerCase();
        if (seen.has(key)) continue;
        seen.add(key);
        words.push(normalized);
        if (words.length === requiredCount) return words;
    }

    let i = 1;
    while (words.length < requiredCount) {
        const fallback = `${category} term ${i}`;
        i += 1;
        words.push(fallback);
    }

    return words;
}

function buildEntries() {
    const entries = [];
    const ids = new Set();

    for (const [category, requiredCount] of Object.entries(TARGET_COUNTS)) {
        const words = pickWords(category, requiredCount);

        words.forEach((enWord, index) => {
            const id = `draft2_${category}_${slugify(enWord)}_${index + 1}`;
            if (ids.has(id)) {
                throw new Error(`Duplicate id generated: ${id}`);
            }
            ids.add(id);

            entries.push({
                id,
                en: enWord,
                ky: '',
                level: 1,
                category,
                ready: false,
                notes:
                    'Batch 02: fill ky translation and set ready=true after language review.',
            });
        });
    }

    return entries;
}

function categoryStats(entries) {
    const stats = new Map();
    for (const entry of entries) {
        stats.set(entry.category, (stats.get(entry.category) ?? 0) + 1);
    }
    return Array.from(stats.entries()).sort((a, b) => a[0].localeCompare(b[0]));
}

function main() {
    const entries = buildEntries();
    fs.writeFileSync(OUTPUT_FILE, JSON.stringify(entries, null, 2), 'utf8');

    console.log(`Created draft batch: ${entries.length} entries`);
    console.log(`Output: ${OUTPUT_FILE}`);
    console.log('Category distribution:');
    for (const [category, count] of categoryStats(entries)) {
        console.log(`- ${category}: ${count}`);
    }
}

main();
