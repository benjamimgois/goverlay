## Context

OptiScaler FSR version selection ("Latest" vs "4.0.2c (INT8)") currently fails to persist the selection inside the game's configuration folder's `goverlay.vars` file. When the configuration is saved, the card in Software Status is not updated and the FSR Version combobox resets to "Latest" upon reloading the game profile because the local `goverlay.vars` retains the cached channel version (e.g. `4.1` or `4.1.1`). Furthermore, when OptiScaler is toggled ON, the default root DLL is copied instead of respecting the saved version configuration.

## Goals / Non-Goals

**Goals:**
- Correctly save FSR version configuration to `goverlay.vars` on configuration save.
- Support both `'4.0.2c (INT8)'` and `'4.0.2c INT8'` string formats when loading configurations.
- Ensure the Software Status card immediately reflects changes after a save.
- Ensure the correct FSR DLL is copied into the game config folder when enabling the OptiScaler toggle.

**Non-Goals:**
- Copying the FSR DLL directly to the game installation folder from GOverlay on configuration save. The `bgmod` wrapper will handle copying the DLL from the config directory to the game directory on run.

## Decisions

### Decision 1: Write `fsrversion` to `goverlay.vars` in `SaveOptiScalerConfigCore`
In `overlay_config.pas` `SaveOptiScalerConfigCore`:
- Load the game configuration folder's `goverlay.vars` file (or copy/create from cache if missing).
- If `Settings.FsrversionItemIndex = 1` (INT8), write `fsrversion=4.0.2c INT8` to the file.
- If `Settings.FsrversionItemIndex = 0` (Latest), read the actual FSR version from the corresponding update channel cache's `goverlay.vars` (stable or edge cache folder) and write that version value (e.g. `4.1` or `4.1.1`) to the file.

### Decision 2: Support flexible string format parsing for FSR INT8 version
To allow displaying `'4.0.2c INT8'` without parentheses on the Software Status card while keeping the combobox state correctly restored:
- In `overlay_config.pas` `LoadOptiScalerConfig`: set `Settings.FsrversionItemIndex := 1` if the parsed `FsrVer` is either `'4.0.2c (INT8)'` or `'4.0.2c INT8'`.
- In `optiscaler_update.pas` `LoadVersionsFromFile`: select index `1` in `FsrVersionComboBox` if `FsrVer` is either `'4.0.2c (INT8)'` or `'4.0.2c INT8'`.

### Decision 3: Update `CopyOptiScalerGameFiles` toggle handler to respect FSR selection
In `sidebar_nav.pas` `CopyOptiScalerGameFiles`:
- After executing the `cp -rn` shell command to copy all OptiScaler files from the cache directory to the game configuration directory:
- Load the configuration for the active game using `LoadOptiScalerConfig`.
- If `Settings.FsrversionItemIndex = 1` (INT8), overwrite `amd_fidelityfx_upscaler_dx12.dll` in the game's configuration folder with the file from `<channel-cache>/FSR4_INT8/amd_fidelityfx_upscaler_dx12.dll`.

### Decision 4: Refresh Software Status card immediately after configuration save
In `optiscaler_tab.pas` `TOptiScalerTabHelper.SaveOptiScalerConfig`:
- After `SaveOptiScalerConfigCore` successfully completes, call `FOptiscalerUpdate.LoadVersionsFromFile` and `RefreshOsStatusDots` to update the UI labels immediately.

## Risks / Trade-offs

- **[Risk]** Mismatched `fsrversion` string format breaks combobox selection restoration.
  - *Mitigation*: Support both formats (`'4.0.2c (INT8)'` and `'4.0.2c INT8'`) during config loading and parsing.
- **[Risk]** `goverlay.vars` in game config is missing on toggle.
  - *Mitigation*: Fall back to the channel cache's `goverlay.vars` to get the default values before writing.
