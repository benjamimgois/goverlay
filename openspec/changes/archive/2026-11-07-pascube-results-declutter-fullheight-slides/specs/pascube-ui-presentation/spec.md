# Spec Delta

## MODIFIED Requirements

### Requirement: Central Viewport Multi-Slide Insights Carousel
The benchmark results overlay SHALL render an animated multi-slide carousel spanning the full vertical viewport from the top margin (`1.0 * charHeight`) down to the bottom action bar, displaying the `Main Score` hero card exclusively on Slide 1 (`Overview`) alongside a full-height `Hardware Comparison` card, and expanding Slides 2–6 to occupy the full viewport height with increased card and bar breathing room.

#### Scenario: Displaying default overview slide
- **WHEN** the benchmark results overlay (`bpResults`) opens
- **THEN** the carousel initializes on Slide 0 (`Overview`), rendering the `Main Score` hero card (with performance tier badge and `?` methodology trigger) at the top of the left column (`1.0 * charHeight` to `7.0 * charHeight`) above the 2x2 subscores grid, `Live Telemetry`, and `Score Trend` cards, while the right-column `Hardware Comparison` card spans the full vertical height from `1.0 * charHeight` to the bottom of the slide viewport with increased item spacing and bar heights.

#### Scenario: Preserving anchored shell elements across slides
- **WHEN** the carousel transitions between slides
- **THEN** the `Main Score` card transitions exclusively with Slide 1 (remaining hidden on Slides 2–6 with its `?` methodology hover zone inactive), Slides 2–6 expand upward to `1.0 * charHeight` with taller KPI cards, spectrum bars, leaderboards, and distribution charts, and the bottom action controls (`RETURN TO MENU`, `SUBMIT RESULTS`, `CLEAR RESULTS`), bottom-right pagination pill, and side navigation arrows remain fixed and visible without flicker.

### Requirement: Carousel Pagination and Timed Auto-Advance Navigation
The carousel SHALL provide a compact bottom-right pagination and countdown pill (`[ ━━ ▪ ▪ ▪ ▪ ▪ | Xs ]`) with manual dot click navigation and automatic hover-pause behavior.

#### Scenario: Automatic timed slide progression
- **WHEN** the results overlay remains active without user interaction
- **THEN** the carousel advances through slides sequentially and displays the remaining seconds (e.g., `8s` on Slide 1, `6s` on Slides 2–6) inside the compact bottom-right pagination pill aligned with the bottom button bar.

#### Scenario: Interactive pause on mouse hover
- **WHEN** the user moves the mouse cursor over the central carousel area or the side navigation arrows
- **THEN** the auto-advance timer immediately pauses and the bottom-right indicator displays `PAUSED` in amber until the cursor leaves.

#### Scenario: Manual pagination via navigation indicators
- **WHEN** the user clicks any of the 6 dash/dot indicators in the bottom-right pagination pill
- **THEN** the carousel navigates directly to the selected slide and resets the progress timer.
