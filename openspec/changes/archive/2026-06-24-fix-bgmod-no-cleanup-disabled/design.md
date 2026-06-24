## Context

Currently `bgmod.lpr` contains an `else` block (lines 923-978) that runs when `GOverlayOptiscaler = False`. This block, even after the `goverlay.vars` guard added in a previous fix, still performs file deletion in the game directory whenever `goverlay.vars` is present — which can happen due to stale files, partial installs, or manual user actions.

The core issue: bgmod does "cleanup" as an automatic side-effect of launch when OptiScaler is disabled. This violates the principle of least surprise — users expect that simply not enabling a feature means no files get modified.

## Goals / Non-Goals

**Goals:**
- Guarantee zero file modifications in game directory when OptiScaler is disabled in `bgmod.lpr`
- Keep the uninstaller (`bgmod-uninstaller.lpr`) as the sole cleanup mechanism for game directory files
- Preserve the sidebar GUI cleanup (`sidebar_nav.pas`) which operates on GOverlay config dir only

**Non-Goals:**
- Rewriting the uninstaller or sidebar cleanup logic
- Changing how OptiScaler install/update works when enabled
- Adding new cleanup mechanisms

## Decisions

### 1. Remove the entire OptiScaler-disabled cleanup block from bgmod.lpr

- **Choice**: Delete the `else` cleanup block (~55 lines) and replace with a single `Log('OptiScaler is disabled, skipping.')` line.
- **Rationale**: The cleanup block was the only source of game file deletion on launch. Removing it eliminates all edge cases (`goverlay.vars` guard failures, race conditions, stale files). The uninstaller already handles full cleanup correctly.
- **Alternative considered**: Further hardening the `goverlay.vars` guard (e.g., comparing file contents, timestamps). Rejected — any heuristic-based guard can fail in edge cases. The principle is simpler: disabled means do nothing.

### 2. Uninstaller remains unchanged

- **Choice**: Keep `bgmod-uninstaller.lpr` as-is (already correctly deletes `goverlay.vars` and cleans up OptiScaler files).
- **Rationale**: The uninstaller is user-invoked, explicit, and expected to clean up. No risk of surprise deletions.

### 3. Keep goverlay.vars for install tracking only

- **Choice**: Retain `goverlay.vars` as a version file written during OptiScaler install (`bgmod.lpr:920`) and deleted by uninstaller (`bgmod-uninstaller.lpr:671`). Remove its use as a cleanup gate.
- **Rationale**: `goverlay.vars` still serves its primary purpose — tracking installed OptiScaler version to avoid redundant copies. It no longer triggers cleanup.

## Risks / Trade-offs

- **[Risk]** If user previously had OptiScaler enabled, disables it, and never runs the uninstaller → stale OptiScaler files remain in game directory.
  - **Mitigation**: Stale DLLs are inert — they don't load without the proxy chain. User can run uninstaller any time. The GOverlay sidebar already prompts removal when toggling off. This is acceptable compared to the current bug where game files are corrupted.
- **[Risk]** Proxy DLLs from other mods (not OptiScaler) could previously survive because of `IsGOverlayProxyFile` size check — now they survive automatically since nothing gets deleted.
  - **Mitigation**: This is the desired behavior. Third-party files should never be touched.
