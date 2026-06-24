## Context

When benchmarking on slow GPUs (aarch64 Mali, low-end AMD iGPUs), PasCube reduces internal render resolution from 1080p to 360p via the `fRenderWidth`/`fRenderHeight` fields (line 2138-2139 in `UnitPasCubeScreen.pas`). The swapchain viewport/scissor reads these fields at draw time (lines 1726-1734). After the GPU phase finishes, `NextPhase` transitions from `bpGPU_1080p` to `bpResults` (line 2229-2234), but the resolution fields remain at 360p. The results screen renders in a 640x360 viewport, making text and cards unreadable.

## Goals / Non-Goals

**Goals:**
- Restore `fRenderWidth`/`fRenderHeight` to 1920x1080 before results screen draws
- Minimal change — no new fields, no swapchain signals, no callback hooks

**Non-Goals:**
- Changing the fallback trigger threshold (FPS < 10)
- Adding a "restore" function or state machine for resolution tracking
- Modifying the score downscaling logic (already correct at line 2274)

## Decisions

### 1. Restore resolution in NextPhase bpGPU_1080p case

- **Choice**: Add `fRenderWidth := 1920; fRenderHeight := 1080;` inside the `bpGPU_1080p` case, before `fBenchmarkPhase := bpResults`.
- **Rationale**: This is the natural transition point — the GPU phase just ended and we're about to enter results. The viewport/scissor values are read every frame, so changing these fields before the next draw call is sufficient.
- **Alternative considered**: Adding restore logic in `CalculateScore` or `FinishBenchmark`. Rejected — those functions are for computing/saving scores, not for managing render state. Resolution restore belongs with phase transition logic.

### 2. Guard with fGPU360pFallback flag only

- **Choice**: Only restore if `fGPU360pFallback` is true. Normal runs (1080p, no fallback) skip the unnecessary assignment.
- **Rationale**: Avoids redundant writes when resolution is already correct. Same flag already used for score downscaling.

## Risks / Trade-offs

- **[Risk]** If the results screen uses a different viewport path that ignores `fRenderWidth`/`fRenderHeight` → resolution stays wrong.
  - **Mitigation**: Verified — results screen uses the same `Viewport.width := fRenderWidth` at line 1726. No separate viewport path.
