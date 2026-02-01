# Parallel Agent Slicing Strategy

## Core Principle
Slice by **contract boundaries** so agents work independently.

## The Slices
```
┌─────────────────────────────────────────┐
│          CONTRACTS (Do First)           │
│    Types, Schemas, API Definitions      │
└─────────────────────────────────────────┘
                    │
    ┌───────────────┼───────────────┐
    ▼               ▼               ▼
┌─────────┐   ┌─────────┐   ┌─────────┐
│FRONTEND │   │   UI    │   │ BACKEND │
│apps/web │   │packages │   │ amplify │
│         │   │   /ui   │   │/functions│
└─────────┘   └─────────┘   └─────────┘
```

## Execution Order
1. **Contracts** (blocking) - Define all types first
2. **Parallel** - Frontend, UI, Backend work simultaneously  
3. **Integrate** - Wire together, E2E tests

## Conflict Prevention
✅ Each agent edits only its directory
✅ Shared types are read-only imports
❌ Never modify package.json in parallel

## Worktree Commands
```bash
./scripts/orchestrate.sh create-all   # Create all slices
./scripts/orchestrate.sh status       # Check status
./scripts/orchestrate.sh sync         # Sync contracts
./scripts/orchestrate.sh clean        # Clean up
```
