# Spec Delta

## Purpose

Defines the modular two-column layout, uncluttered screen monitor placement with dedicated offset controls, segmented dual-pills, and integrated hardware bar on the MangoHud Visual tab.

## ADDED Requirements

### Requirement: Balanced Two-Column Modular Layout
The system SHALL present the MangoHud Visual configuration within a balanced two-column modular layout, dividing settings between an Appearance & Typography card on the left and a Position & Layout card on the right, backed by a unified Display & Hardware action bar at the bottom.

#### Scenario: Appearance and Typography card structure
- **WHEN** the user navigates to the Visual tab
- **THEN** the system SHALL display the Appearance & Typography card containing the custom HUD Title input at the top, a Typography sub-module (font dropdown, font color swatch, font size slider with live value label, and text outline toggle), and a Canvas & Frame sub-module (background color swatch, opacity slider with live value label, and border style pills)

#### Scenario: Position and Layout card structure
- **WHEN** the user navigates to the Visual tab
- **THEN** the system SHALL display the Position & Layout card containing an uncluttered screen placement monitor with 9 anchor points, dedicated X/Y offset inputs, an orientation selector pill, a column count stepper, and a horizontal stretch toggle

#### Scenario: Dynamic resizing and responsive reflow
- **WHEN** the main application window or tab is resized
- **THEN** the two main cards SHALL maintain equal width distribution and synchronized vertical expansion to fill available tab height without clipping controls

### Requirement: Uncluttered Screen Placement and Offset Controls
The system SHALL isolate fine-tuning coordinate offsets from the visual monitor graphic, rendering interactive anchor buttons on the monitor surface while positioning X and Y offset inputs in dedicated labeled fields cleanly below the monitor.

#### Scenario: Monitor grid anchor selection
- **WHEN** the user clicks any of the 9 anchor points (Top-Left, Top-Center, Top-Right, Middle-Left, Middle-Right, Bottom-Left, Bottom-Center, Bottom-Right)
- **THEN** the system SHALL update the active overlay anchor position and highlight the selected anchor point

#### Scenario: Dedicated offset coordinate inputs
- **WHEN** the user configures fine-tuning offsets
- **THEN** the system SHALL accept pixel values via dedicated, labeled offset controls located outside the monitor boundary without obstructing the anchor buttons

### Requirement: Segmented Dual-Pills for Orientation and Borders
The system SHALL provide high-contrast segmented dual-pill buttons for binary visual choices, replacing legacy standalone radio buttons and disconnected preview images.

#### Scenario: HUD orientation selection
- **WHEN** the user selects the orientation segmented pill
- **THEN** the system SHALL switch between Vertical and Horizontal HUD layouts, visually highlighting the active pill option in accent styling

#### Scenario: Corner border style selection
- **WHEN** the user selects the border style segmented pill
- **THEN** the system SHALL switch between Square and Round corner borders, visually highlighting the active pill option in accent styling

### Requirement: Integrated Display and Hardware Action Bar
The system SHALL integrate keyboard shortcut capture, quick display toggles, and GPU selection into a unified full-width card at the bottom of the Visual tab.

#### Scenario: Hotkey shortcut capture
- **WHEN** the user clicks the shortcut capture button in the action bar
- **THEN** the button SHALL enter capture mode and assign the pressed key combination to the HUD toggle hotkey

#### Scenario: Quick display switches
- **WHEN** the user views the action bar
- **THEN** the system SHALL render compact antialiased toggle switches for Compact HUD and Hide by Default

#### Scenario: Active GPU selector integration
- **WHEN** the user views the action bar
- **THEN** the system SHALL render the Active GPU device selection combobox directly within the hardware section, eliminating standalone disconnected footer panels
