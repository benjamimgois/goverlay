## Context

The repository includes a `.gitignore` to keep build outputs and temporary directories out of Git. However, new agentic workspace folders (`.agent/`, `.gemini/`, `.opencode/`) are currently untracked and show up on `git status`.

## Goals / Non-Goals

**Goals:**
- Exclude the `.agent/`, `.gemini/`, and `.opencode/` directories from git version control.

**Non-Goals:**
- Removing or modifying ignores for Lazarus build artifacts, Flatpak files, or other binary files.

## Decisions

### Decision 1: Add Tooling Ignores
- **Approach**: Append `.agent/`, `.gemini/`, and `.opencode/` to the bottom of the `.gitignore` file under a new section.
- **Rationale**: Straightforward fix to ignore tool-specific directories without modifying other ignore rules.

## Risks / Trade-offs

- **No notable risks**: Ignoring workspace/assistant directories has no impact on GOverlay builds.
