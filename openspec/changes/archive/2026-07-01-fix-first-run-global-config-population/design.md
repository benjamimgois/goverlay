## Context

The global profile isolation change moved active global configuration from `~/.local/share/goverlay/bgmod/` to `~/.local/share/goverlay/gameconfig/global/`. `InitializeBGModDirectory` now seeds `gameconfig/global/` on first run, but it does so before `CheckAndInstallOptiScaler` downloads OptiScaler and its runtime assets. Consequently, the first-run copy is incomplete and only contains the template files bundled in `data/bgmod`.

## Goals / Non-Goals

**Goals:**
- Ensure `gameconfig/global/` contains the complete contents of `bgmod/` after the first-run auto-install finishes.
- Keep the existing pristine/template role of `~/.local/share/goverlay/bgmod/` unchanged.
- Preserve the current exclusion list for subsequent-run syncs so user configs in `gameconfig/global/` are never overwritten by binary updates.

**Non-Goals:**
- Changing where OptiScaler is downloaded (still `bgmod/` / `.bgmod_original`).
- Refactoring per-game configuration flow.
- Changing the layout or format of `goverlay.vars`, `bgmod.conf`, `OptiScaler.ini` or `fakenvapi.ini`.

## Decisions

1. **Extract global initialization into a dedicated helper**
   - Move the `gameconfig/global/` copy/sync logic out of `InitializeBGModDirectory` into a new public helper in `bgmod_resources.pas`.
   - Rationale: keeps `InitializeBGModDirectory` focused on setting up `bgmod/` and `.bgmod_original`, and lets `overlayunit.pas` call global init at the right moment.

2. **Call global initialization after auto-install in `overlayunit.pas`**
   - Startup order becomes: `InitializeBGModDirectory` → `CheckAndInstallOptiScaler` → `InitializeGlobalConfigDirectory`.
   - Rationale: this is the earliest point where `bgmod/` is guaranteed to contain downloaded OptiScaler files.

3. **Use the same copy/sync strategy already in the code**
   - First run: `cp -rf bgmod/ -> gameconfig/global/` (complete copy).
   - Subsequent runs: `rsync` excluding `bgmod.conf`, `goverlay.vars`, `OptiScaler.ini`, `fakenvapi.ini`.
   - Rationale: reuses proven commands and avoids surprising behavior changes.

## Risks / Trade-offs

- **[Risk]** If `CheckAndInstallOptiScaler` fails (no network, missing `7z`), `gameconfig/global/` will still only contain templates.
  - *Mitigation*: the helper still runs after auto-install, so any future successful install or restart will sync the files. This is no worse than the current state.

- **[Risk]** Running global init after auto-install delays first-launch UI by a small amount.
  - *Mitigation*: the copy is local and only happens once; the existing auto-install already blocks the UI during download.

## Migration Plan

No user migration is needed. Existing users who already have `gameconfig/global/` will simply take the subsequent-run rsync path on next startup.

## Open Questions

None.
