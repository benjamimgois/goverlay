# Design

## Context

See `proposal.md` for motivation. Currently, GOverlay maintains wrapper templates in `~/.local/share/goverlay/bgmod/` and syncs `gameconfig/global/` on startup. Per-game directories under `gameconfig/<GameName>/` only receive binaries when a user clicks on the corresponding game card in the UI. Consequently, users running games directly via Steam with launch options pointing to `gameconfig/<GameName>/bgmod` execute stale wrapper binaries across GOverlay updates.

## Goals / Non-Goals

**Goals:**
- Iterate all game configuration directories (`goverlay/gameconfig/*/`) during GOverlay startup and update wrapper binaries (`bgmod`, `bgmod-uninstaller`, `bgmod-splash`).
- Keep executable permissions (`0755`) and the `fgmod` symlink up to date.
- Add version identifier constant `BGMOD_VERSION` and `BGMOD_UNINSTALLER_VERSION` and output in execution logs.
- Preserve 100% of user-configured settings, overlays, and backups.

**Non-Goals:**
- Modifying files inside Steam game installation directories (`steamapps/common/...`).
- Auto-syncing OptiScaler or ReShade DLLs (which remain managed by existing OptiScaler channels/toggles).
- Replacing physical wrapper binaries with symlinks (retaining physical binaries ensures compatibility across sandbox/Flatpak and preserves predictable `ParamStr(0)` directory resolution).

## Decisions

### 1. Centralized synchronization procedure in `bgmod_resources.pas`
- **Decision**: Introduce `procedure SyncAllGameConfigBinaries;` in `bgmod_resources.pas` and call it from `FormCreate` in `overlayunit.pas` immediately after `InitializeGlobalConfigDirectory`.
- **Rationale**: `bgmod_resources.pas` already encapsulates path resolution (`GetBGModPath`, `TConfigManager.GetHostDataDir`) and binary handling.
- **Alternatives Considered**:
  - Updating binaries only in `GameCardClick`: Rejected because users who run games from Steam without visiting the Games tab in GOverlay never trigger it.
  - Symlinking `gameconfig/<GameName>/bgmod` to `bgmod/bgmod`: Rejected due to edge cases with symlink resolution in Flatpak/Steam environments and `ParamStr(0)` path inference.

### 2. File filtering and safety
- **Decision**: Synchronization will only touch `bgmod`, `bgmod-uninstaller`, `bgmod-splash`, and `fgmod`. All other files (`*.conf`, `*.ini`, `*.vars`, and `backups/`) are excluded.
- **Rationale**: User settings must never be overwritten or reset on GOverlay update.

### 3. Explicit Version Logging in Wrappers
- **Decision**: Define `const BGMOD_VERSION = '1.9.3';` in `bgmod.lpr` and log `Executing bgmod v%s: %s` on startup.
- **Rationale**: Solves the diagnostic ambiguity seen in issue #413 where it was uncertain whether the user was executing an old or updated binary.

## Risks / Trade-offs

- **[Startup overhead with many games]** → Scanning subdirectories and copying up to 3 small binaries takes < 50ms even for dozens of games. Only existing subdirectories with `bgmod` or `bgmod.conf` will be processed.
- **[Game launched without opening GOverlay]** → If a user updates GOverlay via their package manager and immediately runs a game without opening GOverlay, the game folder will update the next time GOverlay is launched. As a future enhancement, `bgmod` could check timestamp against the system template, but startup sync already resolves the vast majority of cases safely.
