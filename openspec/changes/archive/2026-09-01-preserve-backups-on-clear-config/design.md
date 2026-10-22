## Context

GOverlay currently resets its state when the user triggers "Clear configuration" in the Home tab by calling `DeleteDirectory` on all standard data and configuration directories (`~/.local/share/goverlay`, `~/.config/goverlay`, and Flatpak paths). Because original game DLLs are stored under `~/.local/share/goverlay/gameconfig/<game>/backups/`, this indiscriminate deletion destroys all game backups.

## Goals / Non-Goals

**Goals:**
- Implement an in-place recursive directory cleaner `CleanDirectoryPreservingBackups` that removes configuration files, caches, and logs while preserving non-empty `backups/` folders and their directory hierarchy.
- Prune empty `backups/` folders and empty parent directories so that directories with no backup data are cleanly removed.
- Expose the cleanup logic in a non-GUI unit (`overlay_config.pas` or `apputils.pas`) so it can be thoroughly tested via the test suite in `tests/logic/`.
- Update user-facing confirmation strings in `goverlay_strings.pas`.

**Non-Goals:**
- Changing how `bgmod` or `bgmod-uninstaller` creates or restores backups during game launch or per-game uninstall.
- Preserving non-backup configuration files (e.g. `MangoHud.conf`, `bgmod.conf`, custom profiles, UI state).

## Decisions

### Decision 1: In-place recursive tree traversal with post-order directory pruning
- **Approach**: Recursively walk directories:
  1. For files: delete immediately.
  2. For subdirectories:
     - If the directory name is `backups` (case-insensitive): check if it contains any files. If it contains files, preserve the directory and all its contents untouched. If empty, remove the empty directory.
     - For any other subdirectory: recurse into it. After returning from recursion, if the subdirectory is now empty (i.e., contains no files or preserved backup folders), remove it with `RemoveDir`.
  3. After processing all entries in the root target: if the root target directory itself is empty, remove it.
- **Alternatives Considered**: Staging backups to `/tmp` and restoring after `DeleteDirectory`. Rejected because process interruption or cross-filesystem move failures would result in permanent data loss.

### Decision 2: Shared unit placement for testability
- **Approach**: Implement `CleanDirectoryPreservingBackups` and `IsDirectoryEmpty` in `overlay_config.pas` (or `apputils.pas`), making it callable from both `home_tab.pas` and `logic_test_cases.pas`.
- **Alternatives Considered**: Private method in `THomeTabHelper`. Rejected because it would require GUI/LCL initialization to run unit tests.

### Decision 3: Update confirmation strings in `goverlay_strings.pas`
- **Approach**: Update `rsClearConfigPrompt` to clarify that settings will be restored to defaults while game DLL backups are kept intact.

## Risks / Trade-offs

- **[Risk]** Locked files or permission errors during deletion.  
  → **Mitigation**: Catch exceptions per item, log errors to stderr/stdout, and report partial completion status to the user if any deletion fails.
- **[Risk]** Nested subdirectories inside `backups/`.  
  → **Mitigation**: When a directory named `backups` is identified with files, the entire subtree inside it is preserved without further deletion.
