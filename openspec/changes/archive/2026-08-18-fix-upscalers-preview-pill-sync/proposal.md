## Why

When navigating within the "Upscalers" category, switching from the "Lossless Scaling" tab to the "Optiscaler" tab leaves the floating action dock's `[ 👁 Preview ]` pill visible because `optiscalerTabSheet` lacks an `OnShow` event handler. Furthermore, navigating to the "Upscalers" sidebar category can cause desynchronization where the dock state and tab content reflow are not reliably executed for the active sub-tab.

## What Changes

- Implement a dedicated `optiscalerTabSheetShow` event handler for `optiscalerTabSheet.OnShow` that invokes `FFADock.UpdateForTab(False, False, False)` to hide the Preview pill and loads OptiScaler configuration/layout.
- Update `losslessScalingTabSheetShow` to ensure `FFADock.UpdateForTab(True, False, False)` is consistently applied whenever the Lossless Scaling tab is displayed.
- Symmetrize `optiscalerLabelClick` in `overlayunit.pas` to delegate tab initialization and dock configuration to the active sub-tab's show handler (`optiscalerTabSheetShow` or `losslessScalingTabSheetShow`).

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `lossless-scaling-tab`: Ensure Floating Action Dock preview pill dynamically shows on Lossless Scaling and hides on OptiScaler when switching tabs.

## Impact

- Modified files: `overlayunit.pas`
- Affected components: `goverlayPageControl` sub-tab switching between `optiscalerTabSheet` and `losslessScalingTabSheet`, `TFloatingActionDock` contextual action visibility.
