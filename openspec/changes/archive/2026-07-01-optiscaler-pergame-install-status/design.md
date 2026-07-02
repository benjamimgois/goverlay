## Context

The `global-profile-gameconfig-isolation` change moved the global active config to `~/.local/share/goverlay/gameconfig/global/` and made `bgmod/` a pristine template. Two flows were not migrated:

1. **Install flow** (`TOptiscalerTab.UpdateButtonClick`): destination is hardcoded to `GetGameConfigDir('')` (always `gameconfig/global/`) regardless of `FActiveGameName`. The pristine `.bgmod_original` is extracted and its DLLs sync'd to `bgmod/`, then `goverlay.vars` is written only to `.bgmod_original` + `gameconfig/global/`. A per-game install never lands in `gameconfig/<game>/`.

2. **Status flow** (`LoadVersionsFromFile`, `RefreshOsStatusDots`, `InitializeTab`): all read `TOptiscalerTab.FFGModPath`, which is assigned once at startup (`overlayunit.pas:3307`) to `GetOptiScalerInstallPath` (= `bgmod/`). `RefreshOsStatusDots` mirrors labels populated from `FFGModPath + 'goverlay.vars'`, so Software status always reflects the global pristine, never the active game.

Additionally, the OptiScaler tab is hidden when a game is selected (`games_tab.pas:2093`), preventing any per-game interaction with Software status. And `CopyOptiScalerGameFiles` uses `cp -rn` (no-clobber), so a stale `goverlay.vars` in a game folder wins over a freshly installed one.

## Goals / Non-Goals

**Goals:**
- Install/update OptiScaler resolves its destination from the active game context (`FActiveGameName` → `gameconfig/<game>/` or `gameconfig/global/`).
- Software status card reads versions from the active game's `goverlay.vars`, refreshed on every game switch.
- First click on a game card seeds `gameconfig/<game>/` with stable OptiScaler assets (DLLs) + a stable `goverlay.vars` so status shows the stable version out of the box.
- OptiScaler tab becomes visible per-game; form fields remain disabled when the game's OptiScaler toggle is off (channel combobox + update button included).
- A channel install in a game overwrites that game's `goverlay.vars` and DLLs.
- When the cached `.bgmod_original` already contains the requested channel's latest tag, the install reuses the cache (no re-download).

**Non-Goals:**
- Changing the global pristine template layout in `bgmod/` or `.bgmod_original/`.
- Modifying the bgmod runtime wrapper's auto-update logic (covered by spec `bgmod-update-optiscaler` auto-update requirement).
- Allowing games to run with OptiScaler without the per-game toggle enabled (toggle still gates execution).
- Adding new OptiScaler channels (only Stable and Bleeding-edge remain).
- Backfilling `goverlay.vars` for games that already have a `gameconfig/<game>/` folder but no vars file (those resolve to "—" status until the user installs).

## Decisions

### 1. Single source of truth for the active config path

Introduce a helper `GetActiveGameConfigDir` (or reuse `GetGameConfigDir(FActiveGameName)`) as the single resolution used by:
- install destination,
- `LoadVersionsFromFile` source,
- `RefreshOsStatusDots` labels (transitively via `LoadVersionsFromFile`),
- `InitializeTab`'s existence check,

`TOptiscalerTab.FGModPath` is re-pointed to `GetGameConfigDir(FActiveGameName)` whenever `FActiveGameName` changes (in `GameCardClick`, returning to global, and at startup). When a game has no `gameconfig/<game>/` yet, `LoadVersionsFromFile` exits early (existing behavior) and labels fall back to `—`.

**Alternative considered:** keep `FGModPath` as the pristine install dir and add a separate `FActiveVarsPath`. Rejected — it would require threading two paths through every call site and the pristine dir is already available via `GetBGModOriginalPath`/`GetOptiScalerInstallPath`.

### 2. Install destination resolution inside `UpdateButtonClick`

Replace the hardcoded `GetGameConfigDir('')` write target (lines 1801-1802) with `GetGameConfigDir(goverlayform.FActiveGameName)`. The `.bgmod_original` write stays unchanged (still the pristine store). The DLL/plugin/FSR4/fakenvapi sync (lines 1619-1643) currently copies into `FFGModPath` (= global pristine `bgmod/`); add a second sync into the active destination so the game folder receives the freshly installed DLLs. Concretely:

```
DestDir := GetGameConfigDir(FActiveGameName);
CopyPristineDLLsTo(FFGModPath);        // keep global pristine in sync (existing)
CopyPristineDLLsTo(DestDir);          // NEW: push to active game folder
RegenerateVars(DestDir, IsStableChannel, OptiScalerTag);
```

**Alternative considered:** only write to `DestDir`, skip the global pristine sync. Rejected — the pristine `bgmod/` is still consulted by `IsBGModOptiScalerInstalled` and other heuristics; keeping it in sync avoids drift.

### 3. Cache reuse: skip re-download when tag matches

Before downloading the channel's 7z, read `OptiScalerVersion=` from `.bgmod_original/goverlay.vars`. If it equals the freshly-fetched latest tag for the selected channel, skip the download + extraction steps and go straight to the DLL sync + vars generation into the active destination. If the tag differs (or `.bgmod_original` has no vars), perform the full download-extract cycle as today.

This keeps a per-game bleed-edge switch fast when the edge build was already fetched globally or for another game.

### 4. First-selection stable seeding on `GameCardClick`

When `GameCardClick` runs and `GetGameConfigDir(GameName)/goverlay.vars` does not exist:

