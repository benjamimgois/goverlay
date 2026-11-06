# Spec Delta: pascube-ui-presentation

## ADDED Requirements

### Requirement: Central Viewport Multi-Slide Insights Carousel
The benchmark results overlay SHALL render an animated multi-slide carousel in the central viewport between the anchored top score header and bottom action button bar.

#### Scenario: Displaying default overview slide
- **WHEN** the benchmark results overlay (`bpResults`) opens
- **THEN** the carousel initializes on Slide 0, presenting the complete classic overview (Subscores grid, Live Telemetry, Score Trend, and Hardware Leaderboard) within the central region.

#### Scenario: Preserving anchored shell elements across slides
- **WHEN** the carousel transitions between slides
- **THEN** the top hero score header (with tier badge) and the bottom action controls (`RETURN TO MENU`, `SUBMIT RESULTS`, `CLEAR RESULTS`) remain fixed and visible without flicker.

### Requirement: Carousel Pagination and Timed Auto-Advance Navigation
The carousel SHALL provide an automated progress timer with manual pagination controls and automatic hover-pause behavior.

#### Scenario: Automatic timed slide progression
- **WHEN** the results overlay remains active without user interaction
- **THEN** the carousel advances through slides sequentially, displaying a smooth progress bar indicating time until the next slide transition.

#### Scenario: Interactive pause on mouse hover
- **WHEN** the user moves the mouse cursor over the central carousel area or the pagination controls
- **THEN** the auto-advance timer immediately pauses, keeping the active slide visible until the cursor leaves.

#### Scenario: Manual pagination via navigation indicators
- **WHEN** the user clicks any pagination dot (`● ○ ○ ○`)
- **THEN** the carousel navigates directly to the selected slide and resets the progress timer.

### Requirement: Smooth Slide Transition Animations
Transitions between carousel slides SHALL execute with cubic easing and cross-fade alpha blending to maintain fluid frame rendering.

#### Scenario: Fluid slide transition rendering
- **WHEN** the active slide changes either automatically or via user interaction
- **THEN** the departing slide fades out smoothly while the incoming slide fades in and translates horizontally into position with cubic easing (`EaseOutQuad`), maintaining target display refresh rate.
