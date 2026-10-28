# Spec Delta

## MODIFIED Requirements

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
