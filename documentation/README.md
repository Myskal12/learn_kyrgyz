# Learn Kyrgyz Documentation

I keep this folder as the single place for project documentation. I removed old drafts, duplicate notes, and PDF exports so that the repository has one clear source of truth.

## Documentation Set

1. `PRODUCT_AND_UX.md`
   I explain the product idea, the learning flow, and the UX rules I follow in the app.

2. `ARCHITECTURE.md`
   I describe the current application structure, the data flow, the offline layer, and the sync model.

3. `ENGINEERING_QUALITY.md`
   I document my quality rules, test expectations, release checks, and technical risks.

4. `USER_GUIDE.md`
   I describe the main user flows from the point of view of someone using the app.

5. `TEST_REPORT.md`
   I summarize the checks I run and the testing gaps that still remain.

## Documentation Rule

I only document what already exists in the codebase.

If I change product behavior, I update `PRODUCT_AND_UX.md`.
If I change architecture or data handling, I update `ARCHITECTURE.md`.
If I change testing, release flow, or engineering standards, I update `ENGINEERING_QUALITY.md`.

## What I Do Not Keep Here

- expired wireframe notes
- duplicate backlog files
- generated PDFs
- short-lived status summaries
- documents that no longer match the code
