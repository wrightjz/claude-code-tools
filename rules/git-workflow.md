# Git Workflow Rules

## Commit Messages
Conventional commits (semantic release): `type(scope): description` — types `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`. Subject under 72 chars; body explains why, not what.
- `feat:` → minor bump, `fix:` → patch, `BREAKING CHANGE:` → major.

## Branches & PRs
- Feature branches from `main`, descriptive names (`feature/add-auth`), short-lived, deleted after merge.
- PRs focused and reviewable (under ~400 lines), clear description, link Linear issues.

## Before Committing
- Run `pnpm typecheck`, `pnpm lint`, `pnpm test`; review your own diff.
- Never commit secrets.
