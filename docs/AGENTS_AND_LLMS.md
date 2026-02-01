# Using Different LLMs and Agents

By default, this template uses Claude AI agents for all slices. However, you can configure different LLMs/agents for different slices based on the task.

## Overview

Each slice (contracts, frontend, backend, etc.) can independently use:
- **Claude** (default) - Best for architecture, type design, complex logic
- **GPT-4** - Good for general implementation, JavaScript/Python
- **Other LLMs** - Any compatible agent that supports your tech stack

The key insight: **Pick the right tool for the task**

## Recommended Configuration

Here's a suggested setup for optimal results:

| Slice | Task | Recommended LLM | Why |
|-------|------|-----------------|-----|
| **contracts** | Type definitions | Claude | Excellent at architecture and type safety |
| **frontend** | UI/React | Claude or GPT-4 | Both strong at React, Claude better at complex state |
| **backend** | API/Lambda | Claude | Strong at API design and business logic |
| **data** | Schema/Database | Claude | Excellent at data modeling and relationships |
| **ui** | Component library | Claude or GPT-4 | Both good, GPT-4 faster for simple components |

## How to Use Different LLMs

### Option 1: Claude Code IDE (Recommended)

If you're using Claude Code IDE with multiple terminals:

```bash
# Terminal 1: Contracts with Claude
cd ../slice-contracts
claude  # Uses Claude

# Terminal 2: Frontend with GPT-4 (if available in your IDE)
cd ../slice-frontend
gpt-4-code  # Uses GPT-4 (if available)

# Terminal 3: Backend with Claude
cd ../slice-backend
claude  # Uses Claude
```

### Option 2: Create Agent-Specific Configuration

Create `.llm-config.json` in each slice:

```json
// ../slice-contracts/.llm-config.json
{
  "agent": "claude",
  "model": "claude-opus",
  "context": "TypeScript type definitions and contracts",
  "rules": [
    "Define types first",
    "Use strict typing",
    "Document complex types",
    "Export from index.ts"
  ]
}
```

```json
// ../slice-frontend/.llm-config.json
{
  "agent": "claude",
  "model": "claude-sonnet",
  "context": "Next.js React components",
  "rules": [
    "Use React Server Components where possible",
    "Implement accessibility",
    "Mobile-first responsive design",
    "Import types from @repo/contracts"
  ]
}
```

```json
// ../slice-backend/.llm-config.json
{
  "agent": "claude",
  "model": "claude-opus",
  "context": "AWS Lambda functions and GraphQL API",
  "rules": [
    "Use Amplify Data types",
    "Export from @repo/contracts",
    "Write unit tests",
    "Include error handling"
  ]
}
```

### Option 3: Wrapper Script for Agent Selection

Create `run-agent.sh` to automatically select the right LLM:

```bash
#!/bin/bash
# scripts/run-agent.sh

SLICE=$(basename $(pwd))

case $SLICE in
  slice-contracts)
    echo "🔵 Starting Claude for Contracts..."
    claude
    ;;
  slice-frontend)
    echo "🟢 Starting Claude for Frontend..."
    claude
    ;;
  slice-backend)
    echo "🔵 Starting Claude for Backend..."
    claude
    ;;
  slice-data)
    echo "🟣 Starting Claude for Data..."
    claude
    ;;
  slice-ui)
    echo "🟡 Starting Claude for UI Components..."
    claude
    ;;
  *)
    echo "Unknown slice: $SLICE"
    echo "Using default agent (Claude)"
    claude
    ;;
esac
```

Make it executable:
```bash
chmod +x scripts/run-agent.sh
```

Use it:
```bash
cd ../slice-contracts
../../scripts/run-agent.sh
```

## Why Use Different LLMs?

### Cost Optimization
- **Sonnet** (cheaper) for UI components
- **Opus** (more capable) for complex contracts and APIs

### Speed vs Quality
- **Faster models** for straightforward implementation
- **Stronger models** for architecture and design decisions

### Task-Specific Strengths
- Claude excels at: Type design, architecture, complex business logic
- GPT-4 excels at: General coding, quick implementation
- Specialized models: Code-specific models may be better for pure implementation

### Parallel Development
Different models can work simultaneously without conflicts:
```
Claude contracts (complex type design)
  ↓
GPT-4 frontend (UI implementation)
  ↓
Claude backend (API logic)
  ↓
All layers work in parallel!
```

## Best Practices

### 1. Start with Claude for Contracts
Contracts are critical - use your best model here:
```bash
cd ../slice-contracts
claude  # Best model first - ensures solid foundation
```

### 2. Use Complementary Models
Once contracts are stable, frontend and backend can use different models:
```bash
# Contracts set types → frontend/backend don't need to change them
cd ../slice-frontend
gpt-4  # Can work independently

cd ../slice-backend
claude  # Can work independently
```

### 3. Pin Model Versions in Specs

In your `openspec/changes/<feature>/design.md`, specify which model for each task:

