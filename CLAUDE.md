# CLAUDE.md
# Keep under 150 instructions

## Non-Negotiables
- NEVER add dependencies without approval
- ALWAYS import types from `@repo/contracts`
- ALWAYS run tests after code changes

## TDD Protocol
1. Write failing test first
2. Confirm test fails (RED)
3. Implement minimal code
4. Confirm test passes (GREEN)
5. Refactor only after green

## Slice Boundaries
Check worktree branch to know your slice:
- `slice/contracts` → packages/contracts/
- `slice/frontend` → apps/web/
- `slice/backend` → amplify/functions/

## Before Finishing
Update PROGRESS.md with completed tasks.
