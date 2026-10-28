# mangohud-visual-modular-ui Specification

## Purpose
Defines the modular two-column layout, uncluttered screen monitor placement with dedicated offset controls, segmented dual-pills, and integrated hardware bar on the MangoHud Visual tab.

## Requirements

### Requirement: Balanced Two-Column Modular Layout
The system SHALL present the MangoHud Visual configuration within a balanced two-column modular layout, dividing settings symmetrically into six independent first-class cards (three in the left column and three in the right column) directly on the Visual tab sheet, fully utilizing vertical tab height and horizontal column width without clipping or dead space.

#### Scenario: Appearance and Typography card structure
- **WHEN** the user navigates to the Visual tab
- **THEN** the system SHALL display three independent cards in the left column: HUD Header & Title (custom HUD title input), Typography (font dropdown, font color swatch, font size slider with live value label, and text outline toggle), and Canvas & Frame (background color swatch, opacity slider with live value label, corner style pills with corner radius slider, Compact HUD toggle switch, and No outer margins toggle switch)

#### Scenario: Position and Layout card structure
- **WHEN** the user navigates to the Visual tab
- **THEN** the system SHALL display three independent cards in the right column: Screen Placement (vector monitor with anchor points and dedicated X/Y offset inputs), Flow & Grid (orientation selector pill with adaptive column controls or horizontal stretch toggle), and Display & System (Active GPU selector, HUD toggle shortcut capture button, and Hide HUD by default toggle)

#### Scenario: Dynamic resizing and responsive reflow
- **WHEN** the main application window or tab is resized
- **THEN** both columns SHALL maintain equal width distribution, and their three corresponding cards SHALL share synchronized heights, full column width without double padding, and horizontal alignment across columns without clipping controls

### Requirement: Uncluttered Screen Placement and Offset Controls
The system SHALL isolate fine-tuning coordinate offsets from the visual monitor graphic, rendering interactive anchor buttons on the monitor surface while positioning X and Y offset inputs in dedicated labeled fields cleanly below the monitor.

#### Scenario: Monitor grid anchor selection
- **WHEN** the user clicks any of the 8 anchor points on the modern vector monitor (Top-Left, Top-Center, Top-Right, Middle-Left, Middle-Right, Bottom-Left, Bottom-Center, Bottom-Right)
- **THEN** the system SHALL update the active overlay anchor position, highlight the selected anchor point, render the live mini-HUD preview chip at that anchor, and trigger auto-saving

#### Scenario: Dedicated offset coordinate inputs
- **WHEN** the user configures fine-tuning offsets
- **THEN** the system SHALL accept pixel values via dedicated, labeled offset controls located outside the monitor boundary without obstructing the anchor buttons

### Requirement: Segmented Dual-Pills for Orientation and Borders
The system SHALL provide high-contrast segmented dual-pill buttons for binary visual choices, replacing legacy standalone radio buttons and disconnected preview images.

#### Scenario: HUD orientation selection
- **WHEN** the user selects the orientation segmented pill
- **THEN** the system SHALL switch between Vertical and Horizontal HUD layouts, visually highlighting the active pill option in accent styling, and adaptively display the column controls in Vertical mode or the horizontal stretch toggle in Horizontal mode

#### Scenario: Corner border style selection
- **WHEN** the user selects the border style segmented pill
- **THEN** the system SHALL switch between Square and Round corner borders, visually highlighting the active pill option in accent styling

### Requirement: Integrated Hardware, Hotkey, and Display Settings in Primary Cards
The system SHALL integrate runtime HUD switches, hotkey capture, and GPU hardware selection directly within the primary Visual cards without requiring a separate bottom toolbar.

#### Scenario: Compact HUD toggle in Canvas sub-card
- **WHEN** the user inspects the Canvas & Frame section of the Appearance card
- **THEN** the system SHALL present the Compact HUD toggle switch inline with descriptive text, updating the `compact` configuration flag on toggle

#### Scenario: Active GPU selector in Position & Layout card
- **WHEN** the user views the System & Hotkey section of the Position & Layout card
- **THEN** the system SHALL render the Active GPU device selection combobox (`pcidevComboBox`) safely within the card boundary, completely free from interference with the global floating dock

#### Scenario: HUD Toggle Hotkey and Start Hidden pairing
- **WHEN** the user configures overlay runtime hotkeys in the Position & Layout card
- **THEN** the system SHALL present the shortcut key capture button alongside the "Hide HUD by default" toggle switch, allowing key capture and initial silent state configuration in a single cohesive location
