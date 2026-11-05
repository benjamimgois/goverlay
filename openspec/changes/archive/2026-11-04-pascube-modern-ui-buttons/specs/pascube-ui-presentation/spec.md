# Spec Delta

## MODIFIED Requirements

### Requirement: System Specifications Summary Pill
The benchmark interface SHALL render a system specifications summary badge exclusively on the results overlay, omitting it from the idle menu to provide visual clearance for the 3D scene and floor reflections.

#### Scenario: Display on idle menu
- **WHEN** PasCube enters the idle menu state (`bpIdleMenu`)
- **THEN** the interface omits the specifications summary pill from the bottom viewport to maximize visual clearance for 3D reflections.

#### Scenario: Display on results overlay
- **WHEN** PasCube renders the final results screen (`bpResults`)
- **THEN** the specifications summary badge is rendered at the top of the interface providing hardware context for the recorded scores.

## ADDED Requirements

### Requirement: Modern Cyber-Accent Action Buttons
The PasCube interface SHALL render interactive action buttons with clear visual hierarchy, directional navigation glyphs, and Goverlay Cyber-Accent styling across idle menu and results views.

#### Scenario: Idle menu primary and secondary buttons
- **WHEN** PasCube renders the idle menu overlay (`bpIdleMenu`)
- **THEN** the "Start benchmark" action is rendered as a primary Call-to-Action with a Goverlay Cyan border (`#30BEF0`) and play glyph `▶`, and "View results" is rendered as a secondary Ghost action with glyph `≡` when benchmark history exists.

#### Scenario: Results overlay action buttons
- **WHEN** PasCube renders the results overlay (`bpResults`)
- **THEN** "Return to Menu" is rendered with primary Goverlay Cyan CTA styling and back glyph `◀`, "Submit results" is rendered with secondary Ghost styling and dynamic status text, and "Clear results" is rendered with refined dark danger styling (subtle crimson border and glyph `✕`).

#### Scenario: Interactive button hover feedback
- **WHEN** the mouse cursor hovers over any action button
- **THEN** the hovered button displays high-contrast border and background illumination corresponding to its role (luminous cyan for primary, elevated blue-grey for ghost, vibrant red for danger).
