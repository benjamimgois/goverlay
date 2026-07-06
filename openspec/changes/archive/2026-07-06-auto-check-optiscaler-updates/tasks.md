## 1. Core Implementation

- [x] 1.1 Update `optiscalerLabelClick` in `overlayunit.pas` to invoke `FOptiscalerUpdate.CheckForUpdatesOnClick` when opening the tab page
- [x] 1.2 Update `CheckForUpdatesOnClick` in `optiscaler_update.pas` to use a conditional fallback for `FFGModPath` instead of overwriting it

## 2. Verification

- [x] 2.1 Compile goverlay with `lazbuild goverlay.lpi` to verify no compilation issues
- [x] 2.2 Manually verify that navigating to the OptiScaler tab triggers a background update check, preserving active game/global context
