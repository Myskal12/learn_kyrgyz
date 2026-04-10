const fs = require('fs');
const path = require('path');

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
        if (['true', '1', 'yes', 'y', 'on'].includes(normalized)) return true;
        if (['false', '0', 'no', 'n', 'off'].includes(normalized)) return false;
    }
    return fallback;
}

function parseArgs(argv) {
    const args = {
        input: null,
        output: null,
        sheet: null,
        defaultReady: true,
    };

    for (let i = 0; i < argv.length; i += 1) {
        const token = argv[i];
        if (token === '--input' && argv[i + 1]) {
            args.input = argv[++i];
            continue;
        }
        if (token === '--output' && argv[i + 1]) {
            args.output = argv[++i];
            continue;
        }
        if (token === '--sheet' && argv[i + 1]) {
            args.sheet = argv[++i];
            continue;
        }
        if (token === '--default-ready' && argv[i + 1]) {
            args.defaultReady = parseBool(argv[++i], true);
            continue;
        }
    }

    if (!args.input) {
        throw new Error(
            'Missing --input. Example: node import_words_source.js --input ./my_words.csv',
        );
    }

    return args;
}

function parseDelimitedLine(line, delimiter) {
    const result = [];
    let current = '';
    let inQuotes = false;

    for (let i = 0; i < line.length; i += 1) {
        const ch = line[i];

        if (ch === '"') {
            if (inQuotes && line[i + 1] === '"') {
                current += '"';
                i += 1;
            } else {
                inQuotes = !inQuotes;
            }
            continue;
        }

        if (ch === delimiter && !inQuotes) {
            result.push(current);
            current = '';
            continue;
        }

        current += ch;
    }

    result.push(current);
    return result.map((value) => value.trim());
}

function readCsvRows(filePath) {
    const text = fs.readFileSync(filePath, 'utf8').replace(/^\uFEFF/, '');
    const lines = text
        .split(/\r?\n/)
        .map((line) => line.trim())
        .filter((line) => line.length > 0);

    if (lines.length < 2) {
        throw new Error('CSV must contain header and at least one data row.');
    }

    const headerLine = lines[0];
    const semicolonCount = (headerLine.match(/;/g) || []).length;
    const commaCount = (headerLine.match(/,/g) || []).length;
    const delimiter = semicolonCount > commaCount ? ';' : ',';

    const headers = parseDelimitedLine(headerLine, delimiter).map((h) =>
        h.toLowerCase(),
    );

    return lines.slice(1).map((line) => {
        const values = parseDelimitedLine(line, delimiter);
        const row = {};
        headers.forEach((header, idx) => {
            row[header] = values[idx] ?? '';
        });
        return row;
    });
}

function readXlsxRows(filePath, requestedSheet) {
    let XLSX;
    try {
        XLSX = require('xlsx');
    } catch (_) {
        throw new Error(
            'XLSX import requires the xlsx package. Run: npm install xlsx',
        );
    }

    const workbook = XLSX.readFile(filePath);
    const sheetName = requestedSheet || workbook.SheetNames[0];
    if (!sheetName || !workbook.Sheets[sheetName]) {
        throw new Error(`Sheet not found: ${requestedSheet}`);
    }

    const rows = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], {
        defval: '',
        raw: false,
    });

    return rows.map((row) => {
        const normalized = {};
        Object.entries(row ?? {}).forEach(([key, value]) => {
            normalized[String(key).trim().toLowerCase()] = value;
        });
        return normalized;
    });
}

function normalizeRows(rows, defaultReady) {
    const entries = [];
    const ids = new Set();

    rows.forEach((raw, index) => {
        const row = raw || {};
        const label = `row ${index + 2}`;

        const en = String(row.en ?? row.english ?? '').trim();
        const category = String(row.category ?? '').trim().toLowerCase();
        const ky = String(row.ky ?? row.kyrgyz ?? '').trim();

        if (!isNonEmptyString(en)) {
            throw new Error(`${label}: en is required`);
        }
        if (!isNonEmptyString(category)) {
            throw new Error(`${label}: category is required`);
        }

        const levelRaw = Number.parseInt(String(row.level ?? '').trim(), 10);
        const level = Number.isInteger(levelRaw) && levelRaw > 0 ? levelRaw : 1;

        const idRaw = String(row.id ?? '').trim();
        const id = idRaw || `import_${category}_${slugify(en)}`;
        if (!isNonEmptyString(id)) {
            throw new Error(`${label}: id cannot be empty`);
        }
        if (ids.has(id)) {
            throw new Error(`${label}: duplicate id ${id}`);
        }
        ids.add(id);

        const hasReadyField = Object.prototype.hasOwnProperty.call(row, 'ready');
        let ready = hasReadyField
            ? parseBool(row.ready, defaultReady)
            : defaultReady;

        if (!isNonEmptyString(ky)) {
            ready = false;
        }

        const entry = {
            id,
            en,
            ky,
            level,
            category,
            ready,
        };

        const transcriptionEn = String(
            row.transcription_en ?? row.transcriptionEn ?? '',
        ).trim();
        const transcriptionKy = String(
            row.transcription_ky ?? row.transcriptionKy ?? '',
        ).trim();
        const notes = String(row.notes ?? '').trim();

        if (isNonEmptyString(transcriptionEn)) {
            entry.transcription_en = transcriptionEn;
        }
        if (isNonEmptyString(transcriptionKy)) {
            entry.transcription_ky = transcriptionKy;
        }
        if (isNonEmptyString(notes)) {
            entry.notes = notes;
        }

        entries.push(entry);
    });

    return entries;
}

function resolveOutputPath(inputPath, outputArg) {
    if (outputArg) {
        return path.resolve(process.cwd(), outputArg);
    }

    const inputBase = path.basename(inputPath, path.extname(inputPath));
    const safeBase = slugify(inputBase) || 'imported';
    return path.resolve(__dirname, 'words_sources', `imported_${safeBase}.json`);
}

function summarize(entries) {
    const ready = entries.filter((e) => e.ready).length;
    const drafts = entries.length - ready;
    return { total: entries.length, ready, drafts };
}

function main() {
    const args = parseArgs(process.argv.slice(2));
    const inputPath = path.resolve(process.cwd(), args.input);

    if (!fs.existsSync(inputPath)) {
        throw new Error(`Input file not found: ${inputPath}`);
    }

    const ext = path.extname(inputPath).toLowerCase();
    let rows;

    if (ext === '.csv') {
        rows = readCsvRows(inputPath);
    } else if (ext === '.xlsx' || ext === '.xls') {
        rows = readXlsxRows(inputPath, args.sheet);
    } else {
        throw new Error('Unsupported input format. Use .csv, .xlsx or .xls');
    }

    const entries = normalizeRows(rows, args.defaultReady);
    const outputPath = resolveOutputPath(inputPath, args.output);

    fs.writeFileSync(outputPath, JSON.stringify(entries, null, 2), 'utf8');

    const stats = summarize(entries);
    console.log(`Imported file : ${inputPath}`);
    console.log(`Output file   : ${outputPath}`);
    console.log(`Total entries : ${stats.total}`);
    console.log(`Ready entries : ${stats.ready}`);
    console.log(`Draft entries : ${stats.drafts}`);
}

main();
