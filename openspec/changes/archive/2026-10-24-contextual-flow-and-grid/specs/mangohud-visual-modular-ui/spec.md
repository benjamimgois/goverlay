# Spec Delta: mangohud-visual-modular-ui

## MODIFIED Requirements

### Requirement: Balanced Two-Column Modular Layout
The system SHALL present the MangoHud Visual configuration within a balanced two-column modular layout, dividing settings between an Appearance & Typography card on the left and a Position & Layout card on the right, backed by a unified Display & Hardware action bar at the bottom.

#### Scenario: Appearance and Typography card structure
- **WHEN** the user navigates to the Visual tab
- **THEN** the system SHALL display the Appearance & Typography card containing the custom HUD Title input at the top, a Typography sub-module (font dropdown, font color swatch, font size slider with live value label, and text outline toggle), and a Canvas & Frame sub-module (background color swatch, opacity slider with live value label, and border style pills)

#### Scenario: Position and Layout card structure
- **WHEN** the user navigates to the Visual tab
- **THEN** the system SHALL display the Position & Layout card containing an uncluttered screen placement monitor with 8 anchor points, dedicated X/Y offset inputs, an orientation selector pill, and an adaptive contextual row morphing between the column count stepper in Vertical mode and the horizontal stretch toggle in Horizontal mode

#### Scenario: Dynamic resizing and responsive reflow
- **WHEN** the main application window or tab is resized
- **THEN** the two main cards SHALL maintain equal width distribution and synchronized vertical expansion to fill available tab height without clipping controls

### Requirement: Segmented Dual-Pills for Orientation and Borders
The system SHALL provide high-contrast segmented dual-pill buttons for binary visual choices, replacing legacy standalone radio buttons and disconnected preview images.

#### Scenario: HUD orientation selection
- **WHEN** the user selects the orientation segmented pill
- **THEN** the system SHALL switch between Vertical and Horizontal HUD layouts, visually highlighting the active pill option in accent styling, and adaptively display the column controls in Vertical mode or the horizontal stretch toggle in Horizontal mode

#### Scenario: Corner border style selection
- **WHEN** the user selects the border style segmented pill
- **THEN** the system SHALL switch between Square and Round corner borders, visually highlighting the active pill option in accent styling
