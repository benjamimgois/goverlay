# Proposal

## Why

Users who configure custom environment variables in GOverlay currently have to re-enter them manually for every individual game profile. By making global custom variables act as an inherited catalog that automatically appears in per-game profiles with an inactive toggle (OFF by default), users can easily enable their preferred environment variables per game with a single click.

## What Changes

- **Global Custom Variable Persistence**: Persist custom environment variables in global configuration even when their toggle is switched OFF (storing them in a dedicated `[CustomVariables]` section in `bgmod.conf`), so they are not discarded when disabled.
- **Per-Game Catalog Inheritance**: When viewing the Tweaks (EnvVars) tab for a selected game profile, all custom variables defined globally automatically appear in the "Custom Variables" card with their toggle switch set to OFF by default (or ON if already enabled for that game).
- **Toggle-Driven Game Activation**: Toggling a global custom variable ON within a game profile saves it into that specific game's `bgmod.conf` `[Env]` section, while toggling it OFF removes it from that game's active `[Env]`.
- **Visual Badging**: In game profiles, custom variables originating from the global catalog are marked with a distinct `[Global]` badge chip.
- **Context-Aware Deletion Guard**: In game profiles, global variables do not display the delete button (`×`), preventing accidental deletion of global catalog entries from within a game profile; deletion of global entries is restricted to Global mode. Game-specific custom variables retain the `×` delete button.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `envvars-tab-card-redesign`: Extend Custom Variables card behavior to persist global custom variables across toggle states, inherit global custom variables into per-game profiles as inactive presets, provide visual `[Global]` badge chips, and restrict entry deletion appropriately.

## Impact

- **UI Components**: `tweaks_md3.pas` (painting and click handling in `TTweaksMD3Helper`), `overlayunit.pas` (`FTweaksGrid`, `LoadTweaksFromFGMod`, `SaveTweaksToFGMod`).
- **Configuration & Storage**: `bgmod.conf` format in `~/.local/share/goverlay/gameconfig/global/` and per-game directories. Adds `[CustomVariables]` section without impacting `bgmod` runner (which only reads `[Env]`).
- **Breaking Changes**: None. Full backward compatibility with existing `bgmod.conf` files.
