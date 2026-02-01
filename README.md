# Agent-First Project Template

Scaffolding for AI-native development with parallel agent orchestration.

## Quick Start

```bash
# Clone and setup
npx degit your-username/agent-template my-project
cd my-project
./scripts/setup.sh my-app

# Create parallel worktrees
cd my-app
./scripts/orchestrate.sh create-all

# Start agents (separate terminals)
cd ../slice-contracts && claude
cd ../slice-frontend && claude
```

## Parallel Slicing Strategy

1. **Contracts first** - Define types before implementation
2. **Parallel work** - Frontend, UI, Backend in isolation
3. **Integrate** - PR merge + E2E tests

See `docs/SLICING.md` for full strategy.

## Files

| File | Purpose |
|------|---------|
| AGENTS.md | Universal agent instructions |
| CLAUDE.md | Claude-specific rules |
| .claude/skills/ | On-demand playbooks |
| openspec/ | Spec-driven development |
| scripts/ | Setup & orchestration |

## License
MIT
