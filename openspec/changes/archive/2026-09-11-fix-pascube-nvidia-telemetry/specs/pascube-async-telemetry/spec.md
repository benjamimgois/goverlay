## Purpose

Provides asynchronous hardware telemetry collection for CPU and GPU metrics (peak temperature and power draw) during PasCube benchmark execution without degrading rendering performance.

## ADDED Requirements

### Requirement: Asynchronous Telemetry Collection
The PasCube benchmark system SHALL sample CPU temperature, CPU power, GPU temperature, and GPU power using a dedicated background thread without executing synchronous command-line processes inside the rendering loop.

#### Scenario: Background sampling during benchmark
- **WHEN** any benchmark phase (Warmup, CPU Single-Thread, CPU Multi-Thread, GPU Stress) is actively executing
- **THEN** hardware telemetry is sampled in a background thread periodically and peak metrics are recorded without reducing the graphics render loop frame rate

### Requirement: Unified NVIDIA Telemetry Query
On systems with an NVIDIA graphics card where hardware monitor files are unavailable, the telemetry system SHALL query temperature and power consumption in a single command execution rather than multiple sequential invocations.

#### Scenario: NVIDIA telemetry sampling
- **WHEN** the background telemetry thread queries an NVIDIA GPU
- **THEN** it executes `nvidia-smi` once requesting both `temperature.gpu` and `power.draw` simultaneously and parses both values from the output

### Requirement: Decoupled Render Loop
The rendering procedure (`TPasCubeScreen.Draw`) SHALL NOT execute any external processes or synchronous file I/O for telemetry on any frame.

#### Scenario: Frame rendering during stress test
- **WHEN** the GPU stress test is rendering frames at high frame rates on an NVIDIA or AMD GPU
- **THEN** frame presentation proceeds uninterrupted by external process execution, maintaining native GPU performance
