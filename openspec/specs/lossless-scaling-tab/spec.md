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
The Lossless Scaling tab (`losslessScalingTabSheet`) SHALL render inside a responsive scroll box with dark theme card styling (`StyleMainCard` / `StyleSubCard`).
The background panel (`FLsBgPanel`) SHALL always expand to cover at least the entire visible viewport height (`ClientHeight`) of the scroll box (`FLsScrollBox`), ensuring no unstyled or disabled viewport areas are visible when the tool is disabled or the window is resized:
1. **General & Engine Setup Card**:
   - Path to `Lossless.dll` (`dllPathEdit`)
   - File picker browse button (`browseDllBtn`)
   - Steam Auto-Detect button (`autoDetectDllBtn`)
   - DLL detection status label (`dllStatusLabel` - Green with checkmark if file exists, Red if missing).
2. **Frame Generation Card**:
   - Frame multiplier selector (`multiplierRadioGroup` or `multiplierComboBox` with options `2x`, `3x`, `4x`)
   - Flow scale trackbar (`flowScaleTrackBar` ranging from 25 to 100 with a label updating live)
   - Performance mode toggle (`performanceModeCheckBox` / switch).
3. **Hardware & Pacing Card**:
   - Disable FP16 toggle (`noFp16CheckBox` - "Disable FP16 / Half-Precision")
   - Pacing mode dropdown (`pacingComboBox` with options: `auto`, `vsync`, `mailbox`, `immediate`, `none`)
   - Target GPU dropdown (`gpuComboBox` populated with available GPU devices detected by `systemdetector.pas`).
4. **Environment Preview Card**:
   - Read-only multi-line preview edit (`envPreviewMemo`) displaying the generated environment variables:
     `LSFGVK_ENV=1 LSFGVK_DLL_PATH="..." LSFGVK_MULTIPLIER=... %command%`
   - Copy to clipboard button (`copyEnvBtn`).

#### Scenario: User selects a custom DLL file
- **WHEN** the user selects a valid `Lossless.dll` path using the file dialog or Auto-Detect button
- **THEN** `dllPathEdit.Text` updates to the chosen path
- **AND** `dllStatusLabel` updates to green "● DLL Found"
- **AND** the environment preview updates `LSFGVK_DLL_PATH` immediately.

#### Scenario: User adjusts Frame Generation Multiplier
- **WHEN** the user changes the multiplier to `3x`
- **THEN** `LSFGVK_MULTIPLIER=3` is reflected in the environment preview and saved configuration.

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

### Requirement: Settings Persistence & Per-Game Integration
1. Global configurations SHALL be saved to `~/.config/goverlay/lossless_scaling.ini`.
2. In Per-Game mode (selected game in `gamesTabSheet`), enabling Lossless Scaling SHALL inject `LSFGVK_ENV=1` and configured variables into the game's launch parameters or `bgmod.conf` `[Env]` section.

#### Scenario: Launching a game with Lossless Scaling enabled
- **WHEN** a game is launched with Lossless Scaling active
- **THEN** `LSFGVK_ENV=1` and all configured `LSFGVK_*` environment variables are passed to the game execution environment.
