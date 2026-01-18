# Coding Style Rules

## General Principles
- Prefer immutability - use `const` over `let`, avoid mutations
- Keep functions small and focused (single responsibility)
- Use descriptive names that reveal intent
- No magic numbers - use named constants

## TypeScript
- Strict mode always enabled
- No `any` types without explicit justification
- Use Zod for runtime validation, not just TypeScript types
- Prefer interfaces for objects, types for unions/primitives
- Always define return types for exported functions

## File Organization
- One component/class per file (with reasonable exceptions)
- Keep files under 300 lines - split if larger
- Use path aliases (`@/*`, `@lib/*`, `@app/*`)
- Group related functionality in directories
- Use index files for clean exports

## Imports
Use Prettier import sorting:
```typescript
// 1. External packages
import { z } from 'zod';
import express from 'express';

// 2. Internal aliases
import { handleRequest } from '@lib/handlers';
import { AppConfig } from '@/types';

// 3. Relative imports
import { helper } from './utils';
```

## Code Quality
- No `console.log` in production code (use proper logging)
- No commented-out code - delete it (git has history)
- Handle errors explicitly - no silent catches
- Always await async operations (no floating promises)

## React/Next.js
- Use App Router patterns (not Pages Router)
- Prefer Server Components where possible
- Use `'use client'` directive only when needed
- Follow React 18+ patterns (concurrent features)

## Tailwind CSS
- Consider using semantic design tokens for consistency
- Prefer React Aria or Radix for accessible components
- Use consistent spacing and typography scales

## Formatting
- Let Prettier handle spacing and formatting
- No emojis in code comments or variable names
- 100 character line width
- Single quotes, trailing commas (es5)
