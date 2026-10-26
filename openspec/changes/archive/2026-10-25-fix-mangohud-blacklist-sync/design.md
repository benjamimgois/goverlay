# Design

## Context

See proposal.md for motivation and problem background. Currently, `blacklistunit.pas` operates as an independent modal that saves process entries into `~/.config/goverlay/blacklist.conf`. MangoHud only recognizes blacklists through the `blacklist=item1,item2` line inside its configuration files (`MangoHud.conf`). The synchronization currently only happens when users execute a full save on the MangoHud tab in the main window (`overlayunit.pas`). In addition, GOverlay manages runner execution via `~/.local/share/goverlay/gameconfig/global/MangoHud.conf`, which was not updated by the standalone dialog.

## Goals / Non-Goals

**Goals:**
- Provide instantaneous synchronization between `blacklist.conf` and all `MangoHud.conf` files (system config, `gameconfig/global/`, and Steam Flatpak) upon adding or removing items in `TblacklistForm`.
- Centralize path resolution for `blacklist.conf` using `TConfigManager` / `overlay_utils`.
- Eliminate duplicated blacklist serialization code across `blacklistunit.pas`, `overlay_config.pas`, and `overlayunit.pas`.
- Modernize the `TblacklistForm` UI/UX with card styling, item count badge, owner-drawn list cards, and keyboard shortcuts (Enter to add, Delete/Backspace to remove, Escape to close).

**Non-Goals:**
- Creating per-game blacklist configurations (MangoHud blacklists are inherently global/process-based).

## Decisions

### Decision 1: Implement `SyncBlacklistToMangoHud` helper in `overlay_config.pas`
- **Choice**: Export `function SyncBlacklistToMangoHud(const ABlacklist: TStrings = nil): Boolean;` from `overlay_config.pas`.
- **Rationale**: `overlay_config.pas` handles Steam Flatpak directory detection, global profile paths (`GetGameConfigDir('')`), and manages `MangoHud.conf` serialization.

### Decision 2: Immediate invocation on list modifications
- **Choice**: Call `SyncBlacklistToMangoHud` directly inside `insertblacklistBitBtnClick` and `removeblacklistBitBtnClick` right after saving `blacklist.conf`.
- **Rationale**: Immediate consistency ensures that even if the user never clicks "Save" in the main window or exits the application, all active MangoHud configuration files reflect the blacklisted apps immediately.

### Decision 3: Centralize `BlacklistFile` resolution
- **Choice**: Use `TConfigManager.GetBlacklistFile` everywhere.
- **Rationale**: Avoids manual string concatenations like `GetUserConfig + '/goverlay/blacklist.conf'` which ignore `HOST_XDG_CONFIG_HOME` and cause discrepancies in sandboxed environments (Flatpak / AppImage).

### Decision 4: Modernize Dialog Layout & Owner-Drawn List
- **Choice**: Adapt `TblacklistForm` dynamically on show (`BuildModernUI`):
  - Expand dimensions to 460 x 520 with proper padding.
  - Implement custom owner-draw on `blackListBox` (`lbOwnerDrawFixed`, 32px height) with status dot, crisp fonts, selection highlight, and bottom separators.
  - Support keyboard actions (Enter to add, Delete/Backspace to delete, Escape to close).
  - Add item counter badge and clean action buttons styled via `StyleBitBtnTheme`.

## Risks / Trade-offs

- **[Risk]** `MangoHud.conf` does not exist yet when the user edits the blacklist.
  → **Mitigation**: `SyncBlacklistToMangoHud` ensures target directories exist via `CreateHostDirectory` and creates/saves the file gracefully via `TConfigFile`.
