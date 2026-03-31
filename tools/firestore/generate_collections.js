const fs = require('fs');
const path = require('path');

const WORDS_FILE = path.resolve(__dirname, 'words.json');
const SENTENCES_FILE = path.resolve(__dirname, 'sentences.json');
const QUIZ_FILE = path.resolve(__dirname, 'quiz.json');

function loadWords() {
  if (!fs.existsSync(WORDS_FILE)) {
    throw new Error(`words.json not found. Place it in ${__dirname}`);
  }
  const raw = fs.readFileSync(WORDS_FILE, 'utf8');
  const data = JSON.parse(raw);
  if (!Array.isArray(data) || data.length < 4) {
    throw new Error('words.json must contain at least 4 entries.');
  }
  return data;
}

function slugify(value) {
  return value
    .toString()
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function buildSentences(words) {
  return words.map((word) => {
    const baseId = word.id ?? slugify(word.en);
    return {
      id: `sent_${baseId}`,
      en: `This is ${word.en}`,
      ky: `Бул ${word.ky}`,
      highlight: word.en,
      word_en: word.en,
      word_ky: word.ky,
      wordId: baseId,
      level: word.level ?? 1,
      category: word.category ?? 'basic',
    };
  });
}

function pickWrongOptions(words, targetKy) {
  const pool = words.map((word) => word.ky).filter((ky) => ky !== targetKy);
  if (pool.length < 3) {
    throw new Error('Need at least 4 unique words to build quiz options.');
  }
  const selected = new Set();
  while (selected.size < 3) {
    const randomKy = pool[Math.floor(Math.random() * pool.length)];
    selected.add(randomKy);
  }
  return Array.from(selected);
}

function shuffle(array) {
  const clone = [...array];
  for (let i = clone.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [clone[i], clone[j]] = [clone[j], clone[i]];
  }
  return clone;
}

function buildQuiz(words) {
  return words.map((word) => {
    const wrong = pickWrongOptions(words, word.ky);
    const options = shuffle([...wrong, word.ky]);
    const baseId = word.id ?? slugify(word.en);
    return {
      id: `quiz_${baseId}`,
      type: 'choose_translation',
      question: word.en,
      correct: word.ky,
      options,
      level: word.level ?? 1,
      category: word.category ?? 'basic',
      wordId: baseId,
    };
  });
}

function main() {
  const words = loadWords();
  const sentences = buildSentences(words);
  const quiz = buildQuiz(words);
  fs.writeFileSync(SENTENCES_FILE, JSON.stringify(sentences, null, 2), 'utf8');
  fs.writeFileSync(QUIZ_FILE, JSON.stringify(quiz, null, 2), 'utf8');
  console.log(
    `Generated ${sentences.length} sentences and ${quiz.length} quiz entries.`,
  );
}

main();
