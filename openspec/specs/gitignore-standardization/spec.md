# Gitignore Standardization

## Purpose
Standardize file exclusion rules to keep build outputs, editor configurations, and agentic/workspace tooling directories out of Git.

## Requirements

### Requirement: Exclude agentic and workspace tooling directories
The system MUST ignore directories created by development tools (`.agent/`, `.gemini/`, `.opencode/`).

#### Scenario: Ignoring agent directories
- **WHEN** running `git status`
- **THEN** folders `.agent/`, `.gemini/`, and `.opencode/` MUST NOT appear as untracked files.
