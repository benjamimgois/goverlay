# Capability: Upscalers Tab & DLSS Enabler Support

## Purpose

Provides configuration and management of upscaler engines (OptiScaler and DLSS Enabler) and GPU driver selection in GOverlay.

## Requirements

### Requirement: Tab Rebrand and Top Cards Layout
The sidebar navigation item SHALL display the caption "Upscalers" instead of "OptiScaler".
The top section of the Upscalers tab SHALL render two 50% width cards side-by-side: "Method" on the left and "GPU Driver" on the right.
The "OptiScaler" sub-card (`FOsOptiSec`) SHALL layout "File name" and "Menu scale" controls in the Main sub-card, "Preferred upscaler", "Spoof DLSS", and "Force FSR4-i8" controls in the Spatial Upscaler sub-card, "FG Input", "FG Output", and "Force MLFG in RDNA3" controls in the Temporal Upscaler sub-card, and "Force Reflex" and "Force LatencyFlex" controls in the Reflex / Antilag sub-card.

#### Scenario: Switching between OptiScaler and DLSS Enabler modes
- **WHEN** the user selects the "DLSS Enabler" radio button
- **THEN** the OptiScaler configuration sub-cards (`FOsMainSec`, `FOsSpatialSec`, `FOsTemporalSec`, `FOsReflexSec`) are hidden, and the DLSS Enabler configuration sub-card (`FOsDlssEnablerSec`) is displayed in their place.

### Requirement: DLSS-Enabler Dual Channel Support (Stable & Bleeding-edge)
- GOverlay SHALL query `https://api.github.com/repos/benjamimgois/OptiScaler-builds/contents/de?ref=nightly-action` to list available builds.
- GOverlay SHALL parse the version string from matching build filenames by extracting the text segment following `"DLSS Enabler "` up to the first space.
- WHEN Stable channel is selected for DLSS Enabler (`OPT_CHANNEL=0`), GOverlay SHALL download the build filename containing `"STABLE"` into `~/.local/share/goverlay/dlssenabler-stable/`.
- WHEN Bleeding-edge channel is selected for DLSS Enabler (`OPT_CHANNEL=1`), GOverlay SHALL download the build filename containing `"TRUNK"` into `~/.local/share/goverlay/dlssenabler-edge/`.
- GOverlay SHALL extract `version.dll` from the downloaded ZIP archive into the respective channel cache directory.
- GOverlay SHALL write `dlssenablerversion=<parsed_version>` and `upscalertype=1` to `goverlay.vars` inside the channel directory.

#### Scenario: DLSS-Enabler Channel Download and Installation
- **WHEN** DLSS Enabler channel is updated or selected
- **THEN** the target build (Stable or Bleeding-edge) is downloaded, extracted to the appropriate cache folder, and version information is updated in `goverlay.vars`

### Requirement: Frame Generation Comboboxes in OptiScaler Options
The OptiScaler section SHALL provide two combobox controls for Frame Generation: `fgInputComboBox` ("FG Input") and `fgOutputComboBox` ("FG Output").

#### Scenario: Setting FG Input and Output values
- **WHEN** the user selects a value in `fgInputComboBox` or `fgOutputComboBox`
- **THEN** GOverlay writes `FgInput=<value>` and `FgOutput=<value>` to `OptiScaler.ini` under section `[FrameGen]`.

### Requirement: Frame Generation Combobox Tooltips
Hovering over options in `fgInputComboBox` and `fgOutputComboBox` SHALL display descriptive tooltips explaining each option's behavior and requirements.

#### Scenario: User hovers over combobox items
- **WHEN** the user hovers or inspects an FG option (e.g. `nukems`, `fsrfg`, `upscaler`)
- **THEN** a tooltip is shown with detailed operational guidance.

### Requirement: DLSS Enabler Update Status Display
When DLSS Enabler is enabled (`UPSCALER_TYPE=1` / `dlssenablerRadioButton.Checked = True`) and a newer DLSS Enabler release is available:
1. GOverlay SHALL display the update notification arrow and target version on the DLSS Enabler status row in the Software Status card (`<installed_version> → <new_version>` formatted with `CLR_UPDATE`).
2. GOverlay SHALL keep the OptiScaler status row displaying the installed OptiScaler version in standard purple color (`PURPLE`) without an update arrow.

When standard OptiScaler is selected (`optiscalerRadioButton.Checked = True`) and an OptiScaler update is available:
1. GOverlay SHALL display the update notification arrow on the OptiScaler status row (`<installed_version> → <new_version>` formatted with `CLR_UPDATE`).
2. The DLSS Enabler status row SHALL display `--`.

#### Scenario: DLSS Enabler update is available
- **WHEN** DLSS Enabler is selected (`dlssenablerRadioButton.Checked = True`)
- **AND** a newer version of DLSS Enabler is available from the remote repository (e.g. installed is `4.8.12` and latest is `4.8.13.19`)
- **THEN** the Software Status DLSS Enabler row displays `4.8.12 → 4.8.13.19` in update highlight color
- **AND** the Software Status OptiScaler row displays its installed version (e.g. `stable-0.9.4`) in standard color without an update arrow

#### Scenario: DLSS Enabler is up to date
- **WHEN** DLSS Enabler is selected (`dlssenablerRadioButton.Checked = True`)
- **AND** the installed DLSS Enabler version matches the latest remote release
- **THEN** the Software Status DLSS Enabler row displays its installed version in standard color without an update arrow
- **AND** the Software Status OptiScaler row displays its installed version in standard color without an update arrow

### Requirement: GPU Driver Auto Detected Label Centering and Font Styling
The "Auto Detected" indicator label in the GPU Driver section SHALL be horizontally centered relative to the driver logo image (`mesaImage` or `nvidiaImage`) and formatted with a reduced font size (`Font.Size := 8`).

#### Scenario: Auto Detected label displayed under MESA logo
- **WHEN** MESA driver is auto-detected and `autodetectmesaLabel` is visible
- **THEN** the center X coordinate of `autodetectmesaLabel` aligns with the center X coordinate of `mesaImage`.

#### Scenario: Auto Detected label displayed under Nvidia logo
- **WHEN** Nvidia driver is auto-detected and `autodetectnvLabel` is visible
- **THEN** the center X coordinate of `autodetectnvLabel` aligns with the center X coordinate of `nvidiaImage`.
