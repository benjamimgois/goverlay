## Why

The Lossless Scaling tab currently only exposes MAKO-specific configuration on the `mako` branch, while the `main` branch holds the dedicated, streamlined controls for the classic `lsfg-vk` Vulkan layer. Users need the flexibility to choose between both interpolation engines—or quickly disable frame generation entirely—without sacrificing usability.

Furthermore, the OptiScaler tab already established a proven, clean, and intuitive visual design pattern: a top selector card (`Method`), dedicated middle controls for the active method, and a bottom `Software Status` card featuring clean status dot indicators and update actions. Replicating this exact structure in the Lossless Scaling tab creates visual and functional harmony across GOverlay.

## What Changes

- **Method Selector Card (Top Left - 50% width)**:
  - Added a "Method" card mirroring OptiScaler's upscaler method selector with 3 options:
    - `None` (uses `assets/icons/upscaler_none.png`): Disables interpolation (`GOVERLAY_LOSSLESS=0`, multiplier 1x).
    - `lsfg-vk` (uses `assets/icons/lossless_scaling.png`): Classic Vulkan layer injection using `Lossless.dll`.
    - `MAKO` (uses `assets/icons/mako_renderer.png`): Standalone Vulkan presentation engine with frame generation and spatial scaling.
  - Clickable radio buttons and logo images with dynamic opacity highlighting the active engine.
- **Target GPU Device Card (Top Right - 50% width)**:
  - Positions the Target GPU Device selection card side-by-side with the Method card, mirroring OptiScaler's `Method` + `GPU Driver` top layout.
- **Dynamic Middle Configuration Cards**:
  - `None`: Displays a clean notice informing that interpolation is disabled.
  - `lsfg-vk`: Displays the clean, dedicated controls from branch `main` (Multiplier TrackBar, Flow Scale TrackBar, Performance Mode, HDR Mode, No FP16 / Legacy toggles, and Pacing combobox). Spatial scaling card is hidden.
  - `MAKO`: Displays the complete advanced controls from branch `mako` (Fixed vs Adaptive Frame Generation mode, Target FPS, Ceiling Multiplier, Steady 2x Cap, Smooth Cadence, Live Switch, Flow Scale, Base FPS Cap, Refresh Threshold, and full Spatial Scaling card with LS1, factor, sharpness, and supersampling).
- **Software Status Card (Anchored to Bottom)**:
  - Replaces the top engine card with a bottom `Software Status` card mirroring OptiScaler's `FOsStatusCard`.
  - Displays vertical status rows with colored dot indicators (`●` green/red), component titles, and detected paths/versions:
    - Lossless Scaling (`Lossless.dll`) path and "Browse..." button.
    - MAKO Renderer (`libmako-render.so`) installed version.
    - `lsfg-vk` Vulkan layer detection status.
  - Removes the cluttering "Check Updates" button; checks for updates asynchronously in the background at startup/tab show and displays `[ ⬇ Install Update ]` only when a new version is available or when MAKO is not installed.
- **Backend & Config Serialization**:
  - Persists `INTERPOLATION_METHOD` (`none`, `lsfg`, `mako`) alongside `GOVERLAY_LOSSLESS` in `bgmod.conf`.
  - Integrates `bgmod.lpr` to export either `LSFG_CONFIG` (for `lsfg-vk`) or `ENABLE_MAKO=1` / `MAKO_CONFIG` (for `MAKO`), or no injection flags (for `none`).

## Capabilities

### Modified Capabilities
- `lossless-scaling-config`: Update configuration and launch requirements to support engine selection (`none`, `lsfg-vk`, `mako`), dynamically configuring environment variables (`LSFG_CONFIG` vs `ENABLE_MAKO=1`), toggling `GOVERLAY_LOSSLESS`, and managing the unified Software Status layout.
- `mako-engine-management`: Update update-check behavior to run headless/asynchronous checks and conditionally render the install/update action in the Software Status card rather than requiring an explicit manual check button.

## Impact

- Affected files:
  - `lossless_scaling_tab.pas`: Restructure UI cards, reflow layout, method switching logic, and status card.
  - `bgmod.lpr`: Dispatch environment variables based on `INTERPOLATION_METHOD` (`none`, `lsfg`, `mako`).
  - `overlayunit.pas`: Method change event handlers and background update check triggers.
  - `tests/gui/gui_test_cases.pas` & `tests/logic/logic_test_cases.pas`: Validate method switching and config generation.
