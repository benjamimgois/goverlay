# Spec Delta

## MODIFIED Requirements

### Requirement: Balanced Two-Column Modular Layout
The system SHALL present the MangoHud Visual configuration within a balanced two-column modular layout, dividing settings between an Appearance & Typography card on the left and a Position & Layout card on the right, fully utilizing vertical tab height without a bottom action bar.

#### Scenario: Appearance and Typography card structure
- **WHEN** the user navigates to the Visual tab
- **THEN** the system SHALL display the Appearance & Typography card containing the custom HUD Title input at the top, a Typography sub-module (font dropdown, font color swatch, font size slider with live value label, and text outline toggle), and a Canvas & Frame sub-module (background color swatch, opacity slider with live value label, border style pills, and the Compact HUD toggle switch)

#### Scenario: Position and Layout card structure
- **WHEN** the user navigates to the Visual tab
- **THEN** the system SHALL display the Position & Layout card containing an uncluttered screen placement monitor with 8 anchor points, dedicated X/Y offset inputs, an orientation selector pill with adaptive contextual column controls or horizontal stretch toggle, and an integrated System & Hotkey sub-module containing the Active GPU selector, HUD toggle shortcut capture button, and Hide HUD by default toggle

#### Scenario: Dynamic resizing and responsive reflow
- **WHEN** the main application window or tab is resized
- **THEN** the two main cards SHALL maintain equal width distribution and expand vertically across the full tab height to comfortably accommodate all controls while leaving the bottom-right corner unobstructed for the global floating action dock

## REMOVED Requirements

### Requirement: Integrated Display and Hardware Action Bar
**Reason**: The bottom Action Bar (`FVisActionBar`) caused direct visual overlaps and collisions with GOverlay's global floating action dock (`[☰] [👁 Preview] [✓ Finish]`) in the bottom-right corner, and fragmented the layout into an unnecessary third horizontal container.
**Migration**: Controls previously hosted in the Action Bar are now integrated natively inside the primary modular cards: Compact HUD inside Canvas & Frame (Appearance card), and Active GPU, HUD Toggle, and Hide HUD inside System & Hotkey (Position & Layout card).

## ADDED Requirements

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
