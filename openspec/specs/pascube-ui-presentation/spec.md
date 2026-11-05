# pascube-ui-presentation Specification

## Purpose
Defines visual layout, system specs presentation, live in-engine telemetry HUD, score tier badges, and interactive results cards for the PasCube benchmark interface.

## Requirements

### Requirement: System Specifications Summary Pill
The benchmark interface SHALL render a system specifications summary badge exclusively on the results overlay, omitting it from the idle menu to provide visual clearance for the 3D scene and floor reflections.

#### Scenario: Display on idle menu
- **WHEN** PasCube enters the idle menu state (`bpIdleMenu`)
- **THEN** the interface omits the specifications summary pill from the bottom viewport to maximize visual clearance for 3D reflections.

#### Scenario: Display on results overlay
- **WHEN** PasCube renders the final results screen (`bpResults`)
- **THEN** the specifications summary badge is rendered at the top of the interface providing hardware context for the recorded scores.

### Requirement: Multi-Phase Benchmark Stepper and Live Telemetry HUD
The benchmark execution overlay SHALL present a visual phase stepper indicating the active phase within the execution sequence alongside a real-time live telemetry panel displaying instantaneous and average frame rates, hardware temperatures, and power consumption with enlarged, prominent typography.

#### Scenario: Phase progression display
- **WHEN** the benchmark transitions between execution phases (Warmup, CPU Single-Thread, CPU Multi-Thread, GPU Raster, Ray Tracing)
- **THEN** the phase stepper marks previously completed phases as done, highlights the currently running phase, and displays pending phases as inactive, rendered in enlarged phase chips (scale 1.0).

#### Scenario: Live sensor metric updates
- **WHEN** the GPU or CPU stress phases are executing
- **THEN** the live telemetry panel displays real-time frame rate, average FPS, current CPU temperature, current GPU temperature, and active wattage sampled by the telemetry subsystem, presented in an enlarged card with prominent text scales of 0.95 to 1.25.

### Requirement: Performance Tier Classification and Hero Score Presentation
The results overlay SHALL present the total system score in a prominent hero card accompanied by a performance tier classification badge determined by predefined score thresholds.

#### Scenario: Enthusiast gaming tier badge
- **WHEN** the benchmark completes with a total score exceeding 4,000 points
- **THEN** the hero score card displays the score accompanied by an "Enthusiast Gaming" luminous badge.

#### Scenario: Mainstream gaming tier badge
- **WHEN** the benchmark completes with a total score between 2,200 and 4,000 points
- **THEN** the hero score card displays the score accompanied by a "Mainstream Gaming" badge.

#### Scenario: Handheld and entry tier badge
- **WHEN** the benchmark completes with a total score below 2,200 points
- **THEN** the hero score card displays the score accompanied by an "Entry / Handheld" badge.

### Requirement: Peak Hardware Telemetry Summary Card
The results overlay SHALL display a dedicated peak hardware telemetry card presenting peak CPU temperature, peak GPU temperature, and peak total system power consumption recorded during the benchmark.

#### Scenario: Displaying peak temperature and wattage values
- **WHEN** the benchmark concludes and telemetry data was successfully sampled
- **THEN** the results overlay renders a telemetry summary card indicating the maximum CPU temperature, maximum GPU temperature, and peak power draw recorded during the benchmark run.

#### Scenario: Fallback when hardware sensor telemetry is unavailable
- **WHEN** sensor access permissions or hardware monitor files are unavailable
- **THEN** the telemetry card displays graceful "N/A" indicators without breaking or misaligning other result cards.

### Requirement: Comparative Score Trend and Delta Indicator
The historical score trend visualization SHALL display test execution bars alongside a comparative delta percentage relative to the immediately preceding benchmark run when history exists.

#### Scenario: Score improvement delta display
- **WHEN** two or more benchmark runs exist in history and the latest score differs from the previous run
- **THEN** the score trend card renders a delta percentage pill indicating performance change (e.g. "+4.2%").

#### Scenario: Single-run baseline presentation
- **WHEN** only one benchmark run exists in history
- **THEN** the score trend card displays the initial run as the baseline without a delta comparison badge.

### Requirement: Redesigned Hardware Comparison Leaderboard
The hardware comparison leaderboard SHALL present calibrated reference systems with distinct dual score progress bars for rasterized and ray tracing performance, visually highlighting the current user system entry and rendering hardware specifications with clear, enlarged typography.

#### Scenario: Current system prominence
- **WHEN** the hardware comparison list renders all entries
- **THEN** the user's current system entry is highlighted with a luminous primary border and background tint, with its specification accordion persistently expanded.

#### Scenario: Expanding reference system specifications
- **WHEN** the user hovers or clicks on an alternative reference system item
- **THEN** the selected item animates or expands to display its secondary Ray Tracing score bar and hardware specifications line formatted at an enlarged legible scale (at least 0.80) with high contrast.

### Requirement: Glossy Studio Floor Reflection
The PasCube environment renderer SHALL render an attenuated glossy reflection of the floating cube and its glowing features onto the perspective floor plane during idle showcase presentation.

#### Scenario: Display glossy reflection underneath floating cube
- **WHEN** PasCube renders the studio background environment
- **THEN** the floor below the horizon displays an anisotropic, vertically softened reflection of the cube's specular highlight and neon cyber edges centered with the cube's rotation.

#### Scenario: Deep obsidian studio contrast
- **WHEN** PasCube displays the Cyber Dark Studio environment
- **THEN** background colors are calibrated for Vulkan sRGB swapchain encoding to present true obsidian dark backdrop with a focused backlight halo and corner vignette.

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
