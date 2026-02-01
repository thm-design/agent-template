# Getting Started with Agent Template

This guide walks you through setting up your first project, understanding the workflow, and getting agents working together.

## Quick Setup (5 minutes)

### 1. Create Your Project

```bash
git clone https://github.com/yourusername/agent-template.git my-project
cd my-project
./scripts/setup.sh my-app
cd my-app
```

This creates a Next.js + AWS Amplify app with agent orchestration ready to go.

### 2. Initialize Git & GitHub Actions

The setup script already initializes git. Now push to GitHub:

```bash
git remote add origin https://github.com/yourusername/my-app.git
git push -u origin main
```

**GitHub Actions automatically starts running on your PR and main branch** - no setup needed!

### 3. Set Up Environment Variables

Create `.env.local` in your project root:

```bash
# Amplify (auto-detected from amplify/ folder)
NEXT_PUBLIC_AMPLIFY_REGION=us-east-1

# OAuth (only needed if using social login)
NEXT_PUBLIC_GOOGLE_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID
NEXT_PUBLIC_GITHUB_CLIENT_ID=YOUR_GITHUB_CLIENT_ID
```

**Never commit `.env.local`** - it's in `.gitignore`

### 4. Start Local Development

```bash
pnpm install
pnpm dev
```

Visit `http://localhost:3000` to see your app.

---

## Understanding the Architecture

### File Structure

```
my-app/
├── apps/web/                  # Next.js frontend
├── amplify/                   # AWS Amplify backend
│   ├── functions/            # Lambda handlers
│   ├── data/                 # DynamoDB schema
│   └── backend.ts            # Amplify config
├── packages/contracts/        # Shared TypeScript types
├── openspec/                 # Feature specifications
│   ├── specs/               # Completed features
│   └── changes/             # Work in progress
├── .github/
│   └── workflows/           # GitHub Actions CI/CD
├── docs/                    # Documentation
└── scripts/                 # Automation tools
```

### The Three Layers

**1. Contracts** (`packages/contracts/`)
- Shared TypeScript types
- **Build this first** before other slices
- Example: `User`, `Post`, `AuthContext`
- All slices import from here

**2. Frontend** (`apps/web/`)
- Next.js React app
- Uses types from contracts
- Talks to API via Amplify

**3. Backend** (`amplify/`)
- AWS Lambda functions
- DynamoDB database
- GraphQL API
- Uses types from contracts

---

## How GitHub Actions Works

### Automatic on Every Push

Your code is automatically:

1. **Linted** - ESLint checks code style
2. **Type checked** - TypeScript validation
3. **Tested** - Unit tests run
4. **Built** - Production bundle created

If any step fails, you'll see a red ✗ on your PR - fix it and push again.

### Automatic on Merge to Main

1. All checks run again
2. Deployed to AWS Amplify
3. E2E tests run against live deployment

### Viewing Results

In GitHub:
1. Go to your PR
2. Click "Checks" tab
3. Expand each check to see logs
4. Red ✗ = fix needed
5. Green ✓ = all good

---

## Using OpenSpec for Features

### What is a Spec?

A spec is a shared design document that humans and AI agents both understand. It includes:
- What feature you're building
- Why it matters
- How it should work
- Task breakdown for implementation

### Creating Your First Spec

1. Create the folder structure:
```bash
mkdir -p openspec/changes/my-feature
```

2. Create `openspec/changes/my-feature/proposal.md`:
```markdown
# My Feature

## What
Add user notifications to the app

## Why
Users need to know when someone follows them

## Success Criteria
- Users receive in-app notifications
- Notifications persist in database
- Mark as read functionality
```

3. Create `openspec/changes/my-feature/design.md`:
```markdown
# Design

## Types (packages/contracts/)
```typescript
export interface Notification {
  id: string;
  userId: string;
  message: string;
  read: boolean;
  createdAt: Date;
}
```

## API Changes
- Add GraphQL mutation: `createNotification`
- Add GraphQL subscription: `onNotification`

## Database
- Create `Notification` table in DynamoDB
```

