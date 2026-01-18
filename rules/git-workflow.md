# Git Workflow Rules

## Commit Messages
Use conventional commits with semantic release:
- Format: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Keep subject line under 72 characters
- Body explains "why" not "what" (code shows what)

Examples:
```
feat(auth): add OAuth2 login flow
fix(api): handle rate limiting in requests
docs(readme): update installation instructions
refactor(utils): extract common helpers
```

## Branching
- Create feature branches from `main`
- Use descriptive branch names: `feature/add-auth`, `fix/login-bug`
- Keep branches short-lived - merge frequently
- Delete branches after merging

## Before Committing
- Run `pnpm typecheck` (tsc --noEmit)
- Run `pnpm lint`
- Run `pnpm test`
- Review your own diff before pushing
- Never commit secrets or sensitive data

## Pull Requests
- Keep PRs focused and reviewable (under 400 lines ideal)
- Write clear PR descriptions with context
- Link related issues (GitHub, Linear, Jira, etc.)
- Request reviews from relevant team members
- Use CI/CD for automated checks

## Semantic Release
Commits trigger automatic versioning:
- `feat:` → minor version bump
- `fix:` → patch version bump
- `BREAKING CHANGE:` → major version bump

## Tools
- `git-cz` for guided commit creation
- Husky for pre-commit hooks
- lint-staged for staged file linting
- commitlint for message validation
