---
name: tdd
description: Enforce TDD with Red-Green-Refactor cycle
---

# TDD Workflow

## RED 🔴 - Write Failing Test
```typescript
import { describe, it, expect } from 'vitest'
import { myFunction } from '../myFunction'

describe('myFunction', () => {
  it('should return expected result', () => {
    expect(myFunction('input')).toBe('expected')
  })
})
```

Run: `pnpm test` → Must see FAIL

## GREEN 🟢 - Minimal Implementation
Write ONLY what makes the test pass.
No extras. No "nice to haves."

Run: `pnpm test` → Must see PASS

## REFACTOR 🔵 - Clean Up
Only after green. Run tests again.
