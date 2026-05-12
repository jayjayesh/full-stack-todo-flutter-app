# Agents Guide

## Project Overview

This repository contains a full-stack todo application built for learning and incremental improvement.

- Frontend: Flutter app in `frontend/todoflutterapp`
- Backend: Node.js app in `backend`
- Docs: Beginner-friendly lesson notes and guides in `docs`

The project is intentionally structured as both a working app and a learning resource. Each major improvement is documented as a lesson so the codebase stays understandable for future contributors.

## Main Goal

The goal of this project is to build a clean, maintainable full-stack todo app while learning modern app development step by step.

That includes:

- building a real authentication flow
- building reliable todo CRUD features
- keeping frontend and backend code organized into clear layers/modules
- improving UX over time through small, focused milestones
- documenting each milestone in beginner-friendly language

## Current Status

Based on `PROGRESS.md` and `README.md`, the project currently includes:

- token-based authentication
- todo create/read/update/delete flow
- Flutter frontend connected to backend APIs
- backend validation, error handling, environment config, and tests
- frontend form validation and widget tests
- frontend polish for loading, empty, optimistic update, edit, logout, route guard, and auth flows
- 21 documented lessons, with lesson 21 covering auth success navigation and messaging polish

## Project Structure

```text
backend/                  Node.js backend
frontend/todoflutterapp/  Flutter frontend
docs/                     Learning docs and milestone lessons
PROGRESS.md               Current progress tracker
README.md                 Run instructions and lesson index
```

## Source Of Truth

When starting work, read these files first:

1. `PROGRESS.md`
2. `README.md`

Use `PROGRESS.md` as the source of truth for:

- what has already been completed
- what the current focus is
- what the next recommended steps are

Use `README.md` as the source of truth for:

- how to run the frontend and backend
- the learning path
- the overall repo layout

## Agent Expectations

Agents working in this repo should:

- preserve the project as a learning-friendly codebase
- prefer simple, readable solutions over clever ones
- keep backend and frontend structure consistent with existing patterns
- update documentation when a meaningful milestone is completed
- keep `PROGRESS.md` current after major work
- explain changes in beginner-friendly language when asked

## Recommended Workflow

1. Read `PROGRESS.md` and `README.md`.
2. Inspect the relevant frontend or backend files before making assumptions.
3. Make focused changes tied to a clear milestone or bug fix.
4. Run relevant tests when possible.
5. Update `PROGRESS.md` after meaningful changes.
6. If a new learning milestone is completed, add or update the related doc in `docs/`.
