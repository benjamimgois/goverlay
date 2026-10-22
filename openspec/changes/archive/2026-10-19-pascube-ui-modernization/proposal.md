# Proposal: PasCube UI Modernization

## Why

The PasCube benchmark interface currently uses a purely utilitarian layout with basic solid rectangular boxes and minimal contextual information, leaving users without real-time telemetry feedback, tier classifications, or a clear overview of detected hardware prior to execution. Modernizing the visual presentation elevates PasCube to contemporary gaming benchmark standards (similar to 3DMark and Cinebench 2024), providing an engaging, legible, and professional dark-themed experience with clear data hierarchy.

## What Changes

- **Modern Visual Identity & Glassmorphism Aesthetic**: Redesign interface cards with deep obsidian/dark slate backgrounds (`#161B22`), refined 1px borders, subtle opacity layering, and consistent accent colors (cyan for primary/system metrics, vibrant violet for Ray Tracing, and emerald green for positive score trends).
- **Hardware Summary Badge**: Display a persistent or initial system specs pill badge (*CPU, GPU, Vulkan API version, Preset/Resolution*) on both the main idle menu and the results screen.
- **In-Engine Live HUD & Stepper**: Transform the benchmark progress overlay to include a multi-stage phase stepper (*Warmup → CPU ST → CPU MT → GPU Raster → Ray Tracing*) and a real-time live telemetry panel showing active FPS, average FPS, CPU/GPU temperatures, and power draw (Watts).
- **Hero Score Presentation & Tier Badge**: Upgrade the results screen with a prominent Hero Total Score accompanied by a performance tier classification badge (e.g., *Enthusiast Gaming*, *Mainstream Gaming*, *Entry / Handheld*).
- **Telemetry Peak Summary**: Add a dedicated peak telemetry metrics card on the results overlay highlighting peak CPU temperature, peak GPU temperature, and peak total system power consumption recorded during the run.
- **Enhanced Score Trend & Delta Indicators**: Refine the historical score trend chart with clean bar visuals and a comparative delta badge relative to the previous benchmark run (e.g., `+4.2%`).
- **Interactive Hardware Comparison Redesign**: Modernize the hardware reference list with distinctive dual score bars (Raster + RT), prominent highlighting of the current system, and clean accordion specification views.
- **Refined Action Buttons**: Replace flat rectangular buttons with polished pill-shaped action buttons featuring distinct visual hierarchy (primary CTA for menu/submit, secondary for return, and warning accent for clearing history).

## Capabilities

### New Capabilities
- `pascube-ui-presentation`: Defines visual layout, system specs presentation, live in-engine telemetry HUD, score tier badges, and interactive results cards for the PasCube benchmark interface.

### Modified Capabilities
<!-- None: Core benchmark scoring logic, ray tracing execution pipeline, and hardware telemetry background sampling remain intact. -->

## Impact

- Affected Code:
  - `pascube_src/src/UnitPasCubeScreen.pas`: Update `DrawMenuOverlay`, `DrawBenchmarkOverlay`, `DrawResultsOverlay`, and `DrawMethodologyOverlay` rendering logic and layout geometry.
  - `pascube_src/src/UnitTextOverlay.pas`: Visual rendering routines (`AddBox`, `AddText`) and color definitions.
- APIs & Dependencies: No new external libraries or packages required; leverages existing PasVulkan SDF text rendering and immediate quad drawing.
- Binary & Build: Recompiled via `lazbuild pascube_src/pascube.lpi` and synchronized to root binary `pascube`.