```markdown
## Implementation

### Contracts (Claude Opus)
- Define User, Post, Comment types
- Must be type-safe and extensible
- Takes: 1 day

### Frontend (Claude Sonnet)
- Build UI components
- Reference contract types
- Takes: 2 days

### Backend (Claude Opus)
- GraphQL API implementation
- Complex business logic
- Takes: 1.5 days
```

Then agents know which model to use (you can tell them in the chat).

### 4. Use CLAUDE.local.md for Slice-Specific Rules

Each slice has `CLAUDE.local.md` - customize it for different models:

```markdown
# Slice: Frontend

## Model: Claude Sonnet
Use this model for frontend implementation.
Sonnet is fast and good at React code.

## Rules
1. Import types from @repo/contracts
2. Use React Server Components
3. Implement accessibility
4. Mobile-first responsive design
5. Keep components under 300 lines
```

## Fixing the orchestrate.sh Error

Your error was:

```
fatal: not a git repository (or any of the parent directories): .git
```

This happened because `orchestrate.sh` was called from outside a git repository. **We've already fixed this in the updated script.**

The fix checks if you're in a git repo:

```bash
# Ensure we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: Not in a git repository. Run this from the project root."
  exit 1
fi
```

**Correct usage:**
```bash
cd my-app  # Must be in the git repo root
./scripts/orchestrate.sh create-all
```

## Advanced: Custom Agent Integration

If you want to integrate a custom agent or different LLM:

### 1. Create Agent Wrapper

```bash
# scripts/agents/claude-wrapper.sh
#!/bin/bash
# Wraps Claude with slice-specific context

SLICE=$(basename $(pwd))
CLAUDE_PROMPT="You are implementing $SLICE for a Next.js + Amplify app. Follow CLAUDE.local.md rules."

echo "$CLAUDE_PROMPT" | claude
```

### 2. Create Agent Selector

```bash
# scripts/agents/select-agent.sh
#!/bin/bash

SLICE=$1
MODEL=${2:-"claude-opus"}

case $SLICE in
  contracts)
    echo "Using Claude Opus for contracts"
    claude --model opus
    ;;
  frontend)
    echo "Using Claude Sonnet for frontend"
    claude --model sonnet
    ;;
  *)
    claude
    ;;
esac
```

### 3. Integrate with Orchestrate

Modify `orchestrate.sh` to use agent selector:

```bash
cat > "$WORKTREE/CLAUDE.local.md" << EOF
# Slice: $SLICE

Model: ${MODEL:-claude-opus}
Task: Implement $SLICE according to contracts and specs

Rules from CLAUDE.md apply here.
EOF

# Could call: ../../scripts/agents/select-agent.sh $SLICE
```

## FAQ

**Can I switch models mid-project?**
Yes! Each task can use a different model. Just switch which agent you use in each terminal.

**What if different models produce incompatible code?**
Contracts enforce type compatibility. As long as types match, implementation details don't matter.

**Which model is best for what?**

| Task | Model | Reason |
|------|-------|--------|
| Type design | Claude Opus | Best at architecture |
| React components | Claude Sonnet | Fast, good at React |
| GraphQL API | Claude Opus | Complex logic |
| Testing | Claude | Excellent at test coverage |
| UI components | Any | All are good |
| Performance optimization | Claude Opus | Requires deep thinking |

**Can I use free models?**
The template is model-agnostic. You can use any agent/LLM that supports your tech stack.

**How do I ensure consistency?**
- Contracts define types (single source of truth)
- Specs define behavior (all models follow same spec)
- Tests verify correctness (all models must pass)

## Example: Multi-Model Workflow

### Scenario: Building User Authentication

**Day 1: Contracts with Claude Opus** (best at architecture)
```bash
cd ../slice-contracts
claude  # "Implement User, Session, AuthContext types from spec"
# Agent: Writes types with extensive generics and union types
# Quality: Excellent, battle-tested patterns
```

**Day 2: Frontend with Claude Sonnet** (fast React implementation)
```bash
cd ../slice-frontend
claude --model sonnet  # "Implement login UI from spec"
# Agent: Writes React components quickly
# Quality: Good, matches type contracts
```

**Day 2: Backend with Claude Opus** (complex business logic)
```bash
cd ../slice-backend
claude --model opus  # "Implement auth API from spec"
# Agent: Writes robust GraphQL mutations and auth logic
# Quality: Excellent, handles edge cases
```

**Day 4: Integration** (all models produced compatible code)
```bash
git merge feat/user-auth
# GitHub Actions tests everything
# All three implementations work together!
```

The models worked in parallel on different parts, using contracts as the integration point.

## Summary

- **One model per slice** for simplicity, or
- **Different models per task** for optimization
- **Contracts** ensure all models are compatible
- **Specs** ensure all models build the same thing
- **Tests** verify everything works together

The key is that models never need to communicate directly - they communicate through types and specs.
