# Proposal: Auto-Update OptiPatcher Rolling Release on OptiScaler Tab Open

## Problem Statement
OptiPatcher is a rolling-release tool for game compatibility fixes that receives frequent updates on its repository (`optiscaler/OptiPatcher`). Currently, GOverlay only updates OptiPatcher when the entire OptiScaler builder package is updated. As a result, users miss out on standalone OptiPatcher game fixes pushed between OptiScaler release builds.

## Proposed Changes
1. **Background Rolling Update Check (`optiscaler_update.pas`)**:
   - Implement an asynchronous background check (`CheckAndUpdateOptiPatcherAsync`) that queries the `optiscaler/OptiPatcher` GitHub repository (commits on `main` branch or latest release).
   - Compare the remote commit date against local `optipatcher=rolling-YYYY.MM.DD` stored in `goverlay.vars`.

2. **Automatic Download & File Sync**:
   - If a newer commit/release exists remotely (or if OptiPatcher is missing), download the latest `OptiPatcher.asi` in the background.
   - Automatically overwrite `plugins/OptiPatcher.asi` in:
     - Global library: `~/.local/share/goverlay/optiscaler/plugins/`
     - Global template: `gameconfig/global/.bgmod_original/plugins/`
     - Active game folder: `gameconfig/<active_game>/bgmod/plugins/`
   - Update `optipatcher=rolling-YYYY.MM.DD` in `goverlay.vars`.

3. **Tab Switch Trigger (`overlayunit.pas`)**:
   - Trigger `CheckAndUpdateOptiPatcherAsync` non-blockingly whenever the user switches to the OptiScaler tab.
   - Show a subtle toast notification and update the Software Status card label when a new OptiPatcher build is applied.

## Impact
- Users automatically get the latest OptiPatcher fixes every time they open the OptiScaler tab without freezing the UI or needing manual update clicks.
