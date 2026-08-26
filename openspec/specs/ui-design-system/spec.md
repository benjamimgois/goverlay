# UI Design System Capability

## Purpose
Defines typography scales, design tokens, styling procedures, and modern trackbar styling for the GOverlay user interface.

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

### Requirement: Global Modern TrackBar (QSlider) Styling
The system SHALL apply a unified Qt stylesheet (`QSlider`) across all `TTrackBar` controls in the application, supporting both horizontal and vertical orientations in dark and light theme modes.

#### Scenario: Rendering horizontal trackbars in dark theme
- **WHEN** any horizontal trackbar (e.g. `transpTrackBar`, `fontsizeTrackBar`, `afTrackBar`, `mipmapTrackBar`, `casTrackBar`, `FVsTrackbars`) is rendered
- **THEN** it renders with a 6px height rounded groove in slate-navy (`rgb(38,46,72)`), a cyan progress fill (`rgb(48,190,240)`), and a circular thumb with cyan border and white hover effect.

#### Scenario: Rendering vertical trackbars in dark theme
- **WHEN** any vertical trackbar (e.g. `durationTrackBar`, `delayTrackBar`, `intervalTrackBar`) is rendered
- **THEN** it renders with a 6px width rounded groove, a cyan progress fill, and a circular thumb with cyan border and white hover effect.

#### Scenario: Rendering trackbars in light theme
- **WHEN** light theme is active
- **THEN** trackbars render with light gray grooves (`rgb(220,220,220)`), accent blue progress fill (`rgb(0,120,215)`), and clean white thumbs.

### Requirement: TrackBar Value Label Alignment and Highlighting
The system SHALL highlight numeric value labels associated with trackbars using the cyan accent color token (`CLR_TEXT_ACCENT`) in bold style (`[fsBold]`), aligning them to the right of horizontal trackbars where applicable.

#### Scenario: Displaying value labels in MangoHud Visual tab
- **WHEN** the user navigates to the MangoHud Visual tab
- **THEN** `alphavalueLabel` and `fontsizevalueLabel` are positioned to the right of their respective trackbars, styled with `CLR_TEXT_ACCENT` and `[fsBold]`.

#### Scenario: Displaying value labels in MangoHud Performance tab
- **WHEN** the user navigates to the MangoHud Performance tab
- **THEN** `afvalueLabel` and `mipmapvalueLabel` are positioned to the right of `afTrackBar` and `mipmapTrackBar` respectively, styled with `CLR_TEXT_ACCENT` and `[fsBold]`.

#### Scenario: Reflowing MangoHud Visual tab on resize
- **WHEN** `ReflowVisualTab` calculates control widths
- **THEN** trackbar widths dynamically accommodate the right-aligned value labels with consistent horizontal padding.
