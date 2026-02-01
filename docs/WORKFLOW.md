# Complete Development Workflow

This document covers the entire workflow from spec definition through deployment, including GitHub Actions, environment setup, and API key management.

## 1. Development Workflow Overview

```
┌─────────────────────┐
│  Write OpenSpec     │
│  Define Features    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Create Git Branch   │
│ & Worktree          │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Agent Implementation │
│ (TDD: Red→Green)    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Local Testing       │
│ (pnpm test)        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Push & PR            │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ GitHub Actions CI   │
│ (Lint→Test→Build)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Merge & Deploy      │
│ (Amplify Pipeline)  │
└─────────────────────┘
```

## 2. OpenSpec: Spec-Driven Development

### What is OpenSpec?

OpenSpec is a structured way to propose, design, and implement features before you code. It creates a shared understanding between humans and AI agents.

### Getting Started with OpenSpec

#### Step 1: Create a Feature Proposal

```bash
# In your project root:
cd openspec

# Create a new feature spec
# (or manually create the structure below)
```

Create this structure in `openspec/changes/<feature-name>/`:

```
openspec/
└── changes/
    └── user-auth/
        ├── proposal.md       # What & why
        ├── design.md         # How & architecture
        └── tasks.md          # Implementation checklist
```

#### Step 2: Write the Proposal (`proposal.md`)

```markdown
# User Authentication Feature

## What
Add social login (Google & GitHub) to the app

## Why
- Reduce signup friction
- Support multi-tenant scenarios
- Leverage AWS Cognito capabilities

## Success Criteria
- Users can sign up with Google
- Users can sign up with GitHub
- Session persists across page reloads
- OAuth tokens stored securely

## Scope
- Update: `apps/web/` (frontend)
- Update: `packages/contracts/` (types)
- Update: `amplify/data/` (auth config)
- No changes to: `amplify/functions/`

## Dependencies
- AWS Cognito already configured in Amplify backend
- No external OAuth libraries needed (using Amplify Auth)
```

#### Step 3: Write the Design (`design.md`)

```markdown
# User Authentication - Design

## Architecture

### Frontend Flow
```
User visits /login
  ↓
Click "Sign in with Google"
  ↓
Amplify Auth redirects to Cognito
  ↓
Google OAuth consent screen
  ↓
Redirected back to app
  ↓
Session stored in localStorage
  ↓
User redirected to dashboard
```

### Type Contract
```typescript
// packages/contracts/src/auth.ts
export interface User {
  id: string;
  email: string;
  name?: string;
  provider: 'google' | 'github' | 'cognito';
  createdAt: Date;
}

export interface AuthContext {
  user: User | null;
  isLoading: boolean;
  error?: Error;
  signIn: (provider: 'google' | 'github') => Promise<void>;
  signOut: () => Promise<void>;
}
```

### API Changes
- No GraphQL changes needed (using Cognito)
- Amplify Auth handles all OAuth flows

### Data Model
- Users table already exists in DynamoDB
- Add `provider` field (enum: google, github, cognito)
- Add `providerUserId` field for OAuth ID mapping
```

#### Step 4: Create Implementation Tasks (`tasks.md`)

```markdown
# User Authentication - Implementation Tasks

## Phase 1: Backend Setup (0.5 day)
- [ ] Update User schema in DynamoDB with `provider` & `providerUserId`
- [ ] Configure Cognito identity providers (Google & GitHub)
- [ ] Test OAuth flow in Amplify Console
- [ ] Write unit tests for auth lambda (if custom handler needed)

## Phase 2: Contracts (0.5 day)
- [ ] Create `packages/contracts/src/auth.ts` with User & AuthContext types
- [ ] Export from `@repo/contracts/index.ts`
- [ ] Run tests: `pnpm test`

## Phase 3: Frontend Implementation (1 day)
- [ ] Create auth context provider in `apps/web/lib/AuthContext.tsx`
- [ ] Wrap app in provider at `apps/web/app/layout.tsx`
- [ ] Create login page: `apps/web/app/login/page.tsx`
- [ ] Add sign-in buttons (Google & GitHub)
- [ ] Add sign-out functionality
- [ ] Protect routes with middleware

## Phase 4: Testing (1 day)
- [ ] Write unit tests for AuthContext
- [ ] Write E2E tests for full OAuth flow
- [ ] Test session persistence
- [ ] Test error scenarios (failed login, token refresh)
- [ ] Manual testing across browsers

## Phase 5: Documentation (0.5 day)
- [ ] Update README with auth setup instructions
- [ ] Document required environment variables
- [ ] Create troubleshooting guide

## Estimated Total: 3.5 days
```

