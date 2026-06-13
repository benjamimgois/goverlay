## Why

The `.gitignore` file lacks rules to ignore temporary workspace files, developer CLI tool caches, and AI assistant configurations (such as `.agent/`, `.gemini/`, and `.opencode/`). This leads to untracked files cluttering the repository status and increases the risk of accidentally staging/committing temporary or local configuration files.

## What Changes

- **Stage and ignore workspace directories**: Update `.gitignore` to explicitly ignore agent and workspace directories (`.agent/`, `.gemini/`, `.opencode/`).
- **Clean up working directory clutter**: Remove any untracked or unnecessary configuration files from the tracking context, ensuring developers maintain a clean `git status`.

## Capabilities

### New Capabilities
- `gitignore-standardization`: Defines directory patterns and file signatures to exclude from git version control.

### Modified Capabilities
<!-- Leave empty if no requirement changes. -->

## Impact

- **Affected files**: `.gitignore` in repository root.
- **No functional impact**: This is a pure workspace/tooling layout improvement.