4. Create `openspec/changes/my-feature/tasks.md`:
```markdown
# Tasks

## Contracts (1 day)
- [ ] Define Notification type
- [ ] Define NotificationService interface
- [ ] Write unit tests

## Backend (1.5 days)
- [ ] Create DynamoDB Notification table
- [ ] Implement GraphQL mutations
- [ ] Implement subscriptions
- [ ] Write API tests

## Frontend (1 day)
- [ ] Create NotificationCenter component
- [ ] Subscribe to notifications
- [ ] Mark as read UI
- [ ] E2E tests
```

### Handing Off to Agents

Once your spec is ready:

```bash
# Create a feature branch
git checkout -b feat/my-feature

# Commit your spec
git add openspec/changes/my-feature/
git commit -m "spec: add my feature"
git push -u origin feat/my-feature

# Create a PR on GitHub
# (GitHub PR description can reference the spec)

# Tell an agent to implement it:
cd ../slice-contracts
claude

# In the chat:
# "Implement the types from openspec/changes/my-feature/design.md"
# Follow TDD: write tests first, then implementation
```

The agent will:
1. Read your spec
2. Write failing tests
3. Implement code to pass tests
4. Commit with references to spec
5. Move on to next task

---

## API Keys & Environment Setup

### What You Need

| Variable | Type | When Needed | Where to Get |
|----------|------|-------------|-------------|
| `NEXT_PUBLIC_GOOGLE_CLIENT_ID` | Public | Google login | Google Cloud Console |
| `NEXT_PUBLIC_GITHUB_CLIENT_ID` | Public | GitHub login | GitHub Settings |
| `AWS_ROLE_TO_ASSUME` | Secret | GitHub CI/CD | AWS IAM (GitHub OIDC) |
| `AMPLIFY_APP_ID` | Secret | GitHub CI/CD | Amplify Console |
| `AMPLIFY_TOKEN` | Secret | GitHub CI/CD | AWS Console |

### Safe vs Unsafe

✅ **Safe to commit** (in `.env.local` is OK, in repo is OK with `NEXT_PUBLIC_` prefix):
```
NEXT_PUBLIC_GOOGLE_CLIENT_ID=abc123...
NEXT_PUBLIC_GITHUB_CLIENT_ID=xyz789...
NEXT_PUBLIC_AMPLIFY_REGION=us-east-1
```

❌ **Never commit** (always in `.env.local`, `.gitignore`):
```
AWS_SECRET_ACCESS_KEY=...
GOOGLE_CLIENT_SECRET=...
DATABASE_PASSWORD=...
API_KEYS=...
```

### Local Development Setup

1. Create `.env.local` in project root:
```bash
cat > .env.local << 'EOF'
NEXT_PUBLIC_GOOGLE_CLIENT_ID=your_google_client_id
NEXT_PUBLIC_GITHUB_CLIENT_ID=your_github_client_id
NEXT_PUBLIC_AMPLIFY_REGION=us-east-1
EOF
```

2. Verify it's ignored:
```bash
git status  # Should NOT show .env.local
```

3. Load in development:
```bash
pnpm dev  # Automatically loads .env.local
```

### Setting Up OAuth Providers

#### Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project (or select existing)
3. Enable "Google+ API"
4. Go to "Credentials" → "Create Credentials" → "OAuth 2.0 Client ID"
5. Select "Web application"
6. Add authorized redirect URIs:
   ```
   http://localhost:3000/auth/callback
   https://yourdomain.auth.us-east-1.amazoncognito.com/oauth2/idpresponse
   ```
7. Copy your **Client ID** to `.env.local`:
   ```
   NEXT_PUBLIC_GOOGLE_CLIENT_ID=your_client_id.apps.googleusercontent.com
   ```
8. Copy **Client Secret** to Cognito identity provider (not in code!)

#### GitHub OAuth Setup

1. Go to GitHub Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Fill in:
   - **Application name**: My App
   - **Homepage URL**: `http://localhost:3000` (or your domain)
   - **Authorization callback URL**: `https://yourdomain.auth.us-east-1.amazoncognito.com/oauth2/idpresponse`
4. Copy your **Client ID** to `.env.local`:
   ```
   NEXT_PUBLIC_GITHUB_CLIENT_ID=your_client_id
   ```
5. Copy **Client Secret** to Cognito (not in code!)

### GitHub Actions Secrets Setup

GitHub Actions needs special secrets for deployment. **Only needed before first deploy to AWS.**

