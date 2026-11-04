## MODIFIED Requirements

### Requirement: Redesigned Hardware Comparison Leaderboard
The hardware comparison leaderboard SHALL present calibrated reference systems with distinct dual score progress bars for rasterized and ray tracing performance, visually highlighting the current user system entry and rendering hardware specifications with clear, enlarged typography.

#### Scenario: Current system prominence
- **WHEN** the hardware comparison list renders all entries
- **THEN** the user's current system entry is highlighted with a luminous primary border and background tint, with its specification accordion persistently expanded.

#### Scenario: Expanding reference system specifications
- **WHEN** the user hovers or clicks on an alternative reference system item
- **THEN** the selected item animates or expands to display its secondary Ray Tracing score bar and hardware specifications line formatted at an enlarged legible scale (at least 0.80) with high contrast.

### Requirement: Multi-Phase Benchmark Stepper and Live Telemetry HUD
The benchmark execution overlay SHALL present a visual phase stepper indicating the active phase within the execution sequence alongside a real-time live telemetry panel displaying instantaneous and average frame rates, hardware temperatures, and power consumption with enlarged, prominent typography.

#### Scenario: Phase progression display
- **WHEN** the benchmark transitions between execution phases (Warmup, CPU Single-Thread, CPU Multi-Thread, GPU Raster, Ray Tracing)
- **THEN** the phase stepper marks previously completed phases as done, highlights the currently running phase, and displays pending phases as inactive, rendered in enlarged phase chips (scale 1.0).

#### Scenario: Live sensor metric updates
- **WHEN** the GPU or CPU stress phases are executing
- **THEN** the live telemetry panel displays real-time frame rate, average FPS, current CPU temperature, current GPU temperature, and active wattage sampled by the telemetry subsystem, presented in an enlarged card with prominent text scales of 0.95 to 1.25.
