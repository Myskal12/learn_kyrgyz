const fs = require('fs');
const path = require('path');

const SOURCE_DIR = path.resolve(__dirname, 'words_sources');

function isNonEmptyString(value) {
    return typeof value === 'string' && value.trim().length > 0;
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
        sheet: null,
        setReadyWhenKy: true,
    };

    for (let i = 0; i < argv.length; i += 1) {
        const token = argv[i];

        if (token === '--input' && argv[i + 1]) {
            args.input = argv[++i];
            continue;
        }
        if (token === '--sheet' && argv[i + 1]) {
            args.sheet = argv[++i];
            continue;
        }
        if (token === '--set-ready-when-ky' && argv[i + 1]) {
            args.setReadyWhenKy = parseBool(argv[++i], true);
        }
    }

    if (!args.input) {
        throw new Error(
            'Missing --input. Example: node apply_translation_updates.js --input ./translation/drafts_for_translation.csv',
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

function readTableRows(inputPath, sheet) {
    const ext = path.extname(inputPath).toLowerCase();

    if (ext === '.csv') {
        return readCsvRows(inputPath);
    }
    if (ext === '.xlsx' || ext === '.xls') {
        return readXlsxRows(inputPath, sheet);
    }

    throw new Error('Unsupported input format. Use .csv, .xlsx or .xls');
}

function loadSources() {
    if (!fs.existsSync(SOURCE_DIR)) {
        throw new Error(`Source folder not found: ${SOURCE_DIR}`);
    }

    const files = fs
        .readdirSync(SOURCE_DIR)
        .filter((name) => name.toLowerCase().endsWith('.json'))
        .sort((a, b) => a.localeCompare(b));

    const byFile = new Map();
    const byId = new Map();

    for (const fileName of files) {
        const filePath = path.resolve(SOURCE_DIR, fileName);
        const parsed = JSON.parse(fs.readFileSync(filePath, 'utf8'));
        if (!Array.isArray(parsed)) {
            throw new Error(`${fileName} must contain a JSON array`);
        }

        byFile.set(fileName, parsed);

        parsed.forEach((entry, index) => {
            if (!entry || typeof entry !== 'object' || Array.isArray(entry)) {
                return;
            }

            const id = String(entry.id ?? '').trim();
            if (!isNonEmptyString(id)) {
                return;
            }

            if (byId.has(id)) {
                const first = byId.get(id);
                throw new Error(
                    `Duplicate id across source shards: ${id} (${first.fileName} and ${fileName})`,
                );
            }

            byId.set(id, {
                fileName,
                index,
            });
        });
    }

    return { byFile, byId };
}

function normalizeUpdateRows(rows) {
    return rows.map((row, idx) => {
        const label = `row ${idx + 2}`;
        const id = String(row.id ?? '').trim();
        if (!isNonEmptyString(id)) {
            throw new Error(`${label}: id is required`);
        }

        return {
            id,
            ky: String(row.ky ?? row.kyrgyz ?? '').trim(),
            ready: row.ready,
            transcriptionEn: String(
                row.transcription_en ?? row.transcriptionen ?? '',
            ).trim(),
            transcriptionKy: String(
                row.transcription_ky ?? row.transcriptionky ?? '',
            ).trim(),
            notes: String(row.notes ?? '').trim(),
            label,
        };
    });
}

function applyUpdates(updateRows, sources, setReadyWhenKy) {
    const changedFiles = new Set();
    const idsSeen = new Set();

    let updated = 0;
    let skippedNoMatch = 0;
    let skippedNoPayload = 0;
    let duplicateRows = 0;

    for (const row of updateRows) {
        if (idsSeen.has(row.id)) {
            duplicateRows += 1;
            continue;
        }
        idsSeen.add(row.id);

        const location = sources.byId.get(row.id);
        if (!location) {
            skippedNoMatch += 1;
            continue;
        }

        const fileEntries = sources.byFile.get(location.fileName);
        const entry = fileEntries?.[location.index];
        if (!entry || typeof entry !== 'object') {
            skippedNoMatch += 1;
            continue;
        }

        let changed = false;

        if (isNonEmptyString(row.ky) && entry.ky !== row.ky) {
            entry.ky = row.ky;
            changed = true;
        }

        if (isNonEmptyString(row.transcriptionEn)) {
            if (entry.transcription_en !== row.transcriptionEn) {
                entry.transcription_en = row.transcriptionEn;
                changed = true;
            }
        }

        if (isNonEmptyString(row.transcriptionKy)) {
            if (entry.transcription_ky !== row.transcriptionKy) {
                entry.transcription_ky = row.transcriptionKy;
                changed = true;
            }
        }

        if (isNonEmptyString(row.notes) && entry.notes !== row.notes) {
            entry.notes = row.notes;
            changed = true;
        }

        const hasReady = Object.prototype.hasOwnProperty.call(row, 'ready');
        if (hasReady && isNonEmptyString(String(row.ready ?? ''))) {
            const ready = parseBool(row.ready, true);
            if (entry.ready !== ready) {
                entry.ready = ready;
                changed = true;
            }
        } else if (setReadyWhenKy && isNonEmptyString(row.ky) && entry.ready !== true) {
            entry.ready = true;
            changed = true;
        }

        if (changed) {
            changedFiles.add(location.fileName);
            updated += 1;
        } else {
            skippedNoPayload += 1;
        }
    }

    for (const fileName of changedFiles) {
        const filePath = path.resolve(SOURCE_DIR, fileName);
        const data = sources.byFile.get(fileName);
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
    }

    return {
        updated,
        changedFiles: changedFiles.size,
        skippedNoMatch,
        skippedNoPayload,
        duplicateRows,
    };
}

function main() {
    const args = parseArgs(process.argv.slice(2));
    const inputPath = path.resolve(process.cwd(), args.input);
    if (!fs.existsSync(inputPath)) {
        throw new Error(`Input file not found: ${inputPath}`);
    }

    const rawRows = readTableRows(inputPath, args.sheet);
    const updateRows = normalizeUpdateRows(rawRows);
    const sources = loadSources();

    const result = applyUpdates(updateRows, sources, args.setReadyWhenKy);

    console.log(`Input file          : ${inputPath}`);
    console.log(`Rows parsed         : ${updateRows.length}`);
    console.log(`Rows updated        : ${result.updated}`);
    console.log(`Files changed       : ${result.changedFiles}`);
    console.log(`No id match         : ${result.skippedNoMatch}`);
    console.log(`No value changes    : ${result.skippedNoPayload}`);
    console.log(`Duplicate ids in input skipped: ${result.duplicateRows}`);
}

main();
