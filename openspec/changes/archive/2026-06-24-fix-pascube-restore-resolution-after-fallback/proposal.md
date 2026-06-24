## Why

When the GPU benchmark runs on slow GPUs (primarily aarch64 / Mali, but also low-end AMD iGPUs), the 360p fallback reduces `fRenderWidth`/`fRenderHeight` to maintain testable framerates. However, after the GPU phase completes and transitions to `bpResults`, the render resolution remains at 640x360. The results screen viewport is too small to read, making scores unusable.

## What Changes

- Restore `fRenderWidth := 1920` and `fRenderHeight := 1080` when transitioning from the GPU phase to results, if the 360p fallback was active.
- The swapchain/viewport picks up the new values on the next frame automatically (viewport/scissor reads `fRenderWidth`/`fRenderHeight` at draw time).

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `pascube-benchmark-compatibility`: Add requirement that internal render resolution MUST be restored to 1080p after GPU benchmark fallback before showing results screen.

## Impact

- `pascube_src/src/UnitPasCubeScreen.pas`: Modify `NextPhase` procedure, `bpGPU_1080p` case (line ~2229) — add `fRenderWidth`/`fRenderHeight` restoration before setting `fBenchmarkPhase := bpResults`.
