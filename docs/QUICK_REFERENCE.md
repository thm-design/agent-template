# Quick Reference Guide

Fast answers to common questions and issues.

## Setup

### "I ran setup.sh and got an error"

**Verify you're in the right directory:**
```bash
# ✓ Correct
cd my-project
./scripts/setup.sh my-app

# ✗ Wrong
./scripts/setup.sh my-app  # Can't find scripts/
```

### "orchestrate.sh says 'not a git repository'"

**Make sure you're in the git repo root:**
```bash
# ✓ Correct
cd my-app
./scripts/orchestrate.sh create-all

# ✗ Wrong
cd ..
./orchestrate.sh create-all  # Not in git repo
```

### "No .env.local file"

**Create it in project root:**
```bash
cd my-app
echo "NEXT_PUBLIC_GOOGLE_CLIENT_ID=..." > .env.local
```

## Development

### "I want to start coding"

```bash
cd my-app
./scripts/orchestrate.sh create-all  # Create all slices

cd ../slice-contracts
claude  # Start agent for types first
```

### "GitHub Actions are failing"

1. **Go to:** Your PR → "Checks" tab
2. **Find:** Red ✗ next to failed check
3. **Expand:** Click to see error message
4. **Fix locally:**
   ```bash
   pnpm lint --fix    # Linting error
   pnpm test          # Test failure
   pnpm build         # Build error
   ```
5. **Push again:**
   ```bash
   git add .
   git commit -m "fix: [your fix]"
   git push
   ```

### "Tests won't run"

```bash
# Clean and reinstall
rm -rf node_modules pnpm-lock.yaml
pnpm install

# Run tests
pnpm test

# Run specific test file
pnpm test filename.test.ts
```

### "Local dev server won't start"

```bash
# Kill existing processes
killall node

# Clear caches
rm -rf .next node_modules/.vite

# Reinstall and restart
pnpm install
pnpm dev
```

## Deployment

### "How do I deploy?"

Just merge to `main`. GitHub Actions automatically deploys.

```bash
git push origin feat/my-feature
# Create PR on GitHub
# Merge when checks pass
# Amplify deploys automatically
```

### "Where do I see the deployed app?"

