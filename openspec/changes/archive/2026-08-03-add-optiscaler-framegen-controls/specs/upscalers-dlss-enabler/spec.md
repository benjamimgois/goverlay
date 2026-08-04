# Capability: Upscalers Tab & DLSS Enabler Support

## MODIFIED Requirements

### Requirement: Tab Renaming and Card Layout Reorganization
The sidebar navigation item SHALL display the caption "Upscalers" instead of "OptiScaler".
The top section of the Upscalers tab SHALL render two 50% width cards side-by-side: "Upscaler" on the left and "GPU Driver" on the right.
The middle section SHALL render the "Options" card with 3 equal 33.3% width columns (`FOsOptiSec`, `FOsImgSec`, `FOsFakeSec`) spanning the full available width of the card.
The "OptiScaler" sub-card (`FOsOptiSec`) SHALL layout "File name" and "Preferred upscaler" comboboxes side-by-side in Row 1, "FG Input" and "FG Output" comboboxes in Row 2, "Spoof DLSS" and "Force FSR4-i8" checkboxes in Row 3, and "Emulate FP8" and "OptiPatcher" checkboxes in Row 4.
When either "FG Input" or "FG Output" is set to a non-auto value, GOverlay SHALL write `Enabled=true` under `[FrameGen]` in `OptiScaler.ini`.
The "Software Status" card SHALL be anchored to the bottom of the viewport area, and the "Options" card SHALL expand vertically to fill the remaining space between the top cards and "Software Status", eliminating empty unpainted background strips.

#### Scenario: Frame Generation controls configuration
- **WHEN** user selects an FG Input or FG Output option other than auto
- **THEN** GOverlay writes the selected FG input/output values and sets `Enabled=true` under `[FrameGen]` in `OptiScaler.ini`
