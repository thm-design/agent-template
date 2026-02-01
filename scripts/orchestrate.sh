#!/bin/bash
# Manage parallel agent worktrees

COMMAND=${1:-"status"}

case $COMMAND in
  "status")
    echo "📊 Worktree Status"
    echo ""
    git worktree list
    ;;
    
  "create-all")
    echo "🔨 Creating all standard slices"
    echo ""
    
    for SLICE in contracts frontend ui backend data; do
      BRANCH="slice/$SLICE"
      WORKTREE="../slice-$SLICE"
      
      if [ -d "$WORKTREE" ]; then
        echo "⏭  $SLICE (exists)"
        continue
      fi
      
      git branch $BRANCH 2>/dev/null || true
      git worktree add "$WORKTREE" $BRANCH
      
      cat > "$WORKTREE/CLAUDE.local.md" << EOF
# Slice: $SLICE
Only modify files in your slice directory.
Import types from @repo/contracts (read-only).
EOF
      echo "✓  $SLICE created"
    done
    
    echo ""
    echo "Start agents in separate terminals:"
    echo "  cd ../slice-contracts && claude"
    echo "  cd ../slice-frontend && claude"
    echo "  cd ../slice-ui && claude"
    echo "  cd ../slice-backend && claude"
    ;;
    
  "sync")
    echo "🔄 Syncing contracts to all slices"
    for dir in ../slice-*; do
      if [ -d "$dir" ] && [ "$(basename $dir)" != "slice-contracts" ]; then
        echo "Rebasing $(basename $dir)..."
        git -C "$dir" rebase slice/contracts 2>/dev/null || echo "  ⚠ Conflict"
      fi
    done
    ;;
    
  "clean")
    echo "🧹 Removing all worktrees"
    for dir in ../slice-*; do
      [ -d "$dir" ] && git worktree remove "$dir" --force && echo "Removed: $dir"
    done
    ;;
    
  *)
    echo "Usage: orchestrate.sh [status|create-all|sync|clean]"
    ;;
esac
