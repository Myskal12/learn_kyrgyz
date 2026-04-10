const fs = require('fs');
const path = require('path');

const SOURCE_DIR = path.resolve(__dirname, 'words_sources');
const DEFAULT_OUTPUT = path.resolve(
    __dirname,
    'translation',
    'drafts_for_translation.csv',
);

function parseArgs(argv) {
    const args = {
        output: DEFAULT_OUTPUT,
    };

    for (let i = 0; i < argv.length; i += 1) {
        const token = argv[i];
        if (token === '--output' && argv[i + 1]) {
            args.output = path.resolve(process.cwd(), argv[++i]);
        }
    }

    return args;
}

function parseBool(value, fallback = true) {
    if (typeof value === 'boolean') return value;
    if (typeof value === 'number') return value !== 0;
    if (typeof value === 'string') {
        const normalized = value.trim().toLowerCase();
        if (['true', '1', 'yes', 'y', 'on'].includes(normalized)) return true;
        if (['false', '0', 'no', 'n', 'off'].includes(normalized)) return false;
    }
    return fallback;
}

function isReady(entry) {
    if (Object.prototype.hasOwnProperty.call(entry ?? {}, 'ready')) {
        return parseBool(entry.ready, true);
    }

    const status =
        typeof entry?.status === 'string' ? entry.status.trim().toLowerCase() : '';
    if (status === 'draft') return false;

    return true;
}

function csvEscape(value) {
    const text = String(value ?? '');
    if (text.includes('"') || text.includes(',') || text.includes('\n')) {
        return `"${text.replace(/"/g, '""')}"`;
    }
    return text;
}

function rowToCsv(row) {
    return row.map((cell) => csvEscape(cell)).join(',');
}

function readSourceFiles() {
    if (!fs.existsSync(SOURCE_DIR)) {
        throw new Error(`Source folder not found: ${SOURCE_DIR}`);
    }

    return fs
        .readdirSync(SOURCE_DIR)
        .filter((name) => name.toLowerCase().endsWith('.json'))
        .sort((a, b) => a.localeCompare(b));
}

function collectDraftRows() {
    const files = readSourceFiles();
    const rows = [];

    for (const fileName of files) {
        const filePath = path.resolve(SOURCE_DIR, fileName);
        const parsed = JSON.parse(fs.readFileSync(filePath, 'utf8'));
        if (!Array.isArray(parsed)) {
            throw new Error(`${fileName} must contain a JSON array`);
        }

        parsed.forEach((entry) => {
            if (!entry || typeof entry !== 'object' || Array.isArray(entry)) {
                return;
            }

            const ready = isReady(entry);
            const ky = String(entry.ky ?? '').trim();

            if (ready && ky.length > 0) {
                return;
            }

            rows.push([
                String(entry.id ?? '').trim(),
                String(entry.en ?? '').trim(),
                ky,
                String(entry.category ?? '').trim().toLowerCase(),
                Number.isInteger(entry.level) && entry.level > 0 ? entry.level : 1,
                ready ? 'true' : 'false',
                String(entry.notes ?? '').trim(),
                fileName,
            ]);
        });
    }

    rows.sort((a, b) => {
        const categoryCompare = String(a[3]).localeCompare(String(b[3]));
        if (categoryCompare !== 0) return categoryCompare;
        return String(a[0]).localeCompare(String(b[0]));
    });

    return rows;
}

function writeCsv(outputPath, rows) {
    const header = [
        'id',
        'en',
        'ky',
        'category',
        'level',
        'ready',
        'notes',
        'source_file',
    ];

    const lines = [rowToCsv(header), ...rows.map((row) => rowToCsv(row))];
    fs.mkdirSync(path.dirname(outputPath), { recursive: true });
    fs.writeFileSync(outputPath, lines.join('\n'), 'utf8');
}

function main() {
    const args = parseArgs(process.argv.slice(2));
    const rows = collectDraftRows();
    writeCsv(args.output, rows);

    console.log(`Draft entries exported: ${rows.length}`);
    console.log(`Output file          : ${args.output}`);
}

main();
