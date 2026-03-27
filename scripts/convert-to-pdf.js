/**
 * Convert Learn Kyrgyz documentation Markdown files to styled PDFs
 * Usage: node convert-to-pdf.js [--all]
 */

const path = require('path');
const fs = require('fs');
const { mdToPdf } = require('md-to-pdf');

const PROJECT_ROOT = path.resolve(__dirname, '..');
const DOCS_DIR = path.join(PROJECT_ROOT, 'documentation');
const OUTPUT_DIR = path.join(DOCS_DIR, 'pdf');
const CSS_PATH = path.join(DOCS_DIR, 'pdf-styles.css');

const PDF_DIR = path.join(DOCS_DIR, 'pdf');
const DOCUMENTATION_FILES = [
  { input: path.join(PDF_DIR, 'SYSTEM_DESIGN_DOCUMENT_summary.md'), output: '1_System_Design_Document.pdf' },
  { input: path.join(PDF_DIR, 'WIREFRAMES_summary.md'), output: '2_Wireframes_and_Prototypes.pdf' },
  { input: path.join(PDF_DIR, 'TECHNOLOGY_STACK_summary.md'), output: '3_Technology_Stack_Documentation.pdf' },
  { input: path.join(PDF_DIR, 'PROJECT_ROADMAP_summary.md'), output: '4_Project_Roadmap.pdf' },
  { input: path.join(PDF_DIR, 'SYSTEM_ARCHITECTURE_summary.md'), output: '5_System_Architecture.pdf' },
];

async function convertToPdf(inputPath, outputPath, cssPath) {
  const css = fs.existsSync(cssPath) ? fs.readFileSync(cssPath, 'utf8') : '';
  
  await mdToPdf(
    { path: inputPath },
    {
      dest: outputPath,
      pdf_options: {
        format: 'A4',
        margin: { top: '25mm', right: '25mm', bottom: '25mm', left: '25mm' },
        printBackground: true,
        timeout: 60000,
      },
      launch_options: {
        args: ['--no-sandbox', '--disable-setuid-sandbox'],
        timeout: 90000,
      },
      css: css,
      body_class: ['documentation'],
      marked_options: {
        gfm: true,
        breaks: true,
      },
    }
  );
}

async function main() {
  // Ensure output directory exists
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
    console.log('Created output directory:', OUTPUT_DIR);
  }

  console.log('Learn Kyrgyz - Documentation to PDF Converter\n');
  console.log('Using stylesheet:', CSS_PATH);
  console.log('Output directory:', OUTPUT_DIR);
  console.log('');

  let successCount = 0;
  let errorCount = 0;

  for (const { input, output } of DOCUMENTATION_FILES) {
    const outputPath = path.join(OUTPUT_DIR, output);
    
    if (!fs.existsSync(input)) {
      console.log(`⚠ Skipped (not found): ${path.basename(input)}`);
      errorCount++;
      continue;
    }

    try {
      process.stdout.write(`Converting ${path.basename(input)} → ${output}... `);
      await convertToPdf(input, outputPath, CSS_PATH);
      console.log('✓ Done');
      successCount++;
    } catch (err) {
      console.log('✗ Failed');
      console.error('  Error:', err.message);
      errorCount++;
    }
  }

  console.log('');
  console.log(`Completed: ${successCount} succeeded, ${errorCount} failed`);
  console.log(`PDFs saved to: ${OUTPUT_DIR}`);
}

main().catch((err) => {
  console.error('Fatal error:', err);
  process.exit(1);
});
