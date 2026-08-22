## MODIFIED Requirements

### Requirement: Tab Rebrand and Top Cards Layout
The sidebar navigation item SHALL display the caption "Upscalers" instead of "OptiScaler".
The top section of the Upscalers tab SHALL render two 50% width cards side-by-side: "Method" on the left and "GPU Driver" on the right.
The "Method" card SHALL render three radio options with graphical logos/icons: "OptiScaler", "DLSS Enabler", and "None".
The "OptiScaler" sub-card (`FOsOptiSec`) SHALL layout "File name" and "Menu scale" controls in the Main sub-card, "Preferred upscaler", "Spoof DLSS", and "Force FSR4-i8" controls in the Upscaler sub-card, "FG Input", "FG Output", and "Force MLFG in RDNA3" controls in the Framegen sub-card, and "Force Reflex" and "Force LatencyFlex" controls in the Reflex / Antilag sub-card.

#### Scenario: Switching between OptiScaler and DLSS Enabler modes
- **WHEN** the user selects the "DLSS Enabler" radio button
- **THEN** the OptiScaler configuration sub-cards (`FOsMainSec`, `FOsSpatialSec`, `FOsTemporalSec`, `FOsReflexSec`) are hidden, and the DLSS Enabler configuration sub-card (`FOsDlssEnablerSec`) is displayed in their place.

#### Scenario: Switching to None mode
- **WHEN** the user selects the "None" radio button
- **THEN** the upscaler configuration controls in the Options card are disabled/dimmed, indicating that no DLL proxy upscaler will be injected into the game.

## ADDED Requirements

### Requirement: None Upscaler Method Persistence and Wrapper Execution
When the "None" upscaler method is selected:
1. GOverlay SHALL set `GOVERLAY_OPTISCALER=0` and `UPSCALER_TYPE=2` in `bgmod.conf` under `[Config]`.
2. When launching the game via `bgmod`, `bgmod` SHALL uninstall/clean any leftover OptiScaler or DLSS Enabler proxy DLLs from the game directory and SHALL NOT export `WINEDLLOVERRIDES` for OptiScaler.
3. Lossless Scaling configuration (`GOVERLAY_LOSSLESS`) SHALL remain fully active and independent when the "None" method is selected.

#### Scenario: User selects None method and enables Lossless Scaling
- **WHEN** the user selects "None" in the Method card (`UPSCALER_TYPE=2`)
- **AND** the user sets a Lossless Scaling multiplier > 1x (`GOVERLAY_LOSSLESS=1`)
- **THEN** GOverlay writes `GOVERLAY_OPTISCALER=0` and `GOVERLAY_LOSSLESS=1` to `bgmod.conf`
- **AND** upon game launch, `bgmod` executes the game with `lsfg-vk` enabled without injecting OptiScaler or DLSS Enabler DLLs.

### Requirement: Upscalers Sidebar Switch Compound State
The "Upscalers" toggle switch in the sidebar navigation SHALL reflect the compound state of both OptiScaler and Lossless Scaling.
1. The "Upscalers" switch SHALL display `ON` if `GOVERLAY_OPTISCALER=1` OR `GOVERLAY_LOSSLESS=1`.
2. The "Upscalers" switch SHALL display `OFF` only if both `GOVERLAY_OPTISCALER=0` AND `GOVERLAY_LOSSLESS=0`.
3. Toggling the "Upscalers" switch `OFF` from the sidebar navigation SHALL set both `GOVERLAY_OPTISCALER=0` and `GOVERLAY_LOSSLESS=0`.

#### Scenario: Lossless Scaling active with None upscaler method
- **WHEN** `GOVERLAY_OPTISCALER=0` and `GOVERLAY_LOSSLESS=1`
- **THEN** the sidebar navigation item for "Upscalers" displays `ON`.

#### Scenario: User toggles off Upscalers from sidebar
- **WHEN** the user clicks the "Upscalers" sidebar switch to turn it `OFF`
- **THEN** both `GOVERLAY_OPTISCALER=0` and `GOVERLAY_LOSSLESS=0` are written to `bgmod.conf`.
