# Capability: Lossless Scaling (LSFG-VK) Integration

## Purpose
Provides graphical configuration and management of the `lsfg-vk` Vulkan layer within GOverlay under the "Upscalers" sidebar category, including environment variable synthesis, Steam DLL auto-detection, and per-game integration.

## Requirements

### Requirement: Upscalers Sub-Tabs Navigation
When the user clicks the "Upscalers" item in the sidebar navigation rail:
1. GOverlay SHALL make `goverlayPageControl.ShowTabs := True`.
2. GOverlay SHALL set `optiscalerTabSheet.TabVisible := True` and `losslessScalingTabSheet.TabVisible := True`.
3. GOverlay SHALL hide unrelated tab sheets (MangoHud tabs, vkBasalt, vkSumi, Tweaks, Games).
4. Clicking other sidebar navigation items SHALL hide `losslessScalingTabSheet`.

#### Scenario: Navigating to Upscalers section
- **WHEN** the user clicks "Upscalers" in the sidebar navigation
- **THEN** both "OptiScaler" and "Lossless Scaling" tabs become visible in the top header
- **AND** the active page defaults to the last selected or primary upscaler tab.

### Requirement: Lossless Scaling Tab UI & Cards Layout
The Lossless Scaling tab (`losslessScalingTabSheet`) SHALL render inside a responsive scroll box with dark theme card styling (`StyleMainCard` / `StyleSubCard`), structured into two consolidated cards:
1. **LossLess Scaling Card**:
   - `logoImage`: Lossless Scaling application icon (`assets/icons/lossless_scaling.png`) positioned on the left.
   - `dllPathEdit`: Read-only path edit positioned to the right of the logo.
   - `browseDllBtn`: File picker button positioned to the right of `dllPathEdit`.
   - `dllStatusLabel`: Status label positioned below `dllPathEdit`. When `Lossless.dll` exists, displays `"● DLL file located"` in green. When missing, displays `"● Install Lossless scaling on steam or point the correct file path"` in red and styles `dllPathEdit` with an alert red background and border tint.
2. **Configuration Card**:
   - **Row 1**: Multiplier TrackBar (`multiplierTrackBar`, range 1 to 10) with dynamic value label (`multiplierValueLabel`, displaying `1x (Disabled)` or `Nx FPS`) on the left; Flow Scale TrackBar (`flowScaleTrackBar`, range 25 to 100) with dynamic value label (`flowScaleValueLabel`) on the right.
   - **Row 2**: Three inline toggle checkboxes: Performance Mode (`performanceModeCheckBox`), HDR Mode (`hdrModeCheckBox`), and Disable FP16 / Half-Precision (`noFp16CheckBox`).
   - **Row 3**: Pacing Mode dropdown (`pacingComboBox`) on the left; Target GPU Device dropdown (`gpuComboBox`) on the right.

#### Scenario: User adjusts Multiplier TrackBar
- **WHEN** the user sets `multiplierTrackBar.Position` to `1`
- **THEN** `multiplierValueLabel.Caption` displays `"1x (Disabled)"`
- **AND** downstream controls (Flow Scale, Performance Mode, HDR Mode, FP16, Pacing, GPU) are disabled
- **AND** `GOVERLAY_LOSSLESS` is set to `0`.

#### Scenario: User adjusts Multiplier TrackBar to 4x
- **WHEN** the user sets `multiplierTrackBar.Position` to `4`
- **THEN** `multiplierValueLabel.Caption` displays `"4x FPS"`
- **AND** downstream controls are enabled
- **AND** `GOVERLAY_LOSSLESS` is set to `1` and `multiplier = 4` is saved to `lsfg.toml`.

#### Scenario: Missing DLL file path
- **WHEN** `dllPathEdit` contains an invalid or non-existent file path
- **THEN** `dllStatusLabel.Caption` displays `"● Install Lossless scaling on steam or point the correct file path"` in red
- **AND** `dllPathEdit` renders with an alert red background and border.

#### Scenario: Viewing Lossless Scaling tab when Upscalers tool is disabled
- **WHEN** the Upscalers sidebar toggle is OFF
- **AND** the user views the Lossless Scaling tab
- **THEN** all controls remain disabled, but the entire tab background renders seamlessly with the active theme background color without gray background gaps.

#### Scenario: Resizing the main application window
- **WHEN** the main GOverlay window is resized
- **THEN** `ReflowLosslessScalingTab` recalculates panel dimensions and ensures `FLsBgPanel` spans the full viewport width and height.

### Requirement: Steam Library Auto-Detection
GOverlay SHALL look for `Lossless.dll` in known default Steam paths:
- `~/.local/share/Steam/steamapps/common/Lossless Scaling/Lossless.dll`
- `~/.steam/steam/steamapps/common/Lossless Scaling/Lossless.dll`
- Custom library folders specified in Steam's `libraryfolders.vdf`.

#### Scenario: Auto-detect button clicked
- **WHEN** the user clicks "Auto-detect Steam Path"
- **AND** `Lossless.dll` exists in a detected Steam library folder
- **THEN** `dllPathEdit.Text` is automatically populated with the resolved path.

