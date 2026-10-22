# Design

## Context

Frame generation in GOverlay is currently housed under the "Upscalers" navigation section in a tab sheet named "Lossless Scaling" (`lossless_scaling_tab.pas`), supporting two engines: `lsfg-vk` and `MAKO`. These methods rely on Windows PE DLLs (`Lossless.dll` / `lsfg-vk.dll`) extracted from the Steam release.

The open-source project `afmf-linux` introduces AMD Fluid Motion Frames to Linux as a Vulkan implicit layer (`libafmf-linux.so`). It operates directly on color buffers via FidelityFX Optical Flow shaders and is configured 100% via environment variables (`AFMF_ENABLE`, `AFMF_PERFORMANCE_MODE`, `AFMF_PACING`, etc.).

Upstream `afmf-linux` explicitly warns that stacking multiple frame generation layers (specifically `lsfg-vk`) or injection layers (specifically OptiScaler) results in severe conflicts, frame drops, or presentation hangs. Consolidating the tab into "Frame Interpolation" and adding AFMF as a selectable engine resolves coexistence while keeping GOverlay's architecture modular and clean.

## Goals / Non-Goals

**Goals:**
- Rename the "Lossless Scaling" tab to **"Frame Interpolation"** throughout the GOverlay interface, menus, and log outputs.
- Expand `TInterpolationMethod` to include `imAfmf` alongside `imNone`, `imLsfg`, and `imMako`.
- Add an official `method_afmf.png` banner asset in `assets/icons/` matching the visual style of `method_vkbasalt.png`, `method_lsfg.png`, and `method_mako.png` (squircle icon, white bold text, 100% active brightness, ~35% dimmed brightness when unselected).
- Dynamically display AFMF configuration cards (Performance & Search, Cadence & Pacing, Optimizations & Gamescope, Diagnostics) when AFMF is active, while hiding LSFG/MAKO specific cards (Multiplier trackbar, Adaptive Target FPS, Steam DLL browse).
- Implement a two-way conflict confirmation dialog between Frame Interpolation (AFMF) and OptiScaler / DLSS Enabler.
- Detect the `afmf-linux` Vulkan layer manifest (`afmf-linux.json`) across standard system and user implicit layer search paths.
- Update `bgmod.lpr`, `bgmod.conf`, and the PasCube preview pipeline to export `AFMF_ENABLE=1`, `DISABLE_LSFGVK=1`, and active `AFMF_*` variables.

**Non-Goals:**
- Compiling or packaging the `afmf-linux` binary directly inside GOverlay source tree. GOverlay acts as the manager and configurator for the installed layer.
- Modifying shader code or in-game rendering logic.

## Decisions

### 1. Unified "Frame Interpolation" Tab vs. Standalone AFMF Tab
- **Choice**: Rename the tab to "Frame Interpolation" and add AFMF as an engine choice in the Method card.
- **Rationale**: All three engines (LSFG, MAKO, AFMF) perform frame interpolation. Placing them in the same tab under a mutually exclusive RadioButton group prevents users from accidentally running multiple frame generation layers at the same time. It also prevents tab bloat under the "Upscalers" rail item.
- **Alternatives considered**: Adding a separate "AFMF" tab under Upscalers. Rejected because having separate tabs allows concurrent activation and increases navigation complexity.

### 2. Visual Banner Styling for AFMF (`method_afmf.png`)
- **Choice**: Create `assets/icons/method_afmf.png` matching the exact dimensions and aesthetic of `method_vkbasalt.png`, `method_lsfg.png`, and `method_mako.png`.
- **Rationale**: GOverlay's Method card relies on clickable rectangular banners integrating a squircle icon with bold typography. The helper generates a dimmed version (~35% brightness) at runtime or loads dimmed assets, creating seamless feedback when switching methods.

### 3. Dynamic Card Layout in Frame Interpolation Tab
- **Choice**: Reuse `lossless_scaling_tab.pas` (or rename helper class to `TFrameInterpolationTabHelper`) with state-driven visibility.
  - When `imAfmf`: show `FAfmfPerfCard`, `FAfmfPacingCard`, `FAfmfOptCard`, and layer status in `FLsStatusCard`. Hide Multiplier, Flow Scale, Steam DLL paths, and Spatial Scaling.
  - When `imLsfg` or `imMako`: show LSFG/MAKO controls and Steam DLL paths.
  - When `imNone`: disable all tuning controls with an informational notice.
- **Rationale**: Minimizes code duplication for scrollbox resizing, status dots, toggle switches, and theme reflow.

### 4. Mutual Exclusion Guard with OptiScaler / DLSS Enabler
- **Choice**: Implement interactive confirmation dialogs:
  - If user selects AFMF while OptiScaler or DLSS Enabler is enabled, prompt: *"OptiScaler / DLSS Enabler is currently active. AFMF is incompatible with concurrent upscaling/frame generation layers. Do you want to disable OptiScaler and activate AFMF?"* If confirmed, set OptiScaler upscaler type to None.
  - If user enables OptiScaler or DLSS Enabler while AFMF is active, prompt to switch Frame Interpolation to None.
- **Rationale**: Upstream `afmf-linux` explicitly reports that OptiScaler conflicts with AFMF presentation. Proactive UI guards prevent unexpected game crashes.

### 5. Runtime Environment and Layer Isolation in `bgmod.lpr`
- **Choice**: When `INTERPOLATION_METHOD = afmf`:
  - Export `AFMF_ENABLE=1` and configured `AFMF_*` keys.
  - Export `DISABLE_LSFGVK=1` (defense in depth against dormant implicit LSFG layers).
  - Update launch splash item to "AMD Fluid Motion Frames (AFMF)".
- **Rationale**: Follows upstream documentation instructions to ensure no other Vulkan presentation layer interferes with swapchain acquisition.

## Risks / Trade-offs

- **[Risk]** User activates AFMF on a system where `afmf-linux` is not installed.
  - *Mitigation*: The Software Status card checks for `afmf-linux.json` in system and user layer paths and displays a clear warning status dot with a guidance link.
- **[Risk]** Gamescope sessions require more swapchain images (`AFMF_EXTRA_IMAGES=5`).
  - *Mitigation*: Expose an explicit "Gamescope Mode" toggle and automatically enable `AFMF_GAMESCOPE=1` / `AFMF_EXTRA_IMAGES=5` when the game profile is set to run under Gamescope.
- **[Risk]** Backward compatibility with existing user configs.
  - *Mitigation*: Existing `INTERPOLATION_METHOD` values (`lsfg`, `mako`, `none`) remain completely functional; `afmf` is an additive option.

## Migration Plan

- No manual configuration migration needed. Existing games keep their settings intact.
- The UI tab label transitions from "Lossless Scaling" to "Frame Interpolation".
