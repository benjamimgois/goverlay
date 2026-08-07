# Capability: Upscalers Tab & DLSS Enabler Support

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