### Requirement: Real GPU Device Name Mapping
The GPU selection combobox (`gpuComboBox`) SHALL query `TSystemDetector` / Vulkan device enumeration to list physical GPU device names (e.g. `Auto (Default)`, `AMD Radeon 780M (iGPU)`, `NVIDIA GeForce RTX 4070 (dGPU)`), mapping the selected device index or PCI identifier to `LSFGVK_GPU`.

#### Scenario: Multi-GPU system configuration
- **WHEN** a system has both an integrated and a dedicated GPU
- **THEN** both GPUs appear in `gpuComboBox` with user-friendly descriptive names
- **AND** selecting a GPU sets `LSFGVK_GPU=<gpu_id>`.

### Requirement: Floating Action Dock Integration and 3D Preview
The Lossless Scaling tab SHALL display the floating action dock with the Preview pill enabled (`FFADock.UpdateForTab(True, False, False)`), while the OptiScaler tab SHALL display the floating action dock without the Preview pill (`FFADock.UpdateForTab(False, False, False)`).
When switching between sub-tabs within the Upscalers section (or clicking the Upscalers sidebar category), GOverlay SHALL immediately synchronize the floating action dock buttons according to the newly active sub-tab.
When the user clicks the Preview button on the Lossless Scaling tab, GOverlay SHALL append `LSFG_CONFIG="<config_dir>/lsfg.toml"` generated by `TLosslessScalingTabHelper.BuildEnvLine` to the preview command line if Lossless Scaling is enabled and valid.

#### Scenario: Viewing Lossless Scaling tab floating dock
- **WHEN** the user selects the Lossless Scaling tab
- **THEN** the floating action dock displays the Preview button (`[ 👁 Preview ]`) and Finish button (`[ ✓ Finish ]`).

#### Scenario: Switching from Lossless Scaling to OptiScaler tab
- **WHEN** the user is on the Lossless Scaling tab with Preview button visible
- **AND** clicks the "Optiscaler" sub-tab header
- **THEN** the floating action dock hides the Preview button (`[ 👁 Preview ]`) and displays only the Finish button (`[ ✓ Finish ]`).

#### Scenario: Launching 3D preview from Lossless Scaling tab
- **WHEN** the user clicks the Preview button while Lossless Scaling is configured with a valid DLL and multiplier >= 2x
- **THEN** GOverlay executes `pascube` (or `vkcube`) with `LSFG_CONFIG="<goverlay_dir>/lsfg.toml"` and the layer configuration initialized.

### Requirement: Settings Persistence & Per-Game Integration
1. GOverlay SHALL use `lsfg.toml` as the single source of truth for all detailed Lossless Scaling options (including `dll`, `multiplier`, `flow_scale`, `performance_mode`, `hdr_mode`, and `experimental_present_mode`), parsing `lsfg.toml` upon loading the tab and saving directly to `lsfg.toml`.
2. Global and per-game configuration files (`bgmod.conf`) SHALL only store `GOVERLAY_LOSSLESS=1` (when enabled) or `GOVERLAY_LOSSLESS=0` (when disabled) in the `[Config]` section, without storing redundant `LS_*` or `LSFG_*` configuration keys in `[Config]` or `[Env]`.
3. When Lossless Scaling is disabled (or multiplier set to 1x), GOverlay SHALL set `GOVERLAY_LOSSLESS=0` and remove `lsfg.toml` from the target configuration directory.
4. When launching a game with `GOVERLAY_LOSSLESS=1`, `bgmod` SHALL ensure `lsfg.toml` contains the target game executable profile and pass `LSFG_CONFIG="<game_dir>/lsfg.toml"` to the execution environment.

#### Scenario: Loading Lossless Scaling configuration
- **WHEN** the user opens the Lossless Scaling tab or selects a game with an existing `lsfg.toml`
- **THEN** GOverlay reads and parses `lsfg.toml` to populate the DLL path, multiplier, flow scale, performance mode, HDR mode, and pacing mode dropdown.

#### Scenario: Saving Lossless Scaling configuration
- **WHEN** the user saves settings with Lossless Scaling enabled
- **THEN** GOverlay writes all options directly to `lsfg.toml` in the target config directory
- **AND** writes `GOVERLAY_LOSSLESS=1` to `bgmod.conf` `[Config]` while omitting redundant `LS_*` keys.

#### Scenario: Disabling Lossless Scaling
- **WHEN** the user sets the multiplier to 1x or disables Lossless Scaling
- **THEN** GOverlay writes `GOVERLAY_LOSSLESS=0` to `bgmod.conf` `[Config]` and removes `lsfg.toml`.

#### Scenario: Launching a game with Lossless Scaling enabled
- **WHEN** a game is launched with Lossless Scaling active
- **THEN** `bgmod` writes `lsfg.toml` to the game's directory and exports `LSFG_CONFIG="<game_dir>/lsfg.toml"` to the game execution environment.
