# Proposal

## Why

Bleeding-edge DirectX 12 and Ray Tracing games (such as *Control Resonant*) frequently require experimental Wine/Proton/VKD3D environment variables (`VKD3D_CONFIG=descriptor_heap`, `NGX_DLSS_RR_OVERRIDE=on`, `VKD3D_RTAS_SIZE_MULT=8`) to prevent crashes or unlock features. However, placing experimental or unstable workarounds alongside standard stable settings can cause general users to encounter instability or visual glitches.

Adding a dedicated "Experimental" card with prominent warning indicators separates cutting-edge workarounds from standard tweaks, while providing instant access to critical fixes for newly released games.

## What Changes

- Add a 5th predefined category card: **Experimental** (`TWEAK_CAT_EXPERIMENTAL`) with an amber header and a top warning banner explaining its potential instability.
- Add bundled toggle for **Descriptor Heap**: `VKD3D_CONFIG=descriptor_heap` and `PROTON_VKD3D_HEAP=1` (fixes RT Indirect Lighting in *Control Resonant* and other DX12 RT games).
- Add toggle for **Ray Reconstruction**: `NGX_DLSS_RR_OVERRIDE=on` with green `[NVIDIA]` badge chip.
- Add toggle for **RT Acceleration Structures Multiplier**: `VKD3D_RTAS_SIZE_MULT=8` to resolve RT memory allocation crashes.
- Move experimental tweaks from **Graphics** to **Experimental**:
  - `MESA_LOADER_DRIVER_OVERRIDE=zink` (OpenGL over Vulkan / Zink)
  - `#winedetectionenable=false` (RE Engine Ray Tracing workaround)
- Add explanatory tooltips to each experimental toggle emphasizing experimental nature.
- Register all new variables in `IsPredefinedEnvVar` to avoid leaking into the Custom Variables list.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `envvars-tab-card-redesign`: Adds the `Experimental` category card with warning banner, moves experimental tweaks from Graphics, and introduces descriptor heap, ray reconstruction, and RTAS multiplier variables.

## Impact

- `tweaks_md3.pas`: Category definitions (`TWEAK_CAT_EXPERIMENTAL = 4`), card drawing loop (5 predefined cards), warning banner layout, `TWEAK_ROWS` table, and `IsPredefinedEnvVar` checks.
- `overlayunit.pas`: Internal checkbox references for the new experimental toggles.
- `tests/gui/gui_test_cases.pas`: GUI tests validating the Experimental card, banner rendering, toggle persistence, and absence of custom variable leaks.
