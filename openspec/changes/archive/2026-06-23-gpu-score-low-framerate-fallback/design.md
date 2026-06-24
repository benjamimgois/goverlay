## Context

On low-end graphics cards or software rasterizers (like `llvmpipe`), the Vulkan spinning cubes benchmark runs at less than 4 FPS. The engine clamps `aDeltaTime` to `0.25` seconds (4 FPS) to keep physics stable, which forces the benchmark to render exactly 40 frames over a simulated 10 seconds. This locks the GPU score at a minimum of 100 points, preventing accurate benchmarking of slower devices.

## Goals / Non-Goals

**Goals:**
- Detect if the average GPU framerate falls below 10 FPS during the first iteration.
- Automatically switch the rendering resolution from 1080p (1920x1080) to 360p (640x360) to ease GPU workload.
- Upscale the 360p viewport to the full screen during blit to preserve visual display.
- Scale the final score proportionally to estimate the equivalent 1080p score, allowing scores below 100.

**Non-Goals:**
- Recreating Vulkan graphics pipelines or render passes dynamically (too complex and prone to resource leaks).
- Modifying engine physics delta clamping limits (critical for engine stability).

## Decisions

### 1. Dynamic Viewport and Scissor States on Graphics Pipelines
- **Choice:** Enable dynamic viewport and scissor states in `fVulkanGraphicsPipeline` and `fSkyGraphicsPipeline` by calling `DynamicState.AddDynamicStates` at creation time.
- **Why:** Allows changing the viewport size at draw time without recreating the pipelines.
- **Alternatives Considered:** Recreating the pipelines when resolution drops (causes pipeline cache issues and is too heavy).

### 2. Draw-time Viewport Scaling and Blit Upscaling
- **Choice:** In `TPasCubeScreen.Draw`, if fallback is active, call `CmdSetViewport` and `CmdSetScissor` with `640x360`. In `UnitTextOverlay.pas`, update the swapchain blit call to use the dynamic render size `fRenderWidth` and `fRenderHeight` as the source width/height.
- **Why:** Vulkan's hardware blitting scales the 360p rendering up to the full swapchain size with linear filtering automatically, keeping the display fullscreen with no overhead.

### 3. Score Scaling Factor
- **Choice:** Apply a division factor of `5.0` to the average FPS and score computed during the 360p run.
- **Why:** Extrapolates 360p performance to estimated 1080p performance based on typical fill-rate scaling, allowing scores down to 20 points (e.g. 1.0 FPS at 360p = 0.2 FPS at 1080p = 5 points).

## Risks / Trade-offs

- **[Risk]** Visual blurriness due to 360p upscaling.
  - *Mitigation:* This only triggers on systems struggling to run at 10 FPS at 1080p. The user will see a slightly blurry preview, but the benchmark will successfully complete with a correct score.
