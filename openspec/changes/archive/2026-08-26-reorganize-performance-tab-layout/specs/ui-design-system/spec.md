## MODIFIED Requirements

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
