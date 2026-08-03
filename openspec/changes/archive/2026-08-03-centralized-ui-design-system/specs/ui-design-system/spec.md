# UI Design System Capability

## Requirements

### Requirement: Centralized Design Tokens
The system SHALL centralize all typography scales, color tokens, and layout metric tokens in `themeunit.pas`.

#### Scenario: Rendering UI controls across tabs
- **WHEN** the application initializes or reflows any tab UI
- **THEN** controls adopt standardized font sizes (10pt card headers, 8pt section headers, 9pt form controls), uniform color tokens, and 26px/28px control baselines.

### Requirement: Uniform Font Family Selection
The system SHALL rely on system default sans-serif font styling without hardcoded distro-specific font family names.

#### Scenario: Displaying tab cards across Linux distributions
- **WHEN** the application renders card headers and control labels in vkBasalt or other tabs
- **THEN** fonts render using the system default sans-serif typeface consistently across all tabs.

### Requirement: Reusable Styling Procedures
The system SHALL provide unified helper procedures in `themeunit.pas` for styling cards, sub-cards, labels, inputs, toggles, and buttons.

#### Scenario: Applying dark and light theme styles
- **WHEN** a tab initializes or toggles between dark and light themes
- **THEN** UI components invoke `themeunit` helper procedures to apply consistent background, text, and border styling.
