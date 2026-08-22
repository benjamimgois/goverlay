## Context

When GOverlay launches the 3D preview (`pascube`) while Lossless Scaling (LSFG-VK) is active, `lsfg-vk` hooks the Vulkan swapchain presentation pipeline and produces interpolated frames.
Because Vulkan layer injection occurs at `vkCreateInstance` time during process initialization, the layer cannot be unloaded mid-execution without restarting the process.
Therefore, running the benchmark inside an active LSFG instance would produce corrupt GPU framerate metrics.

## Goals / Non-Goals

**Goals:**
- Detect Lossless Scaling in PasCube via command line argument `--lossless-scaling` (or `--lsfg-active`) and fallback environment detection (`LSFG_CONFIG`, `ENABLE_LSFGVK`).
- Disable the "Start benchmark" button in the PasCube main menu when Lossless Scaling is detected, rendering it dimmed and non-responsive.
- Display a clear warning banner beneath the title informing the user that benchmarks are disabled due to Lossless Scaling.
- Protect benchmark starting (`StartBenchmark`), result saving, and online submission against running under frame generation.
- Keep the 3D cube preview and previous benchmark results history fully functional and viewable.

**Non-Goals:**
- Completely blocking PasCube from running when Lossless Scaling is on (users want to see the 3D preview with frame generation).
- Dynamically restarting PasCube without Vulkan layers when benchmark is requested (this would be jarring and complex).

## Decisions

### 1. Dual-Layer Detection (CLI flag + Environment variables)
- **Decision**: Check `fLosslessScalingActive` during `TPasCubeApplication` startup:
  1. CLI parameter `--lossless-scaling` or `--lsfg-active`.
  2. Fallback check: `GetEnvironmentVariable('LSFG_CONFIG') <> ''` or `GetEnvironmentVariable('ENABLE_LSFGVK') = '1'`.
- **Rationale**: Passing `--lossless-scaling` from GOverlay makes intent explicit, while checking `LSFG_CONFIG` ensures PasCube is protected even when launched from terminal or custom scripts.

### 2. UI Disabling with Informative Message
- **Decision**: In `UnitPasCubeScreen.pas`:
  - When `fLosslessScalingActive = True`:
    - Set `IsStartButtonHovered` to always return `False`.
    - Render the "Start benchmark" button with dimmed background (`bgR := 18/255; bgG := 20/255; bgB := 28/255; textR := 100/255; textG := 105/255; textB := 120/255`).
    - Render an amber warning banner: `[!] Benchmark disabled: Lossless Scaling is active. Disable it in GOverlay to run benchmarks.`
    - In `StartBenchmark`, add an early return guard as defense-in-depth.
- **Rationale**: Immediate visual feedback prevents user confusion as to why the button is unresponsive.

### 3. GOverlay Command Synthesis
- **Decision**: In `overlayunit.pas` (`PreviewBtnClick`, `runpascubetItemClick`):
  - Append `GetPasCubeLosslessParam` (e.g. `' --lossless-scaling'`) whenever `GetLosslessScalingLaunchEnv <> ''`.

## Risks / Trade-offs

- **[Risk]** User wants to benchmark specifically to test LSFG performance multiplier.
  - **Mitigation**: LSFG performance testing should be done in real games with MangoHud overlay, not in standardized hardware benchmarking suites whose leaderboards require raw non-interpolated GPU rendering.
- **[Risk]** Warning banner clipping on small window resolutions.
  - **Mitigation**: Position the warning banner below the title using standard font scaling (`1.2` - `1.4` text scale) and centered text alignment (`toaCenter`).
