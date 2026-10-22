# Design

## Context

See `proposal.md` for motivation.

In `bgmod.lpr`:
- `Key` is declared as a global string variable shared across initialization, configuration parsing, and game invocation.
- At initialization (line 2068), `Key := ExtractFileName(TempStr)` resolves the profile directory (e.g. `'Control Ultimate Edition'`).
- During environment variable loading (line 2604) and TOML parsing (lines 2696, 2822, 2869), `Key` is repeatedly overwritten as a scratch variable for `Key=Val` pairs.
- At splash launch (line 3385), `bgmod` attempts to read `Key` as the game title, resulting in environment variables (such as `VKSUMI_CONFIG_FILE`) or TOML keys being used as the title.
- In `SplashItems` assembly (lines 3347-3379), `GOverlayReshade` is omitted.

## Goals / Non-Goals

**Goals:**
- Guarantee that `bgmod` passes the actual game profile directory name (e.g. `Control Ultimate Edition`) or the executable name (in global mode) to `bgmod-splash`.
- Ensure ReShade is included in `SplashItems` when `GOVERLAY_RESHADE=1`.
- Ensure Lossless Scaling, vkSumi, OptiScaler, and other tools retain their proper labels and do not corrupt the game title.
- Recompile `bgmod` and update `data/bgmod/bgmod`.

**Non-Goals:**
- Modifying `bgmod-splash` UI appearance or geometry (the splash already reflows dynamically and renders any item properly).
- Refactoring `bgmod.lpr`'s entire global variable architecture.

## Decisions

### Decision 1: Dedicated `GameProfileName` variable
- **Choice**: Introduce `GameProfileName: string;` in `bgmod.lpr` and assign it immediately upon inspecting `BgmodPath`:
  ```pascal
  TempStr := ExcludeTrailingPathDelimiter(BgmodPath);
  GameProfileName := ExtractFileName(TempStr);
  ```
  Use `GameProfileName` for determining `IsPerGameProfile`, `CentralLogDir`, and `SplashGameTitle`.
- **Rationale**: Isolates the profile identity from scratch parsing variables (`Key`, `Line`, `Val`).
- **Alternative considered**: Resetting `Key` at the end of each parsing loop. Rejected because it is fragile and can easily regress if new loops or config parsing blocks are added in the future.

### Decision 2: Include ReShade in Splash Checklist
- **Choice**: Add:
  ```pascal
  if GOverlayReshade then
    SplashItems.Add('ReShade');
  ```
  directly adjacent to the `vkBasalt` check in `bgmod.lpr`.
- **Rationale**: Since `vkBasalt` and `ReShade` are the two post-processing methods in GOverlay, keeping them adjacent maintains logical symmetry.

## Risks / Trade-offs

- **[Risk]** Outdated `bgmod` binaries in existing game config directories.
  → **Mitigation**: GOverlay's existing wrapper sync mechanism (`SyncGameWrapperBinaries` in `bgmod_resources.pas`) automatically updates `bgmod` across all game config directories on application launch. Additionally, `make bgmod` copies the built binary to `./data/bgmod/bgmod`.
