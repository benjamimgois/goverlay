# Capability: Upscalers Tab & DLSS Enabler Support

## MODIFIED Requirements

### Requirement: Tab Renaming and Card Layout Reorganization
The sidebar navigation item SHALL display the caption "Upscalers" instead of "OptiScaler".
The top section of the Upscalers tab SHALL render two 50% width cards side-by-side: "Upscaler" on the left and "GPU Driver" on the right.
The middle section SHALL render the "Options" card with 3 equal 33.3% width columns (`FOsOptiSec`, `FOsImgSec`, `FOsFakeSec`) spanning the full available width of the card.
The "OptiScaler" sub-card (`FOsOptiSec`) SHALL layout "File name" and "Preferred upscaler" comboboxes side-by-side in Row 1, "Spoof DLSS" and "Force FSR4-i8" checkboxes in Row 2, and "Emulate FP8" and "OptiPatcher" checkboxes in Row 3.
The "Software Status" card SHALL be anchored to the bottom of the viewport area, and the "Options" card SHALL expand vertically to fill the remaining space between the top cards and "Software Status", eliminating empty unpainted background strips.

#### Scenario: OptiScaler sub-card control grid layout
- **WHEN** user views the Upscalers tab
- **THEN** system renders the OptiScaler sub-card with side-by-side comboboxes on top and a 2x2 grid of checkboxes below
