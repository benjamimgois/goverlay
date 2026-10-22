# Proposal

## Why

When launching a game configured through GOverlay (such as *Control Ultimate Edition*), the startup launch splash screen displayed an incorrect game title (`Game: VKSUMI_CONFIG_FILE`) and completely omitted the ReShade status indicator even when Post-Processing was enabled with ReShade method.

This occurs because:
1. In `bgmod.lpr`, the global variable `Key` initially holds the game directory/profile name, but is later reused in key-value parsing loops for environment variables (`[Env]`) and TOML configurations. As a result, the last parsed variable (`VKSUMI_CONFIG_FILE`) overrides the game name passed to `bgmod-splash`.
2. In `bgmod.lpr`, the list of items built for the splash dialog completely lacks a check for `GOverlayReshade`, meaning ReShade is never forwarded to `bgmod-splash`.

Fixing this ensures that the launch splash accurately reflects the launched game's profile name and provides visual confirmation when ReShade is active.

## What Changes

- Preserve the game profile name in a dedicated variable (`GameProfileName`) in `bgmod.lpr` so it cannot be overwritten by key-value parsing loops (such as `[Env]` in `bgmod.conf`, `lsfg.toml`, or `conf.toml`).
- Use `GameProfileName` when passing `--game=<title>` to `bgmod-splash` (with fallback to `TargetExeName` in global mode).
- Add `if GOverlayReshade then SplashItems.Add('ReShade');` in `bgmod.lpr` so ReShade is included in the splash active modules checklist alongside vkBasalt.
- Update test cases in `tests/logic/logic_test_cases.pas` to verify splash item assembly and game title preservation.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `bgmod-launch-splash`: Include ReShade in the active modules checklist presentation when Post-Processing is configured with ReShade, and guarantee accurate game title display without variable corruption.

## Impact

- `bgmod.lpr`: Variable isolation for game profile name and inclusion of ReShade in `SplashItems`.
- `data/bgmod/bgmod`: Binary rebuild.
- Existing user game config folders (e.g. `~/.local/share/goverlay/gameconfig/<Game>/bgmod`) will automatically receive updated `bgmod` through GOverlay's startup wrapper sync.
