const fs = require('fs');
const path = require('path');

const OUTPUT_FILE = path.resolve(
    __dirname,
    'words_sources',
    'batch_01_missing_categories_draft.json',
);

function slugify(value) {
    return value
        .toString()
        .trim()
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '_')
        .replace(/^_+|_+$/g, '');
}

const CATEGORY_WORDS = {
    adjectives: [
        'big',
        'small',
        'long',
        'short',
        'new',
        'old',
        'young',
        'fast',
        'slow',
        'easy',
        'hard',
        'hot',
        'cold',
        'warm',
        'clean',
        'dirty',
        'beautiful',
        'ugly',
        'strong',
        'weak',
        'happy',
        'sad',
        'good',
        'bad',
        'important',
        'interesting',
        'quiet',
        'loud',
        'early',
        'late',
    ],
    animals: [
        'cow',
        'goat',
        'camel',
        'wolf',
        'fox',
        'rabbit',
        'bear',
        'fish',
        'duck',
        'chicken',
        'rooster',
        'mouse',
        'deer',
        'donkey',
        'bee',
        'butterfly',
    ],
    basic: [
        'goodbye',
        'welcome',
        'sorry',
        'excuse me',
        'maybe',
        'now',
        'later',
        'today',
        'tomorrow',
        'yesterday',
        'question',
        'answer',
        'name',
        'language',
        'country',
        'village',
    ],
    education: [
        'teacher',
        'student',
        'classroom',
        'lesson',
        'homework',
        'exam',
        'grade',
        'subject',
        'notebook',
        'dictionary',
        'alphabet',
        'sentence',
        'story',
        'university',
        'knowledge',
    ],
    emotion: [
        'love',
        'fear',
        'anger',
        'joy',
        'hope',
        'trust',
        'calm',
        'stress',
        'worry',
        'pride',
        'shame',
        'surprise',
        'kindness',
        'patience',
        'courage',
    ],
    family: [
        'grandfather',
        'uncle',
        'aunt',
        'cousin',
        'son',
        'daughter',
        'parents',
        'relatives',
        'husband',
        'wife',
        'wedding',
        'home',
        'support',
        'respect',
    ],
    food: [
        'rice',
        'milk',
        'butter',
        'salt',
        'sugar',
        'pepper',
        'potato',
        'onion',
        'tomato',
        'carrot',
        'cucumber',
        'egg',
        'cheese',
        'chicken meat',
        'breakfast',
        'lunch',
        'dinner',
        'kitchen',
    ],
    health: [
        'doctor',
        'nurse',
        'hospital',
        'clinic',
        'medicine',
        'pain',
        'headache',
        'fever',
        'cough',
        'blood',
        'heart',
        'stomach',
        'tooth',
        'eye',
        'ear',
        'healthy',
        'exercise',
        'vitamin',
        'sleep',
        'emergency',
    ],
    nature: [
        'forest',
        'tree',
        'flower',
        'grass',
        'stone',
        'hill',
        'valley',
        'sky',
        'earth',
        'fire',
        'ice',
        'rain',
        'cloud',
        'storm',
        'season',
    ],
    travel: [
        'map',
        'station',
        'platform',
        'driver',
        'passenger',
        'luggage',
        'hotel',
        'reservation',
        'passport',
        'visa',
        'border',
        'route',
        'distance',
        'direction',
    ],
    verbs: [
        'to be',
        'to have',
        'to do',
        'to go',
        'to come',
        'to see',
        'to hear',
        'to read',
        'to write',
        'to speak',
        'to listen',
        'to learn',
        'to teach',
        'to work',
        'to rest',
        'to eat',
        'to drink',
        'to sleep',
        'to think',
        'to know',
        'to understand',
        'to ask',
        'to answer',
        'to open',
        'to close',
        'to buy',
        'to sell',
        'to call',
        'to help',
        'to wait',
    ],
    weather: [
        'rain',
        'snowfall',
        'fog',
        'temperature',
        'degree',
        'sunrise',
        'sunset',
        'winter',
        'spring',
        'summer',
        'autumn',
        'forecast',
        'humid',
        'dry weather',
        'windy',
    ],
    work: [
        'job',
        'office',
        'company',
        'manager',
        'employee',
        'meeting',
        'project',
        'deadline',
        'salary',
        'career',
        'team',
        'task',
        'report',
        'email',
        'phone call',
        'schedule',
        'training',
        'experience',
        'promotion',
        'business',
    ],
};

function buildDraftEntries() {
    const entries = [];
    const ids = new Set();

    for (const [category, words] of Object.entries(CATEGORY_WORDS)) {
        words.forEach((enWord, index) => {
            const id = `draft_${category}_${slugify(enWord)}_${index + 1}`;
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
                notes: 'Fill ky translation and set ready=true after language review.',
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
    const entries = buildDraftEntries();
    fs.writeFileSync(OUTPUT_FILE, JSON.stringify(entries, null, 2), 'utf8');

    console.log(`Created draft batch: ${entries.length} entries`);
    console.log(`Output: ${OUTPUT_FILE}`);
    console.log('Category distribution:');
    for (const [category, count] of categoryStats(entries)) {
        console.log(`- ${category}: ${count}`);
    }
}

main();
