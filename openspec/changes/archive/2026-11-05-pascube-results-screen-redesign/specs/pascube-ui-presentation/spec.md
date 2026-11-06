# Spec Delta: pascube-ui-presentation

## ADDED Requirements

### Requirement: Cinematic Backdrop Scrim and Opaque Dashboard Cards
The results overlay SHALL render a full-screen dark translucent backdrop scrim over the background 3D viewport and SHALL render all metric cards with 100% opaque backgrounds and high-contrast borders to eliminate 3D geometry and lighting bleed-through.

#### Scenario: Full-screen backdrop scrim activation
- **WHEN** PasCube enters the benchmark results phase (`bpResults`)
- **THEN** a dark translucent scrim (`alpha = 0.75` in deep navy `#080c14`) is drawn over the entire 1920x1080 viewport before card rendering, softly subduing 3D cube rotation and floor glare while preserving background depth.

#### Scenario: Opaque dashboard card rendering
- **WHEN** any results card (`Main Score`, CPU/GPU 2x2 grid, `Live Telemetry`, `Score Trend`, or `Hardware Comparison`) is rendered
- **THEN** the card background is rendered with a 100% solid opaque fill in Goverlay navy (`#131a28`) and a crisp 1.5px border (`#2e3d58`), preventing 3D scene elements from showing through card interiors.

## MODIFIED Requirements

### Requirement: Performance Tier Classification and Hero Score Presentation
The results overlay SHALL present the total system score in a prominent hero card accompanied by a performance tier classification badge determined by predefined score thresholds.

#### Scenario: Enthusiast gaming tier badge
- **WHEN** the benchmark completes with a total score exceeding 4,000 points
- **THEN** the hero score card displays a prominent 2px Goverlay Cyan border (`#30BEF0`) and renders an "Enthusiast Gaming" luminous badge adjacent to the score title.

#### Scenario: Mainstream gaming tier badge
- **WHEN** the benchmark completes with a total score between 2,200 and 4,000 points
- **THEN** the hero score card displays a 2px Goverlay Cyan border (`#30BEF0`) and renders a "Mainstream Gaming" badge adjacent to the score title.

#### Scenario: Handheld and entry tier badge
- **WHEN** the benchmark completes with a total score below 2,200 points
- **THEN** the hero score card displays a 2px Goverlay Cyan border (`#30BEF0`) and renders an "Entry / Handheld" badge adjacent to the score title.
