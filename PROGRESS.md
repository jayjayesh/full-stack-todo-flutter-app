# Project Progress Tracker

This file tracks what has been completed and what we should work on next for the full-stack todo app.

## Current Snapshot

- Project type: Full-stack todo app
- Frontend: Flutter app in `frontend/todoflutterapp`
- Backend: Node.js app in `backend`
- Learning/docs track: 21 lesson docs already added in `docs`

## Work Completed

### Backend

- Basic backend setup and todo API flow
- Flutter integration with todo APIs
- Token authentication
- SQLite/database persistence lesson work
- Backend code structure cleanup
- Environment configuration support
- Error handling improvements
- Input validation rules
- Backend test coverage

### Frontend

- Form validation
- Widget tests
- Loading and empty states polish
- Optimistic todo updates
- Edit todo flow
- Logout and session cleanup polish
- Auth route guards
- Auth provider cleanup and single auth source
- Auth screen controller lifecycle cleanup
- Password visibility toggle
- Auth loading and error states polish
- Auth success navigation and messaging polish

## Current Status

- Core auth flow is present
- Todo CRUD flow is present
- Backend and frontend are both structured into maintainable modules
- Project includes documentation for the completed learning milestones
- Repository guidance now includes an `AGENTS.md` workflow note for contributors/agents

## Next Recommended Steps

- [ ] Run backend and Flutter tests and record the current baseline in `PROGRESS.md`
- [ ] Review the app end-to-end to confirm auth and todo flows still work as expected
- [ ] Choose and start the next milestone after lesson 21, based on any issues found during testing

## Current Focus

- Keep this file updated as the source of truth for recent work, test status, and the next priority

## Update Log

### 2026-05-11

- Added `AGENTS.md` with project overview, source-of-truth guidance, agent expectations, and recommended workflow
- No frontend or backend application code changed today
- Files touched today:
  - `AGENTS.md`
- Tests run today:
  - None recorded
- Known issues / follow-up:
  - Current backend and Flutter test baseline has not been re-run and documented after the latest documentation/process update
  - No new product issues were identified today because today’s change was documentation-only

### 2026-05-07

- Added `PROGRESS.md` to track completed work and upcoming tasks

## How To Use This File With Codex/Claude - v1

- Add a short note under `Update Log` after each meaningful change
- Move finished items into `Work Completed`
- Keep `Next Recommended Steps` limited to the next 3 to 5 actionable items

## How To Use This File With Codex/Claude - v2

At the start of a new session, ask:

```text
Read PROGRESS.md and README.md first, then tell me the current project status and the next best step.
```

After Codex changes code, ask:

```text
Update PROGRESS.md with what changed, files touched, tests run, known issues, and the next recommended step.
```

When you are confused about what changed, ask:

```text
Compare git diff with PROGRESS.md and explain the changes in beginner-friendly language.
```
