# Security Rules

## Secrets Management
- NEVER hardcode API keys, passwords, tokens, or credentials in code
- Use environment variables or secret management services
- Check for `.env` files before committing - they should be in `.gitignore`
- If you see credentials in code, immediately flag and remove them

## Input Validation
- Validate all user inputs at system boundaries
- Sanitize inputs before database queries (prevent SQL injection)
- Escape outputs in HTML contexts (prevent XSS)
- Use parameterized queries, never string concatenation for SQL

## Authentication & Authorization
- Never store passwords in plain text
- Use established auth libraries (don't roll your own crypto)
- Implement proper session management
- Check authorization on every protected endpoint

## Dependencies
- Be cautious with new dependencies - verify package authenticity
- Keep dependencies updated to patch known vulnerabilities
- Prefer well-maintained packages with active communities
