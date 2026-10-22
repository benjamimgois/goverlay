## Context

The Lossless Scaling tab currently diverges between branch `main` (which implements a clean configuration for the classic `lsfg-vk` Vulkan layer) and branch `mako` (which implements standalone presentation engine features including Adaptive FG and Spatial Scaling). The OptiScaler tab in GOverlay (`optiscaler_tab.pas`) has already solved a similar architectural problem by providing a 50/50 split header (Method and GPU Driver), dynamic options cards in the center, and an anchored Software Status card at the bottom with colored status dots and version detection.

## Goals / Non-Goals

**Goals:**
- Unify both engines into a single, cohesive Lossless Scaling tab by implementing the OptiScaler layout pattern.
- Provide a top Method card (50% width) with `None`, `lsfg-vk`, and `MAKO` options, alongside a Target GPU Device card (50% width).
- Dynamically adapt the middle configuration controls:
  - `None`: frame generation disabled notice (`GOVERLAY_LOSSLESS=0`).
  - `lsfg-vk`: clean main-branch controls (multiplier, flow scale, toggles, pacing).
  - `MAKO`: rich mako-branch controls (Fixed/Adaptive FG, target FPS, ceiling multiplier, live toggles, spatial scaling).
- Replicate the OptiScaler `Software Status` card at the bottom with status dots for `Lossless.dll`, `libmako-render.so`, and `lsfg-vk` layer, vertically stacked.
- Provide headless background update checking for MAKO, showing `[ ⬇ Install Update ]` only when an update is detected or MAKO is missing.
- Persist `INTERPOLATION_METHOD` and `GOVERLAY_LOSSLESS` in `bgmod.conf`, and dispatch the correct environment in `bgmod.lpr`.

**Non-Goals:**
- Adding spatial scaling to `lsfg-vk` (it remains exclusive to MAKO).
- Modifying other tabs (OptiScaler, MangoHud, vkBasalt, etc.).

## Decisions

1. **Top Row Layout (Option A)**:
   - Left 50%: `FLsMethodCard` with 3 columns:
     - `None` (`upscaler_none.png`) -> `GOVERLAY_LOSSLESS=0`, 1x multiplier.
     - `lsfg-vk` (`lossless_scaling.png`) -> `GOVERLAY_LOSSLESS=1`, `INTERPOLATION_METHOD=lsfg`.
     - `MAKO` (`mako_renderer.png`) -> `GOVERLAY_LOSSLESS=1`, `INTERPOLATION_METHOD=mako`.
   - Right 50%: `FLsGpuCard` ("Target GPU Device") with the GPU dropdown and device details.
   - *Rationale*: Replicates the proven ergonomics of OptiScaler's Method + GPU Driver row.

2. **Method Selection UX**:
   - Both the radio button and the logo image are clickable.
   - Active method image is 100% opaque; inactive method images are dimmed (`Enabled := False`), directly using LCL/Qt widget states identical to `UpdateUpscalerImageOpacity`.

3. **Dynamic Reflow in `ReflowLosslessScalingTab`**:
   - When `Method = None`: Center cards are collapsed/hidden or replaced by a clean disabled placeholder banner.
   - When `Method = lsfg`: The `FLsFrameGenCard` reflows to show main-branch controls; `FLsSpatialCard` is set to `Visible := False`.
   - When `Method = mako`: Both `FLsFrameGenCard` (with Adaptive FG support) and `FLsSpatialCard` are rendered and reflowed.
   - `FLsStatusCard` is anchored at the bottom with dynamic `CardTop` calculation.

4. **Software Status Card Visual Language**:
   - Replicates `FOsStatusCard`:
     - Three vertical rows with colored dot shapes (`stEllipse`):
       1. `Lossless Scaling (DLL)`: Green if `Lossless.dll` exists, Red if missing. Displays file path + `Browse...` button.
       2. `MAKO Renderer`: Green if `libmako-render.so` installed, Red if missing. Displays installed version.
       3. `lsfg-vk Vulkan Layer`: Green if layer manifest detected, Red/Gray if missing. Displays layer path/status.
     - Header area contains `[ ⬇ Install Update ]` BitBtn with download glyph, shown only when an update is available or MAKO is missing.
     - Progress bar and status label shown during installation/updates.

5. **Config & Environment Dispatch**:
   - `bgmod.conf` stores `INTERPOLATION_METHOD=none|lsfg|mako` and `GOVERLAY_LOSSLESS=0|1`.
   - In `bgmod.lpr`:
     - `none`: skips frame generation layer injection.
     - `lsfg`: exports `LSFG_CONFIG=".../lsfg.toml"` and does not export `ENABLE_MAKO`.
     - `mako`: exports `ENABLE_MAKO=1`, `MAKO_CONFIG=".../conf.toml"`, `DISABLE_LSFG=1`, etc.

## Risks / Trade-offs

- **[Risk] Widget cluttering during dynamic switching** → *Mitigation*: Group controls into distinct sub-panels or dynamically show/hide controls with a unified `ReflowLosslessScalingTab` procedure that recalculates bounding boxes cleanly.
- **[Risk] User confusion between lsfg.toml and conf.toml** → *Mitigation*: When MAKO is active, `WriteMakoTomlConfig` generates both `conf.toml` and a mirror `lsfg.toml`. When lsfg-vk is active, it generates `lsfg.toml` v1.
- **[Risk] GitHub API rate limit during background update check** → *Mitigation*: Update check runs in a lightweight background thread; if rate-limited or offline, gracefully defaults to installed version and keeps UI responsive.
