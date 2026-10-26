# Proposal

## Why

In GOverlay, the "Blacklisted Apps" dialog allows users to blacklist applications from being hooked by MangoHud. However, when users add or remove applications in this modal, the changes are only saved to GOverlay's internal `blacklist.conf` file without updating the actual `blacklist=` directive in `~/.config/MangoHud/MangoHud.conf` (or Steam Flatpak's configuration). Users must navigate to the MangoHud tab and manually click "Save" for the blacklist to be applied, leading to confusion and bug reports (Issue #448) that blacklisting does not work.

## What Changes

- Automatically synchronize the blacklist from `blacklist.conf` directly to `~/.config/MangoHud/MangoHud.conf` (and the Steam Flatpak `MangoHud.conf` when present) immediately upon adding or removing an entry in the Blacklist dialog.
- Standardize the path resolution for `blacklist.conf` using `TConfigManager.GetBlacklistFile` and `overlay_utils.GetGOverlayConfigDir` to respect `HOST_XDG_CONFIG_HOME` and avoid sandbox/AppImage path mismatches.
- Ensure the blacklist logic in `SaveMangoHudConfigCore` and `saveBitbtnClick` reuses the same shared helper for consistency.

## Capabilities

### New Capabilities
- `mangohud-blacklist`: Real-time synchronization of blacklisted application process names between GOverlay's blacklist manager and MangoHud configuration files.

### Modified Capabilities
None.

## Impact

- `blacklistunit.pas`: Calls immediate synchronization routine after inserting or deleting items, and uses centralized config paths.
- `overlay_config.pas` / `overlay_utils.pas` / `configmanager.pas`: Shared helper `SyncBlacklistToMangoHud` to update `blacklist=` in active/global `MangoHud.conf` and Flatpak mirrors.
- `overlayunit.pas`: Deduplicate manual blacklist config manipulation to use the centralized helper.
