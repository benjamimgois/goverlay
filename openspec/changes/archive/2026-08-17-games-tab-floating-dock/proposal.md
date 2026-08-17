## Why

The Games grid currently contains a dummy "Add game folder" card pretending to be a game poster, featuring a small 3-dot action button for removing folders. This clutters the visual game library grid and creates an inconsistent UX. To homogenize the interface with GOverlay's design system, the "Add game folder" action should be integrated into the Floating Action Dock (`[ ☰ ] [ + Add Folder ]`), with folder removal and library refresh centralized into the contextual hamburger menu.

## What Changes

- **Remove Dummy Add Card from Grid**: Remove the fake "+ Add game folder" card from `games_tab.pas` so the grid contains exclusively genuine game posters.
- **Floating Action Dock on Games Tab**: Enhance `TFloatingActionDock` to allow hiding the Finish button (`AShowFinish: Boolean = False`) and customizing the Add button caption (`+ Add Folder`).
- **Games Tab Dock Activation**: Update `overlayunit.pas` to show `[ ☰ ] [ + Add Folder ]` when viewing the Games tab.
- **Contextual Hamburger Menu on Games Tab**: Implement a dedicated popup menu for the Games tab's `[ ☰ ]` button containing:
  - `Add game folder...` (triggers directory chooser dialog)
  - `Remove game folder ▸` (sub-menu listing added paths, or disabled when no custom folders exist)
  - `Refresh game library` (re-scans and updates the game cards grid)

## Capabilities

### Modified Capabilities
- `floating-action-dock`: Support contextual dock layout on the Games tab with optional Finish button and dynamic Add button label.
- `nonsteam-add-folder-floating-button`: Replace dummy game card action button with floating action dock and hamburger menu folder management.

## Impact

- `floating_dock.pas`: `UpdateForTab` supports `AShowFinish` and dynamic button labels.
- `games_tab.pas`: Removed dummy add folder card generation; added Games tab menu creation and refresh handler.
- `overlayunit.pas`: Updated `FFADock` setup and `DockMenuClick` to handle Games tab.
- `tests/gui/gui_test_cases.pas`: Updated test assertions for Games tab dock visibility and non-Steam folder management.
