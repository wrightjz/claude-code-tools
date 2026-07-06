# Coding Style Rules

## General Principles
- Prefer immutability — `const` over `let`, avoid mutations.
- Keep functions small and single-responsibility; descriptive names that reveal intent.
- No magic numbers OR strings — use named constants; group related constants in `as const` objects with a derived type:
  ```typescript
  export const ErrorKey = { NOT_FOUND: "not_found", SERVER_ERROR: "server_error" } as const;
  export type ErrorKey = (typeof ErrorKey)[keyof typeof ErrorKey];
  ```

## Naming
- camelCase for acronyms in identifiers: `toApi`, `fromHtml`, `parseJson` (not `toAPI`). Exception: ALL_CAPS constants (`API_URL`).
- Booleans read as questions: `isLoading`, `hasError`, `canSubmit`.

## Comments
- Comment WHY, not WHAT: early returns with non-obvious conditions, non-evident business logic, workarounds/edge cases. Code should self-document the rest.

## DRY
- Check for existing utilities before writing new code.
- Extract patterns repeated 2+ times into shared utilities, colocated near primary usage.
- Standardize cross-cutting concerns (HTTP error handling, Sentry logging, API calls) into single utility functions — improves testability too.

## TypeScript
- Strict mode always; no `any` without explicit justification.
- Zod for runtime validation, not just types. Interfaces for objects, types for unions/primitives.
- Explicit return types on exported functions.

## Files & Imports
- One component/class per file; keep files under 300 lines. Use path aliases (`@/*`, `@lib/*`, `@app/*`); index files for clean exports.
- Prettier import order: external packages → internal aliases → relative imports.

## Quality
- No `console.log` in production code; no commented-out code (git has history).
- Handle errors explicitly — no silent catches; always await async operations.
- Log meaningful context with errors (status, request IDs); use structured error types (`throw new HTTPError(response.status, response.statusText)`).

## React/Next.js
- App Router patterns; prefer Server Components; `'use client'` only when needed.

## Formatting
- Prettier handles formatting: 100-char width, single quotes, es5 trailing commas. No emojis in code comments or identifiers.
