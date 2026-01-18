# Refactor & Clean Command

Clean up dead code, unused files, and improve code quality after a coding session.

## Instructions

Execute the following cleanup tasks in order:

### Step 1: Identify Dead Code

Search for unused exports, functions, and variables:

```bash
# Find potentially unused exports (TypeScript/JavaScript)
grep -r "export " --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" . | head -50
```

Use the TypeScript compiler or your IDE's "find references" to verify what's actually unused.

### Step 2: Find Orphaned Files

Look for files that may no longer be imported anywhere:

```bash
# List all source files
find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | grep -v node_modules | grep -v ".d.ts"
```

For each file, verify it's imported somewhere or is an entry point.

### Step 3: Remove Unnecessary Markdown Files

Check for loose `.md` files that were created during development but aren't needed:

```bash
# Find markdown files (excluding standard ones)
find . -name "*.md" | grep -v node_modules | grep -v README | grep -v CHANGELOG | grep -v CONTRIBUTING | grep -v LICENSE
```

Review each file - delete if it was temporary documentation created during a session.

### Step 4: Clean Up Console Statements

Find and remove debug statements:

```bash
# Find console.log statements
grep -rn "console\\.log" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" . | grep -v node_modules
```

Remove any that aren't intentional logging.

### Step 5: Remove Commented Code

Search for large blocks of commented-out code:

```bash
# Find multi-line comments that look like code
grep -rn "^\\s*//.*function\\|^\\s*//.*const\\|^\\s*//.*return" --include="*.ts" --include="*.tsx" . | head -30
```

Delete commented code - git history preserves it if needed later.

### Step 6: Check for TODO/FIXME

List remaining todos that should be addressed or converted to issues:

```bash
grep -rn "TODO\\|FIXME\\|HACK\\|XXX" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" . | grep -v node_modules
```

### Step 7: Run Linter & Formatter

```bash
# If using npm/pnpm
npm run lint --fix 2>/dev/null || pnpm lint --fix 2>/dev/null || true
npm run format 2>/dev/null || pnpm format 2>/dev/null || true
```

### Step 8: Type Check

```bash
# TypeScript projects
npx tsc --noEmit
```

Fix any type errors introduced during the session.

### Step 9: Summary Report

Provide a summary of:
- Files deleted
- Dead code removed
- Console statements cleaned
- Type errors fixed
- Remaining TODOs (if any)

---

## Options

You can specify focus areas:

- `/refactor-clean dead-code` - Focus only on dead code removal
- `/refactor-clean console` - Focus only on console.log cleanup
- `/refactor-clean types` - Focus only on type errors
- `/refactor-clean full` - Run all steps (default)
