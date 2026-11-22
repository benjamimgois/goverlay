# Design

## Context

See `proposal.md` for motivation. Currently, `SaveMangoHudConfigCore` in `overlay_config.pas` guards the host global write (`~/.config/MangoHud/MangoHud.conf`) with `if Settings.ActiveGameName = '' then`, but writes to `~/.var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf` unconditionally in both the standard save path and the `fps_only` shortcut. Additionally, `gamesLabelClick`, `GamesEmptySpaceClick`, and `GameCardClick` switch `FActiveGameName` and `MANGOHUDCFGFILE` without cancelling `autoSaveTimer` or immediately reloading `LoadMangoHudConfig` when returning to global mode.

## Goals / Non-Goals

**Goals:**
- Ensure per-game MangoHud saves never touch the Steam Flatpak global `MangoHud.conf`.
- Prevent stale MangoHud UI state or pending `autoSaveTimer` callbacks from writing game-specific values (such as `output_folder`) into global `MangoHud.conf` during profile switches.

**Non-Goals:**
- Changing how `CloneGlobalConfigToGame` seeds new game profiles or auto-cloning global config when clicking an unconfigured game card.
- Modifying `SyncBlacklistToMangoHud`, which intentionally updates only the `blacklist=` key across global and Flatpak configs.

## Decisions

1. **Guard Steam Flatpak writes with `if Settings.ActiveGameName = '' then`**:
   - *Choice*: Wrap the Steam Flatpak mirroring block in `SaveMangoHudConfigCore` (both standard and `fps_only` paths) inside `if Settings.ActiveGameName = '' then` (or combine with the existing host global `if` block).
   - *Rationale*: Steam Flatpak's `MangoHud.conf` is a global fallback for Flatpak Steam games without per-game overrides, symmetric to `~/.config/MangoHud/MangoHud.conf`.
   - *Alternative considered*: Removing Flatpak mirroring altogether — rejected because Flatpak Steam users rely on global config mirroring when editing global settings.

2. **Cancel `autoSaveTimer` and reload MangoHud UI on profile context transitions**:
   - *Choice*: In `gamesLabelClick` and `GamesEmptySpaceClick` (when leaving game mode for global mode) and at the start of `GameCardClick`, disable `autoSaveTimer` (`autoSaveTimer.Enabled := False`) before mutating `FActiveGameName` / `MANGOHUDCFGFILE`, and call `LoadMangoHudConfig` when returning to global mode.
   - *Rationale*: Cancelling instead of flushing avoids unexpectedly writing to the old or new target during navigation; reloading `LoadMangoHudConfig` guarantees `logfolderEdit.Text` and all checkboxes match `gameconfig/global/MangoHud.conf` immediately even if the user presses `Ctrl+S` on the Games tab.
   - *Alternative considered*: Flushing `autoSaveTimer` before switching — rejected because `StartAutoSaveTimer` is only a 300ms debounce for interactive UI tweaks, and flushing on navigation could persist partial/unintended state if the user immediately clicked away.

## Risks / Trade-offs

- [Unflushed 300ms edit lost on rapid navigation] → Acceptable; 300ms debounce only covers the moment a user clicks a card or logo immediately after a control change, and avoids cross-profile corruption.
- [Existing corrupted Steam Flatpak `MangoHud.conf` on user machines] → Mitigation: The next global save in Goverlay will overwrite `~/.var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf` with clean global settings.