1. `ForceDirectories(GameCfgDir)`.
2. `cp -rn .bgmod_original/. GameCfgDir/` (no-clobber — preserves anything already there like `bgmod` scripts already copied at lines 2080-2086).
3. Read `.bgmod_original/goverlay.vars`; if it carries a stable `OptiScalerVersion=<stableTag>`, copy it verbatim to `GameCfgDir/goverlay.vars`. Otherwise generate a fresh stable vars from `.bgmod_original` (the pristine is always stable by first-run contract).

After seeding, `GameCardClick` calls `FOptiscalerUpdate.FGModPath := GameCfgDir`, then `LoadVersionsFromFile` + `InitializeTab` + `RefreshOsStatusDots` so the tab reflects the freshly-seeded stable status.

**Alternative considered:** symlink the game's `goverlay.vars` to `gameconfig/global/`. Rejected — would break the per-game install overwrite model and the per-game isolation guarantees from `global-profile-gameconfig-isolation`.

### 5. OptiScaler tab visible per-game

`GameCardClick` sets `optiscalertabsheet.TabVisible := True` (replacing the current `False` at `games_tab.pas:2093`). The existing `ApplyToolEnabledState(2, FNavToolEnabled[2])` flow continues to disable all form fields when the game's OptiScaler toggle is off; the channel combobox and update button are gated by the same toggle, so a disabled game cannot switch channels or install — matching the user's stated constraint. When returning to global mode (`FActiveGameName := ''`), the tab stays visible (it already is).

### 6. Clobber vs. no-clobber copy rules

Two distinct copy flows now coexist:
- **First-selection seeding** uses `cp -rn` (no-clobber) so it never overwrites an existing per-game `bgmod.conf`, `OptiScaler.ini`, `fakenvapi.ini`, or `goverlay.vars`. This matches the existing `CopyOptiScalerGameFiles` semantics.
- **Install/update channel** uses force copy (`cp -f`) for DLLs, `plugins/`, `FSR4_*`, `fakenvapi.ini`, and explicitly rewrites `goverlay.vars` in `DestDir` (already the behavior in the vars block). This replaces any stale stable files when switching a game to bleeding-edge.

`CopyOptiScalerGameFiles` itself stays `cp -rn` because it is the seeding/toggle-on path; the install path uses a separate force-copy routine.

## Migration Plan

1. **No data migration required** for the global profile or `.bgmod_original` — those flows are unchanged.
2. **Existing per-game `gameconfig/<game>/` folders without `goverlay.vars`** will show `—` for OptiScaler status until the user clicks Update with a channel selected. This matches current behavior and is acceptable.
3. **Existing per-game `goverlay.vars` files** that previously showed global-stable versions remain valid; they continue to display until overwritten by an explicit channel install, at which point the per-game destination is rewritten with the correct tag.
4. **First-run users**: the first time any game card is clicked, the stable seeding occurs automatically. No user action needed.

**Rollback:** revert the code change; existing `goverlay.vars` files in `gameconfig/<game>/` continue to work because the status reader simply falls back to `—` when the tab is hidden or the vars file is absent. No destructive data operation is performed, so rollback is safe.

## Risks / Trade-offs

- **[Risk] Per-game install doubles disk usage for DLLs.** Each game gets its own copy of OptiScaler DLLs (`OptiScaler.dll`, `nvngx_dlss*.dll`, `fakenvapi` etc., ~tens of MB). *Mitigation:* this is the existing isolation model already adopted; the update flow keeps `.bgmod_original` as the dedup source. Disk cost is acceptable for the isolation guarantee.
- **[Risk] Cache reuse serves a stale edge build if the user wants the absolute newest edge tag.** *Mitigation:* the reuse check compares against the latest tag freshly fetched from the manifest; if the user explicitly clicks Update and the tag matches the cache, the operation is a no-op with respect to DLLs but still regenerates `goverlay.vars` — which is itself the desired outcome for a channel switch.
- **[Risk] OptiScaler tab visible per-game may confuse users who expect tab visibility to be tool-toggle-gated.** *Mitigation:* `ApplyToolEnabledState` still disables every interactive control when the toggle is off; the tab being visible simply surfaces the (read-only) Software status. Status card was designed to be informational, so this is consistent.
- **[Risk] Timing of `FOptiscalerUpdate.FGModPath` re-pointing vs background update thread.** `CheckForUpdatesOnClick` spawns `TOptiUpdateThread` that uses `FFGModPath` for comparisons. If the user switches games while a check is in flight, the thread could compare against the wrong game's `OptiScalerVersion`. *Mitigation:* the existing `SyncUpdateUI` already cancels when the channel combobox changes; extend the same guard to fire when `FFGModPath` changed since spawn (capture `FSpawnedFGModPath` in the thread constructor and compare in `SyncUpdateUI`).
- **[Trade-off] First-selection seeding runs `cp -rn` even for games whose toggle stays off**, slightly increasing disk usage for games that never use OptiScaler. Preferred over lazy seeding because it makes status consistent immediately and the disk cost is small.

## Open Questions

- Should the global pristine `bgmod/` receive the DLL sync on every per-game install (decision 2 keeps it), or only when the global profile is the install target? Current design keeps the sync for safety; can be revisited if disk/write cost matters.
- Should `RefreshOsStatusDots` also reflect an "Update available" arrow when the active game's tag is below the latest remote for its channel? The current global-only logic shows the arrow via `optLabel2`; per-game update-notifications are out of scope here and left to a follow-up.