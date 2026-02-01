#!/bin/bash
# Agent Template Setup Script
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🤖 Agent Template Setup${NC}"

PROJECT_NAME=${1:-"my-app"}

echo "Creating: $PROJECT_NAME"

# Create Next.js + Amplify project
npx create-next-app@latest $PROJECT_NAME \
  --typescript --tailwind --eslint --app \
  --src-dir --import-alias "@/*" --use-pnpm

cd $PROJECT_NAME

# Add Amplify
npm create amplify@latest -- --yes

# Create monorepo structure
mkdir -p packages/contracts/src packages/ui/src

# Copy agent files from template
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"

cp "$TEMPLATE_DIR/AGENTS.md" ./
cp "$TEMPLATE_DIR/CLAUDE.md" ./
cp -r "$TEMPLATE_DIR/.claude" ./
cp -r "$TEMPLATE_DIR/openspec" ./
cp -r "$TEMPLATE_DIR/docs" ./
cp -r "$TEMPLATE_DIR/scripts" ./

# Update project name
sed -i "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" AGENTS.md

# Initialize git
git init
git add .
git commit -m "Initial setup with agent orchestration"

echo -e "${GREEN}✓ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  ./scripts/orchestrate.sh create-all"
echo "  cd ../slice-contracts && claude"
