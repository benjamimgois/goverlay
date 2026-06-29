## Why

To maintain consistency across all cards in the Games tab, the "Add non-Steam folder" card should utilize the same floating action button design instead of relying on a right-click context menu.

## What Changes

- Add floating action button (`CreateActionPanel`) to the "Add non-Steam folder" card (`Tag = 9998`).
- Allow hovering on card `9998` to display the floating action button.
- Trigger `ShowRemoveFoldersMenu` when clicking the floating action button on card `9998`.
- Remove right-click context menu triggering on card `9998`.

## Capabilities

### New Capabilities
- `nonsteam-add-folder-floating-button`: Adds floating action button to the "Add non-Steam folder" card to replace its right-click context menu.

### Modified Capabilities
<!-- None -->

## Impact

- `games_tab.pas`: Updated card 9998 creation, hover visibility, and action button click handlers.
