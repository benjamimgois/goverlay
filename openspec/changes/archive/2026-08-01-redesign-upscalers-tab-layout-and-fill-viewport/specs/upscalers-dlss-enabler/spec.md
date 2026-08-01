# Capability: Upscalers Tab & DLSS Enabler Support

## MODIFIED Requirements

### Requirement: Tab Renaming and Card Layout Reorganization
The sidebar navigation item SHALL display the caption "Upscalers" instead of "OptiScaler".
The top section of the Upscalers tab SHALL render two 50% width cards side-by-side: "Upscaler" on the left and "GPU Driver" on the right.
The middle section SHALL render the "Options" card with 3 equal 33.3% width columns (`FOsOptiSec`, `FOsImgSec`, `FOsFakeSec`) spanning the full available width of the card.
The "Software Status" card SHALL be anchored to the bottom of the viewport area, and the "Options" card SHALL expand vertically to fill the remaining space between the top cards and "Software Status", eliminating empty unpainted background strips.

#### Scenario: Upscalers tab display and tab switching
- **WHEN** user launches GOverlay or switches between navigation tabs
- **THEN** system renders the Upscalers tab with full viewport height coverage, bottom-anchored Software Status card, and 3-column Options card without exposed background strips
