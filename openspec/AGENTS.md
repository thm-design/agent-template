# OpenSpec Workflow

## Commands
/opsx:new <feature>    Create change proposal
/opsx:ff               Fast-forward planning docs
/opsx:apply            Implement tasks
/opsx:verify           Check vs spec
/opsx:archive          Complete and archive

## Structure
openspec/
├── specs/             # Source of Truth (read-only)
└── changes/<feature>/ # Your working area
    ├── proposal.md
    ├── design.md
    └── tasks.md
