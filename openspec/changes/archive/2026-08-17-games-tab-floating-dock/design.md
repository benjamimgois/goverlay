## Context

See `proposal.md` for motivation. Currently, `games_tab.pas` creates a dummy game card with a plus icon and a 3-dot action button at the end of the grid to allow adding and removing non-Steam folders. `TFloatingActionDock` in `floating_dock.pas` is used across configuration tabs, but was previously hidden on the Games tab and always assumed `FFinishBox` was visible.

## Goals / Non-Goals

**Goals:**
- Eliminate the fake "+ Add game folder" card from `games_tab.pas` so the grid displays strictly genuine game cards.
- Generalize `TFloatingActionDock` to support optional Finish button (`AShowFinish: Boolean = True`) and customizable Add button label (`+ Add Folder` on Games tab, `+ Add` on EnvVars tab).
- Display `[ ☰ ] [ + Add Folder ]` floating dock on the Games tab.
- Unify non-Steam folder addition, removal, and library refresh under the Games tab's contextual hamburger menu.

**Non-Goals:**
- Modifying how Steam game libraries are discovered or how Steam cover artwork is cached.
- Changing game launch options or configuration profiles.

## Decisions

### 1. Generalize `TFloatingActionDock.UpdateForTab`
- **Choice**: Extend `UpdateForTab` with `AShowFinish: Boolean = True` and `const AAddCaption: string = '+ Add'`. Dynamically calculate the Add button width based on the caption text (e.g. 100px for `+ Add Folder`, 76px for `+ Add`).
- **Rationale**: Keeps `TFloatingActionDock` completely reusable across all present and future tabs without duplicating pill rendering logic.

### 2. Clean Grid Generation in `games_tab.pas`
- **Choice**: Remove the `CardPanel` creation block for "Add game folder" in `LoadSteamGames`.
- **Rationale**: Removes visual clutter, eliminates edge-case math in `ReflowGamesGrid`, and creates a uniform grid of real games.

### 3. Contextual Games Tab Hamburger Menu
- **Choice**: In `overlayunit.pas`, wire `DockMenuClick` when on `gamesTabSheet` to pop up a dedicated Games menu:
  - `Add game folder...` (triggers `AddNonSteamFolderClick`)
  - `Remove game folder ▸` (sub-menu dynamically populated with added non-Steam paths from `nonsteam_folders.txt`, disabled if empty)
  - Separator
  - `Refresh game library` (triggers `RefreshGameCards`)
- **Rationale**: Provides clear, discoverable, and centralized management of game libraries and custom folders in one consistent UI location.

## Risks / Trade-offs

- **[Risk] User familiarity**: Users used to seeing the "+" card at the bottom of the grid might look for it.
  - *Mitigation*: The floating pill `[ + Add Folder ]` is positioned in the prominent bottom-right action area, consistent with modern apps and other GOverlay tabs.