### Step 5: Hand Off to Implementation

Once your spec is ready:

1. **Create a Git branch** from your spec:
   ```bash
   git checkout -b feat/user-auth
   ```

2. **Tell an agent** to implement it:
   - Start with contracts slice: `cd ../slice-contracts && claude`
   - Then frontend: `cd ../slice-frontend && claude`
   - Reference the spec: "Implement according to `openspec/changes/user-auth/`"

3. **Agent follows spec exactly**:
   - Creates files matching design
   - Writes tests first (TDD)
   - Uses types from `@repo/contracts`
   - Commits with reference to spec

4. **Archive completed spec**:
   ```bash
   mv openspec/changes/user-auth/ openspec/specs/completed/user-auth/
   ```

## 3. GitHub Actions CI/CD Pipeline

### What Happens Automatically

#### On Every Pull Request
```
1. Install dependencies (cached)
2. Lint code (ESLint)
3. Type check (TypeScript)
4. Run unit tests
5. Build application
```

If any step fails, the PR cannot be merged.

#### On Merge to Main
```
1. All PR checks run again
2. Build optimized production bundle
3. Deploy to AWS Amplify
4. Run E2E tests against deployed app
```

### Workflow Files

**`.github/workflows/ci.yml`** - Runs on every push/PR
- Linting
- Type checking
- Unit tests
- Build verification

**`.github/workflows/deploy.yml`** - Runs only on main branch
- Production build
- AWS authentication
- Amplify deployment
- E2E tests

### Viewing Results

In GitHub, after pushing:

1. Go to your PR → "Checks" tab
2. Expand each check to see logs
3. Red ✗ = build failed (fix required)
4. Green ✓ = ready to merge

Common failures:
- **ESLint**: Run `pnpm lint --fix` locally
- **TypeScript**: Run `pnpm type-check` locally
- **Tests**: Run `pnpm test` locally

## 4. Environment Variables & API Keys

### What You Need to Set Up

#### Local Development

Create `.env.local` in your project root:

```bash
# Amplify Backend (auto-configured by `amplify pull`)
NEXT_PUBLIC_AMPLIFY_API_ENDPOINT=<from amplify/backend>
NEXT_PUBLIC_AMPLIFY_REGION=us-east-1

# OAuth (from Google Cloud Console)
NEXT_PUBLIC_GOOGLE_CLIENT_ID=<your-google-client-id>

# OAuth (from GitHub Settings)
NEXT_PUBLIC_GITHUB_CLIENT_ID=<your-github-client-id>

# Cognito (from Amplify Console)
NEXT_PUBLIC_COGNITO_USER_POOL_ID=<your-pool-id>
NEXT_PUBLIC_COGNITO_CLIENT_ID=<your-client-id>
```

**Do NOT commit `.env.local`** - it's in `.gitignore`

#### GitHub Secrets (for Deployment)

Go to **Settings → Secrets and variables → Actions**

Add these secrets:

| Secret | Where to Get | When Needed |
|--------|-------------|------------|
| `AWS_ROLE_TO_ASSUME` | AWS IAM (GitHub OIDC) | Before first deploy |
| `AMPLIFY_APP_ID` | Amplify Console | Before first deploy |
| `AMPLIFY_TOKEN` | AWS Console | Before first deploy |

### Setting Up AWS Credentials for GitHub

1. Create OIDC provider in AWS:
   ```bash
   # Use AWS Console or CLI
   # Provider: github.com
   # Audience: sts.amazonaws.com
   ```

2. Create IAM role with Amplify permissions:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [{
       "Effect": "Allow",
       "Action": ["amplify:*", "iam:*"],
       "Resource": "*"
     }]
   }
   ```

3. Add role ARN as GitHub secret `AWS_ROLE_TO_ASSUME`

### Setting Up OAuth Providers

#### Google

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create OAuth 2.0 credentials (web app)
3. Add redirect URI: `https://yourdomain.auth.us-east-1.amazoncognito.com/oauth2/idpresponse`
4. Copy Client ID and secret to Cognito

#### GitHub

1. Go to Settings → Developer settings → OAuth Apps
2. Create new OAuth app
3. Authorization callback URL: `https://yourdomain.auth.us-east-1.amazoncognito.com/oauth2/idpresponse`
4. Copy Client ID and secret to Cognito

### Environment Variable Safety

