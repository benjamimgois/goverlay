## Context

The `bgmod` wrapper binary is responsible for setting up and updating files in the game's directory when starting a game. Currently, it compares version variables in `goverlay.vars` to decide whether to update. Because saving new settings in the GOverlay GUI only writes to the config directory (`~/.local/share/goverlay/gameconfig/<game>/`) and doesn't change version strings, the wrapper skips copying these configurations on run if the DLL files are already up-to-date. In addition, `PRESERVE_INI=true` blocks copying `OptiScaler.ini` to avoid clobbering user adjustments made in-game.

## Goals / Non-Goals

**Goals:**
- Detect when GOverlay configuration for `OptiScaler.ini` is newer than the game directory's file.
- Update `OptiScaler.ini` in the game directory when it is older than GOverlay's config.
- Unconditionally copy `fakenvapi.ini` from the config directory to the game directory on run if it exists.
- Perform these checks on every game launch, even if no DLL updates are required.

**Non-Goals:**
- Parsing/merging individual lines inside `OptiScaler.ini`.
- Changing how GOverlay saves configurations.

## Decisions

### Decision 1: Create a helper `SyncOptiScalerIni` in `bgmod.lpr`
We will implement a helper procedure `SyncOptiScalerIni` in `bgmod.lpr` that:
- Reads timestamps of `ConfigDir + 'OptiScaler.ini'` and `GameDir + 'OptiScaler.ini'` using `FileAge` / `TDateTime`.
- Overwrites the game's file only if GOverlay's file is newer, or if `PRESERVE_INI` is false.
- Respects `PRESERVE_INI=true` (keeping in-game edits) by only overwriting when GOverlay's configuration has been saved more recently.

### Decision 2: Run configuration sync on launch
We will call `SyncOptiScalerIni` and copy `fakenvapi.ini` in `bgmod.lpr` in two paths:
- In the skipped copy path (when the wrapper logs "OptiScaler files in game directory are already up to date, skipping copy").
- In the active install/update path (replacing the direct `PreserveIni` copy block).

## Risks / Trade-offs

- **Risk:** Time drift or file attribute issues might cause incorrect mtime comparisons.
  * **Mitigation:** FPC's `FileAge` uses standard filesystem metadata. Since both directories are on the same machine/filesystem (typically local home directory), mtimes are highly consistent.
