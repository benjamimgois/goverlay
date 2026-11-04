# Proposal: Enlarge Typography for Benchmark Phases, Live Sensors and Hardware Specs

## Problem
In PasCube's presentation overlay:
1. **Benchmark Phase Stepper**: The phase chips at the top during benchmark runs (`1. Warmup`, `2. CPU ST`, etc.) used a font scale of `0.7` with a cramped chip height of `30px`, making the phase indicators difficult to read at 1080p.
2. **Live Sensors Card**: The top-right telemetry panel used font scales of `0.7`–`0.85` in a tight `295x95px` box, making FPS, temperatures, and power metrics small and cramped.
3. **Hardware Comparison Specifications**: Inside the Hardware Comparison leaderboard, expanded accordion items displayed the hardware specs line (`CPU: ... | RAM: ... | GPU: ... | OS: ...`) at an extremely small font scale of `0.6` with muted grey text, and the Ray Tracing label at `0.7`.

## Proposed Solution
1. **Enlarge Phase Stepper Chips**:
   - Increase chip text font scale from `0.7` to `1.0` (+43%).
   - Expand chip pill height from `30px` to `38px`, padding to `18px`, and gap to `12px`.
   - Reposition the centered phase title `phaseStr` to `Y=72.0` with clean breathing room below the stepper.
   - Enlarge progress bar height to `24px`, progress percentage scale to `0.85`, and info text to `1.35`.
2. **Enlarge Live Sensors Panel**:
   - Expand card dimensions from `295x95px` to `360x142px`.
   - Scale `LIVE SENSORS` header to `0.95`.
   - Scale `FPS: %.1f` to `1.25` in bright white.
   - Scale temperatures (`CPU: xx C   GPU: xx C`) and power to `0.95`.
3. **Enlarge Hardware Comparison Specifications**:
   - Increase specs font scale from `0.6` to dynamic `0.80`–`0.85` with automatic width-fitting so long hardware strings never overflow.
   - Brighten specs text to crisp ice blue/white (`215, 225, 240`) for Current System and light slate (`195, 200, 215`) for reference entries.
   - Increase Ray Tracing label and score scale from `0.7` to `0.85`.
   - Adjust expanded item height from `4.9` to `5.1 * charHeight` to ensure clean margins.

## Impact
- All telemetry, phase progress, and hardware specification text become comfortably readable from distance at 1080p.
