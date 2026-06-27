## Context

Currently, the `plugins/` directory containing `OptiPatcher.asi` is missing from the global `bgmod` folder copy step in `UpdateButtonClick`.

## Goals / Non-Goals

**Goals:**
- Add recursive directory copy of `plugins/` folder from `.bgmod_original` to global `bgmod` if it exists.

## Decisions

### Add folder copy in SyncProc shell call
- **Why:** Reuses existing shell copy logic. Executes atomically after DLL copy.

## Risks / Trade-offs

- None.
