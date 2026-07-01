## 1. Folder Restructuring

- [x] 1.1 In `optiscaler_update.pas`, add logic in `UpdateButtonClick` to check if `OptiScaler` subfolder exists after extraction, move its contents recursively to the root of `.bgmod_original`, and delete the subfolder.
- [x] 1.2 In `optiscaler_update.pas`, implement the same `OptiScaler` subfolder relocation check and shell copy/cleanup process in `CheckAndInstallOptiScaler`.

## 2. Frame Generation Helper

- [x] 2.1 In `optiscaler_update.pas` (`UpdateButtonClick`), add download step for `dlssg_to_fsr3_amd_is_better.dll` using `DownloadFile` into `.bgmod_original/`.
- [x] 2.2 In `optiscaler_update.pas` (`CheckAndInstallOptiScaler`), add the same curl download command to download the helper dll to `.bgmod_original/`.

## 3. FakeNVAPI Integration

- [x] 3.1 Declare and implement `FetchFakeNvapiLatest` helper in `optiscaler_update.pas` using `curl` and json parsing (`fpjson`, `jsonparser`) to retrieve the latest release tag name and `.7z` browser download URL.
- [x] 3.2 In `optiscaler_update.pas` (`UpdateButtonClick`), call `FetchFakeNvapiLatest`, download the `.7z` file, extract it to `.bgmod_original`, clean up the downloaded archive, and add the version (without 'v' prefix) under `FakeNvapiVersion` in `goverlay.vars`.
- [x] 3.3 Update the sync commands in `UpdateButtonClick` to explicitly copy `fakenvapi.ini` from `.bgmod_original/` to `FFGModPath`.
- [x] 3.4 In `optiscaler_update.pas` (`CheckAndInstallOptiScaler`), implement the same dynamic FakeNVAPI download, extraction, and `goverlay.vars` tracking.

## 4. FSR and XeSS Dynamic Version Retrieval

- [x] 4.1 Declare and implement `FetchVarsTxt` helper in `optiscaler_update.pas` to download `vars.txt` from the remote repository and parse the values of `fsrstable`, `fsredge`, `xessstable`, and `xessedge`.
- [x] 4.2 In `optiscaler_update.pas` (`UpdateButtonClick`), call `FetchVarsTxt` and populate `fsrversion` and `xessversion` in `goverlay.vars` using channel-specific values.
- [x] 4.3 In `optiscaler_update.pas` (`CheckAndInstallOptiScaler`), call `FetchVarsTxt` and write stable values for `fsrversion` and `xessversion` to `goverlay.vars`.
