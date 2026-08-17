## Why

Proton-CachyOS supports enabling Discord Rich Presence integration for Windows games running under Wine/Proton through the `PROTON_DISCORD_BRIDGE=1` environment variable. Adding a toggle for this variable in GOverlay's EnvVars tab (General category) gives users an easy, visual way to enable Discord Rich Presence per-game or globally.

## What Changes

- Add a new tweak row for `PROTON_DISCORD_BRIDGE=1` under the **General** section in the EnvVars tab.
- Display the description as `"[proton-cachyos] Enable Discord's Rich Presence."` with the `[proton-cachyos]` prefix highlighted in purple.
- Display tooltip `"Works only with proton-cachyos"` on hover.
- Add backing `TCheckBox` component `FProtonDiscordBridgeCheckBox` on `Tgoverlayform` and wire it up to `bgmod.conf` save/load logic.

## Capabilities

### New Capabilities
- `proton-discord-bridge-tweak`: Toggle `PROTON_DISCORD_BRIDGE=1` in GOverlay's EnvVars tab under General, displaying `[proton-cachyos] Enable Discord's Rich Presence.` in purple prefix with proton-cachyos tooltip and persisting to `bgmod.conf`.

### Modified Capabilities

## Impact

- `overlayunit.pas`: Backing checkbox declaration on `Tgoverlayform`.
- `tweaks_md3.pas`: Row definition in `TWEAK_ROWS`, mapping in `GetTweakRowCheckBox`, instantiation in `InitTweaksCards`, hover tooltip check, and save/load in `SaveTweaksConfig`, `HasTweaksEnabled`, and `LoadTweaksFromFGMod`.
- `tests/gui/gui_test_cases.pas`: GUI integration test coverage for toggle save/load roundtrip.
