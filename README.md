# Agent-First Project Template

Scaffolding for AI-native development with parallel agent orchestration, spec-driven design, and automated CI/CD.

## Features

- **OpenSpec** - Spec-driven development workflow for humans and AI agents
- **Parallel Slicing** - Contracts-first architecture with independent work slices
- **GitHub Actions** - Automatic linting, testing, and deployment
- **AWS Amplify** - Full-stack Next.js + Amplify integration out of the box
- **Agent Orchestration** - Coordinate AI agents across contracts, frontend, and backend

## Quick Start (5 minutes)

```bash
# Clone and setup
git clone https://github.com/yourusername/agent-template.git my-project
cd my-project
./scripts/setup.sh my-app
cd my-app

# Push to GitHub (GitHub Actions auto-starts)
git remote add origin <your-repo>
git push -u origin main

# Local development
echo "NEXT_PUBLIC_GOOGLE_CLIENT_ID=..." > .env.local
pnpm install
pnpm dev
```

Your app is live at `http://localhost:3000` and GitHub Actions is automatically testing every change!

## Full Documentation

| Document | Purpose |
|----------|---------|
| **[QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)** | ⚡ Quick answers to common questions |
| **[GETTING_STARTED.md](docs/GETTING_STARTED.md)** | 📖 Complete setup guide + API keys + environment variables |
| **[WORKFLOW.md](docs/WORKFLOW.md)** | 🔄 End-to-end development workflow + GitHub Actions CI/CD |
| **[AGENTS_AND_LLMS.md](docs/AGENTS_AND_LLMS.md)** | 🤖 Using different LLMs for different slices |
| **[SLICING.md](docs/SLICING.md)** | 🧩 Parallel development strategy |
| **AGENTS.md** | Agent instructions (universal) |
| **CLAUDE.md** | Claude-specific rules |

## Architecture Overview

```
my-app/
├── apps/web/                    # Next.js frontend
├── amplify/                     # AWS backend
│   ├── functions/              # Lambda handlers
│   ├── data/                   # DynamoDB schema
│   └── backend.ts              # Config
├── packages/contracts/          # Shared types (build first)
├── openspec/                   # Feature specifications
│   ├── specs/                 # Completed features
│   └── changes/               # Work in progress
├── .github/workflows/          # GitHub Actions CI/CD
├── docs/                       # Documentation
└── scripts/                    # Automation
```

## How It Works

### 1. Write Specs
Create feature specs in `openspec/changes/<feature>/`:
- `proposal.md` - What & why
- `design.md` - Architecture & types
- `tasks.md` - Implementation breakdown

