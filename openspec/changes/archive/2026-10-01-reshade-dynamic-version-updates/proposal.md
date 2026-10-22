# Proposal

## Why

Currently, GOverlay hardcodes ReShade runtime downloads to version 6.4.0 (`ReShade_Setup_6.4.0_Addon.exe`) and hardcodes the UI status label to "6.4 (Add-on Edition)" in both the ReShade tab and Home tab. When users click "Check updates", GOverlay repeatedly re-downloads version 6.4.0 without updating to the latest upstream release (such as 6.8.0), and the absence of explicit success logging or buffer flushing leaves the console output appearing stalled.

## What Changes

- Implement dynamic remote version discovery for ReShade (`GetReShadeLatestRemoteVersion`) querying official GitHub tags (`crosire/reshade`) with fallback to parsing `reshade.me`.
- Dynamically construct the download URL for the latest Add-on installer executable (`https://reshade.me/downloads/ReShade_Setup_<version>_Addon.exe`).
- Track the locally installed ReShade version via a metadata file (`~/.local/share/goverlay/reshade/version.txt`) written upon successful installation/update, with fallback version detection from `ReShade64.dll`.
- Provide `GetReShadeInstalledVersion` and integrate it into both `reshade_tab.pas` and `home_tab.pas` to replace hardcoded "6.4 (Add-on Edition)" strings with dynamic version strings.
- Add clear console feedback and completion logs (`[AUTO-INSTALL] ReShade runtime installed successfully (version: ...)`) and ensure `Flush(Output)` is invoked prior to external process execution so logs remain chronologically ordered.
- Update "Check updates" action in `reshade_tab.pas` to check the remote version, download updates when available, and reflect the new version in the status card.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `reshade-post-processing`: Replaces hardcoded 6.4 download URL and static status label with dynamic remote version discovery, dynamic Add-on installer download, version metadata tracking, and dynamic UI version display.
- `home-libraries-reshade-status`: Uses dynamic `GetReShadeInstalledVersion` to display the actual installed ReShade version in the Home tab Libraries card rather than static "6.4 (Add-on Edition)" text.

## Impact

- `optiscaler_update.pas`: Introduces `GetReShadeInstalledVersion` and `GetReShadeLatestRemoteVersion`; updates `CheckAndInstallReShade` to resolve version dynamically, write `version.txt`, and log results clearly.
- `reshade_tab.pas`: Updates `RefreshStatus` and `OnUpdateBtnClick` to use detected version and handle update flow.
- `home_tab.pas`: Updates `RefreshHomeOptiStatus` to read detected ReShade version.
- Tests: Test cases in logic and GUI test suites for ReShade version detection, remote parsing, and metadata file creation.
