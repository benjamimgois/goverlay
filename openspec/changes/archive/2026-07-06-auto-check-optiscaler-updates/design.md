## Context

GOverlay contains an asynchronous update checker for OptiScaler. The GUI triggers the update check on application startup, manual clicks, and when opening the OptiScaler tab page.

However, `CheckForUpdatesOnClick` unconditionally resets `FFGModPath := GetOptiScalerInstallPath`, which represents the global template folder. This breaks game-specific status representation since the installed versions are read from the global template folder's `goverlay.vars` instead of the active game profile's folder.

## Goals / Non-Goals

**Goals:**
- Automatically start the update checking thread in the background when the user navigates to the OptiScaler configuration tab.
- Prevent clobbering of `FFGModPath` during the update check to preserve the active game-specific/global configuration directory context.

**Non-Goals:**
- Modifying other components of GOverlay update checking.

## Decisions

- **Decision:** Trigger check in `Tgoverlayform.optiscalerLabelClick` in `overlayunit.pas`
  - *Rationale:* `optiscalerLabelClick` is the unique entry point called when navigating to the OptiScaler tab sheet.
- **Decision:** Use conditional fallback for `FFGModPath` in `TOptiscalerTab.CheckForUpdatesOnClick`
  - *Rationale:* By changing `FFGModPath := GetOptiScalerInstallPath` to:
    ```pascal
    if FFGModPath = '' then
      FFGModPath := GetOptiScalerInstallPath;
    ```
    we preserve the active profile directory (whether game-specific or global gameconfig) while falling back to the template directory if no path has been established yet.

## Risks / Trade-offs

- **Risk:** Rapid tab switching could cause redundant HTTP requests or thread clashes.
  - *Mitigation:* The existing `CheckForUpdatesOnClick` implementation checks if an existing update checking thread is active (`FOptiscalerUpdate.FUpdateThread`) and terminates/discards it before spawning a new one.
