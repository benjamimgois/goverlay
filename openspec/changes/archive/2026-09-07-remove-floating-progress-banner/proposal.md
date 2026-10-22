## Why

When updating OptiScaler or DLSS-Enabler, a floating progress banner (`FFloatingProgress`) is displayed at the top of the screen in addition to the integrated progress bar inside the Software Status card. This floating banner is redundant, stays stuck at 0%, displays inaccurate hardcoded text ("Downloading OptiScaler components...") even when updating DLSS-Enabler, and obscures controls at the top of the window. Removing this redundant banner ensures component downloads rely solely on the integrated in-card progress controls.

## What Changes

- Remove the invocation of `FFloatingProgress.ShowProgress` and `FFloatingProgress.HideProgress` from `updateBitBtnClick` in `overlayunit.pas`.
- Remove the update of `FFloatingProgress` from `ReshadeGitProgress` in `overlayunit.pas`, keeping progress reporting exclusively inside the integrated `FVkToggleCard` controls (`FReshadeProgressBar` and `FReshadePhaseLabel`).
- Preserve the `TFloatingProgressBanner` class definition in `floating_overlay.pas` and its component unit tests in `tests/gui/gui_test_cases.pas`, ensuring clean decoupling without breaking utility test coverage.
- Add an automated GUI test verifying that component update initiation does not display the floating progress banner.

## Capabilities

### New Capabilities
- `download-progress-display`: Defines the behavior and placement of download and update progress indicators across tabs, establishing that progress must be rendered in-card rather than via floating top banners.

### Modified Capabilities
<!-- None -->

## Impact

- `overlayunit.pas`: Cleaner `updateBitBtnClick` and `ReshadeGitProgress` routines without floating banner triggers.
- UI Experience: No duplicate or frozen progress bars floating over tab content during OptiScaler, DLSS-Enabler, or ReShade downloads.
