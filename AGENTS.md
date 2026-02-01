# AGENTS.md
# Universal AI agent instructions

## Project: {{PROJECT_NAME}}
Stack: Next.js 15 + TypeScript + AWS Amplify Gen2

## Commands
```
pnpm install    # Install dependencies
pnpm dev        # Development server
pnpm test       # Run tests (TDD required)
pnpm build      # Production build
```

## Architecture: Contract-First Slices
```
packages/contracts/   → Shared types (BUILD FIRST)
apps/web/            → Next.js frontend
amplify/functions/   → Lambda handlers
amplify/data/        → DynamoDB schema
```

## Rules
1. Import types from `@repo/contracts` only
2. Run `pnpm test` before any commit
3. Stay within your assigned slice directory
4. TDD: Write failing test → implement → verify
