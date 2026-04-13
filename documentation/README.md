# Learn Kyrgyz Documentation

This directory contains active documentation for the current codebase only.
Outdated drafts, one-off summaries, and duplicate notes are intentionally removed so the repository has one source of truth.

## Documentation Set

1. PRODUCT_AND_UX.md
   Current product positioning, screen roles, learning loop, and UX principles.

2. ARCHITECTURE.md
   Current application architecture, data layer, offline-first foundation, sync, and analytics.

3. ENGINEERING_QUALITY.md
   Engineering quality rules, testing standards, operational notes, and open technical debt.

4. USER_GUIDE.md
   End-user guide for the core app flows.

5. TEST_REPORT.md
   Current testing report and verified coverage areas.

6. PRODUCTION_CHECKLIST.md
   Mandatory checklist to move the project to full release readiness.

7. RELEASE_EXECUTION_CHECKLIST.md
   Ordered release runbook with concrete execution steps and current blockers.

8. STATIC_PARTS_IMPLEMENTATION_PLAN.md
   Migration plan for static app parts to data-driven configuration.

## Current Project Status

- Stage 1. Product structure and CTA hierarchy: baseline completed.
- Stage 2. Per-word progress model and review logic: foundation completed.
- Stage 3. Offline-first foundation: catalog cache and local-first repositories implemented.
- Stage 4. Learning loop: review mode and linked mode transitions added.
- Stage 5. Motivation and personalization: progress, milestone, and study snapshot improved.
- Stage 6. Quality and stabilization: local analytics, tests, and hygiene checks added.

## Documentation Update Rule

Documentation must describe only what exists in code now.

If one of these areas changes, update the matching file:

- Product flow, screen behavior, or UX rule -> PRODUCT_AND_UX.md
- Architecture, data state, sync, offline, analytics -> ARCHITECTURE.md
- Tests, quality gates, release process, security notes -> ENGINEERING_QUALITY.md

## Intentionally Excluded

- Outdated wireframe specs that no longer match implementation
- One-off change summaries
- Generated PDF artifacts committed to source control
- Parallel backlog files that duplicate the same improvement lists
