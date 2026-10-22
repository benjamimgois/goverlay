## Why

When navigating to the vkBasalt tab (e.g. from the sidebar), the bottom Toggle Key card buttons (`[ Home ]`, `[ Restore Defaults ]`, `[ Sync Shaders ]`) are clipped at the bottom of the window. This happens because `vkbasaltTabSheetShow` is missing a call to `ReflowVkBasaltTab`, and `vkbasaltLabelClick` activates the sidebar before the tab is visible, causing `ReflowVkBasaltTab` to use an inaccurate fallback height calculation that overestimates the available tab height and pushes the lower cards off-screen.

## What Changes

- In `overlayunit.pas` (`vkbasaltTabSheetShow`), add `ReflowVkBasaltTab` call to reflow the tab whenever it becomes visible.
- In `overlayunit.pas` (`vkbasaltLabelClick`), ensure tab visibility and active page state are updated before calling `SetNavActive(2)`.
- In `vkbasalt_tab.pas` (`ReflowVkBasaltTab`), improve fallback height estimation when `vkbasaltTabSheet.ClientHeight < 150` using `goverlayPageControl.ClientHeight`.
- In `tests/gui/gui_test_cases.pas`, add test case verifying that vkBasalt tab layout properly positions the Toggle Key card and its action buttons within visible tab sheet bounds on first show.

## Capabilities

### New Capabilities
- `vkbasalt-tab-layout-reflow`: Responsive and accurate layout reflow of the vkBasalt tab upon activation and resize.

### Modified Capabilities
<!-- None -->

## Impact

- **Affected Files**: `overlayunit.pas`, `vkbasalt_tab.pas`, `tests/gui/gui_test_cases.pas`
- **Affected Functionality**: vkBasalt tab layout reflow and card positioning.
- **Breaking Changes**: None.
