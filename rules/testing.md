# Testing Rules

## Recommended Testing Stack
- **Framework**: Vitest 2.x (fast, modern, Vite-native)
- **React Testing**: `@testing-library/react`
- **API Mocking**: Mock Service Worker (MSW 2.x)
- **E2E**: Playwright
- **Coverage**: `@vitest/coverage-v8`

## Vitest Configuration
```javascript
export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    environment: 'node',
    globals: true,
    setupFiles: ['./src/__tests__/vitest/setup.ts'],
    include: ['src/__tests__/vitest/**/*.test.{ts,tsx}'],
    testTimeout: 100000,
  },
});
```

## Test-Driven Development
- Write tests before implementation when appropriate
- Each test should test one thing
- Tests must be independent and deterministic
- Use descriptive test names that explain expected behavior

## Coverage Goals
- Focus on critical paths (not arbitrary percentages)
- 100% on business logic and utilities
- Integration tests for action handlers
- E2E for user-facing workflows

## Test Structure
- Arrange, Act, Assert pattern
- Use factories/fixtures for test data
- Mock external dependencies (APIs, databases)
- Keep tests fast - mock slow operations

## What to Test
- API endpoints with various inputs
- Business logic and utility functions
- Error handling and validation
- Edge cases and boundary conditions
- Integration points with external services
