# UI Design System Specification (Delta)

## MODIFIED CAPABILITY
`ui-design-system`

## Requirements

### Requirement: Global Modern TrackBar (QSlider) Styling
The system SHALL apply a unified Qt stylesheet (`QSlider`) across all `TTrackBar` controls in the application, supporting both horizontal and vertical orientations in dark and light theme modes.

#### Scenario: Rendering horizontal trackbars in dark theme
- **WHEN** any horizontal trackbar (e.g. `transpTrackBar`, `fontsizeTrackBar`, `casTrackBar`, `FVsTrackbars`) is rendered
- **THEN** it renders with a 6px height rounded groove in slate-navy (`rgb(38,46,72)`), a cyan progress fill (`rgb(48,190,240)`), and a circular thumb with cyan border and white hover effect.

#### Scenario: Rendering vertical trackbars in dark theme
- **WHEN** any vertical trackbar (e.g. `afTrackBar`, `mipmapTrackBar`, `durationTrackBar`, `delayTrackBar`, `intervalTrackBar`) is rendered
- **THEN** it renders with a 6px width rounded groove, a cyan progress fill, and a circular thumb with cyan border and white hover effect.

#### Scenario: Rendering trackbars in light theme
- **WHEN** light theme is active
- **THEN** trackbars render with light gray grooves (`rgb(220,220,220)`), accent blue progress fill (`rgb(0,120,215)`), and clean white thumbs.

### Requirement: TrackBar Value Label Alignment and Highlighting
The system SHALL highlight numeric value labels associated with trackbars using the cyan accent color token (`CLR_TEXT_ACCENT`) in bold style (`[fsBold]`), aligning them to the right of horizontal trackbars where applicable.

#### Scenario: Displaying value labels in MangoHud Visual tab
- **WHEN** the user navigates to the MangoHud Visual tab
- **THEN** `alphavalueLabel` and `fontsizevalueLabel` are positioned to the right of their respective trackbars, styled with `CLR_TEXT_ACCENT` and `[fsBold]`.

#### Scenario: Reflowing MangoHud Visual tab on resize
- **WHEN** `ReflowVisualTab` calculates control widths
- **THEN** trackbar widths dynamically accommodate the right-aligned value labels with consistent horizontal padding.