1. Go to [Amplify Console](https://console.aws.amazon.com/amplify)
2. Select your app
3. Click domain link (top right)

### "Deployment failed"

1. **Check Amplify logs:**
   - Console → Your app → Deployments tab
   - Click failed deployment
   - Scroll to see error

2. **Common issues:**
   - Missing GitHub Secrets → Add in repo Settings
   - Build command failed → Run `pnpm build` locally
   - Missing .env → Add to GitHub Secrets

## API Keys & Environment

### "What env variables do I need?"

**Local development (`.env.local`):**
```bash
NEXT_PUBLIC_GOOGLE_CLIENT_ID=abc...
NEXT_PUBLIC_GITHUB_CLIENT_ID=def...
NEXT_PUBLIC_AMPLIFY_REGION=us-east-1
```

**GitHub deployment (Settings → Secrets):**
```
AWS_ROLE_TO_ASSUME=arn:aws:iam::...
AMPLIFY_APP_ID=d...
AMPLIFY_TOKEN=...
```

See [GETTING_STARTED.md](GETTING_STARTED.md#api-keys--environment-setup) for full details.

### "Where do I get Google Client ID?"

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create OAuth credentials (web app)
3. Copy Client ID
4. Add to `.env.local`:
   ```bash
   NEXT_PUBLIC_GOOGLE_CLIENT_ID=your_id
   ```

### "Where do I get GitHub Client ID?"

1. Go to GitHub Settings → Developer settings → OAuth Apps
2. Create new OAuth app
3. Copy Client ID
4. Add to `.env.local`:
   ```bash
   NEXT_PUBLIC_GITHUB_CLIENT_ID=your_id
   ```

### "Which variables are secrets?"

✅ **Safe to commit** (public):
```
NEXT_PUBLIC_*  (any prefixed with NEXT_PUBLIC_)
AMPLIFY_REGION
```

❌ **Never commit** (secrets):
```
AWS_SECRET_ACCESS_KEY
GOOGLE_CLIENT_SECRET
GITHUB_CLIENT_SECRET
DATABASE_PASSWORD
API_KEYS
Private keys
```

## Git & Branching

### "How do I create a feature?"

```bash
# 1. Create spec
mkdir openspec/changes/my-feature
# Create proposal.md, design.md, tasks.md

# 2. Commit spec
git add openspec/
git commit -m "spec: my feature"

# 3. Create branch
git checkout -b feat/my-feature
git push -u origin feat/my-feature

# 4. Implement (in separate slices)
cd ../slice-contracts
claude  # Implement types

# 5. Merge when done
git checkout main
git merge feat/my-feature
```

### "How do I work on different slices simultaneously?"

```bash
# Terminal 1: Contracts
cd ~/projects/my-app
git worktree list  # See all worktrees

cd ../slice-contracts
claude

# Terminal 2: Frontend (same time!)
cd ~/projects/my-app
cd ../slice-frontend
claude

# They work in parallel without conflicts!
```

### "I messed up a commit"

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Fix and recommit
git add .
git commit -m "fixed message"
git push --force-with-lease
```

## Specs (OpenSpec)

### "How do I write a spec?"

Create three files in `openspec/changes/<feature>/`:

**proposal.md** - What & why
```markdown
# Feature Name

## What
One-sentence description

## Why
Why it matters

## Success Criteria
- ✓ Criterion 1
- ✓ Criterion 2

## Scope
What changes, what doesn't
```

**design.md** - How
```markdown
# Design

## Types
```typescript
export interface MyType {
  id: string;
  name: string;
}
```

## API
- GraphQL mutations/subscriptions
- REST endpoints

## Data Model
- DynamoDB tables
- Relationships
```

**tasks.md** - Tasks
```markdown
# Tasks

## Phase 1: Contracts (1 day)
- [ ] Define types
- [ ] Tests

## Phase 2: Frontend (1 day)
- [ ] Create components
- [ ] Integration tests

## Phase 3: Backend (1.5 days)
- [ ] Implement API
- [ ] Unit tests
```

See [GETTING_STARTED.md](GETTING_STARTED.md#using-openspec-for-features) for full example.

### "I finished a feature, now what?"

```bash
# 1. Archive the spec
mv openspec/changes/my-feature/ openspec/specs/completed/my-feature/

# 2. Commit
git add openspec/
git commit -m "docs: archive my-feature spec"

# 3. Clean up worktrees
./scripts/orchestrate.sh clean

# 4. Ready for next feature!
```

## Multiple LLMs

### "Can I use different models for different slices?"

Yes! See [AGENTS_AND_LLMS.md](AGENTS_AND_LLMS.md) for full guide.

**Quick example:**
```bash
# Contracts with Claude (best for types)
cd ../slice-contracts
claude

# Frontend with faster model
cd ../slice-frontend
gpt-4  # If you prefer

# Backend with Claude (complex logic)
cd ../slice-backend
claude
```

### "Which model should I use for what?"

| Task | Model |
|------|-------|
| Type design | Claude Opus |
| React UI | Claude Sonnet or GPT-4 |
| API logic | Claude Opus |
| Testing | Claude |
| Simple components | Any |

See [AGENTS_AND_LLMS.md](AGENTS_AND_LLMS.md) for details.

## Troubleshooting Index

| Problem | Solution |
|---------|----------|
| "not a git repository" | Run from git repo root (e.g., `cd my-app`) |
| GitHub Actions failing | Check PR "Checks" tab for error |
| Tests won't run | `rm -rf node_modules && pnpm install` |
| Local dev won't start | Kill node, clear `.next`, restart |
| OAuth not working | Verify Client IDs in `.env.local` |
| Deployment failed | Check Amplify Console logs |
| Worktrees not creating | Use `./scripts/orchestrate.sh create-all` |
| Missing environment vars | Create `.env.local` or add GitHub Secrets |

## Documentation Map

| Need | Document |
|------|----------|
| First time setup | [GETTING_STARTED.md](GETTING_STARTED.md) |
| Full workflow | [WORKFLOW.md](WORKFLOW.md) |
| GitHub Actions | [WORKFLOW.md - GitHub Actions](WORKFLOW.md#3-github-actions-cicd-pipeline) |
| Parallel development | [SLICING.md](SLICING.md) |
| OpenSpec guide | [GETTING_STARTED.md - OpenSpec](GETTING_STARTED.md#using-openspec-for-features) |
| Multi-LLM setup | [AGENTS_AND_LLMS.md](AGENTS_AND_LLMS.md) |
| Quick answers | [QUICK_REFERENCE.md](QUICK_REFERENCE.md) (this file) |

## Common Commands Cheat Sheet

```bash
# Setup
./scripts/setup.sh my-app        # Create new project
cd my-app

# Development
pnpm install                     # Install deps
pnpm dev                         # Start local server
pnpm test                        # Run tests
pnpm lint --fix                 # Fix linting
pnpm build                       # Production build
pnpm type-check                 # TypeScript check

# Slices
./scripts/orchestrate.sh create-all  # Create all slices
./scripts/orchestrate.sh status      # View worktrees
./scripts/orchestrate.sh clean       # Remove slices

# Git & GitHub
git status                       # See changes
git add .                        # Stage changes
git commit -m "msg"             # Create commit
git push                        # Push to GitHub
git checkout -b feat/name       # Create branch

# Agents
cd ../slice-contracts           # Go to slice
claude                          # Start agent
# Tell agent what to implement
```

## Getting Help

1. **Check this guide** - You're reading it!
2. **Check GETTING_STARTED.md** - Setup and basic questions
3. **Check WORKFLOW.md** - Detailed process guide
4. **Check GitHub Actions** - PR "Checks" tab for errors
5. **Check Amplify Console** - Deployment errors
6. **Check .env.local** - Missing environment variables

## Next Steps

- ✅ Read this quick reference
- 📖 Read [GETTING_STARTED.md](GETTING_STARTED.md) for full setup
- 🚀 Run `./scripts/setup.sh my-app`
- 📝 Create your first OpenSpec
- 🤖 Start an agent: `cd ../slice-contracts && claude`
