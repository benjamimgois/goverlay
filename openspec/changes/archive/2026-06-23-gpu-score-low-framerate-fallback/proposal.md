## Why

On systems with low-end GPUs or when falling back to CPU software rendering (e.g., Mesa `llvmpipe`), the PasCube GPU benchmark phase can run at less than 4 FPS. Because the PasVulkan engine clamps the maximum frame delta time to `0.25` seconds (4 FPS) for physics stability, the benchmark gets stuck in a loop requiring exactly 40 frames to reach its 10-second target, resulting in a locked minimum GPU score of exactly 100 points. This obscures performance differences on lower-end devices.

## What Changes

- Implement dynamic resolution fallback: during the GPU benchmark phase, if the average framerate drops below 10 FPS, restart the GPU phase at a lower resolution (360p).
- Adjust the resulting 360p GPU score proportionally to estimate the corresponding 1080p score, allowing scores below 100 without hitting the engine's 4 FPS delta clamping threshold.

## Capabilities

### New Capabilities

### Modified Capabilities

- `pascube-benchmark-compatibility`: Add requirements for dynamic resolution fallback when GPU performance is below 10 FPS, including score scaling/estimation for 360p runs.

## Impact

- Affected files: `pascube_src/src/UnitPasCubeScreen.pas` (GPU benchmark update loop, resolution switching, and score calculation).
