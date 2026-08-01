## Why

When DLSS Enabler is selected on the Upscalers tab, the Software Status card incorrectly displays raw build release tag strings for DLSS Enabler instead of the actual DLSS Enabler version (e.g., `4.8.10.11`) and integrated OptiScaler version (e.g., `v0.10.0-pre1`). Furthermore, update checking when DLSS Enabler is active incorrectly checks standard OptiScaler channels instead of querying the DLSS Enabler repository (`bygalacos/OptiScalerBuilder`), causing misleading update notifications.

## What Changes

- **Release Table Parsing**: Update `DownloadAndExtractDlssEnabler` and version loading routines to parse the release body from `bygalacos/OptiScalerBuilder` and extract the distinct `DLSS Enabler` version (e.g., `4.8.10.11`) and integrated `OptiScaler` version (e.g., `v0.10.0-pre1`) into `goverlay.vars`.
- **Targeted Update Checking**: When DLSS Enabler is enabled (`UPSCALER_TYPE=1`), background update checking (`TOptiUpdateThread`) will check the `bygalacos/OptiScalerBuilder` releases for DLSS Enabler updates rather than checking OptiScaler channels.
- **UI Update Actions**: Clicking the Update button while DLSS Enabler is selected triggers the DLSS Enabler update process instead of OptiScaler.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `upscalers-dlss-enabler`: Update requirements for DLSS Enabler version parsing and update checking when DLSS Enabler is active.

## Impact

- `optiscaler_update.pas`: Update `DownloadAndExtractDlssEnabler`, `TOptiUpdateThread.SyncUpdateUI`, `LoadVersionsFromFile`, and `UpdateButtonClick` to handle DLSS Enabler release body parsing and targeted update notifications.
- `optiscaler_tab.pas`: Ensure UI controls correctly reflect DLSS Enabler update status.
