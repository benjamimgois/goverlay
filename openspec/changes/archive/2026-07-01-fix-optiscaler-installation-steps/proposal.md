## Why

This change addresses multiple gaps in the OptiScaler installation and update workflows of GOverlay:
1. Files extracted from the OptiScaler release archives (which are structured under an `OptiScaler/` subfolder) are not moved to the root bgmod folder, causing game launches to fail to locate required libraries.
2. The mandatory frame generation helper `dlssg_to_fsr3_amd_is_better.dll` is not automatically downloaded.
3. The `fakenvapi` dependency is not downloaded, extracted, or version-tracked, which prevents features dependent on FakeNVAPI (like Reflex configuration) from working correctly.
4. FSR and XeSS versions are not parsed and stored dynamically in `goverlay.vars`, leading to missing or incorrect version labels in the user interface.

## What Changes

- **Folder restructuring**: Automatically move all contents extracted from the `OptiScaler` subfolder inside the pristine `.bgmod_original` cache directory to its root, then clean up the empty subfolder.
- **Auto-download auxiliary dlls**: Download `dlssg_to_fsr3_amd_is_better.dll` to `.bgmod_original` during stable and bleeding-edge updates/auto-installs.
- **Dynamic FakeNVAPI updates**: Query the GitHub API for the latest stable `fakenvapi` release, download the release archive, extract it to `.bgmod_original`, track its version (without the 'v' prefix) under `FakeNvapiVersion` in `goverlay.vars`, and sync it (along with `fakenvapi.ini`) to the working copy.
- **Dynamic FSR and XeSS version parsing**: Query the raw `vars.txt` file from the `OptiScaler-builds` repository to fetch the active FSR and XeSS versions (stable and edge), and populate `fsrversion` and `xessversion` in `goverlay.vars`.

## Capabilities

### Modified Capabilities
- `bgmod-update-optiscaler`: Correct folder structure, download additional dlls, dynamically fetch and update FakeNVAPI, and parse FSR/XeSS versions dynamically to record them in `goverlay.vars`.

## Impact

- `optiscaler_update.pas`: Updated to add subfolder move, download the frame generation helper, query/download/extract fakenvapi, parse versions from `vars.txt`, and write correct variables to `goverlay.vars`.
- `bgmod.lpr`: Will now copy `fakenvapi.ini` (since it will be properly populated and synced from `.bgmod_original`).