1. Go to your repo → Settings → Secrets and variables → Actions
2. Add these secrets:

**`AWS_ROLE_TO_ASSUME`**
- Format: `arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME`
- Get from AWS IAM after setting up GitHub OIDC

**`AMPLIFY_APP_ID`**
- Go to [Amplify Console](https://console.aws.amazon.com/amplify)
- Select your app
- Copy "App ID" from top right

**`AMPLIFY_TOKEN`** (optional)
- Only needed if using Amplify CLI deployment
- Create in AWS CLI: `amplify configure`

### Environment Variables in GitHub Actions

GitHub Actions automatically uses secrets from your repo:

```yaml
# In .github/workflows/deploy.yml
env:
  AWS_REGION: us-east-1

jobs:
  deploy:
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
          aws-region: ${{ env.AWS_REGION }}
```

**Never hardcode credentials in workflows!** Always use `${{ secrets.VAR_NAME }}`

---

## Common Tasks

### Run Tests Locally

```bash
# All tests
pnpm test

# Watch mode (re-runs on changes)
pnpm test --watch

# Specific file
pnpm test auth.test.ts

# With coverage
pnpm test --coverage
```

Before pushing, always run:
```bash
pnpm test  # Verify no failures
pnpm lint --fix  # Auto-fix lint issues
pnpm build  # Verify production build works
```

### Check GitHub Actions Status

```bash
# After pushing, check PR
git push origin feat/my-feature

# Go to GitHub → PR → "Checks" tab
# Wait for all green ✓
# Click "Merge" when ready
```

### Deploy to Production

1. Make sure PR is merged to `main`
2. GitHub Actions automatically deploys
3. Check [Amplify Console](https://console.aws.amazon.com/amplify) for status
4. App is live at your custom domain

### Create a New Slice

```bash
cd my-app
./scripts/orchestrate.sh create-all  # Creates all standard slices

# Or manually create one:
git worktree add ../slice-myfeature slice/myfeature
cd ../slice-myfeature
claude
```

---

## Troubleshooting

### GitHub Actions Failing

**Red ✗ on lint:**
```bash
pnpm lint --fix
git add .
git commit -m "fix: linting"
git push
```

**Red ✗ on tests:**
```bash
pnpm test --watch
# Fix failing tests locally
git add .
git commit -m "fix: tests"
git push
```

**Red ✗ on build:**
```bash
pnpm build  # Check error locally
# Fix and push again
```

### Local Dev Not Working

```bash
# Make sure .env.local exists
test -f .env.local && echo "✓ env file exists" || echo "✗ missing .env.local"

# Rebuild dependencies
rm -rf node_modules pnpm-lock.yaml
pnpm install

# Clear Next.js cache
rm -rf .next

# Restart dev server
pnpm dev
```

### OAuth Not Working

1. Check `.env.local` has correct Client IDs
2. Check redirect URLs match in Google/GitHub settings
3. Check Cognito is configured in Amplify
4. Test locally: `http://localhost:3000/auth/google`

### Deployment Failed

1. Check [Amplify Console](https://console.aws.amazon.com/amplify)
2. View build logs for the error
3. Common issues:
   - Missing environment variables (add to GitHub Secrets)
   - Missing AWS permissions (check IAM role)
   - Build command failed (run `pnpm build` locally)

---

## Next Steps

1. ✅ Ran `./scripts/setup.sh`
2. ✅ Created `.env.local`
3. ✅ Pushed to GitHub (GitHub Actions runs automatically)
4. 📝 **Create your first OpenSpec** - Pick a feature to build
5. 📝 **Write the spec** - Proposal + Design + Tasks
6. 🤖 **Start an agent** - `cd ../slice-contracts && claude`
7. 🚀 **Deploy** - Merge to main, Amplify deploys automatically

For more details:
- See `docs/WORKFLOW.md` for complete development workflow
- See `docs/SLICING.md` for parallel development strategy
- See `AGENTS.md` for agent-specific instructions
- See `CLAUDE.md` for Claude rules and conventions

---

## Questions?

Check the section in this guide that matches your question:
- "How GitHub Actions Works" - CI/CD questions
- "Using OpenSpec for Features" - Spec-driven development
- "API Keys & Environment Setup" - Environment variables
- "Troubleshooting" - Common issues and fixes
