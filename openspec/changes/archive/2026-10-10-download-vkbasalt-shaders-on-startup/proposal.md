# Proposal

## Why

Currently, vkBasalt's ReShade shaders repository (`~/.config/vkBasalt/reshade-shaders/`) is not verified or downloaded during GOverlay's initial boot sequence. Because the vkBasalt tab was unified into the Post processing view (`reshadeTabSheet`), the old `vkbasaltTabSheetShow` event is never triggered, leaving the vkBasalt shaders list blank until manual intervention or leaving users with an empty list. Verifying and downloading the vkBasalt shaders during application startup alongside other mandatory runtime assets ensures the shaders are ready immediately upon first launch.

## What Changes

- Add vkBasalt shaders directory (`~/.config/vkBasalt/reshade-shaders/`) check to `HasMissingMandatoryLibraries`.
- Add `CheckAndInstallVkBasaltShaders` in `optiscaler_update.pas` (downloading the repository archive or cloning into `VKBASALTFOLDER + 'reshade-shaders'`) with progress reporting on the boot splash.
- Integrate `CheckAndInstallVkBasaltShaders` into `TStartupDownloadThread.Execute` in `overlayunit.pas` with a dedicated progress range (e.g. 96%–99%).
- Repopulate `aveffectsListbox` and refresh the vkBasalt UI when startup downloads complete or when the tab is shown.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `startup-libraries-verification`: Add vkBasalt ReShade shaders directory (`~/.config/vkBasalt/reshade-shaders/`) to mandatory startup asset verification and self-healing downloads.

## Impact

- `optiscaler_update.pas`: Adds `CheckAndInstallVkBasaltShaders` and updates `HasMissingMandatoryLibraries`.
- `overlayunit.pas`: Calls `CheckAndInstallVkBasaltShaders` in `TStartupDownloadThread.Execute`.
- `vkbasalt_tab.pas`: Refreshes effects list when repository directory is detected.