✅ **Safe to commit** (prefixed with `NEXT_PUBLIC_`):
- Public Client IDs (Google, GitHub)
- API endpoints
- Region names

❌ **Never commit**:
- Secrets (client secrets, API keys, tokens)
- Database passwords
- AWS credentials
- Private keys

Store sensitive variables in:
- `.env.local` (local development)
- GitHub Secrets (for CI/CD)
- AWS Secrets Manager (production)

## 5. Full Development Cycle Example

### Scenario: Adding User Profiles

#### Day 1: Spec & Planning

```bash
# 1. Write OpenSpec
cd openspec/changes
mkdir user-profiles
# Create proposal.md, design.md, tasks.md

# 2. Create Git branch
git checkout -b feat/user-profiles

# 3. Commit spec
git add openspec/changes/user-profiles/
git commit -m "spec: add user profiles feature"
git push -u origin feat/user-profiles
```

#### Day 2: Implementation (Contracts)

```bash
# 4. Start with contracts
cd ../slice-contracts
claude  # Tell agent: "Implement types from openspec/changes/user-profiles/design.md"

# Agent creates:
# - packages/contracts/src/profile.ts
# - profile.test.ts
# Commits and exits
```

#### Day 2-3: Implementation (Frontend & Backend in Parallel)

```bash
# 5. Frontend in parallel
cd ../slice-frontend
claude  # Tell agent: "Implement profile pages from spec"

# Agent creates pages, components, tests

# 6. Backend in parallel (if needed)
cd ../slice-backend
claude  # Tell agent: "Add profile GraphQL API from spec"
```

#### Day 4: Integration & Testing

```bash
# 7. Back to main branch
git checkout main
git pull origin main

# 8. Merge feature branches
git merge feat/user-profiles
# GitHub Actions runs automatically:
# - Lint ✓
# - Test ✓
# - Build ✓

# 9. Merge to main
# GitHub Actions runs deploy:
# - Production build ✓
# - Deploy to Amplify ✓
# - E2E tests ✓
```

#### Day 5: Archive & Documentation

```bash
# 10. Archive completed spec
mv openspec/changes/user-profiles/ openspec/specs/completed/user-profiles/
git add openspec/
git commit -m "docs: archive user-profiles spec"

# 11. Update README with new feature
# 12. Create user guide if needed
```

## 6. Troubleshooting

### GitHub Actions Failed

Check the "Checks" tab in your PR:

**ESLint Failure:**
```bash
pnpm lint --fix
git add .
git commit -m "fix: linting errors"
git push
```

**Test Failure:**
```bash
pnpm test --watch  # Run tests locally
# Fix failing tests
git add .
git commit -m "fix: failing tests"
git push
```

**Build Failure:**
```bash
pnpm build  # Try locally
# Look for TypeScript or build errors
# Fix and push again
```

### Deployment Failed

1. Check [Amplify Console](https://console.aws.amazon.com/amplify)
2. View build logs for errors
3. Common issues:
   - Missing environment variables (check GitHub Secrets)
   - Missing AWS permissions (check IAM role)
   - Build command failing (run `pnpm build` locally)

### OAuth Not Working Locally

1. Check `.env.local` has correct IDs
2. Verify redirect URLs in Google/GitHub settings
3. Check Cognito is properly configured:
   ```bash
   amplify pull  # Updates local config
   ```

## 7. Best Practices

### For Specs
- Be specific about acceptance criteria
- Include architecture diagrams if complex
- Break into realistic daily tasks
- Reference types and files by path

### For Code
- Always run `pnpm test` before pushing
- Write tests first (TDD), then code
- Keep commits small and atomic
- Reference spec in commit messages: "feat: add auth (closes openspec/changes/user-auth/)"

### For Commits
```bash
# Good
git commit -m "feat: add Google OAuth login
- Update Cognito identity providers
- Add sign-in button to login page
- Tests: oauth sign-in flow
Ref: openspec/changes/user-auth/"

# Bad
git commit -m "update stuff"
```

### For PRs
- Link to spec in PR description
- Describe what changed and why
- Link to GitHub issues if applicable
- Wait for all checks to pass before merging

## 8. Next Steps

1. **Write your first OpenSpec** - Define a feature you want
2. **Commit and push** - Create a PR with your spec
3. **Run locally** - `pnpm dev` to see the base app
4. **Get feedback** - Have team review your spec
5. **Implement** - Hand spec to agents for implementation
6. **Deploy** - Merge to main and watch Amplify deploy

See `docs/SLICING.md` for details on parallel development strategies.
