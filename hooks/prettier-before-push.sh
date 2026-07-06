#!/bin/bash
# Pre-push hook: verify prettier formatting on outgoing changes before git push.
# Deliberately does NOT auto-write or amend commits — it blocks with instructions
# so formatting fixes land as intentional, hook-verified commits.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only act on git push commands
if ! echo "$COMMAND" | grep -qE '^\s*git\s+push'; then
  exit 0
fi

CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
if [ -z "$CWD" ] || [ ! -d "$CWD" ]; then
  exit 0
fi

# Only run if the project uses prettier (config file or package.json key)
HAS_PRETTIER=0
for f in .prettierrc .prettierrc.js .prettierrc.json .prettierrc.yml .prettierrc.yaml .prettierrc.toml prettier.config.js prettier.config.mjs prettier.config.cjs; do
  [ -f "$CWD/$f" ] && HAS_PRETTIER=1 && break
done
if [ "$HAS_PRETTIER" -eq 0 ]; then
  [ -f "$CWD/package.json" ] && grep -q '"prettier"' "$CWD/package.json" 2>/dev/null && HAS_PRETTIER=1
fi
[ "$HAS_PRETTIER" -eq 0 ] && exit 0

# Check only files that differ from the upstream (or last commit as fallback)
cd "$CWD" || exit 0
RANGE=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
if [ -n "$RANGE" ]; then
  FILES=$(git diff --name-only --diff-filter=ACMR "$RANGE"...HEAD 2>/dev/null)
else
  FILES=$(git diff --name-only --diff-filter=ACMR HEAD~1 2>/dev/null)
fi
[ -z "$FILES" ] && exit 0

if ! echo "$FILES" | xargs npx prettier --check >/dev/null 2>&1; then
  echo "BLOCKED: outgoing files are not prettier-formatted." >&2
  echo "Run: npx prettier --write <files>, commit the formatting change, then push." >&2
  exit 2
fi

exit 0
