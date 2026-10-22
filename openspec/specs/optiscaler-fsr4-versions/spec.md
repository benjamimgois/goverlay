# optiscaler-fsr4-versions Specification

## Purpose
Enables selection and automated deployment of alternative FSR4 versions in OptiScaler, maintaining a centralized cache of builds, removing legacy channel-level FSR folders, and ensuring reliable restoration of the official bundled release.

## Requirements

### Requirement: FSR Version Selection UI
The system SHALL display an "FSR Version" combobox with label permanently visible below "Prefered upscaler" inside the "Upscaler" section of the OptiScaler configuration tab.

#### Scenario: Default option is Latest
- **WHEN** user opens the OptiScaler tab for global or per-game configuration
- **THEN** the "FSR Version" combobox is visible with options "Latest", "4.1.1b", and "4.0.2c", defaulting to "Latest" if not previously configured.

#### Scenario: User selects alternative version
- **WHEN** user selects "4.1.1b" or "4.0.2c" from the FSR Version combobox
- **THEN** the selection is automatically persisted via auto-save in `goverlay.vars` and restored across application restarts.

### Requirement: Centralized FSR4 Directory and Download of Alternative Builds
The system SHALL maintain a centralized `FSR4/` directory under GOverlay's data directory containing subdirectories for `Latest`, `4.1.1b`, and `4.0.2c`, downloading alternative INT8 versions during OptiScaler download, update, or startup integrity self-healing.

#### Scenario: Alternative builds downloaded during setup
- **WHEN** OptiScaler is downloaded, installed, or updated
- **THEN** the system ensures `~/.local/share/goverlay/FSR4/` exists and downloads the 4.1.1b and 4.0.2c DLLs into their respective subfolders if not already cached.

#### Scenario: Alternative builds verified and restored at startup
- **WHEN** GOverlay starts up and any FSR4 subfolder (`Latest`, `4.1.1b`, `4.0.2c`) is missing its required `amd_fidelityfx_upscaler_dx12.dll`
- **THEN** the system automatically triggers a targeted download or copy into the respective subfolder.

### Requirement: Pristine Latest Version Preservation and Restoration
The system SHALL ensure the native `amd_fidelityfx_upscaler_dx12.dll` bundled with the OptiScaler release is stored in `~/.local/share/goverlay/FSR4/Latest/` and restored cleanly whenever the user selects "Latest".

#### Scenario: Restoring Latest version
- **WHEN** user selects "Latest" in the FSR Version combobox and saves the configuration
- **THEN** the system copies `amd_fidelityfx_upscaler_dx12.dll` from `FSR4/Latest/` into the target configuration directory (`gameconfig/global/` or `gameconfig/<game>/`).

#### Scenario: Deploying alternative version
- **WHEN** user selects "4.1.1b" or "4.0.2c" and saves the configuration
- **THEN** the system copies `amd_fidelityfx_upscaler_dx12.dll` from the corresponding `FSR4/<version>/` directory into the target configuration directory without modifying `FSR4/Latest/`.

### Requirement: Legacy FSR4 Folder Deprecation
The system SHALL NOT create or sync legacy `FSR4_LATEST` or `FSR4_INT8` subdirectories within `optiscaler-stable`, `optiscaler-edge`, or game configuration folders.

#### Scenario: Setup does not create legacy directories
- **WHEN** OptiScaler is installed, updated, or synced
- **THEN** only the centralized `~/.local/share/goverlay/FSR4/` directory is used, and legacy `FSR4_LATEST` and `FSR4_INT8` folders are neither created nor copied.

### Requirement: Independent Force FSR4-i8 Toggle
The system SHALL preserve the independent "Force FSR4-i8" toggle switch controlling `Fsr4ForceEnableInt8` in `OptiScaler.ini` independently of the FSR Version combobox selection.

#### Scenario: Toggle switch operates independently
- **WHEN** user toggles "Force FSR4-i8"
- **THEN** `Fsr4ForceEnableInt8` in `OptiScaler.ini` is set to `true` or `false` without overriding the selected FSR version DLL.
