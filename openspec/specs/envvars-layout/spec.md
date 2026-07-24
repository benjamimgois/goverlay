# envvars-layout Specification

## Requirements

### Requirement: 2-column responsive layout for EnvVars items
The system SHALL layout EnvVars tweak items in two side-by-side columns within each category section when the container width is greater than or equal to 700 pixels.

#### Scenario: Window width >= 700px renders two columns
- **WHEN** the EnvVars tab container width is at least 700 pixels
- **THEN** items under each category header SHALL be positioned in two equal-width side-by-side columns
- **THEN** toggle switches within each item SHALL be placed immediately to the right of the item text within its column boundary

#### Scenario: Narrow window width < 700px falls back to single column
- **WHEN** the EnvVars tab container width is less than 700 pixels
- **THEN** items under each category header SHALL be rendered in a single full-width column

### Requirement: Full-width category headers in 2-column grid
The system SHALL render category header bars spanning the full width of the EnvVars panel regardless of the number of columns below it.

#### Scenario: Category headers span full container width
- **WHEN** category section headers ('General', 'Graphics', 'Performance', 'Latency reduction') are drawn
- **THEN** each header bar SHALL extend across the entire width of the EnvVars paint box
