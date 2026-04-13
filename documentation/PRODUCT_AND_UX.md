# Product And UX

## 1. Product Purpose

Learn Kyrgyz is a mobile-first app for daily Kyrgyz language practice through:

- flashcards
- quiz
- sentence builder
- category-based learning path
- streak and milestone motivation
- synced progress between guest/local and cloud account

The main product goal is to guide the user into short, clear, repeatable daily practice sessions, not to present a collection of disconnected screens.

## 2. Primary User Scenarios

### New user

1. Opens the app.
2. Completes the welcome flow.
3. Selects a daily goal.
4. Continues as guest or signs in.
5. Lands on Home and gets one best next action.

### Returning user

1. Opens the app.
2. Uses Home as the "what to do now" screen.
3. Continues the last session or closes review-due items.
4. Completes an activity and receives a summary + next recommendation.

## 3. Main Screen Roles

### Home

Home is not a second Practice screen and not a full app catalog.

It answers one question:
"What should I do right now?"

Home priorities:

- continue last lesson
- review due
- daily goal progress
- next milestone

### Practice

Practice is a tactical hub, not a second home page.

It exists for intentional mode selection:

- flashcards
- quick quiz
- sentence builder
- review-focused entry points

### Categories

Categories is the learning roadmap.

It should show:

- where the user is now
- what is already completed
- what unlocks next
- where review is needed

### Flashcards / Quiz / Sentence Builder

These are three modes of one learning system, not three isolated mini-apps.

Expected sequence:

1. learn or recall
2. verify
3. apply in context
4. return to mistakes

### Progress / Profile

These screens must not show fake analytics.

They are intended for:

- streak
- mastered / weak / review due
- next milestone
- sync state
- basic user settings

## 4. Current UX Direction

The following rules are already accepted and partially implemented:

1. One primary CTA per screen.
2. Critical actions should not be hidden in long scrolling sections.
3. Home and Practice must remain clearly separated by role.
4. Learning-direction setting belongs in settings, not in overloaded learning screens.
5. Review due must be part of the core experience, not a side feature.
6. Progress must be based on real data.

## 5. Current Learning Loop

The product is moving toward this loop:

1. User chooses a category or continues the latest one.
2. User completes flashcards or review mode.
3. User takes a quiz.
4. User reinforces via sentence builder.
5. User gets a summary and next action.
6. Problem words return to the review loop.

This is stronger than the previous fragmented flow, but not fully complete yet.

## 6. Improvements Already Delivered

- Simplified Home / Practice / Categories product structure.
- Added review mode for flashcards.
- Improved milestone and progress surfaces.
- Added local analytics for learning sessions.
- Improved adaptive behavior and CTA visibility on small screens.

## 7. Remaining UX Priorities

### P1

- Dedicated review hub instead of distributed review entry points.
- Stronger error feedback in quiz and sentence builder.
- More transparent category progression.

### P2

- Weekly recap based on real history rather than placeholders.
- Full interface localization maturity.
- Tablet and web layouts beyond mobile scaling.

### P3

- Richer audio/pronunciation experience.
- Stronger achievement claiming flow.
- Smarter Home personalization by momentum and review debt.

## 8. UX Guardrails

- Do not add decorative CTAs without real actions.
- Do not build motivation on fake analytics.
- Do not turn Home into a full features catalog.
- Do not overload learning screens with settings and extra chrome.
- Do not document future behavior that is not implemented.