**See [GETTING_STARTED.md](docs/GETTING_STARTED.md#using-openspec-for-features) for example**

### 2. Hand Off to Agents
```bash
cd ../slice-contracts
claude
# "Implement types from openspec/changes/user-auth/design.md"
```

### 3. GitHub Actions Tests Everything
- Lint & type-check on every push
- Run tests automatically
- Build production bundle
- Deploy to Amplify on main branch

**All automatic - no configuration needed!**

### 4. Deploy to Production
Merge to `main` → GitHub Actions automatically deploys to AWS Amplify

## What's Included

✅ Next.js 15 with TypeScript
✅ AWS Amplify Gen2 (Auth, API, Database)
✅ GitHub Actions workflows (CI/CD)
✅ TailwindCSS styling
✅ Monorepo with contracts pattern
✅ OpenSpec spec-driven development
✅ Parallel agent worktrees
✅ Pre-configured ESLint & TypeScript

## Getting Started

**Quick answers?** Start here:
→ [QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)

**New to this template?** See:
→ [GETTING_STARTED.md](docs/GETTING_STARTED.md)

**Understanding the workflow?** See:
→ [WORKFLOW.md](docs/WORKFLOW.md)

**Using different LLMs?** See:
→ [AGENTS_AND_LLMS.md](docs/AGENTS_AND_LLMS.md)

**Want to parallelize development?** See:
→ [SLICING.md](docs/SLICING.md)

## Typical Workflow

### Day 1: Write Spec
```bash
mkdir openspec/changes/user-profiles
# Create proposal.md, design.md, tasks.md
git add openspec/
git commit -m "spec: user profiles feature"
git push -u origin feat/user-profiles
# Create PR on GitHub
```

### Day 2: Contracts
```bash
cd ../slice-contracts
claude
# "Implement types from spec"
# Agent writes tests → code → commits
```

### Day 2-3: Frontend & Backend in Parallel
```bash
cd ../slice-frontend
claude  # Implement UI

cd ../slice-backend
claude  # Implement API
```

### Day 4: Integration
```bash
git checkout main
git pull
git merge feat/user-profiles
# GitHub Actions: Lint ✓ Test ✓ Build ✓
# Merge PR
# GitHub Actions: Deploy to Amplify ✓
```

## Environment Setup

### Local Development
Create `.env.local`:
```bash
NEXT_PUBLIC_GOOGLE_CLIENT_ID=your_google_client_id
NEXT_PUBLIC_GITHUB_CLIENT_ID=your_github_client_id
NEXT_PUBLIC_AMPLIFY_REGION=us-east-1
```

See [GETTING_STARTED.md - API Keys](docs/GETTING_STARTED.md#api-keys--environment-setup) for detailed setup.

### GitHub Actions (CI/CD)
Add these secrets to GitHub Settings → Secrets:
- `AWS_ROLE_TO_ASSUME` - IAM role for AWS access
- `AMPLIFY_APP_ID` - Amplify Console app ID
- `AMPLIFY_TOKEN` - Amplify CLI token

See [GETTING_STARTED.md - GitHub Secrets](docs/GETTING_STARTED.md#github-actions-secrets-setup) for setup steps.

## Common Commands

```bash
pnpm install              # Install dependencies
pnpm dev                  # Local development
pnpm test                 # Run tests (before push!)
pnpm lint --fix          # Fix linting errors
pnpm build               # Production build
pnpm type-check          # TypeScript validation

./scripts/orchestrate.sh create-all    # Create all slices
./scripts/orchestrate.sh status        # View worktrees
./scripts/orchestrate.sh clean         # Remove worktrees
```

## Troubleshooting

**GitHub Actions failing?**
→ [GETTING_STARTED.md - Troubleshooting](docs/GETTING_STARTED.md#troubleshooting)

**Environment variables wrong?**
→ [GETTING_STARTED.md - API Keys](docs/GETTING_STARTED.md#api-keys--environment-setup)

**OAuth not working?**
→ [GETTING_STARTED.md - OAuth Setup](docs/GETTING_STARTED.md#setting-up-oauth-providers)

**Worktrees not creating?**
→ Run from project root: `cd my-app && ./scripts/orchestrate.sh create-all`

## Key Concepts

### Contracts-First
Build `packages/contracts/` types first, then frontend and backend import from there. Ensures type safety across your app.

### OpenSpec
Structured specs that both humans and AI agents understand. Prevents miscommunication and keeps work aligned.

### Parallel Slicing
Use git worktrees to work on contracts, frontend, UI, and backend simultaneously without conflicts.

### Spec-Driven Implementation
Agents read specs and implement exactly what's specified. Update spec → update implementation automatically.

## Architecture Details

See [SLICING.md](docs/SLICING.md) for:
- Detailed architecture explanation
- How contracts ensure type safety
- Parallel development workflow
- Integration patterns
- Common pitfalls to avoid

## Next Steps

1. ✅ Clone repo and run `./scripts/setup.sh my-app`
2. ✅ Push to GitHub (GitHub Actions starts automatically)
3. 📖 Read [GETTING_STARTED.md](docs/GETTING_STARTED.md) for full setup
4. 📝 Create your first OpenSpec feature
5. 🤖 Start an agent: `cd ../slice-contracts && claude`
6. 🚀 Merge to main and deploy automatically!

## FAQ

**Do I need to configure GitHub Actions?**
No! It's pre-configured and runs automatically on every push.

**What API keys do I need?**
For local dev: Google & GitHub Client IDs (public)
For deployment: AWS role + Amplify app ID (in GitHub Secrets)
See [GETTING_STARTED.md](docs/GETTING_STARTED.md#api-keys--environment-setup)

**Can I use different LLMs for different tasks?**
Yes! Each slice can use a different LLM. You control which model/agent runs in each slice. The template uses Claude by default, but any compatible agent works.

**How do I deploy?**
Merge to `main` branch. GitHub Actions automatically deploys to AWS Amplify. Done!

**What about database migrations?**
Amplify handles DynamoDB schema automatically via the data model in `amplify/data/`.

## License

MIT - Built on the AWS Amplify Next template

---

**Questions?** Start with [GETTING_STARTED.md](docs/GETTING_STARTED.md) or check [WORKFLOW.md](docs/WORKFLOW.md) for detailed explanations.
