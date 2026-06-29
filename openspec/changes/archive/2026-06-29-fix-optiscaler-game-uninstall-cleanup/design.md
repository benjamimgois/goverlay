## Context

In games with nested binary directories (e.g., Unreal Engine games with `Binaries/Win64/`), OptiScaler DLLs reside inside subdirectories. When "Uninstall changes" is invoked, GOverlay currently checks only the top-level directory if `bgmod-uninstaller` is missing in root. Furthermore, `bgmod.lpr` does not clean up DLLs on launch when OptiScaler is disabled.

## Goals / Non-Goals

**Goals:**
- Implement recursive scan in `GameCardUninstallClick` (`games_tab.pas`) for any subdirectory in `GamePath` containing `goverlay.vars`, `OptiScaler.dll`, or `OptiScaler.ini`.
- Perform `RunFGModUninstallCommands` on each matched directory.
- In `bgmod.lpr`, update the `else` branch of `if GOverlayOptiscaler` to run proxy cleanup and restore backup DLLs if `goverlay.vars` or proxy files exist in `GameDir`.

**Non-Goals:**
- Modifying Steam launch commands in user profiles.

## Decisions

### Decision 1: Recursive directory scan helper in games_tab.pas
Create a helper procedure `FindTargetDirsWithMarkers(const ABaseDir: string; AList: TStringList)` in `games_tab.pas` that traverses subdirectories (up to a reasonable depth of 4) looking for `goverlay.vars`, `OptiScaler.dll`, or `OptiScaler.ini`.

### Decision 2: Active wrapper cleanup in bgmod.lpr
In `bgmod.lpr`, under `if not GOverlayOptiscaler`, call `SafeCleanOrRestore` for all proxy DLLs and remove OptiScaler runtime files if `goverlay.vars` is present.

## Risks / Trade-offs

- None identified.
